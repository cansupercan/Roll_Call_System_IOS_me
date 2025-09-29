//
//  MainViewController.swift
//  coding
//
//  Created by imac-3888 on 2025/9/19.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {

    @IBOutlet weak var lbtitle: UILabel!
    
    @IBOutlet weak var tbvselect: UITableView!
    
    // 存儲所有使用者的陣列
    private var users: Results<User>?
    
    // 定時器用於更新即時時間
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設置淡藍色導航欄
        setupNavigationBar()
        
        // 設置"記錄"按鈕
        setupRecordButton()
        
        // 設置"+"按鈕
        setupAddButton()
        
        // 設置 TableView
        setupTableView()
        
        // 載入使用者數據
        loadUsers()
        
        // 設置時間顯示標籤
        setupTimeLabel()
        
        // 啟動定時器來更新時間
        startTimeUpdater()
    }
    
    // 設置時間顯示標籤
    private func setupTimeLabel() {
        lbtitle.textAlignment = .center
        lbtitle.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        updateTimeLabel() // 初始化顯示
    }
    
    // 啟動定時器來更新時間
    private func startTimeUpdater() {
        // 每秒更新一次時間
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        timer?.tolerance = 0.1 // 增加容差以節省電量
    }
    
    // 更新時間標籤
    @objc private func updateTimeLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentTimeString = dateFormatter.string(from: Date())
        
        lbtitle.text = "現在時間: \(currentTimeString)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 停止定時器
        timer?.invalidate()
        timer = nil
    }
    
    // 設置淡藍色導航欄
    private func setupNavigationBar() {
        
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
    
    // 設置"記錄"按鈕
    private func setupRecordButton() {
        
        let recordButton = UIBarButtonItem(title: "記錄", style: .plain, target: self, action: #selector(recordButtonTapped))
        navigationItem.rightBarButtonItem = recordButton
    }
    
    // 設置"+"按鈕
    private func setupAddButton() {
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.leftBarButtonItem = addButton
    }
    
    // "+"按鈕點擊事件
    @objc private func addButtonTapped() {
        showAddPersonAlert()
    }
    
    // 顯示新增人員的警告框
    private func showAddPersonAlert() {
        let alertController = UIAlertController(title: "新增使用者", message: "請輸入使用者資訊", preferredStyle: .alert)
        
        // 添加使用者 ID 輸入框
        alertController.addTextField { textField in
            textField.placeholder = "請輸入使用者 ID"
            textField.keyboardType = .default
        }
        
        // 添加姓名輸入框
        alertController.addTextField { textField in
            textField.placeholder = "請輸入姓名"
            textField.keyboardType = .default
        }
        
        // 添加取消按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        // 添加確認按鈕
        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // 獲取使用者輸入
            guard let userIdTextField = alertController.textFields?[0],
                  let nameTextField = alertController.textFields?[1],
                  let userId = userIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !userId.isEmpty, !name.isEmpty else {
                self.showErrorAlert(message: "請填寫所有欄位")
                return
            }
            
            // 將資料寫入資料庫
            self.addPersonToDatabase(userId: userId, name: name)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true)
    }
    
    // 添加人員到數據庫
    private func addPersonToDatabase(userId: String, name: String) {
        let realm = try! Realm()
        
        // 檢查使用者 ID 是否已存在
        if let _ = realm.objects(User.self).filter("userId == %@", userId).first {
            showErrorAlert(message: "使用者 ID 已存在")
            return
        }
        
        // 建立新使用者
        let newUser = User(userId: userId, name: name)
        
        do {
            try realm.write {
                realm.add(newUser)
            }
            showSuccessAlert(message: "使用者新增成功")
            
            // 重新加載表格
            tbvselect.reloadData()
        } catch {
            showErrorAlert(message: "儲存失敗: \(error.localizedDescription)")
        }
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
    
    // 記錄按鈕點擊事件
    @objc private func recordButtonTapped() {
        // 未來這裡會導航到記錄頁面
        print("記錄按鈕被點擊")
        
        // 這裡可以添加跳轉到記錄頁面的代碼
         let recordVC = listViewController()
         navigationController?.pushViewController(recordVC, animated: true)
    }
    
    // 設置 TableView
    private func setupTableView() {
        tbvselect.delegate = self
        tbvselect.dataSource = self
        
        // 註冊 cell
        tbvselect.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        
        // 設置行高
        tbvselect.rowHeight = 60
    }
    
    // 載入使用者數據
    private func loadUsers() {
        let realm = try! Realm()
        users = realm.objects(User.self).sorted(byKeyPath: "createdAt", ascending: false)
        tbvselect.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUsers() // 每次視圖出現時重新加載數據
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 返回表格有幾個區域
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 返回每個區域有多少行
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    // 返回每一行的內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        
        // 獲取對應的使用者資料
        if let currentUser = users?[indexPath.row] {
            cell.textLabel?.text = "\(currentUser.Name) (\(currentUser.userId))"
        } else {
            cell.textLabel?.text = "未知使用者"
        }
        
        return cell
    }
    
    // 行被選中時的處理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 獲取選中的使用者
        guard let selectedUser = users?[indexPath.row] else {
            showErrorAlert(message: "無法獲取選中的使用者資料")
            return
        }
        
        // 顯示簽到確認對話框
        showCheckInConfirmation(for: selectedUser)
    }
    
    // 顯示簽到確認對話框
    private func showCheckInConfirmation(for user: User) {
        let alertController = UIAlertController(
            title: "簽到確認",
            message: "確認為 \(user.Name) 進行簽到嗎？",
            preferredStyle: .alert
        )
        
        // 添加備註輸入欄位
        alertController.addTextField { textField in
            textField.placeholder = "備註（選填）"
        }
        
        // 添加取消按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        // 添加確認按鈕
        let confirmAction = UIAlertAction(title: "確認簽到", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // 獲取備註內容
            let noteText = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 執行簽到
            self.performCheckIn(for: user, note: noteText)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true)
    }
    
    // 執行簽到並寫入資料庫
    private func performCheckIn(for user: User, note: String?) {
        let realm = try! Realm()
        
        // 檢查上次簽到時間，判斷是否允許再次簽到
        if let lastCheckInTime = user.lastCheckInTime {
            // 計算上次簽到時間與當前時間的時間差（小時）
            let timeInterval = Date().timeIntervalSince(lastCheckInTime) / 3600
            
            // 如果時間差小於 12 小時，則不允許簽到
            if timeInterval < 12 {
                // 計算還需等待的時間
                let hoursLeft = 12 - timeInterval
                let minutesLeft = Int((hoursLeft - Double(Int(hoursLeft))) * 60)
                
                let message = String(format: "距離上次簽到時間不足 12 小時，還需等待 %d 小時 %d 分鐘", Int(hoursLeft), minutesLeft)
                showErrorAlert(message: message)
                return
            }
        }
        
        // 建立新的簽到記錄
        let checkInRecord = CheckInRecord(userId: user.userId, note: note)
        
        do {
            try realm.write {
                // 添加簽到記錄
                realm.add(checkInRecord)
                
                // 更新使用者的最後簽到時間
                let userToUpdate = realm.objects(User.self).filter("userId == %@", user.userId).first
                userToUpdate?.lastCheckInTime = checkInRecord.checkInTime
            }
            
            // 顯示簽到成功訊息
            showSuccessAlert(message: "\(user.Name) 簽到成功！時間：\(formatDate(checkInRecord.checkInTime))")
        } catch {
            showErrorAlert(message: "簽到失敗：\(error.localizedDescription)")
        }
    }
    
    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
