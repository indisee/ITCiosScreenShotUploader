//
//  ViewController.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 19/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Cocoa

enum ScreenShotUploadingMode : Int {
    case SameScreenShotUploadingMode = 0
    case DiffScreenShotUploadingMode
}

class ViewController: NSViewController, FiniteTask {
    
    @IBOutlet weak var dragNDropView: DranNDropView!
    @IBOutlet weak var screenInfoLbl: NSTextField!
    @IBOutlet weak var notion: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.hidden = true
        dragNDropView.delegate = self
    }
    
    func goToScreenshotsList() {
        self.performSegueWithIdentifier("ScreenShotsListViewControllerSegueID", sender: self)
    }
    
    func didEndTask(taskKey:String) {
        if taskKey == DropScreenShotsTask {
            notion.hidden = false
            screenInfoLbl.hidden = false
            spinner.hidden = true
            goToScreenshotsList()
        }
    }
    
    func didStartTask(taskKey:String) {
        if taskKey == DropScreenShotsTask {
            notion.hidden = true
            screenInfoLbl.hidden = true
            spinner.hidden = false
            spinner.startAnimation(nil)
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        let destination:ScreenShotsListViewController = segue.destinationController as! ScreenShotsListViewController
        destination.screenShotsList = dragNDropView.screenShotsList
        destination.segue = segue as? ReplaceSegue
    }
}
