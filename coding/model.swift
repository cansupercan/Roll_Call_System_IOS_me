//
//  model.swift
//  coding
//
//  Created by imac-3888 on 2025/9/19.
//

import Foundation
import RealmSwift

// 使用者資訊資料表
class User: Object {
    @objc dynamic var userId: String = ""
    @objc dynamic var Name: String = ""
    //@objc dynamic var end_at: Date? = nil
    @objc dynamic var createdAt = Date()
    @objc dynamic var active = true
    @objc dynamic var lastCheckInTime: Date? = nil
    
    convenience init(userId: String, name: String) {
        self.init()
        self.userId = userId
        self.Name = name
        self.active = true
    }
    
  
}

// 簽到記錄資料表
class CheckInRecord: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var checkInTime = Date()
    @objc dynamic var note: String? = nil
    @objc dynamic var userId: String = ""
    
    convenience init(userId: String, note: String? = nil) {
        self.init()
        self.userId = userId
        self.note = note
    }
    
   
}
