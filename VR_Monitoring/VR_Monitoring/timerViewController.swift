//
//  timerViewController.swift
//  VR_Monitoring
//
//  Created by Sarada Symonds on 12/9/15.
//  Copyright (c) 2015 NU Enabling Engineering. All rights reserved.
//

import UIKit
import Firebase
import CoreBluetooth
import ResearchKit

class timerViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var userName = String()
    var exerciseTitle = String()
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    var running = false;
    var score = 0;
    var totalscore = 0;
    var numberofdata = 0;
    var temp1 = 0;
    var temp2 = 0;
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var exerciseTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exerciseTitleLabel.text = exerciseTitle
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg2.png")!)
        // Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil)
        // Do any additional setup after loading the view.
    }

    @IBAction func startButton(sender: UIButton) {
        launchBool = !launchBool
    }
    var launchBool: Bool = false {
        didSet {
            if launchBool == true {
                startButton.setTitle("Stop", forState: .Normal)
                let aSelector : Selector = "updateTime"
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
                startTime = NSDate.timeIntervalSinceReferenceDate()
            } else {
                timer.invalidate()
           /*
                var currentTime = timeLabel.text!
                var ref = Firebase(url: "https://amber-inferno-7571.firebaseio.com/")
                
                
                /**
                 * Note: the occurance, exercise, and user are all within a list. So we need to add a specific instance
                 * i.e. occurance0, exercise0 and user0. 
                 * This will have to be improved later on to find the correct item in the list to append to OR to add a new user.
                 * Decision Tree:
                    Is it a new user?
                        -Yes
                            Append a new user
                        -No
                            Find the current user
                            Is it a new exercise?
                                -Yes
                                    Append a new exercise
                                -No
                                    Find the current exercise and append this occurance.
                 */
           /*   var name = "riverraft"
                var occurance = ["dataset":"100", "date":"26/3", "duration":"1", "feedback":"great"]
                var occurance0 = [occurance]
                var exercise = ["name":name, "occurance":occurance0]
                var exercise0 = [exercise]
                var id = "ben"
                var nameuser = "Ben";
                var user = ["name":nameuser, "exercise":exercise0, "id":id];
                var user2 = ["user":user];
                var usersRef = ref.childByAppendingPath("userlist")
                usersRef.updateChildValues(user2)
             */
                
                
                
                /*
                 * By auto id on all list items
                 */
                var usersRef = ref.childByAppendingPath("userlist")
                var nameuser = "Ben";
                var id = "ben"
                var user = ["name":nameuser, "id":id];
                var userLocation = usersRef.childByAutoId()
                userLocation.setValue(user)
              //  var occurance = ["dataset":"100", "date":"26/3", "duration":"1", "feedback":"great"]
               // var occurance0 = [occurance]
                var exercise = ["name":"RiverRaft"]
                
                
              //  var husky = ["user_name": "Husky", "time": currentTime]
                
              //  var usersRef = ref.childByAppendingPath("users")
                
              //  var users = ["husky": husky]
             //   usersRef.setValue(users)
*/
                startButton.setTitle("Start", forState: .Normal)
                print("THE USER SCORE IS ")
                print(totalscore) //this is the FINAL SCORE of HOW THE USER PERFORM IN THE EXERCISE!!!
                //SEND THIS TO THE DATABASE AND DONE!!!!!
                let taskViewController = ORKTaskViewController(task: SurveyTask, taskRunUUID: nil)
                taskViewController.delegate = self
                presentViewController(taskViewController, animated: true, completion: nil)

            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var startTime = NSTimeInterval()
    
    var timer:NSTimer = NSTimer()
    
    
    
    func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        timeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }

    // BLE
    var centralManager : CBCentralManager!
    var peripheralDevice : CBPeripheral!
    var buffer = ""
    var uartService:CBService?
    
    
    
    // Check BLE status for centralManager
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        if central.state == CBCentralManagerState.PoweredOn{
            
            central.scanForPeripheralsWithServices(nil, options: nil)
            self.statusLabel?.text = "Searching for BLE Devices"
            
        }else if central.state == CBCentralManagerState.PoweredOff{
            
            self.statusLabel?.text = "Turn on bluetooth"
            
        }else{
            
            print("Bluetooth switched off or not initialized", terminator: "")
            
        }
    }
    
    // Check out the discovered peripherals to find the deviced you want to connect
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        let deviceName = "WHAM"
        let nameOfDeviceFound = peripheral.name
        
        
        print("Found devices--------------------------", terminator: "")
        print(peripheral, terminator: "")
        print("Name Of Device Found ------------------", terminator: "")
        print(nameOfDeviceFound, terminator: "")
        print("---------------------------------------", terminator: "")
        print("---------------------------------------", terminator: "")
        print("---------------------------------------", terminator: "")
        
        if(deviceName == nameOfDeviceFound){
            
            // Update status label
            self.statusLabel?.text = "Device Found"
            // Stop scanning
            self.centralManager.stopScan()
            // Set the peripheral to use and establish connection
            self.peripheralDevice = peripheral
            self.peripheralDevice.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)
            
        }else{
            sleep(1)
            self.statusLabel?.text = "Sensor Tag Not Found"
        }
        
    }
    //Connected to Central
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Peripheral connected.", terminator: "")
        print(peripheral, terminator: "")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    //Discover Service
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if error != nil {
            print("Error discovering services \(error?.localizedDescription)", terminator: "")
            return
        }
        let services = peripheral.services as [CBService]!
        for service in services {
                  //  if (service.characteristics != nil){
               // peripheral.discoverCharacteristics(nil, forService: service)
           // }
            if (service.UUID == CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")){ //uart
                print("found", terminator: "")
                uartService = service
                peripheral.discoverCharacteristics([CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e"), CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")], forService: uartService!)
            }
            //        for service: CBService in peripheral.services! {
            //            peripheral.discoverCharacteristics(nil, forService: service)
            //        }
            
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        if error != nil {
            print("Error discovering characteristics \(error?.localizedDescription)", terminator: "")
            return
        }
        else {
            let characteristics = service.characteristics as [CBCharacteristic]!
            for characteristic in characteristics {
                print(characteristic.UUID, terminator: "")
                switch characteristic.UUID{
                case CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e"):
                    
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    print("Found TX", terminator: "")
                    break
                case CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e"):
                    print("sip", terminator: "")
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    
                    print("gee", terminator: "")
                    break
            //    case "2A37":
                    // Set notification on heart rate measurement
             //       print("Found a Heart Rate Measurement Characteristic", terminator: "")
               //     peripheral.setNotifyValue(true, forCharacteristic: characteristic)
               //     break
             //   case "2A38":
                    // Read body sensor location
                //    print("Found a Body Sensor Location Characteristic", terminator: "")
               //     peripheral.readValueForCharacteristic(characteristic)
                //    break
                    //                var rawArray:[UInt8] = [0x01];
                    //                let data = NSData(bytes: &rawArray, length: rawArray.count)
                    //                peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
                    
                default:
                    print("nope", terminator: "")
                    break
                    
                    
                    // for some devices, you can skip readValue() and print the value here
                    //            }
                }
            }
        }
    }
    
    
    
    //update heart rate value
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            //            handleError("Error updating value for characteristic\(characteristic.description.utf8) \(error.description.utf8)")
            print("got it", terminator: "")
            return
        }
        else{
            //print("fail")
        }
       // print("here", terminator: "")
        switch characteristic.UUID{
            //    case "2A37":
            //      update(heartRateData:characteristic.value!)
            //    break
        case CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e"):
           // print("got this far", terminator: "")
            //   print(characteristic.value!)
            didReceiveData(characteristic.value!)
            break
        default:
            break
        }
    }
    
    //receive data
    func didReceiveData(newData: NSData) {
        
        //Data incoming from UART peripheral, forward to current view controller
        
        receiveData(newData)
        
        
    }
    
    func receiveData(newData : NSData){
        
        
        
        // Update UI
        updateConsoleWithIncomingData(newData)
        
        
    }
    
    func updateConsoleWithIncomingData(newData:NSData) {
        
        //Write new received data to the console text view
        
        //convert data to string & replace characters we can't display
        let dataLength:Int = newData.length
        var data = [UInt8](count: dataLength, repeatedValue: 0)
        
        newData.getBytes(&data, length: dataLength)
        
        for index in 0...dataLength-1 {
            if (data[index] <= 0x1f) || (data[index] >= 0x80) { //null characters
                if (data[index] != 0x9)       //0x9 == TAB
                    && (data[index] != 0xa)   //0xA == NL
                    && (data[index] != 0xd) { //0xD == CR
                        data[index] = 0xA9
                }
                
            }
        }
        
        
        let newString = NSString(bytes: &data, length: dataLength, encoding: NSUTF8StringEncoding)
        //  printLog(self, funcName: "updateConsoleWithIncomingData", logString: newString! as String)
       // print(newString as! String, terminator: "")
        let sensor = newString!.componentsSeparatedByString(",")
        // print(sensor[0])
        
        
        if (launchBool == true){
            //assuming sensor[0] contains the score! not sure if it's correct though
            if (sensor[0] != ""){
                numberofdata = numberofdata + 1 //increment to get number of data
                score = Int(sensor[0])! + temp1;  //Get the Sum of all values
                temp1 = score
                totalscore = score/numberofdata //Take the average
              //  print(numberofdata)
                temp2 = totalscore  //this is just average of all the data values we get
                print(sensor[0])
            }
        }
        else {//RESET EVERYTHING BACK TO 0!!!!!!
            numberofdata = 0;
            //print("reset")
            //print(numberofdata)
            score = 0;
            totalscore = 0;
            temp1 = 0;
            temp2 = 0;
        }
        totalscore = temp2 //just to be safe, assign it one last time

        //Check for notification command & send if needed
        //            if newString?.containsString(self.notificationCommandString) == true {
        //                printLog(self, "Checking for notification", "does contain match")
        //                let msgString = newString!.stringByReplacingOccurrencesOfString(self.notificationCommandString, withString: "")
        //                self.sendNotification(msgString)
        //            }
        
    }
    
    ///////UPDATE HEART RATE
    func update(heartRateData:NSData){
        
        var buffer = [UInt8](count: heartRateData.length, repeatedValue: 0x00)
        heartRateData.getBytes(&buffer, length: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2){
            if (buffer[0] & 0x01 == 0){
                bpm = UInt16(buffer[1]);
            }else {
                bpm = UInt16(buffer[1]) << 8
                bpm =  bpm! | UInt16(buffer[2])
            }
        }
        
        if let actualBpm = bpm{
            print(actualBpm, terminator: "")
        }else {
            print(bpm, terminator: "")
        }
        
    }

    
}

extension timerViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        //Handle results with taskViewController.result
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
