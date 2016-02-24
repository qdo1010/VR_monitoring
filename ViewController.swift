//
//  ViewController.swift
//  BlueTooth
//  Learing from https://github.com/anas-imtiaz/SwiftSensorTag/blob/master/SwiftSensorTag/ViewController.swift
//  Created by shan jiang on 21/01/16.
//  Copyright © 2016 Shan Jiang. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var temLabel: UILabel?
    
    // BLE
    var centralManager : CBCentralManager!
    var peripheralDevice : CBPeripheral!
      var buffer = ""
  var uartService:CBService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
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
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
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
        for service: CBService in peripheral.services! {
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
        for characteristic: CBCharacteristic in service.characteristics! {
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


