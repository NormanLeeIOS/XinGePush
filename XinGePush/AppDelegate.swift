//
//  AppDelegate.swift
//  XinGePush
//
//  Created by 李亚坤 on 15/3/31.
//  Copyright (c) 2015年 李亚坤. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    // 注册苹果推送
    func registerPushForIOS8() {
        // 检查版本
        let os = NSProcessInfo().operatingSystemVersion
        if os.majorVersion >= 8 {
            // Types
            var types: UIUserNotificationType = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
            
            // Actions
            var acceptAction = UIMutableUserNotificationAction()
            
            acceptAction.identifier = "ACCEPT_IDENTIFIER"
            acceptAction.title = "Accept"
            acceptAction.destructive = false
            acceptAction.authenticationRequired = false
            
            // Categories
            var inviteCategory: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            inviteCategory.identifier = "INVITE_CATEGORY"
            inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Default)
            inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Minimal)
            var categories: NSSet = NSSet(objects: inviteCategory)
            var mySettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: categories)
            UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
    }

    
    func registerPush()->Void {
        UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // 初始化App的Push信息
        XGPush.startApp(AccessID, appKey: AccessKey)
        
        //注销之后需要再次注册前的准备
        var successCallback: (()->Void) = { ()->Void in
          //判断当前是否是已注销状态
            if XGPush.isUnRegisterStatus() == false {
                //iOS8注册push方法
                let os = NSProcessInfo().operatingSystemVersion
                if os.majorVersion >= 8 {
                    var sysVer: Float = (UIDevice.currentDevice().systemVersion as NSString).floatValue
                    if sysVer < 8 {
                        self.registerPush()
                    }
                    else {
                        self.registerPushForIOS8()
                    }
                }//end >= iOS8
                else {
                    self.registerPush()
                }
            }
        }//end block
        
        XGPush.initForReregister(successCallback)
        
        
        //推送反馈回调版本示例
        var successBlock: (()->Void) = { ()->Void in
            // 成功之后的处理
            println("[XGPush]handleLaunching's successBlock")
        }
        
        var errorBlock:(()->Void) = { ()->Void in
            // 失败之后的处理
            println("[XGPush]handleLaunching's errorBlock")
        }
        
        // 初始化角标清零
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        // 清除所有本地通知
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        XGPush.handleLaunching(launchOptions, successCallback: successBlock, errorCallback: errorBlock)
        
        //本地推送示例
//        var fireDate: NSDate = NSDate().dateByAddingTimeInterval(10)
//        var dicUserInfo: NSMutableDictionary = NSMutableDictionary()
//        dicUserInfo.setValue("myid", forKey: "clockID")
//        var userInfo: NSDictionary = dicUserInfo
//        
//        XGPush.localNotification(fireDate, alertBody: "测试本地推送", badge: 2, alertAction: "确定", userInfo: userInfo)
        
        
        return true
    }
    
    // MARK: - 如果deviceToken获取会进入此事件
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var successBlock: (()->Void) = { ()->Void in
            // 成功之后的处理
            println("[XGPush]registerDeviceToken successBlock")
        }
        
        var errorBlock:(()->Void) = { ()->Void in
            // 失败之后的处理
            println("[XGPush]registerDeviceToken errorBlock")
        }
        
        //注册设备
//        [[XGSetting getInstance] setChannel:@"appstore"];
//        [[XGSetting getInstance] setGameServer:@"巨神峰"];
        
        var deviceTokenStr: NSString = XGPush.registerDevice(deviceToken, successCallback: successBlock, errorCallback: errorBlock)
        
        // 打印deviceToken的字符串
        println("deviceTokenStr:\(deviceToken)")
    }
    
    // MARK: - 如果deviceToken获取不到会进入此事件
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("DeviceTokenError %@", error)
    }
    
    
    // MARK: - 接收到远程推送的消息进入回调
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // 推送反馈(app运行时)
        XGPush.handleReceiveNotification(userInfo)
    }
    
    // MARK: - 接收到本地推送的消息进入回调
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // notification是发送推送时传入的字典信息
        XGPush.localNotificationAtFrontEnd(notification, userInfoKey: "clockID", userInfoValue: "myID")
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

