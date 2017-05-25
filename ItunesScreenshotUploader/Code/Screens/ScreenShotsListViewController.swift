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
    
    
    fileprivate var uploadType:ScreenShotUploadingMode = ScreenShotUploadingMode.sameScreenShotUploadingMode {
        didSet {
            updateUIState()
        }
    }
    
    var draggingIndexPath:IndexPath?
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
        backBtn.action = #selector(ScreenShotsListViewController.back(_:))
        
        selectLang.delegate = self
        
        updateUIState()
        setupCollectionView()
        setupUI()
        
    }
    
    //MARK: - UI setup -
    
    fileprivate func setupUI() {
        setupStabView()
        setupSpinners()
        setupSegmentControll()
    }
    
    fileprivate func setupStabView() {
        let l = CALayer()
        l.backgroundColor = NSColor.darkGray.cgColor
        l.opacity = 0.5
        
        stabView.wantsLayer = true
        stabView.layer = l
        stabView.isHidden = true
    }
    
    fileprivate func setupSpinners() {
        stabSpinner2.isHidden = true
        
        stabSpinner.startAnimation(nil)
        stabSpinner2.startAnimation(nil)
        
        stabSpinner.controlTint = NSControlTint.graphiteControlTint
        stabSpinner2.controlTint = NSControlTint.graphiteControlTint
    }
    
    fileprivate func setupSegmentControll() {
        segment.target = self
        segment.action = #selector(ScreenShotsListViewController.changeSegment(_:))
    }
    
    fileprivate func setupCollectionView() {
        collectionView.register(ScreenShotCell.self, forItemWithIdentifier: ScreenShotCell.ID)
        collectionView.register(NSNib(nibNamed: "ScreeenShotsHeader", bundle: Bundle.main), forSupplementaryViewOfKind: NSCollectionElementKindSectionHeader, withIdentifier: ScreeenShotsHeader.ID)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(forDraggedTypes: [NSURLPboardType])
        collectionView.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: true)
    }
    
    
    //MARK: - UI actions -
    
    fileprivate func  showLoading() {
        stabView.isHidden = false
        stabSpinner2.isHidden = false
    }
    
    fileprivate func hideLoading() {
        stabView.isHidden = true
        stabSpinner2.isHidden = true
    }
    
    fileprivate func fillStatusLbl(_ text:String, color:NSColor) {
        statusLbl.stringValue = text
        statusLbl.textColor = color
    }
    
    
    //MARK: - Actions helper-
    
    fileprivate func updateUIState() {
        generateModelForCollectionView()
        selectLang.isHidden = (uploadType == .sameScreenShotUploadingMode)
    }
    
    func changeSegment(_ sender:NSSegmentedControl) {
        uploadType = ScreenShotUploadingMode(rawValue: segment.selectedSegment)!
    }
    
    func back(_ sender:AnyObject) {
        segue.pop()
    }
    
    fileprivate func showSettings() {
        self.performSegue(withIdentifier: "ShowSettingsSegueId", sender: nil)
    }
    
    
    //MARK: - Actions ITC -
    
    @IBAction func validate(_ sender: AnyObject) {
        showLoading()
        
        self.fillStatusLbl("Validating...", color: blueColor)
        
        
        let r = itcHandler.verifyScreenshots { (status) -> Void in
            print("verifyScreenshots \(status)")
            
            if status == .successStatus {
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
    
    @IBAction func upload(_ sender: AnyObject) {
        showLoading()
        
        self.fillStatusLbl("Uploading...", color: blueColor)
        
        let r = itcHandler.uploadScreenshots { (status) -> Void in
            print("uploadScreenshots \(status)")
            
            if status == .successStatus {
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
    
    @IBAction func getMeta(_ sender: AnyObject) {
        showLoading()
        
        self.fillStatusLbl("Getting Meta...", color: blueColor)
        
        let r = itcHandler.getMetaWithCallback { [unowned self] (status) -> Void in
            print("getMeta \(status)")
            
            if status == .successStatus {
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
        
        model = screenshotsHandler.convertRawScreenShotsToDataSet(screenShotsList, useLangs:(uploadType == .diffScreenShotUploadingMode))
        
        allLanguages = Array(model.keys)
        allLanguages = allLanguages.sorted()
        
        if allLanguages.count > 0 {
            lang = allLanguages.first!
            
            if uploadType == .diffScreenShotUploadingMode {
                selectLang.removeAllItems()
                selectLang.addItems(withObjectValues: allLanguages)
                selectLang.selectItem(at: 0)
            }
        }
        
        reloadData()
    }
    
    func itemForIndexPath(_ indexPath:IndexPath) -> ScreenShot {
        return modelToShow[indexPath.section][indexPath.item]
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return modelToShow.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelToShow[section].count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: ScreenShotCell.ID, for: indexPath)
        let screenShot = itemForIndexPath(indexPath)
        item.representedObject = screenShot
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
        if kind == NSCollectionElementKindSectionHeader {
            let view = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: ScreeenShotsHeader.ID, for: indexPath) as? ScreeenShotsHeader
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
    
    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        draggingIndexPath = indexPaths.first
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        let screenShot = itemForIndexPath(indexPath)
        let url = URL(fileURLWithPath: screenShot.path)
        return url as NSPasteboardWriting?
    }
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<IndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        return .move
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        
        let temp = modelToShow[draggingIndexPath!.section][draggingIndexPath!.item]
        
        var section = modelToShow[draggingIndexPath!.section]
        section.remove(at: draggingIndexPath!.item)
        section.insert(temp, at: indexPath.item)
        
        modelToShow[draggingIndexPath!.section] = section
        model[lang] = modelToShow
        
        collectionView.animator().moveItem(at: draggingIndexPath!, to: indexPath)
        
        return true
    }
}


//MARK: - NSComboBoxDelegate -

extension ScreenShotsListViewController : NSComboBoxDelegate {
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if selectLang.objectValues.count > 0{
            lang = selectLang.objectValues[selectLang.indexOfSelectedItem] as! String
            reloadData()
        }
    }
    
}
