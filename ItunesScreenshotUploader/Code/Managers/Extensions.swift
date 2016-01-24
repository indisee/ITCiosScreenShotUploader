//
//  Extensions.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 20/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {
    var imageRepresentation: NSData {
        return NSBitmapImageRep(data: TIFFRepresentation!)!.representationUsingType(.NSPNGFileType, properties: [:])!
    }
    func savePNG(path:String) -> Bool {
        return imageRepresentation.writeToFile(path, atomically: true)
    }
}

extension NSImage {
    func resizeImage(width: CGFloat, _ height: CGFloat) -> NSImage {
        let img = NSImage(size: CGSizeMake(width, height))
        
        img.lockFocus()
        let ctx = NSGraphicsContext.currentContext()
        ctx?.imageInterpolation = .High
        self.drawInRect(NSMakeRect(0, 0, width, height), fromRect: NSMakeRect(0, 0, size.width, size.height), operation: .CompositeCopy, fraction: 1)
        img.unlockFocus()
        
        return img
    }
}
