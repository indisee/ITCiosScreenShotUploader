//
//  Protocols.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 20/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Foundation



protocol FiniteTask : class {
    func didStartTask(_ taskKey:String)
    func didEndTask(_ taskKey:String)
}
