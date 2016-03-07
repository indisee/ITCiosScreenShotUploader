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
    
    func screenShotLang(useLangs:Bool) -> String {
        var lang = useLangs ? (langId ?? NoLangID) : NoLangID
        if lang == "" {
            lang = NoLangID
        }
        return lang
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
        
        //to prevent misspelling
        let i640:CGFloat    = 640
        let i920:CGFloat    = 920
        let i960:CGFloat    = 960
        let i600:CGFloat    = 600
        let i1096:CGFloat   = 1096
        let i1136:CGFloat   = 1136
        let i750:CGFloat    = 750
        let i1334:CGFloat   = 1334
        let i1242:CGFloat   = 1242
        let i2208:CGFloat   = 2208
        let i1024:CGFloat   = 1024
        let i748:CGFloat    = 748
        let i768:CGFloat    = 768
        let i2048:CGFloat   = 2048
        let i1496:CGFloat   = 1496
        let i1536:CGFloat   = 1536
        let i1004:CGFloat   = 1004
        let i2008:CGFloat   = 2008
        let i2732:CGFloat   = 2732
        //        let <##>:CGFloat = <##>

        if (w == i640 && h == i920) ||
            (w == i640 && h == i960) ||
            (w == i960 && h == i600) ||
            (w == i960 && h == i640) {
                //3.5
                screenType = .iPhone4
        }
        
        if (w == i640 && h == i1096) ||
            (w == i640 && h == i1136) ||
            (w == i1136 && h == i600) ||
            (w == i1136 && h == i640) {
                //4
                screenType = .iPhone5
        }
        
        if (w == i750 && h == i1334) ||
            (w == i1334 && h == i750) {
                //4.7
                screenType = .iPhone6
        }
        
        if (w == i1242 && h == i2208) ||
            (w == i2208 && h == i1242) {
                //5.5
                screenType = .iPhone6Plus
        }
        
        if (w == i1024 && h == i748) ||
            (w == i1024 && h == i768) ||
            (w == i2048 && h == i1496) ||
            (w == i2048 && h == i1536) ||
            (w == i768 && h == i1004) ||
            (w == i768 && h == i1024) ||
            (w == i1536 && h == i2008) ||
            (w == i1536 && h == i2048) {
                //ipad
                screenType = .iPad
        }
        
        if (w == i2732 && h == i2048) ||
            (w == i2048 && h == i2732) {
                //ipad pro
                screenType = .iPadPro
        }
        
    }
    
    
    override var description: String {
        return "path: \(path), fileSize: \(fileSize) \n"
    }
    
}


