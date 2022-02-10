//
//  VideoEditorHelper.swift
//  RapsodoAssignment
//
//  Created by Arda Yatman on 08.02.2022.
//
import UIKit
import AVFoundation

class VideoEditorHelper {
    
    let backgroundLayerVisibileWidth = 100.0
    
    func addWatermark(fromVideoAt videoURL: URL,shotVM:ShotCellViewModel, onComplete: @escaping (URL?) -> Void) {
        
        let asset = AVURLAsset(url: videoURL)
        let composition = AVMutableComposition()
        
        
        //Add a track to the composition and grab the video track from the asset
        guard
            let compositionTrack = composition.addMutableTrack(
                withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
            let assetTrack = asset.tracks(withMediaType: .video).first
        else {
            print("Something is wrong with the asset.")
            onComplete(nil)
            return
        }
        
        do {
            //  Specifies time ranges inside videos.
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            // Insert the whole video from the asset your composition’s video track.
            try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
            
            // Add a new audio track to your composition and then insert the asset’s audio into the track.
            if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(
                    timeRange,
                    of: audioAssetTrack,
                    at: .zero)
            }
        } catch {
            print(error)
            onComplete(nil)
            return
        }
        
        //Sizing and orientation of composition
        compositionTrack.preferredTransform = assetTrack.preferredTransform
        let videoInfo = orientation(from: assetTrack.preferredTransform)
        
        let videoSize: CGSize
        if videoInfo.isPortrait {
            videoSize = CGSize(
                width: assetTrack.naturalSize.height,
                height: assetTrack.naturalSize.width)
        } else {
            videoSize = assetTrack.naturalSize
        }
        
        let backgroundLayer = CAGradientLayer()
        backgroundLayer.frame = CGRect(origin: .zero, size: videoSize)
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        
        backgroundLayer.colors = [UIColor.darkGray.cgColor,UIColor.black.cgColor]
        backgroundLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        backgroundLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundLayer.locations = [0,1]
        backgroundLayer.backgroundColor = UIColor.yellow.cgColor
        videoLayer.frame = CGRect(x: videoLayer.frame.minX, y: 0, width: videoLayer.frame.width - backgroundLayerVisibileWidth, height: videoLayer.frame.height)
        overlayLayer.frame = videoLayer.frame
        createWaterMarkUI(backgroundLayer: backgroundLayer, videoSize: videoSize,shotVM: shotVM)
        
        let outputLayer = CALayer()
        outputLayer.frame = CGRect(origin: .zero, size: videoSize)
        outputLayer.addSublayer(backgroundLayer)
        outputLayer.addSublayer(videoLayer)
        outputLayer.addSublayer(overlayLayer)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: outputLayer)
        
        //Takes assembled output layer and the video layer and renders the video track into the video layer.
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(
            start: .zero,
            duration: composition.duration)
        videoComposition.instructions = [instruction]
        let layerInstruction = compositionLayerInstruction(
            for: compositionTrack,
               assetTrack: assetTrack)
        instruction.layerInstructions = [layerInstruction]
        
        //Export session to render the video to a file
        guard let export = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality)
        else {
            print("Cannot create export session.")
            onComplete(nil)
            return
        }
        
        //Create a file path and set up the export session
        let videoName = UUID().uuidString
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(videoName)
            .appendingPathExtension("mov")
        
        export.videoComposition = videoComposition
        export.outputFileType = .mov
        export.outputURL = exportURL
        
        export.exportAsynchronously {
            DispatchQueue.main.async {
                switch export.status {
                case .completed:
                    onComplete(exportURL)
                default:
                    print("Something went wrong during export.")
                    print(export.error ?? "unknown error")
                    onComplete(nil)
                    break
                }
            }
        }
    }
  
  //Returns the orientation – portrait or landscape – of the video
  private func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
    var assetOrientation = UIImage.Orientation.up
    var isPortrait = false
    if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
      assetOrientation = .right
      isPortrait = true
    } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
      assetOrientation = .left
      isPortrait = true
    } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
      assetOrientation = .up
    } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
      assetOrientation = .down
    }
    
    return (assetOrientation, isPortrait)
  }
  
  //Scale and rotate itself to match the original video’s size and orientation.
  private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
    let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    let transform = assetTrack.preferredTransform

    instruction.setTransform(transform, at: .zero)

    return instruction
  }
  
  private func add(text: String, to layer: CALayer, videoSize: CGSize, fontSize:CGFloat, layerFrame:CGRect) {
    
    let attributedText = NSAttributedString(
      string: text,
      attributes: [
        .font: UIFont(name: "ArialRoundedMTBold", size: fontSize) as Any,
        .foregroundColor: UIColor.white,])
    
    let textLayer = CATextLayer()
    textLayer.string = attributedText
    textLayer.shouldRasterize = true
    textLayer.rasterizationScale = UIScreen.main.scale
    textLayer.backgroundColor = UIColor.clear.cgColor
    textLayer.alignmentMode = .center
    
    
    textLayer.frame = layerFrame
    textLayer.displayIfNeeded()
    layer.addSublayer(textLayer)
    
  }

    func createWaterMarkUI(backgroundLayer:CALayer, videoSize:CGSize,shotVM:ShotCellViewModel) {
        
        let layerWidth = backgroundLayerVisibileWidth
        let itemWidth = 70.0
        let itemHeight = 60.0
        let xPoint = backgroundLayer.frame.width - layerWidth + ((layerWidth - itemWidth) / 2.0)
        let spacing = 17.0
        let valueFontSize = CGFloat(20)
        let descFontSize = CGFloat(10)
        var yPoint = backgroundLayer.frame.height - 100.0
        
        let labelTextList = ["\(shotVM.point)","POINT","\(shotVM.segment)","SEGMENT","\(shotVM.inOut)","INOUT",String(format: "%.2f", shotVM.xValue),"X POS.",String(format: "%.2f", shotVM.yValue),"Y POS."]
        
        for (index,text) in labelTextList.enumerated() {
            
            let fontSize = index % 2 == 0 ? valueFontSize : descFontSize

            let itemFrame = CGRect(x: xPoint, y: yPoint, width: itemWidth, height: itemHeight)
            add(text: text, to: backgroundLayer, videoSize: videoSize, fontSize: fontSize, layerFrame: itemFrame)

            yPoint -= ((index % 2 == 0 ? spacing : spacing * 2 ) + 15.0)
        }

    }
  
}
