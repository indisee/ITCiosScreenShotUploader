//
//  ScreenShotCell.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 21/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Cocoa

class ScreenShotCell: NSCollectionViewItem {
    
    static let ID = "ScreenShotCellID"
    override var highlightState: NSCollectionViewItemHighlightState {
        didSet {
            if highlightState == .ForSelection {
                self.view.layer?.borderColor = NSColor.lightGrayColor().CGColor
                self.view.layer?.borderWidth = 2
            }
        }
    }
    
    override var selected: Bool {
        didSet {
            if selected {
                self.view.layer?.borderColor = NSColor.grayColor().CGColor
                self.view.layer?.borderWidth = 2
            } else {
                self.view.layer?.borderWidth = 0
            }
        }
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if theEvent.clickCount == 2 {
                openImage()
            } else {
                super.mouseDown(theEvent)
        }
    }
    
    func openImage() {
                    if let image = representedObject as? ScreenShot {
            NSWorkspace.sharedWorkspace().openFile(image.path)
                    }
    }
    
}
