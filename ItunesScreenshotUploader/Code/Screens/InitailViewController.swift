//
//  ViewController.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 19/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Cocoa

enum ScreenShotUploadingMode : Int {
    case sameScreenShotUploadingMode = 0
    case diffScreenShotUploadingMode
}

class InitailViewController: NSViewController {
    
    @IBOutlet weak var dragNDropView: DranNDropView!
    @IBOutlet weak var screenInfoLbl: NSTextField!
    @IBOutlet weak var notion: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    fileprivate func setupUI() {
        spinner.isHidden = true
        dragNDropView.delegate = self
    }
    
    
    //MARK: - Go next -
    
    func goToScreenshotsList() {
        self.performSegue(withIdentifier: "ScreenShotsListViewControllerSegueID", sender: self)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let destination:ScreenShotsListViewController = segue.destinationController as! ScreenShotsListViewController
        destination.screenShotsList = dragNDropView.screenShotsList
        destination.segue = segue as? ReplaceSegue
    }
}


//MARK: - FiniteTask -

extension InitailViewController : FiniteTask {
    
    func didEndTask(_ taskKey:String) {
        if taskKey == DropScreenShotsTask {
            notion.isHidden = false
            screenInfoLbl.isHidden = false
            spinner.isHidden = true
            goToScreenshotsList()
        }
    }
    
    func didStartTask(_ taskKey:String) {
        if taskKey == DropScreenShotsTask {
            notion.isHidden = true
            screenInfoLbl.isHidden = true
            spinner.isHidden = false
            spinner.startAnimation(nil)
        }
    }
    
}
