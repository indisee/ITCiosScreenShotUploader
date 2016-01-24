//
//  ScreenShot.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 20/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Foundation
import Cocoa

enum ScreenShotType : String {
    
    case iUndefinedScreenShotType   = "Undefined ScreenShot Type"
    case iPhone4                    = "iOS-3.5-in"
    case iPhone5                    = "iOS-4-in"
    case iPhone6                    = "iOS-4.7-in"
    case iPhone6Plus                = "iOS-5.5-in"
    case iPad                       = "iOS-iPad"
    case iPadPro                    = "iOS-iPad-Pro"
    
    func description() -> String {
        var str = ""
        
        switch self{
        case .iUndefinedScreenShotType:
            str = "_Undefined"
        case .iPhone4:
            str = "iPhone 4, 4s"
        case .iPhone5:
            str = "iPhone 5, 5s"
        case .iPhone6:
            str = "iPhone 6, 6s"
        case .iPhone6Plus:
            str = "iPhone 6+, 6s+"
        case .iPad:
            str = "iPad"
        case .iPadPro:
            str = "iPad Pro"
        }
        
        return str
    }
    
}



class ScreenShot : NSObject {
    
    var thumb:NSImage = NSImage()
    
    private var _image:NSImage = NSImage()
    var image:NSImage! {
        set {
            _image = newValue
            
            fillCorrectSizes()
            fillCorrectScreenshotType()
            fillThumb()
        }
        get {return _image}
    }
    
    var path:String = ""
    var size:NSSize = NSMakeSize(0, 0)
    var md5:String = ""
    var name:String = "" {
        didSet {
            let matches = matchesForRegexInText("\\[.*\\]", text: name)
            if matches.count > 0 {
                langId = matches[0]
            } else {
                langId = NoLangID
            }
        }
    }
    var langId:String = ""
    var fileSize:Int = 0
    
    var screenType:ScreenShotType = .iUndefinedScreenShotType
    var nameForUpload:String {
        get {
            var temp = name as NSString
            temp = temp.stringByReplacingOccurrencesOfString("[", withString: "")
            temp = temp.stringByReplacingOccurrencesOfString("]", withString: "")
            temp = temp.stringByReplacingOccurrencesOfString(" ", withString: "_")
            return "\(screenType.rawValue)__\(temp)"
        }
    }
    
    //MARK: - _ -
    
    func fillThumb() {
        //        thumb = image
        thumb = image.resizeImage(size.width/5.0, size.height/5.0)
    }
    
    func fillCorrectSizes() {
        if image.representations.count > 0 {
            let rep:NSImageRep = image.representations[0]
            size = NSMakeSize(CGFloat(rep.pixelsWide), CGFloat(rep.pixelsHigh))
        }
    }
    
    func fillCorrectScreenshotType() {
        
        //https://developer.apple.com/library/ios/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Appendices/Properties.html#//apple_ref/doc/writerid/itc_screenshot_properties
        
        //3.5 -- 640 x 920, 640 x 960, 960 x 600, 960 x 640
        //4 -- 640 x 1096, 640 x 1136, 1136 x 600, 1136 x 640
        //4.7 -- 750 x 1334, 1334 x 750
        //5.5 -- 1242 x 2208 , 2208 x 1242
        //iPad  -- 1024 x 748, 1024 x 768, 2048 x 1496, 2048 x 1536, 768 x 1004, 768 x 1024, 1536 x 2008, 1536 x 2048
        //iPadPro -- 2732 x 2048, 2048 x 2732
        
        let w = size.width
        let h = size.height
        
        if (w == 640 && h == 920) ||
            (w == 640 && h == 960) ||
            (w == 960 && h == 600) ||
            (w == 960 && h == 640) {
                //3.5
                screenType = .iPhone4
        }
        
        if (w == 640 && h == 1096) ||
            (w == 640 && h == 1136) ||
            (w == 1136 && h == 600) ||
            (w == 1136 && h == 640) {
                //4
                screenType = .iPhone5
        }
        
        if (w == 750 && h == 1334) ||
            (w == 1334 && h == 750) {
                //4.7
                screenType = .iPhone6
        }
        
        if (w == 1242 && h == 2208) ||
            (w == 2208 && h == 1242) {
                //5.5
                screenType = .iPhone6Plus
        }
        
        if (w == 1024 && h == 748) ||
            (w == 1024 && h == 768) ||
            (w == 2048 && h == 1496) ||
            (w == 2048 && h == 1536) ||
            (w == 768 && h == 1004) ||
            (w == 768 && h == 1024) ||
            (w == 1536 && h == 2008) ||
            (w == 1536 && h == 2048) {
                //ipad
                screenType = .iPad
        }
        
        if (w == 2732 && h == 2048) ||
            (w == 2048 && h == 2732) {
                //ipad pro
                screenType = .iPadPro
        }
        
    }
    
    
    override var description: String {
        return "path: \(path), fileSize: \(fileSize) \n"
    }
    
}


