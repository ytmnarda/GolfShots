//
//  FileManagerHelper.swift
//  RapsodoAssignment
//
//  Created by Arda Yatman on 6.02.2022.
//

import UIKit
import MobileCoreServices
import AVKit

enum MediaExtension:String {
    case video = ".mov"
    case file = ".txt"
}

class FileManagerHelper {
    
    static func hasShotAssociatedWithAVideo(id:String) -> Bool{
        
        let suffix = id + MediaExtension.video.rawValue
        let pathComponent = documentsDirectoryURL.appendingPathComponent(suffix)
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: filePath) ? true : false
        
    }
    
    static func moveItem(at:URL,to:URL) {
        
        do {
            try FileManager.default.moveItem(at: at, to: to)
            print("movie saved")
        } catch {
            print(error)
        }
    }
    
}
