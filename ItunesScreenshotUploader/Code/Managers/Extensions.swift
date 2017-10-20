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
    var imageRepresentation: Data {
        return NSBitmapImageRep(data: tiffRepresentation!)!.representation(using: .PNG, properties: [:])!
    }
    func savePNG(_ path:String) -> Bool {
        return ((try? imageRepresentation.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil)
    }
}

extension NSImage {
    func resizeImage(_ width: CGFloat, _ height: CGFloat) -> NSImage {
        let img = NSImage(size: CGSize(width: width, height: height))
        
        img.lockFocus()
        let ctx = NSGraphicsContext.current()
        ctx?.imageInterpolation = .high
        self.draw(in: NSMakeRect(0, 0, width, height), from: NSMakeRect(0, 0, size.width, size.height), operation: .copy, fraction: 1)
        img.unlockFocus()
        
        return img
    }
}
