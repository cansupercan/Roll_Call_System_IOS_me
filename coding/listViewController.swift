//
//  listViewController.swift
//  coding
//
//  Created by imac-3888 on 2025/9/21.
//

import UIKit
import RealmSwift

class listViewController: UIViewController {

    @IBOutlet weak var tbvlist: UITableView!
    
    @IBOutlet weak var pkvs: UIPickerView!
    
    // 存儲所有使用者的陣列
    private var users: Results<User>?
    
    // 存儲所有簽到記錄的陣列
    private var checkInRecords: Results<CheckInRecord>?
    
    // 篩選後的簽到記錄
    private var filteredCheckInRecords: Results<CheckInRecord>?
    
    // 用戶數據陣列 (用於 PickerView)
    private var userPickerData: [String] = ["所有人"]
    
    // 定義顯示模式
    enum DisplayMode {
        case users
        case checkInRecords
    }
    
    // 當前顯示模式
    private var currentDisplayMode: DisplayMode = .users
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 設置導航欄
        setupNavigationBar()
        
        // 設置切換顯示模式按鈕
        setupSwitchModeButton()
        
        // 設置 TableView
        setupTableView()
        
        // 設置 PickerView
        setupPickerView()
        
        // 載入使用者數據
        loadUsers()
        
        // 根據當前模式設置 PickerView 的可見性
        updatePickerViewVisibility()
    }
    
    // 設置導航欄
    private func setupNavigationBar() {
        title = "人員列表"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0) // 淡藍色
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // 確保導航欄不透明
        navigationController?.navigationBar.isTranslucent = false
    }
    
    // 設置切換顯示模式按鈕
    private func setupSwitchModeButton() {
        let switchButton = UIBarButtonItem(
            title: "切換到簽到記錄",
            style: .plain,
            target: self,
            action: #selector(switchModeButtonTapped)
        )
        navigationItem.rightBarButtonItem = switchButton
    }
    
    // 切換顯示模式按鈕點擊事件
    @objc private func switchModeButtonTapped() {
        // 切換顯示模式
        currentDisplayMode = (currentDisplayMode == .users) ? .checkInRecords : .users
        
        // 更新按鈕標題
        if let switchButton = navigationItem.rightBarButtonItem {
            switchButton.title = (currentDisplayMode == .users) ? "切換到簽到記錄" : "切換到人員列表"
        }
        
        // 根據當前模式載入對應數據
        if currentDisplayMode == .users {
            loadUsers()
        } else {
            // 加載用戶數據到 PickerView
            loadUserPickerData()
            // 載入所有簽到記錄（預設顯示所有人的記錄）
            loadCheckInRecords()
            // 選擇「所有人」選項
            pkvs.selectRow(0, inComponent: 0, animated: false)
            filterCheckInRecords(forUserIndex: 0)
        }
        
        // 更新 PickerView 的可見性
        updatePickerViewVisibility()
        
        // 更新導航欄標題
        title = (currentDisplayMode == .users) ? "人員列表" : "簽到記錄"
    }
    
    // 設置 TableView
    private func setupTableView() {
        tbvlist.delegate = self
        tbvlist.dataSource = self
        
        // 註冊 cell
        tbvlist.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // 設置行高
        tbvlist.rowHeight = 60
    }
    
    // 設置 PickerView
    private func setupPickerView() {
        // 設置代理和數據源
        pkvs.delegate = self
        pkvs.dataSource = self
        
        // 初始選擇「所有人」選項
        pkvs.selectRow(0, inComponent: 0, animated: false)
    }
    
    // 載入使用者數據
    private func loadUsers() {
        let realm = try! Realm()
        users = realm.objects(User.self).sorted(byKeyPath: "createdAt", ascending: false)
        tbvlist.reloadData()
    }
    
    // 載入簽到記錄
    private func loadCheckInRecords() {
        let realm = try! Realm()
        checkInRecords = realm.objects(CheckInRecord.self).sorted(byKeyPath: "checkInTime", ascending: false)
        tbvlist.reloadData()
    }
    
    // 載入用戶數據到 PickerView
    private func loadUserPickerData() {
        userPickerData.removeAll()
        userPickerData.append("所有人") // 添加「所有人」選項
        
        if let users = users {
            for user in users {
                userPickerData.append(user.Name)
            }
        }
        
        // 重新載入 PickerView 數據
        pkvs.reloadAllComponents()
    }
    
    // 根據選中的用戶篩選簽到記錄
    private func filterCheckInRecords(forUserIndex index: Int) {
        guard let users = users else { return }
        
        if index == 0 {
            // 如果選擇的是「所有人」，則顯示所有簽到記錄
            filteredCheckInRecords = checkInRecords
        } else {
            // 否則，根據選中的用戶篩選簽到記錄
            let selectedUser = users[index - 1] // 減去 1 是因為索引 0 是「所有人」
            let realm = try! Realm()
            filteredCheckInRecords = realm.objects(CheckInRecord.self).filter("userId == %@", selectedUser.userId).sorted(byKeyPath: "checkInTime", ascending: false)
        }
        
        // 重新載入 TableView 數據
        tbvlist.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 根據當前模式載入對應數據
        if currentDisplayMode == .users {
            loadUsers()
        } else {
            loadCheckInRecords()
        }
    }
    
    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    // 根據當前模式設置 PickerView 的可見性
    private func updatePickerViewVisibility() {
        pkvs.isHidden = (currentDisplayMode == .users)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension listViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 返回表格有幾個區域
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 返回每個區域有多少行
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentDisplayMode {
        case .users:
            return users?.count ?? 0
        case .checkInRecords:
            return filteredCheckInRecords?.count ?? 0
        }
    }
    
    // 返回每一行的內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch currentDisplayMode {
        case .users:
            // 獲取對應的使用者資料
            if let currentUser = users?[indexPath.row] {
                cell.textLabel?.text = "\(currentUser.Name) (\(currentUser.userId))"
            } else {
                cell.textLabel?.text = "未知使用者"
            }
        case .checkInRecords:
            // 獲取對應的簽到記錄
            if let record = filteredCheckInRecords?[indexPath.row] {
                // 嘗試獲取用戶名
                let realm = try! Realm()
                let userObj = realm.objects(User.self).filter("userId == %@", record.userId).first
                let userName = userObj?.Name ?? "未知用戶"
                
                cell.textLabel?.text = "\(userName) - 簽到時間: \(formatDate(record.checkInTime))"
            } else {
                cell.textLabel?.text = "未知記錄"
            }
        }
        
        return cell
    }
    
    // 行被選中時的處理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch currentDisplayMode {
        case .users:
            // 獲取選中的使用者
            guard let selectedUser = users?[indexPath.row] else { return }
            
            // 顯示用戶詳細資訊
            showUserDetails(user: selectedUser)
            
        case .checkInRecords:
            // 獲取選中的簽到記錄
            guard let selectedRecord = filteredCheckInRecords?[indexPath.row] else { return }
            
            // 顯示記錄詳細資訊
            showRecordDetails(record: selectedRecord)
        }
    }
    
    // 支援左滑刪除操作
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // 允許所有行可編輯（左滑）
    }
    
    // 定義左滑操作
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch currentDisplayMode {
            case .users:
                // 刪除用戶
                deleteUser(at: indexPath)
            case .checkInRecords:
                // 刪除簽到記錄
                deleteCheckInRecord(at: indexPath)
            }
        }
    }
    
    // 顯示用戶詳細資訊
    private func showUserDetails(user: User) {
        let alertController = UIAlertController(
            title: "用戶詳細資訊",
            message: "ID: \(user.userId)\n姓名: \(user.Name)\n創建時間: \(formatDate(user.createdAt))",
            preferredStyle: .alert
        )
        
        // 添加確認按鈕
        let okAction = UIAlertAction(title: "確定", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    // 顯示記錄詳細資訊
    private func showRecordDetails(record: CheckInRecord) {
        // 嘗試獲取用戶名
        let realm = try! Realm()
        let userObj = realm.objects(User.self).filter("userId == %@", record.userId).first
        let userName = userObj?.Name ?? "未知用戶"
        
        let alertController = UIAlertController(
            title: "簽到記錄詳細資訊",
            message: "用戶: \(userName)\n用戶ID: \(record.userId)\n簽到時間: \(formatDate(record.checkInTime))\n備註: \(record.note ?? "無")",
            preferredStyle: .alert
        )
        
        // 添加確認按鈕
        let okAction = UIAlertAction(title: "確定", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    // 刪除用戶
    private func deleteUser(at indexPath: IndexPath) {
        guard let userToDelete = users?[indexPath.row] else {
            showErrorAlert(message: "找不到要刪除的用戶")
            return
        }
        
        // 顯示確認刪除的警告框
        let alertController = UIAlertController(
            title: "確認刪除",
            message: "確定要刪除用戶「\(userToDelete.Name)」嗎？此操作無法復原，且將刪除該用戶的所有簽到記錄。",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            let realm = try! Realm()
            
            do {
                // 刪除該用戶的所有簽到記錄
                let userRecords = realm.objects(CheckInRecord.self).filter("userId == %@", userToDelete.userId)
                
                try realm.write {
                    // 刪除相關記錄
                    realm.delete(userRecords)
                    // 刪除用戶
                    realm.delete(userToDelete)
                }
                
                // 重新加載數據
                self.loadUsers()
                
                // 顯示成功訊息
                self.showSuccessAlert(message: "用戶已成功刪除")
            } catch {
                self.showErrorAlert(message: "刪除失敗：\(error.localizedDescription)")
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true)
    }
    
    // 刪除簽到記錄
    private func deleteCheckInRecord(at indexPath: IndexPath) {
        guard let recordToDelete = checkInRecords?[indexPath.row] else {
            showErrorAlert(message: "找不到要刪除的記錄")
            return
        }
        
        // 嘗試獲取用戶名
        let realm = try! Realm()
        let userObj = realm.objects(User.self).filter("userId == %@", recordToDelete.userId).first
        let userName = userObj?.Name ?? "未知用戶"
        
        // 顯示確認刪除的警告框
        let alertController = UIAlertController(
            title: "確認刪除",
            message: "確定要刪除 \(userName) 於 \(formatDate(recordToDelete.checkInTime)) 的簽到記錄嗎？此操作無法復原。",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            do {
                try realm.write {
                    realm.delete(recordToDelete)
                }
                
                // 重新加載數據
                self.loadCheckInRecords()
                
                // 顯示成功訊息
                self.showSuccessAlert(message: "記錄已成功刪除")
            } catch {
                self.showErrorAlert(message: "刪除失敗：\(error.localizedDescription)")
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true)
    }
    
    // 顯示成功訊息
    private func showSuccessAlert(message: String) {
        let alertController = UIAlertController(title: "成功", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    // 顯示錯誤訊息
    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension listViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // 返回 PickerView 有幾個區域
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 返回每個區域的行數
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userPickerData.count // 使用 userPickerData 而不是直接使用 users
    }
    
    // 返回每一行的內容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return userPickerData[row] // 從 userPickerData 取得標題
    }
    
    // 行被選中時的處理
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 使用 filterCheckInRecords 方法根據選擇的索引篩選記錄
        filterCheckInRecords(forUserIndex: row)
    }
}
