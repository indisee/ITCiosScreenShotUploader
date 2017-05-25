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
    
    //MARK: -  -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - States -
    
    override var highlightState: NSCollectionViewItemHighlightState {
        didSet {
            if highlightState == .forSelection {
                self.view.layer?.borderColor = NSColor.lightGray.cgColor
                self.view.layer?.borderWidth = 2
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.view.layer?.borderColor = NSColor.gray.cgColor
                self.view.layer?.borderWidth = 2
            } else {
                self.view.layer?.borderWidth = 0
            }
        }
    }
    
    //MARK: - Open image actinos -
    
    override func mouseDown(with theEvent: NSEvent) {
        if theEvent.clickCount == 2 {
            openImage()
        } else {
            super.mouseDown(with: theEvent)
        }
    }
    
    func openImage() {
        if let image = representedObject as? ScreenShot {
            NSWorkspace.shared().openFile(image.path)
        }
    }
    
}
