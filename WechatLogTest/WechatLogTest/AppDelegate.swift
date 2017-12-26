//
//  AppDelegate.swift
//  WechatLogTest
//
//  Created by zetafin on 2017/12/21.
//  Copyright © 2017年 赵宏亚. All rights reserved.
//

import UIKit



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        WXApi.registerApp(APPID)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func onReq(_ req: BaseReq!) {
        
        if req.isKind(of: GetMessageFromWXReq.self) {
            // 微信请求APP提供内容，需要app提供内容后使用senRsp返回
            print("微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信")
        } else if req.isKind(of: ShowMessageFromWXReq.self) {

            let tmp: ShowMessageFromWXReq = req as! ShowMessageFromWXReq
            
            // 显示微信传过来的内容
            let msg: WXMediaMessage = tmp.message
            let obj: WXAppExtendObject = msg.mediaObject as! WXAppExtendObject
            
            print("标题：\(msg.title) 内容：\(msg.description) 附带信息：\(obj.extInfo) 缩略图：\(msg.thumbData.count)")
        } else if req.isKind(of: LaunchFromWXReq.self) {
            // 从微信启动app
            print("从微信启动app")
        }
    }
    
    func onResp(_ resp: BaseResp!) {
        
        switch resp.errCode {
        case 0: // 用户同意
            // 调用相关方法
            let aresp: SendAuthResp = resp as! SendAuthResp
            print("code *********** \(aresp.code)")
            WXLogTool.shared.weChatCallBackWithCode(code: aresp.code)
            break
        case -4: // 用户拒绝授权
            break
        case -2: // 用户取消
            break
        default:
            break
        }
        
    }
    
    
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

