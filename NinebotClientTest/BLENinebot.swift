//
//  BLENinebot.swift
//  NinebotClientTest
//
//  Created by Francisco Gorina Vanrell on 2/2/16.
//  Copyright © 2016 Paco Gorina. All rights reserved.
//
//
// BLENinebot represents the state of the wheel
//
//  It really is aan array simulating original description
//
//  It is an Int array
//
//  Also provides a log of information as a log array that may be saved.
//
//  Methods are provided to interpret labels and get most information in correct units
//
//  Usually there is just one object just for the current wheel
//
//

import UIKit

class  BLENinebot : NSObject{
    
    struct LogEntry {
        var time : NSDate
        var variable : Int
        var value : Int
    }
    
    struct NinebotVariable {
        var codi : Int = -1
        var timeStamp : NSDate = NSDate()
        var value : Int = -1
        var log : [LogEntry] = [LogEntry]()
        
    }
    
    static let kAltitude = 0       // Obte les dades de CMAltimeterManager. 0 es l'inici i serveix per variacions unicament
    static let kSerialNo = 16       // 16-22
    static let kPinCode = 23        // 23-25
    static let kVersion = 26
    static let kError = 27
    static let kWarn = 28
    static let kWorkMode = 31
    static let kBattery = 34
    static let kRemainingDistance = 37
    static let kCurrentSpeed = 38
    static let kTotalMileage0 = 41
    static let kTotalMileage1 = 42
    static let kTotalRuntime0 = 50
    static let kTotalRuntime1 = 51
    static let kSingleRuntime = 58
    static let kTemperature = 62
    static let kVoltage = 71
    static let kUnknown = 74
    static let kCurrent = 80
    static let kPitchAngle = 97
    static let kRollAngle = 98
    static let kPitchAngleVelocity = 99
    static let kRollAngleVelocity = 100
    
    static let kvCodeError = 176
    static let kvCodeWarning = 177
    static let kvFlags = 178
    static let kvWorkMode = 179
    static let kvPowerRemaining = 180
    static let kvSpeed = 181
    static let kvAverageSpeed = 182
    static let kvTotalDistance0 = 183
    static let kvTotalDistance1 = 184
    static let kvSingleMileage = 185
    static let kvTemperature = 187
    static let kvDriveVoltage = 188
    static let kvRollAngle = 189
    static let kvPitchAngle = 190
    static let kvMaxSpeed = 191
    static let kvRideMode = 210
    
    static var  labels = Array<String>(count:256, repeatedValue:"?")
    
    static var displayableVariables : [Int] = [BLENinebot.kCurrentSpeed, BLENinebot.kTemperature,
        BLENinebot.kVoltage, BLENinebot.kCurrent, BLENinebot.kPitchAngle, BLENinebot.kRollAngle,
        BLENinebot.kvSingleMileage, BLENinebot.kAltitude]
    
    var data = [NinebotVariable](count:256, repeatedValue:NinebotVariable())
     
    var headersOk = false
    var firstDate : NSDate?
    
    
    
    
    override init(){
        
        if BLENinebot.labels[37] == "?"{
            BLENinebot.initNames()
        }
        super.init()
        
        for i in 0..<256 {
            data[i].codi = i
        }
        
    }
    
    static func initNames(){
        BLENinebot.labels[0]  = "Alt Var(m)"
        BLENinebot.labels[16]  = "SN0"
        BLENinebot.labels[17]  = "SN1"
        BLENinebot.labels[18]  = "SN2"
        BLENinebot.labels[19]  = "SN3"
        BLENinebot.labels[20]  = "SN4"
        BLENinebot.labels[21]  = "SN5"
        BLENinebot.labels[22]  = "SN6"
        BLENinebot.labels[23]  = "BTPin0"
        BLENinebot.labels[24]  = "BTPin1"
        BLENinebot.labels[25]  = "BTPin2"
        BLENinebot.labels[26]  = "Version"
        BLENinebot.labels[34]  = "Batt (%)"
        BLENinebot.labels[37]  = "Remaining Mileage"
        BLENinebot.labels[38]  = "Speed (Km/h)"
        BLENinebot.labels[41]  = "Total Mileage 0"
        BLENinebot.labels[42]  = "Total Mileage 1"
        BLENinebot.labels[50]  = "Total Runtime 0"
        BLENinebot.labels[51]  = "Total Runtime 1"
        BLENinebot.labels[58]  = "Single Runtime"
        BLENinebot.labels[62]  = "T (ºC)"
        BLENinebot.labels[71]  = "Voltage (V)"
        BLENinebot.labels[80]  = "Current (A)"
        BLENinebot.labels[97]  = "Pitch (º)"
        BLENinebot.labels[98]  = "Roll (º)"
        BLENinebot.labels[99]  = "Pitch Angle Angular Velocity"
        BLENinebot.labels[100]  = "Roll Angle Angular Velocity"
        BLENinebot.labels[105]  = "Active Data Encoded"
        BLENinebot.labels[115]  = "Tilt Back Speed?"
        BLENinebot.labels[116]  = "Speed Limit"
        
        BLENinebot.labels[176] = "Code Error"
        BLENinebot.labels[177] = "Code Warning"
        BLENinebot.labels[178] = "Flags"             // Lock, Limit Speed, Beep, Activation
        BLENinebot.labels[179] = "Work Mode"
        BLENinebot.labels[180] = "Power Remaining"
        BLENinebot.labels[181] = "Speed"
        BLENinebot.labels[182] = "Average Speed"
        BLENinebot.labels[183] = "Total Distance0"
        BLENinebot.labels[184] = "Total Distance1"
        BLENinebot.labels[185] = "Dist (Km)"
        BLENinebot.labels[186] = "Single Mileage?"
        BLENinebot.labels[187] = "Body Temp"
        BLENinebot.labels[188] = "Drive Voltage"
        BLENinebot.labels[189] = "Roll Angle"
        BLENinebot.labels[191] = "Max Speed"
        BLENinebot.labels[210] = "Ride Mode"
        BLENinebot.labels[211] = "One Fun Bool"
        
    }
    
    func clearAll(){
        
        for i in 0..<256{
            data[i].value = -1
            data[i].timeStamp = NSDate()
            if data[i].log.count > 0{
                data[i].log.removeAll()
            }
        }
        
        headersOk = false
        
        firstDate = nil
    }
    
    func checkHeaders() -> Bool{
        
        if headersOk {
            return true
        }
        
        var filled = true
        
        for i in 16..<27 {
            if data[i].value == -1{
                filled = false
            }
        }
        
        headersOk = filled
        
        return filled
    }
    
    func addValue(variable : Int, value : Int){
        
        let t = NSDate()
        
        if firstDate == nil {
            firstDate = t
        }
        
        if variable >= 0 && variable < 256 {
            
            if data[variable].value != value {    // If value change put into log
                
                let v = LogEntry(time: t, variable: variable, value: value)
                data[variable].log.append(v)
            }
            
            
            // Now update values of variables
            
            data[variable].value = value
            data[variable].timeStamp = t
        }
    }
    
    // Creates a log text file and
    
    func createTextFile() -> NSURL?{
        
        // Format first date into a filepath
        
        let ldateFormatter = NSDateFormatter()
        let enUSPOSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        ldateFormatter.locale = enUSPOSIXLocale
        ldateFormatter.dateFormat = "'9B_'yyyyMMdd'_'HHmmss'.txt'"
        let newName = ldateFormatter.stringFromDate(NSDate())
       
        let  path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
        
        
        let tempFile = (path + "/" ).stringByAppendingString(newName )
        
        
        let mgr = NSFileManager.defaultManager()
        
        mgr.createFileAtPath(tempFile, contents: nil, attributes: nil)
        let file = NSURL.fileURLWithPath(tempFile)
        
        
        
        do{
            let hdl = try NSFileHandle(forWritingToURL: file)
            // Get time of first item
            
            if firstDate == nil {
                firstDate = NSDate()
            }
            
            
            let title = String(format: "Time\tVar\tValor\n")
            hdl.writeData(title.dataUsingEncoding(NSUTF8StringEncoding)!)
            
            for v in self.data {
                
                if v.value != -1 && v.log.count > 0{
                    
                    let varName = String(format: "%d\t%@\n",v.codi, BLENinebot.labels[v.codi])
                    
                    NSLog("Gravant log per %@", varName)
                    
                    if let vn = varName.dataUsingEncoding(NSUTF8StringEncoding){
                        hdl.writeData(vn)
                    }
                    
                    for item in v.log {
                        
                        let t = item.time.timeIntervalSinceDate(firstDate!)
                        
                        let s = String(format: "%20.3f\t%d\t%d\n", t, item.variable, item.value)
                        if let vn = s.dataUsingEncoding(NSUTF8StringEncoding){
                             hdl.writeData(vn)
                        }
                    }
                }
            }
            
            hdl.closeFile()
            
            return file
            
        }
        catch{
            NSLog("Error al obtenir File Handle")
        }
        
        return nil
    }
    
    // MARK: Query Functions
    
    func serialNo() -> String{
        
        var no = ""
        
        for (var i = 16; i < 23; i++){
            let v = self.data[i].value
            
            
            let v1 = v % 256
            let v2 = v / 256
            
            let ch1 = Character(UnicodeScalar(v1))
            let ch2 = Character(UnicodeScalar( v2))
            
            no.append(ch1)
            no.append(ch2)
        }
        
        return no
    }
    
    func version() -> (Int, Int, Int){
        
        let clean = self.data[BLENinebot.kVersion].value & 4095
        
        let v0 = clean / 256
        let v1 = (clean - (v0 * 256) ) / 16
        let v2 = clean % 16
        
        return (v0, v1, v2)
        
    }
    
    // Return total mileage in Km
    
    func totalMileage() -> Double {
        
        let d : Double = Double (data[BLENinebot.kTotalMileage1].value * 65536 + data[BLENinebot.kTotalMileage0].value) / 1000.0
        
        return d
        
    }
    
    // Total runtime in seconds
    
    func totalRuntime() -> NSTimeInterval {
        
        let t : NSTimeInterval = NSTimeInterval(data[BLENinebot.kTotalRuntime1].value * 65536 + data[BLENinebot.kTotalRuntime0].value)
        
        return t
    }
    
    func singleRuntime() -> NSTimeInterval {
        
        let t : NSTimeInterval = NSTimeInterval(data[BLENinebot.kSingleRuntime].value)
        
        return t
    }
    
    func totalRuntimeHMS() -> (Int, Int, Int) {
        
        let total = data[BLENinebot.kTotalRuntime1].value * 65536 + data[BLENinebot.kTotalRuntime0].value
        
        let hours = total / 3600
        let minutes = (total - (hours * 3600)) / 60
        let seconds = total - (hours * 3600) - (minutes + 60)
        
        return (hours, minutes, seconds)
        
    }
    
    // Body Temperature in ºC
    
    func temperature() -> Double {
        let t : Double = Double(data[BLENinebot.kTemperature].value) / 10.0
        
        return t
    }
    
    func temperature(i : Int) -> Double {
        let t : Double = Double(data[BLENinebot.kTemperature].log[i].value) / 10.0
        
        return t
    }
    
    // Voltage
    
    func voltage() -> Double {
        let t : Double = Double(data[BLENinebot.kVoltage].value) / 100.0
        return t
    }
    func voltage(i : Int) -> Double {
        
        let t : Double = Double(data[BLENinebot.kVoltage].log[i].value) / 100.0
        return t
    }
    
    
    // Current
    func current() -> Double {
        var v = data[BLENinebot.kCurrent].value
        
        if v >= 32768 {
            v = v - 65536
        }
        
        let t = Double(v) / 100.0
        return t
    }
    
    func current(i : Int) -> Double {
        var v = data[BLENinebot.kCurrent].log[i].value
        
        if v >= 32768 {
            v = v - 65536
        }
        
        let t = Double(v) / 100.0
        return t
    }
    
    // pitch Angle
    
    func pitch() -> Double {
        var v = data[BLENinebot.kPitchAngle].value
        
        if v >= 32768 {
            v = v - 65536
        }
        
        let t = Double(v) / 100.0
        return t
    }
    
    func pitch(i : Int) -> Double {
        var v = data[BLENinebot.kPitchAngle].log[i].value
        
        if v >= 32768 {
            v = v - 65536
        }
        
        let t = Double(v) / 100.0
        return t
    }
    
    
    // roll Angle
    
    func roll() -> Double {
        var v = data[BLENinebot.kRollAngle].value
        
        if v >= 32768 {
            v = v - 65536
        }
        
        let t = Double(v) / 100.0
        return t
    }
    
    func roll(i : Int) -> Double {
        var v = data[BLENinebot.kRollAngle].log[i].value
        
        if v >= 32768 {
            v = v - 65536
        }
        
        let t = Double(v) / 100.0
        return t
    }
    
    // pitch angle speed
    
    
    
    // roll angle speed
    
    
    
    // Remaining km
    
    func remainingMileage() -> Double{
        
        let v = data[BLENinebot.kRemainingDistance].value
        
        let t = Double(v) / 100.0
        
        return t
        
        
    }
    
    
    // Battery Level
    
    func batteryLevel() -> Double{
        
        let v = data[BLENinebot.kBattery].value
        return Double(v)
        
    }
    
    // Speed
    
    func speed() -> Double {
        let s : Double = Double(data[BLENinebot.kCurrentSpeed].value) / 1000.0
        
        return s
    }
    
    func speed(i : Int) -> Double {
        let s : Double = Double(data[BLENinebot.kCurrentSpeed].log[i].value) / 1000.0
        
        return s
    }
    
    
    // Speed limit
    
    
    // Single runtime
    
    
    // Single distance. Sembla pitjor que la total. En fi
    
    func singleMileage() -> Double{
        
        let s : Double = Double(data[BLENinebot.kvSingleMileage].value) / 100.0
        
        return s
    }
    
    func singleMileage(i : Int) -> Double{
        
        let s : Double = Double(data[BLENinebot.kvSingleMileage].log[i].value) / 100.0
        
        return s
    }
    
    func altitude() -> Double{
        
        let s : Double = Double(data[BLENinebot.kAltitude].value) / 10.0
        
        return s
    }
    
    func altitude(i : Int) -> Double{
        
        let s : Double = Double(data[BLENinebot.kAltitude].log[i].value) / 10.0
        
        return s
    }
   
    
    
    func getLogValue(variable : Int, index : Int) -> Double{
        
        switch(variable){
            
        case 0:
            return self.speed(index)
            
        case 1:
            return self.temperature(index)
            
        case 2:
            return self.voltage(index)
            
        case 3:
            return self.current(index)
            
        case 4:
            return self.pitch(index)
            
        case 5:
            return self.roll(index)
            
        case 6:
            return self.singleMileage(index)
            
        case 7:
            return self.altitude(index)
            
        default:
            return 0.0
            
        }
    }
    
    
    // Ride mode
    
    // One Fun Bool ?
    
    
    
}