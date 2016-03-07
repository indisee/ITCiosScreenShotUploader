//
//  ScreenShotsListViewController.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 20/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Cocoa

class ScreenShotsListViewController: NSViewController {
    
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var selectLang: NSComboBox!
    @IBOutlet weak var backBtn: NSButton!
    @IBOutlet weak var statusLbl: NSTextField!
    @IBOutlet weak var segment: NSSegmentedControl!
    @IBOutlet weak var stabView: BlockView!
    @IBOutlet weak var stabSpinner: NSProgressIndicator!
    @IBOutlet weak var stabSpinner2: NSProgressIndicator!
    
    
    let redColor = NSColor(red: 240.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
    let greenColor = NSColor(red: 70.0/255.0, green: 160.0/255.0, blue: 100.0/255.0, alpha: 1)
    let blueColor = NSColor(red: 85.0/255.0, green: 130.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    
    private var uploadType:ScreenShotUploadingMode = ScreenShotUploadingMode.SameScreenShotUploadingMode {
        didSet {
            updateUIState()
        }
    }
    
    var draggingIndexPath:NSIndexPath?
    var segue: ReplaceSegue!
    
    //model
    var screenShotsList:[ScreenShot]!
    var model: [String:[[ScreenShot]]] = [String:[[ScreenShot]]]()
    var modelToShow: [[ScreenShot]] = [[ScreenShot]]()
    var allLanguages:[String] = [String]()
    var lang:String = NoLangID
    
    //handlers
    let itcHandler = ItunesConnectHandler.sharedInstance
    let screenshotsHandler = ScreenshotsHandler()
    let xmlMetaHandler = ITCMetaXMLHandler()
    
    
    
    override func viewDidLoad() {
        
        assert(screenShotsList != nil)
        assert(segue != nil)
        
        super.viewDidLoad()
        
        backBtn.target = self
        backBtn.action = Selector("back:")
        
        selectLang.delegate = self
        
        updateUIState()
        setupCollectionView()
        setupUI()
        
    }
    
    //MARK: - UI setup -
    
    private func setupUI() {
        setupStabView()
        setupSpinners()
        setupSegmentControll()
    }
    
    private func setupStabView() {
        let l = CALayer()
        l.backgroundColor = NSColor.darkGrayColor().CGColor
        l.opacity = 0.5
        
        stabView.wantsLayer = true
        stabView.layer = l
        stabView.hidden = true
    }
    
    private func setupSpinners() {
        stabSpinner2.hidden = true
        
        stabSpinner.startAnimation(nil)
        stabSpinner2.startAnimation(nil)
        
        stabSpinner.controlTint = NSControlTint.GraphiteControlTint
        stabSpinner2.controlTint = NSControlTint.GraphiteControlTint
    }
    
    private func setupSegmentControll() {
        segment.target = self
        segment.action = Selector("changeSegment:")
    }
    
    private func setupCollectionView() {
        collectionView.registerClass(ScreenShotCell.self, forItemWithIdentifier: ScreenShotCell.ID)
        collectionView.registerNib(NSNib(nibNamed: "ScreeenShotsHeader", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: NSCollectionElementKindSectionHeader, withIdentifier: ScreeenShotsHeader.ID)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.registerForDraggedTypes([NSURLPboardType])
        collectionView.setDraggingSourceOperationMask(NSDragOperation.Every, forLocal: true)
    }
    
    
    //MARK: - UI actions -
    
    private func  showLoading() {
        stabView.hidden = false
        stabSpinner2.hidden = false
    }
    
    private func hideLoading() {
        stabView.hidden = true
        stabSpinner2.hidden = true
    }
    
    private func fillStatusLbl(text:String, color:NSColor) {
        statusLbl.stringValue = text
        statusLbl.textColor = color
    }
    
    
    //MARK: - Actions helper-
    
    private func updateUIState() {
        generateModelForCollectionView()
        selectLang.hidden = (uploadType == .SameScreenShotUploadingMode)
    }
    
    private func changeSegment(sender:NSSegmentedControl) {
        uploadType = ScreenShotUploadingMode(rawValue: segment.selectedSegment)!
    }
    
    private func back(sender:AnyObject) {
        segue.pop()
    }
    
    private func showSettings() {
        self.performSegueWithIdentifier("ShowSettingsSegueId", sender: nil)
    }
    
    
    //MARK: - Actions ITC -
    
    @IBAction func validate(sender: AnyObject) {
        showLoading()
        
        self.fillStatusLbl("Validating...", color: blueColor)
        
        
        let r = itcHandler.verifyScreenshots { (status) -> Void in
            print("verifyScreenshots \(status)")
            
            if status == .SuccessStatus {
                self.fillStatusLbl("Validated. Ready to upload", color: self.greenColor)
            } else {
                self.fillStatusLbl("Not Valid", color: self.redColor)
            }
            self.hideLoading()
        }
        if !r {
            self.fillStatusLbl("Fill all settings", color: redColor)
            showSettings()
            hideLoading()
        }
    }
    
    @IBAction func upload(sender: AnyObject) {
        showLoading()
        
        self.fillStatusLbl("Uploading...", color: blueColor)
        
        let r = itcHandler.uploadScreenshots { (status) -> Void in
            print("uploadScreenshots \(status)")
            
            if status == .SuccessStatus {
                self.fillStatusLbl("Uploaded!", color: self.greenColor)
            } else {
                self.fillStatusLbl("Something went wrong", color: self.redColor)
            }
            self.hideLoading()
        }
        if !r {
            self.fillStatusLbl("Fill all settings", color: redColor)
            showSettings()
            self.hideLoading()
        }
    }
    
    @IBAction func getMeta(sender: AnyObject) {
        showLoading()
        
        self.fillStatusLbl("Getting Meta...", color: blueColor)
        
        let r = itcHandler.getMetaWithCallback { (status) -> Void in
            print("getMeta \(status)")
            
            if status == .SuccessStatus {
                self.screenshotsHandler.copyScreenShotsImagesToITMSP(Array(self.model.values))
                self.xmlMetaHandler.updateMetadataForScreenShots(self.model, uploadType:self.uploadType, callback: { (status) -> Void in
                    self.fillStatusLbl("Meta downloaded", color: self.greenColor)
                    self.hideLoading()
                })
            } else {
                self.fillStatusLbl("Meta failed", color: self.redColor)
                self.hideLoading()
            }
        }
        if !r {
            self.fillStatusLbl("Fill all settings", color: redColor)
            hideLoading()
            showSettings()
        }
    }
}


//MARK: - NSCollectionViewDataSource -


extension ScreenShotsListViewController : NSCollectionViewDataSource {
    
    func reloadData() {
        if let m = model[lang] {
            modelToShow = m
            collectionView.reloadData()
        } else {
            assert(false, "no data")
        }
    }
    
    func generateModelForCollectionView() {
        
        model = screenshotsHandler.convertRawScreenShotsToDataSet(screenShotsList, useLangs:(uploadType == .DiffScreenShotUploadingMode))
        
        allLanguages = Array(model.keys)
        allLanguages = allLanguages.sort()
        
        if allLanguages.count > 0 {
            lang = allLanguages.first!
            
            if uploadType == .DiffScreenShotUploadingMode {
                selectLang.removeAllItems()
                selectLang.addItemsWithObjectValues(allLanguages)
                selectLang.selectItemAtIndex(0)
            }
        }
        
        reloadData()
    }
    
    func itemForIndexPath(indexPath:NSIndexPath) -> ScreenShot {
        return modelToShow[indexPath.section][indexPath.item]
    }
    
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return modelToShow.count
    }
    
    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelToShow[section].count
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItemWithIdentifier(ScreenShotCell.ID, forIndexPath: indexPath)
        let screenShot = itemForIndexPath(indexPath)
        item.representedObject = screenShot
        return item
    }
    
    func collectionView(collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> NSView {
        if kind == NSCollectionElementKindSectionHeader {
            let view = collectionView.makeSupplementaryViewOfKind(kind, withIdentifier: ScreeenShotsHeader.ID, forIndexPath: indexPath) as? ScreeenShotsHeader
            if view?.headerLbl != nil {
                let itemName = itemForIndexPath(indexPath).screenType.description()
                view?.headerLbl.stringValue = itemName
            }
            return view!
        }
        return NSView()
    }
}


//MARK: - NSCollectionViewDelegate -

extension ScreenShotsListViewController : NSCollectionViewDelegate {
    
    func collectionView(collectionView: NSCollectionView, canDragItemsAtIndexPaths indexPaths: Set<NSIndexPath>, withEvent event: NSEvent) -> Bool {
        draggingIndexPath = indexPaths.first
        return true
    }
    
    func collectionView(collectionView: NSCollectionView, pasteboardWriterForItemAtIndexPath indexPath: NSIndexPath) -> NSPasteboardWriting? {
        let screenShot = itemForIndexPath(indexPath)
        let url = NSURL(fileURLWithPath: screenShot.path)
        return url
    }
    
    func collectionView(collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath?>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        return .Move
    }
    
    func collectionView(collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: NSIndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        
        let temp = modelToShow[draggingIndexPath!.section][draggingIndexPath!.item]
        
        var section = modelToShow[draggingIndexPath!.section]
        section.removeAtIndex(draggingIndexPath!.item)
        section.insert(temp, atIndex: indexPath.item)
        
        modelToShow[draggingIndexPath!.section] = section
        model[lang] = modelToShow
        
        collectionView.animator().moveItemAtIndexPath(draggingIndexPath!, toIndexPath: indexPath)
        
        return true
    }
}


//MARK: - NSComboBoxDelegate -

extension ScreenShotsListViewController : NSComboBoxDelegate {
    
    func comboBoxSelectionDidChange(notification: NSNotification) {
        if selectLang.objectValues.count > 0{
            lang = selectLang.objectValues[selectLang.indexOfSelectedItem] as! String
            reloadData()
        }
    }
    
}