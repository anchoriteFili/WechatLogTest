//
//  WXLogTool.swift
//  WechatLogTest
//
//  Created by zetafin on 2017/12/26.
//  Copyright © 2017年 赵宏亚. All rights reserved.
//

import UIKit

let APPID = "wx0cd8451d269de523"
let SECRET = "e70fa5e1c1bce1360768ef64078fda78"
let USER_DEFAULT = UserDefaults.standard // 获取userDefault

class WXLogTool: NSObject {
    
    /**
     * 创建单例，使用实例：let ClassName = HYHttpTool.shared
     */
    static let shared = WXLogTool.init()
    private override init() {}
    
    var code = ""
    var refresh_token = ""
    var openid = ""
    var unionid = ""
    var access_token = ""
    
    
    /** https://api.weixin.qq.com/sns/oauth2/access_token
     *  链接返回数据
     access_token : 接口调用凭证
     *  expires_in : access_token接口调用凭证超时时间，单位（秒）
     *  refresh_token : 用户刷新access_token
     *  openid : 授权用户唯一标识
     *  scope : 用户授权的作用域，使用逗号（,）分隔
     *  unionid : 当且仅当该移动应用已获得该用户的userinfo授权时，才会出现该字段
     */
    func weChatCallBackWithCode(code: String) {
        
        let urlString = "https://api.weixin.qq.com/sns/oauth2/access_token"
        print("urlString ************** \(urlString)")
        
        self.code = code
        HYHttpTool.post(url: urlString, param: ["appid":APPID,"secret":SECRET,"code":code,"grant_type":"authorization_code",]) { (response, result) in
            print("dicOne ************ \(String(describing: result.value))")
            
            let dic: NSDictionary = result.value as! NSDictionary
            if let errmsg = dic.value(forKey: "errmsg") {
                print("errmsg ************** \(errmsg)")
                return
            }
            
            USER_DEFAULT.object(forKey: dic.value(forKey: "refresh_token") as! String)

            self.getUserInfoWithAccessToken(accessToken:  dic.value(forKey: "access_token")  as! String, openId: dic.value(forKey: "openid") as! String)
        }
        
    }
    
    /// 获取微信用户信息方法
    ///
    /// - Parameters:
    ///   - accessToken: 接口调用凭证
    ///   - openId: 授权用户唯一标识
    func getUserInfoWithAccessToken(accessToken: String, openId: String) {
        
        let urlString = "https://api.weixin.qq.com/sns/userinfo"
        
        HYHttpTool.post(url: urlString, param: ["access_token":accessToken,"openid":openId]) { (response, result) in
            print("dicTwo ************ \(String(describing: result.value))")
            let dic: NSDictionary = result.value as! NSDictionary
            
            if let errmsg = dic.value(forKey: "errmsg") {
                print("errmsg ************** \(errmsg)")
                return
            }
        }
    }
    
    
    /// 使用refresh_token刷新access_token
    ///
    /// - Parameter refreshToken: 用户刷新access_token
    func refreshAccessToken(refreshToken: String) {
        
        let urlString = "https://api.weixin.qq.com/sns/oauth2/refresh_token"
        
        HYHttpTool.post(url: urlString, param: ["appid":APPID,"grant_type":"refresh_token","refresh_token":refreshToken]) { (response, result) in
            print("dicTwo ************ \(String(describing: result.value))")
            let dic: NSDictionary = result.value as! NSDictionary
            
            if let errmsg = dic.value(forKey: "errmsg") {
                // 如果刷新失败，表示过期，可进行再次申请授权
                self.sendAuthRequest()
                print("errmsg ************** \(errmsg)")
            } else {
                // 如果刷新成功，则根据refreshToken获取获取相关信息
                self.access_token = dic.value(forKey: "access_token") as! String
                self.openid = dic.value(forKey: "openid") as! String
                self.refresh_token = dic.value(forKey: "refresh_token") as! String
                
                USER_DEFAULT.object(forKey: dic.value(forKey: "refresh_token") as! String)
                
                self.getUserInfoWithAccessToken(accessToken:  dic.value(forKey: "access_token")  as! String, openId: dic.value(forKey: "openid") as! String)
            }
        }
    }
    
    /// 登录点击方法
    func weChatLogin() {
        
        if (USER_DEFAULT.object(forKey: "WXLogTool_Refresh") != nil) {
            // 如果存在则使用refresh_token刷新access_token
            refreshAccessToken(refreshToken: USER_DEFAULT.object(forKey: "WXLogTool_Refresh") as! String)
        } else {
            // 如果不存在则直接授权
            sendAuthRequest()
        }
    }
    
    /// 授权方法
    func sendAuthRequest() {
        let req: SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "WechatLogTest"
        WXApi.send(req)
    }

}
