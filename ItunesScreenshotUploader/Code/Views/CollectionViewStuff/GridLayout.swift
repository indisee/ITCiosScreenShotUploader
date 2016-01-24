//
//  GridLayout.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 22/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Cocoa

class GridLayout: NSCollectionViewFlowLayout {

    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        setup()
    }
    
    func setup() {
        itemSize = NSMakeSize(200, 200)
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
        headerReferenceSize = NSMakeSize(10000, 30)
    }
}
