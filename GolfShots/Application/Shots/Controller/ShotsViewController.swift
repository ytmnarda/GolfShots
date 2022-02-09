//
//  ShotsViewController.swift
//  RapsodoAssignment
//
//  Created by Arda Yatman on 5.02.2022.
//

import UIKit
import MobileCoreServices
import AVKit

class ShotsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    private let editor = VideoEditorHelper()
    
    let shotsViewModel = ShotsViewModel()
    let manager = FileManager.default   
    var lastShotId:String?
    var isListForPlayerOne = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ShotTableViewCell.createNib(), forCellReuseIdentifier: ShotTableViewCell.id)
        
        setupUI()
        initViewModel()
        
    }
    
    func setupUI() {
        
        navigationController?.navigationBar.isTranslucent = true
        title = "PLAYER 1"
        
    }
    
    func initViewModel() {
        
        shotsViewModel.fetchShotsData()
        
        shotsViewModel.reloadTableViewClosure = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        shotsViewModel.alertClosure = { [weak self] message in
            guard let self = self else { return }
            self.showAlert(message: message)
        }
    }
    
    @IBAction func rightBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        isListForPlayerOne = !isListForPlayerOne
        shotsViewModel.createShotCellViewModel(playerId: isListForPlayerOne ? 1 : 2)
        title = isListForPlayerOne ? "PLAYER 1" : "PLAYER 2"
        rightBarButtonItem.title = isListForPlayerOne ? "PLAYER 2" : "PLAYER 1"
        
    }
}

//MARK: - UITableViewDelegate
extension ShotsViewController:UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource
extension ShotsViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shotsViewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ShotTableViewCell.id, for: indexPath) as! ShotTableViewCell
        let cellVM = shotsViewModel.getShotCellViewModel(at: indexPath.row)
        cell.delegate = self
        cell.configure(with: cellVM)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
}

//MARK: - ShotTableViewCellDelegate
extension ShotsViewController: ShotTableViewCellDelegate {
    
    func videoButtonTapped(with id:String) {
        
        lastShotId = id
        
        if FileManagerHelper.hasShotAssociatedWithAVideo(id: lastShotId!) {
            
            //Play Video
            let playerVC = VideoPlayerHelper.createVideoPlayer(with: lastShotId!)
            self.present(playerVC, animated: true) {
                playerVC.player!.play()
            }
            
        } else {
            
            //Record Video
            VideoPlayerHelper.startMediaBrowser(delegate: self, sourceType: .camera)
            
        }
    }
}

//MARK: - UIImagePickerControllerDelegate
extension ShotsViewController:UIImagePickerControllerDelegate {
    
    func imagePickerController( _ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String), let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
        
        dismiss(animated: true) { [self] in
            
            guard let lastShotId = self.lastShotId else { return }
            guard let shotVM = self.shotsViewModel.getShotViewModelWithShotId(id: lastShotId) else { return }
            
            self.editor.addWatermark(fromVideoAt: url,shotVM:shotVM) { [weak self] exportedURL in
                guard let self = self else { return }
                guard let exportedURL = exportedURL else { return }
                
                let suffix = self.lastShotId! + MediaExtension.video.rawValue
                FileManagerHelper.moveItem(at: exportedURL, to: documentsDirectoryURL.appendingPathComponent(suffix))
                
                self.shotsViewModel.updateShotViewModel(id: self.lastShotId!)
                
            }
        }
    }
}

//MARK: - UINavigationControllerDelegate
extension ShotsViewController:UINavigationControllerDelegate {
    
}

