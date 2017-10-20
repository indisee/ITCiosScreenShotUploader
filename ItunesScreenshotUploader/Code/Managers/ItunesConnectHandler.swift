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
    case successStatus
    case failStatus
    
    init(rawValue:Int32) {
        if rawValue == 0 {
            self = .successStatus
            return
        }
        self = .failStatus
    }
}



class ItunesConnectHandler {
    
    static let sharedInstance = ItunesConnectHandler()
    
    let credStorage = DefaultsStorage()
    let fileManager = FileManager.default
    
    internal fileprivate(set) var ITCPath:String     = ""
    internal fileprivate(set) var ITMSUSER:String    = ""
    internal fileprivate(set) var ITMSPASS:String    = ""
    internal fileprivate(set) var ITMSSKU:String     = ""
    
    fileprivate let q = OperationQueue()
    
    
    //MARK: - Helpers -
    
    fileprivate let pathToStore = "\(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String)/iTunesUploader/"
    
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
        
        let launchPathExists = fileManager.fileExists(atPath: ITCPath)
        
        if ITMSUSER == "" || ITMSPASS == "" || ITMSSKU == "" || !launchPathExists {
            return false
        }
        return true
    }
    
    
    //MARK: - ITC -
    
    fileprivate func executeITCCommand(_ arguments:[String], callback:@escaping (_ status:CallbackStatus)->Void, progressBlock:((_ str:String)->Void)? = nil) {
        
        var isDir : ObjCBool = false
        if !fileManager.fileExists(atPath: pathToStore, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(atPath: pathToStore, withIntermediateDirectories: true, attributes: nil)
            } catch {
                assert(false)
            }
        }
        
        let op = BlockOperation()
        
        op.addExecutionBlock { () -> Void in
            
            let task = Process()
            
            print("itunes uploader \(self.ITCPath)")
            print("——————")
            
            task.launchPath = self.ITCPath
            task.arguments = arguments
            task.currentDirectoryPath = self.pathToStore
            task.launch()
            
            task.waitUntilExit()
            
            let status = task.terminationStatus
            
            if !op.isCancelled {
                OperationQueue.main.addOperation({ () -> Void in
                    callback(CallbackStatus(rawValue: status))
                })
            }
            
        }
        
        q.addOperation(op)
    }
    
    
    //MARK: - Public end point -
    
    func getMetaWithCallback(_ callback:@escaping (_ status:CallbackStatus)->Void) -> Bool {
        
        if allCredentialValuesAreFilled() {
            
            if fileManager.fileExists(atPath: itmspPath()){
                do {
                    try fileManager.removeItem(atPath: itmspPath())
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
    
    func verifyScreenshots(_ callback:@escaping (_ status:CallbackStatus)->Void) -> Bool {
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
    
    func uploadScreenshots(_ callback:@escaping (_ status:CallbackStatus)->Void) -> Bool {
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

