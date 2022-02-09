//
//  ShotTableViewCell.swift
//  RapsodoAssignment
//
//  Created by Arda Yatman on 3.02.2022.
//

import UIKit

protocol ShotTableViewCellDelegate:AnyObject {
    func videoButtonTapped(with id:String)
}
class ShotTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var xValueLabel: UILabel!
    @IBOutlet weak var yValueLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var playRecordButton: UIButton!
    
    weak var delegate:ShotTableViewCellDelegate?
    static let id = String(describing: ShotTableViewCell.self)
    
    var shotId:String?
    
    static func createNib() -> UINib {
        return UINib(nibName: id, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupInitialUI()
        
    }
    
    func setupInitialUI() {
        
        selectionStyle = .none
        
        playRecordButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
        playRecordButton.tintColor = .black
        

        rightView.layer.shadowOpacity = 0.5
        rightView.layer.shadowColor = UIColor.black.cgColor
        rightView.layer.shadowOffset = CGSize(width: -2.0, height: 1.0)
        rightView.layer.shadowRadius = 3.0
        
    }
    
    func configure(with vm:ShotCellViewModel?) {
        
        guard let vm = vm else { return }
        
        self.xValueLabel.text = vm.xValue
        self.yValueLabel.text = vm.yValue
        self.statusImageView.image = vm.inOut ? (UIImage(named: "check")) : UIImage(named: "wrong")
     
        let playImage = UIImage(systemName: "play.circle")?.resizeImage(targetSize: CGSize(width: 35, height: 35))?.withTintColor(.green)
        let recordImage = UIImage(systemName: "record.circle")?.resizeImage(targetSize: CGSize(width: 35, height: 35))?.withTintColor(.systemRed)
        self.playRecordButton.setImage(vm.hasShotVideo ? playImage : recordImage, for: .normal)
        
        shotId = vm.id
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func playRecordButtonTapped(_ sender: Any) {
        
        delegate?.videoButtonTapped(with: shotId!)
        
    }
    
    
}
