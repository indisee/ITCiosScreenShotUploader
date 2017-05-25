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
    
    fileprivate let q = OperationQueue()
    
    internal fileprivate(set) var screenShotsList:[ScreenShot]?
    weak var delegate: FiniteTask?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        register(forDraggedTypes: [NSFilenamesPboardType])
        
        setupUI()
    }
    
    func setupUI() {
        setBackGroundColor(NSColor.lightGray)
    }
    
    func setBackGroundColor(_ color:NSColor) {
        let l = CALayer()
        l.backgroundColor = color.cgColor
        l.cornerRadius = 5
        self.wantsLayer = true
        self.layer = l
    }
    
    
    //MARK: - Dragging -
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        setBackGroundColor(NSColor.gray)
        
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()
        if pboard.availableType(from: [NSFilenamesPboardType]) == NSFilenamesPboardType {
            if sourceDragMask.rawValue & NSDragOperation.generic.rawValue != 0 {
                return NSDragOperation.generic
            }
        }
        return NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        setBackGroundColor(NSColor.lightGray)
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.generic
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        if sender.draggingSource() as? DranNDropView != self {

            q.cancelAllOperations()
            
            if let d = self.delegate {
                
                d.didStartTask(DropScreenShotsTask)
                self.setBackGroundColor(NSColor.lightGray)

                let op = BlockOperation()
                
                op.addExecutionBlock { [unowned self, op] () -> Void in
                    
                    let pBoard = sender.draggingPasteboard()
                    if let pathes = pBoard.propertyList(forType: "NSFilenamesPboardType") as? [String] {
                        var screenshots = [ScreenShot]()
                        let screenshotsHandler = ScreenshotsHandler()
                        for path in pathes {
                            let s = screenshotsHandler.getAllScreenshotsFromDirectory(path)
                            screenshots += s
                        }
                        
                        if !op.isCancelled {
                            OperationQueue.main.addOperation({ () -> Void in
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
