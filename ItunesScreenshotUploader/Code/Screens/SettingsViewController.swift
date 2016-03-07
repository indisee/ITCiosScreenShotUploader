//
//  SettingsViewController.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 21/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    @IBOutlet weak var field1: NSTextField!
    @IBOutlet weak var field3: NSTextField!
    @IBOutlet weak var pathControll: NSPathControl!
    @IBOutlet weak var passwordTF: NSSecureTextField!
    @IBOutlet weak var saveCheckBox: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ItunesConnectHandler.sharedInstance.fillCurrentValues()
        
        pathControll.URL = NSURL(fileURLWithPath: ItunesConnectHandler.sharedInstance.ITCPath)
        field1.stringValue = ItunesConnectHandler.sharedInstance.ITMSUSER ?? ""
        field3.stringValue = ItunesConnectHandler.sharedInstance.ITMSSKU ?? ""
        passwordTF.stringValue = ItunesConnectHandler.sharedInstance.ITMSPASS ?? ""
    }
    
    @IBAction func save(sender: AnyObject) {
        self.view.window?.makeFirstResponder(nil)
        
        let ITMSPASS = passwordTF.stringValue
        let ITMSUSER = field1.stringValue
        let ITMSSKU = field3.stringValue
        let ITCPath = (pathControll.URL?.path) ?? ""
        
        let storage = DefaultsStorage()
        
        storage.saveCredentialsIncludingPassword(saveCheckBox.state == 1, user: ITMSUSER, sku: ITMSSKU, password: ITMSPASS, path: ITCPath)
        ItunesConnectHandler.sharedInstance.fillCurrentValues()
    }
    
    @IBAction func changeDoSavePassword(sender: AnyObject) {
    }
    
}
