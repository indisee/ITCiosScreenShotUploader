//
//  ScreeenShotsHeader.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 22/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Cocoa

class ScreeenShotsHeader: NSView {
    
    static let ID = "ScreeenShotsHeaderID"

    @IBOutlet weak var headerLbl: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.setFill()
        NSRectFill(dirtyRect)
        super.draw(dirtyRect)
    }
    
}
