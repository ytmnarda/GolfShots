//
//  VideoPlayerHelper.swift
//  RapsodoAssignment
//
//  Created by Arda Yatman on 9.02.2022.
//

import UIKit
import MobileCoreServices
import AVKit

class VideoPlayerHelper {
    
    static func startMediaBrowser(
      delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate,
      sourceType: UIImagePickerController.SourceType
    ) {
      guard UIImagePickerController.isSourceTypeAvailable(sourceType)
        else { return }

      let mediaUI = UIImagePickerController()
      mediaUI.sourceType = sourceType
      mediaUI.mediaTypes = [kUTTypeMovie as String]
      mediaUI.allowsEditing = true
      mediaUI.delegate = delegate
      delegate.present(mediaUI, animated: true, completion: nil)
    }
    
    static func createVideoPlayer(with id:String) -> AVPlayerViewController{
        
        let suffix = id + MediaExtension.video.rawValue
        let filePath = documentsDirectoryURL.appendingPathComponent(suffix)
        let player = AVPlayer(url: filePath)  // video path coming from above function
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        return playerViewController
        
    }
    
}

