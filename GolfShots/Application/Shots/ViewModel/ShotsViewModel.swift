//
//  ShotsViewModel.swift
//  RapsodoAssignment
//
//  Created by Arda Yatman on 3.02.2022.
//

import Foundation
import RealmSwift

class ShotsViewModel {
    
    let realm = try! Realm()
    
    private var userData:List<UserData>?
    
    var shotCellViewModel:[ShotCellViewModel]? {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
   
    var numberOfRowsInSection:Int {
        return shotCellViewModel?.count ?? 0
    }
    
    var reloadTableViewClosure:(()->())?
    var alertClosure:((String)->())?
    var updateFetchingStatusClosure: (()->())?
    
    private var alertMessage:String? {
        didSet{
            alertClosure?(alertMessage!)
        }
    }
    
    func fetchShotsData() {
        
        guard let url = URL(string:"http://ec2-18-188-69-79.us-east-2.compute.amazonaws.com:3000/shots") else {
            fatalError("Wrong url")
        }
        
        let resource = Resource<InfoModel>(url: url)
        
        WebService.fetchData(resource: resource) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let _infoModel):
                
                if _infoModel.success! {
                    
                    self.userData = _infoModel.data
                    self.createShotCellViewModel(playerId: 1)
                    RealmHelper.saveDataToRealm(userdata: self.userData!)
                    
                }else {
                    self.alertMessage = "Response hatalı"
                }
            case.failure(let error):
                
                print(error)
                DispatchQueue.main.async {
                    RealmHelper.readDataFromRealm { [weak self] list in
                        
                        guard let self = self else { return }
                        guard let list = list, list.count > 0 else {
                            self.alertMessage = error.localizedDescription
                            return
                        }
                        self.userData = list
                        self.createShotCellViewModel(playerId: 1)
                        
                    }
                }
            }
        }
    }
    
    func createShotCellViewModel(playerId:Int) {
        
        guard let userData = self.userData else { return }
        
        let shots = userData[playerId - 1].shots
        var _shotCellViewModel = [ShotCellViewModel]()
        
        for shot in shots {
            
            let cellVM = ShotCellViewModel(xValue: "X : \(shot.shotPosX!)", yValue: "Y : \(shot.shotPosY!)", inOut: shot.inOut!, point: shot.point!, segment: shot.segment!,id:shot.id!, hasShotVideo: hasShotAssociatedWithVideo(shot: shot))
            
            _shotCellViewModel.append(cellVM)
        }
        
        shotCellViewModel = _shotCellViewModel
        
    }
    
    func getShotCellViewModel(at row:Int) -> ShotCellViewModel? {
    
        return shotCellViewModel?[row]
    }
    
    func hasShotAssociatedWithVideo(shot:Shot) -> Bool {
        
        FileManagerHelper.hasShotAssociatedWithAVideo(id: shot.id!)
    }
    
    func updateShotViewModel(id:String){
        
        guard let vm = shotCellViewModel?.firstIndex(where: { $0.id == id }) else { return }
        shotCellViewModel?[vm].hasShotVideo = true
        
    }
    
    func getShotViewModelWithShotId(id:String) -> ShotCellViewModel? {
        
        guard let vm = shotCellViewModel?.firstIndex(where: { $0.id == id }) else { return nil }
        return shotCellViewModel?[vm]
    }
}

struct ShotCellViewModel {
    
    var xValue:String
    var yValue:String
    var inOut:Bool
    var point:Int
    var segment:Int
    var id:String
    var hasShotVideo:Bool
    
}

struct UserViewModel {
    
    var name:String
    var surname:String
    
}
