//
//  RealmHelper.swift
//  RapsodoAssignment
//
//  Created by Arda Yatman on 8.02.2022.
//

import Foundation
import RealmSwift

class RealmHelper {
    
    static let realm = try! Realm()
    
    static func saveDataToRealm(userdata:List<UserData>) {
        
        DispatchQueue.main.async {
            try! self.realm.write {
                self.realm.deleteAll()
            }
    
            do {
                try self.realm.write({
                    self.realm.add(userdata)
                })
            }catch {
                print(error)
            }
        }
    }
    
    static func readDataFromRealm( completion:@escaping (List<UserData>?)->()) {
        DispatchQueue.main.async {
            
            let results = self.realm.objects(UserData.self)
            let userDataList = results.reduce(List<UserData>()) { (list, element) -> List<UserData> in
                list.append(element)
                return list
            }
            completion(userDataList)
        }
    }
    
}
