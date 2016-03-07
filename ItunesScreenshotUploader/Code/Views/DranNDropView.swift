//
//  DranNDropView.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 20/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Cocoa
import Foundation

class DranNDropView: NSView {
    
    private let q = NSOperationQueue()
    
    internal private(set) var screenShotsList:[ScreenShot]?
    weak var delegate: FiniteTask?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerForDraggedTypes([NSFilenamesPboardType])
        
        setupUI()
    }
    
    func setupUI() {
        setBackGroundColor(NSColor.lightGrayColor())
    }
    
    func setBackGroundColor(color:NSColor) {
        let l = CALayer()
        l.backgroundColor = color.CGColor
        l.cornerRadius = 5
        self.wantsLayer = true
        self.layer = l
    }
    
    
    //MARK: - Dragging -
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        setBackGroundColor(NSColor.grayColor())
        
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()
        if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
            if sourceDragMask.rawValue & NSDragOperation.Generic.rawValue != 0 {
                return NSDragOperation.Generic
            }
        }
        return NSDragOperation.None
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        setBackGroundColor(NSColor.lightGrayColor())
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Generic
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        if sender.draggingSource() as? DranNDropView != self {

            q.cancelAllOperations()
            
            if let d = self.delegate {
                
                d.didStartTask(DropScreenShotsTask)
                self.setBackGroundColor(NSColor.lightGrayColor())

                let op = NSBlockOperation()
                
                op.addExecutionBlock { [unowned self, op] () -> Void in
                    
                    let pBoard = sender.draggingPasteboard()
                    if let pathes = pBoard.propertyListForType("NSFilenamesPboardType") as? [String] {
                        var screenshots = [ScreenShot]()
                        let screenshotsHandler = ScreenshotsHandler()
                        for path in pathes {
                            let s = screenshotsHandler.getAllScreenshotsFromDirectory(path)
                            screenshots += s
                        }
                        
                        if !op.cancelled {
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                self.screenShotsList = screenshots
                                d.didEndTask(DropScreenShotsTask)
                            })
                        }
                    }
                    
                }
                q.addOperation(op)
            }
        }
        
        return true
    }
    
}
