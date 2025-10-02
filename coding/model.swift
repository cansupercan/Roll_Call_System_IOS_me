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
    @Persisted(primaryKey: true) var userId: String = ""
    @Persisted var Name: String = ""
    @Persisted var createdAt = Date()
    @Persisted var active = true
    @Persisted var lastCheckInTime: Date? = nil
    
    // 關聯到此用戶的所有簽到記錄
    @Persisted var checkInRecords: List<CheckInRecord>
    
    convenience init(userId: String, name: String) {
        self.init()
        self.userId = userId
        self.Name = name
        self.active = true
    }
}

// 簽到記錄資料表
class CheckInRecord: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var checkInTime = Date()
    @Persisted var note: String? = nil
    
    // 建立與用戶的關聯
    @Persisted(originProperty: "checkInRecords") var user: LinkingObjects<User>
    
    convenience init(user: User, note: String? = nil) {
        self.init()
        // 將記錄添加到用戶的記錄列表中
        user.checkInRecords.append(self)
        self.note = note
    }
}
