//
//  ItunesConnectHandler.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 19/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Foundation
import Cocoa

enum CallbackStatus : Int32 {
    case SuccessStatus
    case FailStatus
    
    init(rawValue:Int32) {
        if rawValue == 0 {
            self = .SuccessStatus
            return
        }
        self = .FailStatus
    }
}



class ItunesConnectHandler {
    
    static let sharedInstance = ItunesConnectHandler()
    
    let credStorage = DefaultsStorage()
    let fileManager = NSFileManager.defaultManager()
    
    internal private(set) var ITCPath:String     = ""
    internal private(set) var ITMSUSER:String    = ""
    internal private(set) var ITMSPASS:String    = ""
    internal private(set) var ITMSSKU:String     = ""
    
    private let q = NSOperationQueue()
    
    
    //MARK: - Helpers -
    
    private let pathToStore = "\(NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String)/iTunesUploader/"
    
    internal func itmspPath() -> String {
        return "\(pathToStore)\(ITMSSKU).itmsp"
    }
    
    func fillCurrentValues() {
        ITMSUSER = credStorage.userName
        ITMSSKU = credStorage.sku
        ITCPath = credStorage.pathToTransporter
        ITMSPASS = credStorage.password
    }
    
    func allCredentialValuesAreFilled() -> Bool {
        fillCurrentValues()
        
        let launchPathExists = fileManager.fileExistsAtPath(ITCPath)
        
        if ITMSUSER == "" || ITMSPASS == "" || ITMSSKU == "" || !launchPathExists {
            return false
        }
        return true
    }
    
    
    //MARK: - ITC -
    
    private func executeITCCommand(arguments:[String], callback:(status:CallbackStatus)->Void, progressBlock:((str:String)->Void)? = nil) {
        
        var isDir : ObjCBool = false
        if !fileManager.fileExistsAtPath(pathToStore, isDirectory: &isDir) {
            do {
                try fileManager.createDirectoryAtPath(pathToStore, withIntermediateDirectories: true, attributes: nil)
            } catch {
                assert(false)
            }
        }
        
        let op = NSBlockOperation()
        
        op.addExecutionBlock { () -> Void in
            
            let task = NSTask()
            
            print("itunes uploader \(self.ITCPath)")
            print("——————")
            
            task.launchPath = self.ITCPath
            task.arguments = arguments
            task.currentDirectoryPath = self.pathToStore
            task.launch()
            
            task.waitUntilExit()
            
            let status = task.terminationStatus
            
            if !op.cancelled {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    callback(status:CallbackStatus(rawValue: status))
                })
            }
            
        }
        
        q.addOperation(op)
    }
    
    
    //MARK: - Public end point -
    
    func getMetaWithCallback(callback:(status:CallbackStatus)->Void) -> Bool {
        
        if allCredentialValuesAreFilled() {
            
            if fileManager.fileExistsAtPath(itmspPath()){
                do {
                    try fileManager.removeItemAtPath(itmspPath())
                } catch {
                }
            }
            
            executeITCCommand([
                "-m", "lookupMetadata",
                "-u", ITMSUSER,
                "-p", ITMSPASS,
                "-vendor_id", ITMSSKU,
                "-destination", pathToStore
                ],
                callback: callback)
            return true
        } else {
            return false
        }
    }
    
    func verifyScreenshots(callback:(status:CallbackStatus)->Void) -> Bool {
        //    iTMSTransporter -m verify -u $ITMSUSER -p $ITMSPASS -vendor_id $ITMSSKU -f ~/Desktop/*.itmsp
        if allCredentialValuesAreFilled() {
            executeITCCommand([
                "-m", "verify",
                "-u", ITMSUSER,
                "-p", ITMSPASS,
                "-vendor_id", ITMSSKU,
                "-f", "\(pathToStore)/\(ITMSSKU).itmsp"
                ],
                callback: callback)
            return true
        } else {
            return false
        }
    }
    
    func uploadScreenshots(callback:(status:CallbackStatus)->Void) -> Bool {
        //iTMSTransporter -m upload -u $ITMSUSER -p $ITMSPASS -vendor_id $ITMSSKU -f ~/Desktop/*.itmsp
        if allCredentialValuesAreFilled() {
            executeITCCommand([
                "-m", "upload",
                "-u", ITMSUSER,
                "-p", ITMSPASS,
                "-vendor_id", ITMSSKU,
                "-f", "\(pathToStore)/\(ITMSSKU).itmsp"
                ],
                callback: callback
            )
            return true
        } else {
            return false
        }
    }
}

