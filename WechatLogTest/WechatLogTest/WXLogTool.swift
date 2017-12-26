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
let WXRefreshToken = "WXLogTool_refreshToken"
let WXAccessToken = "WXLogTool_accessToken"
let WXOpenID = "WXLogTool_openid"
let WXUnionid = "WXLogTool_unionid"



class WXLogTool: NSObject {
    
    /**
     * 创建单例，使用实例：let ClassName = HYHttpTool.shared
     */
    static let shared = WXLogTool.init()
    private override init() {}
    
    
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
        
        HYHttpTool.post(url: urlString, param: ["appid":APPID,"secret":SECRET,"code":code,"grant_type":"authorization_code",]) { (response, result) in
            print("code 获取 ************ \(String(describing: result.value))")
            
            let dic: NSDictionary = result.value as! NSDictionary
            if let errmsg = dic.value(forKey: "errmsg") {
                print("errmsg ************** \(errmsg)")
                return
            }
            
            USER_DEFAULT.set(dic.value(forKey: "refresh_token") as! String, forKey: WXRefreshToken)
            USER_DEFAULT.set(dic.value(forKey: "access_token") as! String, forKey: WXAccessToken)
            USER_DEFAULT.set(dic.value(forKey: "openid") as! String, forKey: WXOpenID)
            

            self.getUserInfoWithAccessToken(accessToken:  dic.value(forKey: "access_token") as! String, openId: dic.value(forKey: "openid") as! String)
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
            print("获取微信用户信息方法 ************ \(String(describing: result.value))")
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
            print("使用refresh_token刷新access_token ************ \(String(describing: result.value))")
            let dic: NSDictionary = result.value as! NSDictionary
            
            if let errmsg = dic.value(forKey: "errmsg") {
                // 如果刷新失败，表示过期，可进行再次申请授权
                self.sendAuthRequest()
                print("errmsg ************** \(errmsg)")
            } else {
                // 如果刷新成功，则根据refreshToken获取获取相关信息
                
                USER_DEFAULT.set(dic.value(forKey: "refresh_token") as! String, forKey: WXRefreshToken)
                USER_DEFAULT.set(dic.value(forKey: "access_token") as! String, forKey: WXAccessToken)
                USER_DEFAULT.set(dic.value(forKey: "openid") as! String, forKey: WXOpenID)
                
                self.getUserInfoWithAccessToken(accessToken:  dic.value(forKey: "access_token")  as! String, openId: dic.value(forKey: "openid") as! String)
            }
        }
    }
    
    
    /// 判断本地的 access_token 是否可用
    ///
    /// - Parameters:
    ///   - access_token: 调用接口凭证
    ///   - openId: 普通用户标识，对该公众帐号唯一
    ///   - complete: 返回处理结果
    func accessTokenUsable(access_token: String, openId: String, complete: @escaping(Bool) -> Void) {
        
        let urlString = "https://api.weixin.qq.com/sns/auth"
        
        HYHttpTool.post(url: urlString, param: ["access_token":access_token,"openid":openId]) { (response, result) in
            print("判断本地的 access_token 是否可用 ************ \(String(describing: result.value))")
            let dic: NSDictionary = result.value as! NSDictionary
            
            if let errmsg = dic.value(forKey: "errmsg") {
                print("errmsg ************** \(errmsg)")
                
                if errmsg as! String == "ok" {
                    complete(true)
                } else {
                    complete(false)
                }
            }
        }
    }
    
    /// 登录点击方法
    func weChatLogin() {
        
        if WXApi.isWXAppInstalled() {
            print("****** 安装了微信APP *********")
        } else {
            print("****** 未安装微信 *********")
            return
        }
        
        if (USER_DEFAULT.object(forKey: WXAccessToken) != nil) {
            
            accessTokenUsable(access_token: USER_DEFAULT.object(forKey: WXAccessToken) as! String, openId: USER_DEFAULT.object(forKey: WXOpenID) as! String, complete: { (isOK) in
                
                if isOK {
                    print("isOK === yes")
                    // 如果还可以用，则直接去申请用户信息
                    self.getUserInfoWithAccessToken(accessToken:  USER_DEFAULT.object(forKey: WXAccessToken) as! String, openId: USER_DEFAULT.object(forKey: WXOpenID) as! String)
                } else {
                    print("isOK === no")
                    // 如果不可以用，则调取refreshAccessToken
                    // 如果存在则使用refresh_token刷新access_token
                    self.refreshAccessToken(refreshToken: USER_DEFAULT.object(forKey: WXRefreshToken) as! String)
                }
                
            })
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
