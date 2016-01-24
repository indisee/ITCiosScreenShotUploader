//
//  HelperFunctions.swift
//  ItunesScreenshotUploader
//
//  Created by iN on 24/01/16.
//  Copyright © 2016 2tickets2dublin. All rights reserved.
//

import Foundation

func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text,
            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substringWithRange($0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}


func md5(path:String) -> String {
    let task = NSTask()
    task.launchPath = "/sbin/md5"
    task.arguments = [path]
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
    let md5 = output.componentsSeparatedByString(" ").last!
    return md5
}
