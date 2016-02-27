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
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var exerciseTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exerciseTitleLabel.text = exerciseTitle
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
                var currentTime = timeLabel.text!
                var ref = Firebase(url: "https://amber-inferno-7571.firebaseio.com/")
                var husky = ["user_name": "Husky", "time": currentTime]
                
                var usersRef = ref.childByAppendingPath("users")
                
                var users = ["husky": husky]
                usersRef.setValue(users)
                startButton.setTitle("Start", forState: .Normal)
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
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
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
            
            print("Bluetooth switched off or not initialized")
            
        }
    }
    
    // Check out the discovered peripherals to find the deviced you want to connect
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        let deviceName = "VRM"
        let nameOfDeviceFound = peripheral.name
        
        
        print("Found devices--------------------------")
        print(peripheral)
        print("Name Of Device Found ------------------")
        print(nameOfDeviceFound)
        print("---------------------------------------")
        print("---------------------------------------")
        print("---------------------------------------")
        
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
        print("Peripheral connected.")
        print(peripheral)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    //Discover Service
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if error != nil {
            print("Error discovering services \(error?.localizedDescription)")
            return
        }
        let services = peripheral.services as! [CBService]!
        for service in services {
                    if (service.characteristics != nil){
                peripheral.discoverCharacteristics(nil, forService: service)
            }
            if (service.UUID == CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")){ //uart
                print("found")
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
            print("Error discovering characteristics \(error?.localizedDescription)")
            return
        }
        else {
            let characteristics = service.characteristics as! [CBCharacteristic]!
            for characteristic in characteristics {
                print(characteristic.UUID)
                switch characteristic.UUID{
                case CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e"):
                    
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    print("Found TX")
                    break
                case CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e"):
                    print("sip")
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    
                    print("gee")
                    break
                case "2A37":
                    // Set notification on heart rate measurement
                    print("Found a Heart Rate Measurement Characteristic")
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    break
                case "2A38":
                    // Read body sensor location
                    print("Found a Body Sensor Location Characteristic")
                    peripheral.readValueForCharacteristic(characteristic)
                    break
                    //                var rawArray:[UInt8] = [0x01];
                    //                let data = NSData(bytes: &rawArray, length: rawArray.count)
                    //                peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
                    
                default:
                    print("nope")
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
            print("got it")
            return
        }
        else{
            //print("fail")
        }
        print("here")
        switch characteristic.UUID{
            //    case "2A37":
            //      update(heartRateData:characteristic.value!)
            //    break
        case CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e"):
            print("got this far")
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
        print(newString as! String)
        let sensor = newString!.componentsSeparatedByString(",")
        // print(sensor[0])
        print(sensor[2])
        
        
        
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
            print(actualBpm)
        }else {
            print(bpm)
        }
        
    }

    
}

extension timerViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        //Handle results with taskViewController.result
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
