//
//  ViewController.swift
//  XinGePush
//
//  Created by 李亚坤 on 15/3/31.
//  Copyright (c) 2015年 李亚坤. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var txtAddItem: UITextField!
    
    @IBOutlet weak var tblShoppingList: UITableView!
    
    @IBOutlet weak var btnAction: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var shoppingList: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleModifyListNotification", name: "modifyListNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDeleteListNotification", name: "deleteListNotification", object: nil)
        
        self.tblShoppingList.delegate = self
        
        self.tblShoppingList.dataSource = self
        
        self.txtAddItem.delegate = self
        
        // UI
        datePicker.hidden = true
        
        loadShoppingList()
        // 设置开启通知
        setupNotificationSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate method implementation
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if shoppingList == nil {
            shoppingList = NSMutableArray()
        }
        shoppingList.addObject(textField.text)
        
        tblShoppingList.reloadData()
        
        txtAddItem.text = ""
        txtAddItem.resignFirstResponder()
        saveShoppingList()
        
        return true
    }

    // MARK: UITableViewDelegate method implementation
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if let list = shoppingList {
            rows = list.count
        }
        return rows
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(50.0)
    }
    
    // MARK: UITableViewDataRource method implementation
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCellItem", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel!.text = shoppingList[indexPath.row] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            removeItemAtIndex(indexPath.row)
        }
    }
    
    // MARK: Save/Remove to document
    func saveShoppingList() {
        let pathsArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory = pathsArray[0] as! String
        let savePath = documentsDirectory.stringByAppendingPathComponent("shopping_list")
        shoppingList.writeToFile(savePath, atomically: true)
    }
    
    func removeItemAtIndex(index: Int)
    {
        shoppingList.removeObject(index)
        tblShoppingList.reloadData()
        saveShoppingList()
    }
    
    func loadShoppingList() {
        let pathsArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentationDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory = pathsArray[0] as! String
        let shoppingListPath = documentsDirectory.stringByAppendingPathComponent("Shopping_list")
        
        // 判断文件是否存在
        if NSFileManager.defaultManager().fileExistsAtPath(shoppingListPath) {
            shoppingList = NSMutableArray(contentsOfFile: shoppingListPath)
            tblShoppingList.reloadData()
        }
    }
    // MARK: animate Method
    
    func animateMyViews(viewToHide: UIView, viewToShow: UIView) {
        let animationDuration = 0.35
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            viewToHide.transform = CGAffineTransformScale(viewToHide.transform, 0.001, 0.001)
            }){ (completion) -> Void in
                
                viewToHide.hidden = true
                viewToShow.hidden = false
                
                viewToShow.transform = CGAffineTransformScale(viewToShow.transform, 0.001, 0.001)
                
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    viewToShow.transform = CGAffineTransformIdentity
                })
        }
    }
    
    // MARK: UI Method
    @IBAction func scheduleReminder(sender: AnyObject) {
        if datePicker.hidden == true {
            animateMyViews(tblShoppingList, viewToShow: datePicker)
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        else {
            animateMyViews(datePicker, viewToShow: tblShoppingList)
            scheduleLocalNotification()
        }
        txtAddItem.enabled = !txtAddItem.enabled
    }
    func setupNotificationSettings() {
        let notificationSettings: UIUserNotificationSettings! = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if (notificationSettings.types == UIUserNotificationType.None){
            // Specify the notification types.
            var notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
            
            
            // Specify the notification actions.
            var justInformAction = UIMutableUserNotificationAction()
            justInformAction.identifier = "justInform"
            justInformAction.title = "OK, got it"
            justInformAction.activationMode = UIUserNotificationActivationMode.Background
            justInformAction.destructive = false
            justInformAction.authenticationRequired = false
            
            var modifyListAction = UIMutableUserNotificationAction()
            modifyListAction.identifier = "editList"
            modifyListAction.title = "Edit list"
            modifyListAction.activationMode = UIUserNotificationActivationMode.Foreground
            modifyListAction.destructive = false
            modifyListAction.authenticationRequired = true
            
            var trashAction = UIMutableUserNotificationAction()
            trashAction.identifier = "trashAction"
            trashAction.title = "Delete list"
            trashAction.activationMode = UIUserNotificationActivationMode.Background
            trashAction.destructive = true
            trashAction.authenticationRequired = false
            
            let actionsArray = NSArray(objects: justInformAction, modifyListAction, trashAction)
            let actionsArrayMinimal = NSArray(objects: trashAction, modifyListAction)
            
            // Specify the category related to the above actions.
            var shoppingListReminderCategory = UIMutableUserNotificationCategory()
            shoppingListReminderCategory.identifier = "shoppingListReminderCategory"
            shoppingListReminderCategory.setActions(actionsArray as [AnyObject], forContext: UIUserNotificationActionContext.Default)
            shoppingListReminderCategory.setActions(actionsArrayMinimal as [AnyObject], forContext: UIUserNotificationActionContext.Minimal)
            
            
            let categoriesForSettings = NSSet(objects: shoppingListReminderCategory)
            
            
            // Register the notification settings.
            let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings as Set<NSObject>)
            UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
        }
    }
    
//    func setupNotificationSettings() {
//        // Specify the notification types.
//        let notificationSettings: UIUserNotificationSettings! = UIApplication.sharedApplication().currentUserNotificationSettings()
//        
//        if (notificationSettings.types == UIUserNotificationType.None) {
//            var notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
//            
//            // UIMutableUserNotification...iOS8 新引入的特性
//            
//            // 点击消失,app仍然在后台，只给几秒钟时间处理任务
//            var justInformation = UIMutableUserNotificationAction()
//            justInformation.identifier = "justInform"
//            justInformation.title = "OK, got it"
//            justInformation.activationMode = UIUserNotificationActivationMode.Background
//            justInformation.destructive = false
//            justInformation.authenticationRequired = false
//            
//            // 点击后添加一个物品
//            var modifyListAction = UIMutableUserNotificationAction()
//            modifyListAction.identifier = "editList"
//            modifyListAction.title = "Edit List"
//            modifyListAction.activationMode = UIUserNotificationActivationMode.Foreground
//            modifyListAction.destructive = false
//            modifyListAction.authenticationRequired = true
//            
//            // 点击后删除
//            var trashAction = UIMutableUserNotificationAction()
//            trashAction.identifier = "trashAction"
//            trashAction.title = "Delete List"
//            trashAction.activationMode = UIUserNotificationActivationMode.Background
//            trashAction.destructive = true
//            trashAction.authenticationRequired = false
//            
//            // 分类
//            let actionsArray = Array(arrayLiteral: justInformation, modifyListAction, trashAction)
//            let actionsArrayMinimal = Array(arrayLiteral: trashAction, modifyListAction)
//            
//            // 创建分类的category
//            var shoppingListReminderCategory = UIMutableUserNotificationCategory()
//            shoppingListReminderCategory.identifier = "ShoppingListReminderCategory"
//            shoppingListReminderCategory.setActions(actionsArray as [AnyObject], forContext:UIUserNotificationActionContext.Default)
//            shoppingListReminderCategory.setActions(actionsArrayMinimal as [AnyObject], forContext: UIUserNotificationActionContext.Minimal)
//            
//            // 注册设置
//            let categoriesForSettings = Set(arrayLiteral: shoppingListReminderCategory)
//            let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings)
//            UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
//        }
//    }
    
    func scheduleLocalNotification() {
        // 本地推送设置
        var localNotification = UILocalNotification()
        localNotification.fireDate = fixNotificationDate(datePicker.date)
        localNotification.alertBody = "时间到了，该去购物了！"
        localNotification.alertAction = "查看清单"
        localNotification.category = "shoppingListReminderCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func fixNotificationDate(dateToFix: NSDate) -> NSDate {
        // 处理时间的秒位为0
        var dateComponets: NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: dateToFix)
        dateComponets.second = 0
        var fixedDate: NSDate! = NSCalendar.currentCalendar().dateFromComponents(dateComponets)
        return fixedDate
    }
    
    // MARK: Notification Method
    func handleModifyListNotification() {
        txtAddItem.becomeFirstResponder()
    }
    
    func handleDeleteListNotification() {
        shoppingList.removeAllObjects()
        saveShoppingList()
        tblShoppingList.reloadData()
    }
    
    
}



















