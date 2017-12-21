//
//  HYHttpTool.swift
//  WechatLogTest
//
//  Created by zetafin on 2017/12/21.
//  Copyright © 2017年 赵宏亚. All rights reserved.
//

import UIKit
import Alamofire

class HYHttpTool: NSObject {
    
    /*  接口post请求
     *  url: 传过来的url
     *  param: 传过来的接口个性参数
     *  complete：接口返回的参数
     */
    class func post(url: String?, param: Parameters, complete: @escaping (HTTPURLResponse?, Result<Any>) -> Void ) -> Void {
        
        // 如果发过来的链接长度为空，则直接返回，不做任何反应
        guard let urlString = url, strlen(url) > 0 else {
            return
        }
        
        Alamofire.request(urlString, method: .post, parameters: param).responseJSON { (response) in
            complete(response.response, response.result)
        }
    }
    
    /*  接口get请求
     *  url: 传过来的url
     *  complete：接口返回的参数
     */
    class func get(url: String?, complete: @escaping (HTTPURLResponse?, Result<Any>) -> Void ) -> Void {
        
        // 如果发过来的链接长度为空，则直接返回，不做任何反应
        guard let urlString = url, strlen(url) > 0 else {
            return
        }
        
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            complete(response.response, response.result)
        }
    }

}
