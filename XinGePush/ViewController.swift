//
//  ViewController.swift
//  XinGePush
//
//  Created by 李亚坤 on 15/3/31.
//  Copyright (c) 2015年 李亚坤. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func SetTagBtnClick(sender: AnyObject) {
        //为不同的"用户"设置标签
        var tag: NSString = "name: LiYakun"
        
        var successBlock: (()->Void) = { ()->Void in
            // 成功之后的处理
            var alert = UIAlertView(title: "信鸽推送", message: "设置标签成功", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        var errorBlock: (()->Void) = { ()->Void in
            // 失败之后的处理
            var alert = UIAlertView(title: "信鸽推送", message: "设置标签失败", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        XGPush.setTag(tag as String, successCallback: successBlock, errorCallback: errorBlock)
        
    }
    
    
    @IBAction func DelTagBunClick(sender: AnyObject) {
        var tag: NSString = "name: LiYakun"
        
        var successBlock: (()->Void) = { ()->Void in
            // 成功之后的处理
            println("")
            var alert = UIAlertView(title: "信鸽推送", message: "删除标签成功", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        var errorBlock: (()->Void) = { ()->Void in
            // 失败之后的处理
            var alert = UIAlertView(title: "信鸽推送", message: "删除标签失败", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        XGPush.delTag(tag as String, successCallback: successBlock, errorCallback: errorBlock)
    }
    
    
    @IBAction func logoutDevice(sender: AnyObject) {
        XGPush.unRegisterDevice()
        var alert = UIAlertView(title: "信鸽推送", message: "注销设备", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    

}

