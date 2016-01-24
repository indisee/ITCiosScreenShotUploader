//
//  Segues.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 20/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Foundation
import Cocoa

class ReplaceSegue: NSStoryboardSegue {
    override func perform() {

        if let fromViewController = sourceController as? NSViewController {
            if let toViewController = destinationController as? NSViewController {

                toViewController.view.frame = fromViewController.view.frame
                fromViewController.view.window?.contentViewController = toViewController
                
            }
        }
    }
    
    func pop() {
        if let fromViewController = sourceController as? NSViewController {
            if let toViewController = destinationController as? NSViewController {
                
                fromViewController.view.frame = toViewController.view.frame
                toViewController.view.window?.contentViewController = fromViewController
                
            }
        }
    }
}

