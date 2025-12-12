# 簽到系統 (Roll Call System) - iOS App

## 📋 項目概述

這是一個基於 iOS 平台開發的**簽到管理系統**，旨在為組織、教育機構或企業提供便捷的人員簽到記錄功能。系統採用 **Swift** 和 **Realm 資料庫** 構建，提供了完整的人員管理和簽到記錄追蹤能力。

## 🎯 核心功能

### 1. 人員管理
- ✅ **新增使用者** - 通過輸入使用者 ID 和姓名快速添加新人員
- ✅ **查看人員列表** - 展示所有已註冊的使用者信息
- ✅ **用戶狀態管理** - 支持啟用/停用使用者（軟刪除）
- ✅ **用戶詳細資訊** - 查看每個使用者的完整資訊

### 2. 簽到功能
- ✅ **實時簽到** - 點擊人員快速進行簽到操作
- ✅ **簽到驗證** - 防止重複簽到（12 小時內限制）
- ✅ **備註功能** - 為簽到記錄添加備註說明
- ✅ **時間追蹤** - 自動記錄簽到時間和最後簽到時間

### 3. 簽到記錄管理
- ✅ **查看簽到記錄** - 瀏覽所有簽到記錄
- ✅ **篩選功能** - 按人員篩選特定使用者的簽到記錄
- ✅ **刪除記錄** - 支持刪除不必要的簽到記錄
- ✅ **記錄詳情** - 查看每條簽到記錄的完整信息

### 4. 數據導出
- ✅ **匯出人員資料** - 將人員資訊導出為 CSV 格式
- ✅ **匯出簽到記錄** - 將簽到記錄導出為 CSV 格式
- ✅ **文件分享** - 支持通過分享功能發送導出的文件

## 📱 用戶界面

### 主視圖 (MainViewController)
- **實時時鐘** - 頂部顯示當前日期時間（每秒更新）
- **人員列表** - 中央表格展示所有使用者
- **操作按鈕** - 上方導航欄提供新增使用者和查看記錄功能
- **匯出按鈕** - 底部提供數據匯出選項

### 記錄視圖 (listViewController)
- **模式切換** - 在人員列表和簽到記錄之間切換
- **人員篩選** - 使用 Picker View 選擇要查看的人員
- **詳細列表** - 表格顯示相應的數據
- **編輯功能** - 支持左滑刪除操作

## 🗄️ 數據模型

### User (使用者資訊表)
```swift
class User: Object {
    @Persisted(primaryKey: true) var userId: String          // 用戶唯一ID
    @Persisted var Name: String                              // 姓名
    @Persisted var createdAt = Date()                        // 創建時間
    @Persisted var active = true                             // 活動狀態
    @Persisted var lastCheckInTime: Date? = nil              // 最後簽到時間
    @Persisted var checkInRecords: List<CheckInRecord>       // 關聯的簽到記錄
}
```

### CheckInRecord (簽到記錄表)
```swift
class CheckInRecord: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString  // 記錄唯一ID
    @Persisted var checkInTime = Date()                      // 簽到時間
    @Persisted var note: String? = nil                       // 備註
    @Persisted(originProperty: "checkInRecords") 
    var user: LinkingObjects<User>                           // 關聯的使用者
}
```

### 數據關係
- **一對多關係**：一個 User 對應多個 CheckInRecord
- **反向關聯**：CheckInRecord 通過 LinkingObjects 關聯到 User
- **級聯刪除**：刪除 User 時自動刪除其所有簽到記錄

## 🛠️ 技術棧

| 技術 | 版本/說明 |
|------|---------|
| **語言** | Swift |
| **數據庫** | Realm Swift |
| **UI Framework** | UIKit |
| **最低部署** | iOS 13.0+ |
| **開發工具** | Xcode |

## 📦 項目結構

```
coding/
├── Model層
│   └── model.swift              # 數據模型 (User, CheckInRecord)
├── 視圖控制器
│   ├── MainViewController.swift  # 主視圖 (人員管理和簽到)
│   ├── MainViewController.xib    # 主視圖界面配置
│   ├── listViewController.swift  # 記錄視圖 (簽到記錄查看)
│   └── listViewController.xib    # 記錄視圖界面配置
├── 應用委托
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── 資源
│   ├── Assets.xcassets/
│   └── Info.plist
└── UI配置
    └── Base.lproj/LaunchScreen.storyboard
```

## 🚀 主要功能流程

### 簽到流程
1. 用戶在主視圖選擇要簽到的人員
2. 點擊該人員行
3. 彈出簽到確認對話框
4. 可選：輸入簽到備註
5. 確認簽到
6. 系統驗證最後簽到時間（防止 12 小時內重複簽到）
7. 簽到記錄寫入 Realm 資料庫
8. 更新用戶的 `lastCheckInTime`
9. 表格刷新展示最新數據

### 數據導出流程
1. 用戶點擊匯出按鈕
2. 系統從 Realm 資料庫讀取數據
3. 將數據轉換為 CSV 格式
4. 生成帶時間戳的文件名
5. 將文件保存到 Documents 目錄
6. 打開分享菜單供用戶選擇導出方式

## 💾 數據持久化

系統使用 **Realm** 作為本地數據庫，具有以下優勢：

- **高效率** - 快速查詢和寫入操作
- **異步支持** - 非阻塞式數據庫操作
- **關聯支持** - 原生支持對象間關係
- **版本控制** - 支持數據遷移
- **跨平台** - iOS、Android 統一方案

## 🔐 數據驗證

### 簽到驗證規則
- **重複簽到防止** - 同一使用者 12 小時內不可重複簽到
- **使用者ID唯一** - 添加新使用者時檢查 ID 是否已存在

## 📊 時間管理

- **實時時鐘** - 主視圖頂部每秒更新顯示當前時間
- **定時器管理** - 視圖跳轉時自動暫停/恢復時鐘更新
- **時間格式** - 統一使用 "yyyy-MM-dd HH:mm:ss" 格式

## 🎨 界面設計

- **配色方案** - 淡藍色 (RGB: 173, 216, 230) 為主色調
- **響應式設計** - 使用 Auto Layout 適配各種設備
- **用戶友好** - 清晰的導航和直觀的操作流程

## 📥 導入與依賴

### CocoaPods 依賴
```ruby
pod 'RealmSwift'
```

確保已在 `Podfile` 中配置，運行 `pod install` 安裝依賴。

## 🔄 更新和維護

### 主要更新內容
1. **實時時鐘功能** - 在主視圖顯示當前時間
2. **簽到驗證** - 添加 12 小時防重複簽到機制
3. **CSV 導出** - 支持人員資料和簽到記錄導出
4. **模式切換** - 記錄視圖支持人員和記錄兩種顯示模式
5. **篩選功能** - 使用 Picker View 實現簽到記錄按人員篩選

## 📝 使用說明

### 基本操作
1. **啟動應用** - 打開 Xcode，選擇設備並運行
2. **新增使用者** - 點擊 "+" 按鈕，輸入使用者 ID 和姓名
3. **進行簽到** - 點擊人員列表中的任意人員進行簽到
4. **查看記錄** - 點擊 "記錄" 按鈕查看簽到記錄
5. **導出數據** - 點擊 "匯出人員資料" 或 "匯出簽到記錄" 按鈕

## 🐛 已知限制

- 目前使用同步的 Realm 操作，未來可優化為異步
- CSV 導出功能仍需完善特殊字符處理
- 移動設備之間未支持雲同步

## 🔮 未來計劃

- [ ] 支持雲端備份與同步
- [ ] 添加統計分析功能
- [ ] 支持批量導入使用者
- [ ] 添加生物識別認證 (Face ID / Touch ID)
- [ ] 支持離線簽到
- [ ] 添加簽到統計報表

## 👨‍💻 開發者

- **創建者**: imac-3888
- **創建日期**: 2025/9/19
- **最後更新**: 2025/12/12
- **Repository**: [Roll_Call_System_IOS_me](https://github.com/cansupercan/Roll_Call_System_IOS_me)

## 📄 許可證

本項目採用開源許可證，詳見項目根目錄的 LICENSE 文件。

---

**提示**：首次運行應用前，請確保已通過 CocoaPods 安裝所有依賴包。如遇到任何問題，請檢查 Xcode 的構建設置和依賴版本。
