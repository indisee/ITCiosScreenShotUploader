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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initDefaults()
    }
    
    func initDefaults() {
        UserDefaults.standard.register(defaults: [iTMSTransporterPathKey :DefaultiTMSTransporterPath])
    }
    
}

