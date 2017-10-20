//
//  DefaultsStorage.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 07/03/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Foundation

class DefaultsStorage {
    
    lazy fileprivate var keychain = KeychainSwift()

    func saveCredentialsIncludingPassword(_ savePassword:Bool, user:String, sku:String, password:String, path:String) {
        
        UserDefaults.standard.setValue(user, forKey: UserNameKey)
        UserDefaults.standard.setValue(sku, forKey: SKUKey)
        UserDefaults.standard.setValue(path, forKey: iTMSTransporterPathKey)
        
        if savePassword {
            keychain.set(password, forKey: PasswordKey)
        } else {
            keychain.delete(PasswordKey)
        }
    }
    
    var userName:String {
        return UserDefaults.standard.value(forKey: UserNameKey) as? String ?? ""
    }
    
    var password:String {
        return keychain.get(PasswordKey) ?? ""
    }
    
    var pathToTransporter:String {
        return UserDefaults.standard.value(forKey: iTMSTransporterPathKey) as? String ?? ""
    }
    
    var sku:String {
        return UserDefaults.standard.value(forKey: SKUKey) as? String ?? ""
    }

}
