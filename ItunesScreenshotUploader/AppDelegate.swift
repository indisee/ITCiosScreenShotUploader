//
//  AppDelegate.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 19/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        initDefaults()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    
    func initDefaults() {
        let inited = NSUserDefaults.standardUserDefaults().valueForKey("inited") as? Bool ?? false
        if !inited {
            NSUserDefaults.standardUserDefaults().setObject("/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/itms/bin/iTMSTransporter", forKey: "ITCPath")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "inited")
        }
    }
    
}

