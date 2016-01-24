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
    case SuccessStatus = 0
    case FailStatus
}



class ItunesConnectHandler {
    
    static let sharedInstance = ItunesConnectHandler()
    
    internal private(set) var ITCPath:String?     = ""
    internal private(set) var ITMSUSER:String?    = ""
    internal private(set) var ITMSPASS:String?    = "" {
        didSet {
            print(ITMSPASS)
        }
    }
    internal private(set) var ITMSSKU:String?     = ""
    
    private let keychain = KeychainSwift()
    private let q = NSOperationQueue()
    
    let pathToStore = "\(NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String)/iTunesUploader/"
    
    func itmspPath() -> String {
        return "\(pathToStore)\(ITMSSKU!).itmsp"
    }
    
    func fillCurrentValues() {
        ITMSUSER = NSUserDefaults.standardUserDefaults().valueForKey("ITMSUSER") as? String ?? ""
        ITMSSKU = NSUserDefaults.standardUserDefaults().valueForKey("ITMSSKU") as? String ?? ""
        ITCPath = NSUserDefaults.standardUserDefaults().valueForKey("ITCPath") as? String ?? ""
        ITMSPASS = !(ITMSPASS!.isEmpty) ? ITMSPASS : keychain.get("ITMSPASS")
    }
    
    func saveCredentialsIncludingPassword(savePassword:Bool, user:String, sku:String, password:String, path:String) {
        
        ITCPath = path
        ITMSUSER = user
        ITMSPASS = password
        ITMSSKU = sku
        
        NSUserDefaults.standardUserDefaults().setValue(ITMSUSER, forKey: "ITMSUSER")
        NSUserDefaults.standardUserDefaults().setValue(ITMSSKU, forKey: "ITMSSKU")
        NSUserDefaults.standardUserDefaults().setValue(ITCPath, forKey: "ITCPath")
        
        if savePassword {
            keychain.set(ITMSPASS!, forKey: "ITMSPASS")
        } else {
            keychain.delete("ITMSPASS")
        }
    }
    
    //MARK: - ITC -
    
    func executeITCCommand(arguments:[String], callback:(status:CallbackStatus)->Void, progressBlock:((str:String)->Void)? = nil) {
        
        var isDir : ObjCBool = false
        if !NSFileManager.defaultManager().fileExistsAtPath(pathToStore, isDirectory: &isDir) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(pathToStore, withIntermediateDirectories: true, attributes: nil)
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
            
            /*
            let pipe = NSPipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleReadCompletionNotification, object: pipe.fileHandleForReading, queue: nil, usingBlock: { (notification) -> Void in
            
            let output = pipe.fileHandleForReading.availableData
            let outStr = NSString(data: output, encoding: NSUTF8StringEncoding) as! String
            
            if progressBlock != nil {
            progressBlock!(str: outStr)
            }
            
            if task.running {
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            pipe.fileHandleForReading.readInBackgroundAndNotify()
            })
            }
            })
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            pipe.fileHandleForReading.readInBackgroundAndNotify()
            })
            */
            
            task.launch()
            
            task.waitUntilExit()
            
            let status = task.terminationStatus
            
            if !op.cancelled {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    callback(status: (status == 0 ? .SuccessStatus : .FailStatus))
                })
            }
            
        }
        
        q.addOperation(op)
    }
    
    func allCredentialValuesAreFilled() -> Bool {
        fillCurrentValues()
        
        let launchPathExists = NSFileManager.defaultManager().fileExistsAtPath(ITCPath!)
        if ITMSUSER == "" || ITMSPASS == "" || ITMSSKU == "" || !launchPathExists {
            return false
        }
        return true
    }
    
    func getMetaWithCallback(callback:(status:CallbackStatus)->Void) -> Bool {
        
        if allCredentialValuesAreFilled() {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(itmspPath()){
                do {
                    try fileManager.removeItemAtPath(itmspPath())
                } catch {
                }
                
            }
            
            executeITCCommand([
                "-m", "lookupMetadata",
                "-u", ITMSUSER!,
                "-p", ITMSPASS!,
                "-vendor_id", ITMSSKU!,
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
                "-u", ITMSUSER!,
                "-p", ITMSPASS!,
                "-vendor_id", ITMSSKU!,
                "-f", "\(pathToStore)/*.itmsp"
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
                "-u", ITMSUSER!,
                "-p", ITMSPASS!,
                "-vendor_id", ITMSSKU!,
                "-f", "\(pathToStore)/*.itmsp"
                ],
                callback: callback
            )
            return true
        } else {
            return false
        }
    }
}




class ITCMetaXMLHandler {
    
    private let q = NSOperationQueue()

    
    //MARK: - Vars -
    
    func metaXmlPath() -> String {
        return "\(ItunesConnectHandler.sharedInstance.itmspPath())/metadata.xml"
    }
    
    func pathForImageOfScreenShot(screenShot:ScreenShot) -> String {
        return "\(ItunesConnectHandler.sharedInstance.itmspPath())/\(screenShot.nameForUpload)"
    }
    
    
    //MARK: - Helpers -
    
    func writeXmlBackToMetaFile(xml:AEXMLDocument) {
        let xmlPath = metaXmlPath
        
        do {
            try xml.root.xmlString.writeToFile(xmlPath(), atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {
            assert(false)
        }
    }
    
    func replaceChildrensOfElement(element:AEXMLElement, newChildrens:[AEXMLElement]?) -> AEXMLElement {
        
        for ch in element.children {
            ch.removeFromParent()
        }
        if let new = newChildrens {
            for el in new {
                element.addChild(el)
            }
        }
        
        return element
    }
    
    
    //MARK: - Meta stuff -
    
    func xmlNodeFromScreenShot(screenShot:ScreenShot, position:Int) -> AEXMLElement? {
        
        if position > 5 || screenShot.screenType == .iUndefinedScreenShotType {
            return nil
        }
        
        /*
        <software_screenshot display_target="iOS-3.5-in" position="1">
        <size>258477</size>
        <file_name>1.png</file_name>
        <checksum type="md5">7a8c1d8e5fe8b029fea88d0ea1e30a6d</checksum>
        </software_screenshot>
        */
        let attributes = [
            "display_target" : screenShot.screenType.rawValue,
            "position" : "\(position)"
        ]
        let software_screenshot = AEXMLElement("software_screenshot", value: nil, attributes: attributes)
        
        software_screenshot.addChild(name: "size", value: "\(screenShot.fileSize)", attributes: nil)
        software_screenshot.addChild(name: "file_name", value: "\(screenShot.nameForUpload)", attributes: nil)
        software_screenshot.addChild(name: "checksum", value: "\(screenShot.md5)", attributes: [
            "type":"md5"
            ])
        
        return software_screenshot
        
    }
    
    func getMetaData() -> AEXMLDocument? {
        
        let xmlPath = metaXmlPath()
        
        guard let
            data = NSData(contentsOfFile: xmlPath)
            else { return nil }
        do {
            let xmlDoc = try AEXMLDocument(xmlData: data)
            return xmlDoc
        } catch {
            print("\(error)")
        }
        
        return nil
    }
    
    
    func getLocalesForMetadata(xml:AEXMLDocument? = nil) -> AEXMLElement? {
        
        var xmlDoc:AEXMLDocument! = xml
        
        if xmlDoc == nil {
            xmlDoc = getMetaData()
        }
        if xmlDoc == nil {
            return nil
        }
        
        let versions = xmlDoc.root["software"]["software_metadata"]["versions"]
        if versions.children.count > 0 {
            
            let versionIndex = indexOfLatestVersionFromElement(versions)
            let currentVersion = versions.children[versionIndex]
            
            let locales = currentVersion["locales"]
            return locales
        }
        
        return nil
    }
    
    
    func indexOfLatestVersionFromElement(versions:AEXMLElement) -> Int {
        
        var versionNumber:Double = 0.0
        var versionIndex = 0
        
        for (i,e) in versions.children.enumerate() {
            if let eVersion = Double(e.attributes["string"]!) {
                if eVersion > versionNumber {
                    versionNumber = eVersion
                    versionIndex = i
                }
            }
        }
        
        return versionIndex
    }
    
    
    //MARK: - Actions -
    
    func copyScreenShotsImagesToITMSP(allImagesPlatf:[[[ScreenShot]]]) {
        
        let fileManager = NSFileManager.defaultManager()
        for allImages in allImagesPlatf {
            for img in allImages {
                for i in img {
                    if i.screenType != .iUndefinedScreenShotType {
                        let path = pathForImageOfScreenShot(i)
                        do {
                            try
                                fileManager.copyItemAtPath(i.path, toPath: path)
                            i.md5 = md5(path)
                        } catch {
                            assert(false)
                        }
                        
                    }
                }
            }
        }
    }
    
    func updateMetadataForScreenShots(rawScreenShots:[String:[[ScreenShot]]], uploadType:ScreenShotUploadingMode, callback:(status:Int32)->Void) {
        
        let op = NSBlockOperation()
        
        op.addExecutionBlock { () -> Void in
            
            let fail = {()->Void in
                if !op.cancelled {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        callback(status: 1)
                    })
                }
            }
            
            if let localesParent = self.getLocalesForMetadata() {
                
                self.copyScreenShotsImagesToITMSP(Array(rawScreenShots.values))
                
                let locales = localesParent.children
                
                var localesByLang = [String:AEXMLElement]()
                for loc in locales {
                    if let lang = loc.attributes["name"] {
                        localesByLang[lang] = loc
                    }
                }
                
                var screenShots:[String:[[ScreenShot]]] = [String:[[ScreenShot]]]()
                if uploadType == .SameScreenShotUploadingMode {
                    
                    for lang in Array(localesByLang.keys) {
                        screenShots["[\(lang)]"] = rawScreenShots[NoLangID]!
                    }
                    
                } else {
                    screenShots = rawScreenShots
                }
                
                let finalLocales = AEXMLElement("locales", value: nil, attributes: nil)
                
                for key in Array(localesByLang.keys) {
                    
                    let locale = localesByLang[key]!
                    let lang = "[\(key)]"
                    
                    if let allPlatformsScreens = screenShots[lang] {
                        
                        var langScreenshots = [AEXMLElement]()
                        
                        for platformScreens in allPlatformsScreens {
                            var i = 1
                            for screen in platformScreens {
                                if let el = self.xmlNodeFromScreenShot(screen, position: i) {
                                    ++i
                                    langScreenshots.append(el)
                                }
                            }
                        }
                        
                        //fill locale
                        let children = locale.children
                        var hasScreenShotSection = false
                        
                        for ch in children {
                            if ch.name == "software_screenshots"{
                                hasScreenShotSection = true
                                break
                            }
                        }
                        
                        if hasScreenShotSection {
                            var software_screenshots = locale["software_screenshots"]
                            software_screenshots = self.replaceChildrensOfElement(software_screenshots, newChildrens: langScreenshots)
                        } else {
                            
                            let screens = AEXMLElement("software_screenshots", value: nil, attributes: nil)
                            for sc in langScreenshots {
                                screens.addChild(sc)
                            }
                            
                            locale.addChild(screens)
                            
                        }
                        
                    } else {
                        locale["software_screenshots"].removeFromParent()
                        //                    replaceChildrensOfElement(locale["software_screenshots"], newChildrens: nil)
                    }
                    
                    finalLocales.addChild(locale)
                }
                
                if let document = self.getMetaData() {
                    
                    let versions = document.root["software"]["software_metadata"]["versions"]
                    if versions.children.count > 0 {
                        let versionIndex = self.indexOfLatestVersionFromElement(versions)
                        
                        self.replaceChildrensOfElement(document.root["software"]["software_metadata"]["versions"].children[versionIndex]["locales"], newChildrens: finalLocales.children)
                        
                        print("—————————")
                        print(document.root.xmlString)
                        
                        self.writeXmlBackToMetaFile(document)
                        
                    } else {
                        fail()
                        return
                    }
                } else {
                    fail()
                    return
                }
                
                if !op.cancelled {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        callback(status: 0)
                    })
                }
                
                
            } else {
                fail()
                return
            }
            
        }
        
        q.addOperation(op)
        
    }
    
}

