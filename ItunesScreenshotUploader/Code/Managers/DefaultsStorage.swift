//
//  DefaultsStorage.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 07/03/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Foundation

class DefaultsStorage {
    
    lazy private var keychain = KeychainSwift()

    func saveCredentialsIncludingPassword(savePassword:Bool, user:String, sku:String, password:String, path:String) {
        
        NSUserDefaults.standardUserDefaults().setValue(user, forKey: UserNameKey)
        NSUserDefaults.standardUserDefaults().setValue(sku, forKey: SKUKey)
        NSUserDefaults.standardUserDefaults().setValue(path, forKey: iTMSTransporterPathKey)
        
        if savePassword {
            keychain.set(password, forKey: PasswordKey)
        } else {
            keychain.delete(PasswordKey)
        }
    }
    
    var userName:String {
        return NSUserDefaults.standardUserDefaults().valueForKey(UserNameKey) as? String ?? ""
    }
    
    var password:String {
        return keychain.get(PasswordKey) ?? ""
    }
    
    var pathToTransporter:String {
        return NSUserDefaults.standardUserDefaults().valueForKey(iTMSTransporterPathKey) as? String ?? ""
    }
    
    var sku:String {
        return NSUserDefaults.standardUserDefaults().valueForKey(SKUKey) as? String ?? ""
    }

}