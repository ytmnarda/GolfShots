//
//  InfoModel.swift
//  RapsodoAssignment
//
//  Created by Arda Yatman on 3.02.2022.
//

import Foundation
import RealmSwift

//// MARK: - InfoModel
class InfoModel:Object, Codable {
    @Persisted var success: Bool?
    @Persisted var data = List<UserData>()
}

// MARK: - UserData
class UserData:Object, Codable {
    @Persisted var user: User?
    @Persisted var shots = List<Shot>()
}

// MARK: - Shot
class Shot:Object, Codable {
    @Persisted var point:Int?
    @Persisted var segment: Int?
    @Persisted var id: String?
    @Persisted var inOut: Bool?
    @Persisted var shotPosX: Double?
    @Persisted var shotPosY: Double?
    
    enum CodingKeys: String, CodingKey {
        case point, segment
        case id = "_id"
        case inOut = "InOut"
        case shotPosX = "ShotPosX"
        case shotPosY = "ShotPosY"
    }
}

// MARK: - User
class User:Object, Codable {
    @Persisted var name:String?
    @Persisted var surname: String?
}
