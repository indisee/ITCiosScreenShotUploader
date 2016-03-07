//
//  XMLWorker.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 07/03/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Foundation


class ITCMetaXMLHandler {
    
    private let q = NSOperationQueue()
    
    
    //MARK: -  -
    
    var metaXmlPath:String {
        return "\(ItunesConnectHandler.sharedInstance.itmspPath())/metadata.xml"
    }
    
    
    //MARK: - Helpers -
    
    private func writeXmlBackToMetaFile(xml:AEXMLDocument) {
        do {
            try xml.root.xmlString.writeToFile(metaXmlPath, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {
            assert(false)
        }
    }
    
    private func replaceChildrensOfElement(element:AEXMLElement, newChildrens:[AEXMLElement]?) -> AEXMLElement {
        
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
    
    private func xmlNodeFromScreenShot(screenShot:ScreenShot, position:Int) -> AEXMLElement? {
        
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
    
    private func getMetaData() -> AEXMLDocument? {
        
        guard let
            data = NSData(contentsOfFile: metaXmlPath)
            else { return nil }
        do {
            let xmlDoc = try AEXMLDocument(xmlData: data)
            return xmlDoc
        } catch {
            print("\(error)")
        }
        
        return nil
    }
    
    
    private func getLocalesForMetadata(xml:AEXMLDocument? = nil) -> AEXMLElement? {
        
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
    
    
    private func indexOfLatestVersionFromElement(versions:AEXMLElement) -> Int {
        
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
    
    
    //MARK: - XML helpers -
    
    func localesSortedByLang(locales:[AEXMLElement]) -> [String:AEXMLElement] {
        
        var localesByLang:[String:AEXMLElement] = [String:AEXMLElement]()
        for loc in locales {
            if let lang = loc.attributes["name"] {
                localesByLang[lang] = loc
            }
        }
        return localesByLang
    }
    
    func mandatoryScreenshotsForMode(mode:ScreenShotUploadingMode, fromRaw raw:[String:[[ScreenShot]]], forLangs langs:[String:AEXMLElement]) -> [String:[[ScreenShot]]] {
        
        var screenShots = [String:[[ScreenShot]]]()
        
        if mode == .SameScreenShotUploadingMode {
            for lang in Array(langs.keys) {
                screenShots["[\(lang)]"] = raw[NoLangID]!
            }
            
        } else {
            screenShots = raw
        }
        
        return screenShots
    }
    
    
    //MARK: - -
    
    func updateMetadataForScreenShots(rawScreenShots:[String:[[ScreenShot]]], uploadType:ScreenShotUploadingMode, callback:(status:CallbackStatus)->Void) {
        
        let op = NSBlockOperation()
        
        op.addExecutionBlock { [unowned self, op] () -> Void in
            
            let fail = {()->Void in
                if !op.cancelled {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        callback(status: .FailStatus)
                    })
                }
            }
            
            if let localesParent = self.getLocalesForMetadata() {
                
                let locales = localesParent.children
                let localesByLang:[String:AEXMLElement] = self.localesSortedByLang(locales)
                let screenShots:[String:[[ScreenShot]]] = self.mandatoryScreenshotsForMode(uploadType, fromRaw: rawScreenShots, forLangs: localesByLang)
                
                let finalLocales = self.generateFinalXMLFromCurrentLocales(localesByLang, screenShots: screenShots)
                
                if let document = self.getMetaData() {
                    
                    let versions = document.root["software"]["software_metadata"]["versions"]
                    if versions.children.count > 0 {
                        
                        let versionIndex = self.indexOfLatestVersionFromElement(versions)
                        self.replaceChildrensOfElement(document.root["software"]["software_metadata"]["versions"].children[versionIndex]["locales"], newChildrens: finalLocales.children)
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
                        callback(status: .SuccessStatus)
                    })
                }
            } else {
                fail()
                return
            }
        }
        
        q.addOperation(op)
        
    }
    
    
    private func generateFinalXMLFromCurrentLocales(localesByLang:[String:AEXMLElement], screenShots:[String:[[ScreenShot]]]) -> AEXMLElement {
        
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
            }
            
            finalLocales.addChild(locale)
        }
        
        return finalLocales
    }
    
}
