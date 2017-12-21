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
    class func post(url: String?, param: NSMutableDictionary, complete: @escaping (HTTPURLResponse?, Result<String>) -> Void ) -> Void {
        
        // 如果发过来的链接长度为空，则直接返回，不做任何反应
        guard let urlString = url, strlen(url) > 0 else {
            return
        }
        
        // 发起post申请
        let request: Alamofire.Request? = Alamofire.request(urlString, method: .post)
        // 如果是数据类型的请求
        if let request = request as? DataRequest {
            
            request.responseString(completionHandler: { response in
                complete(response.response, response.result)
            })
        }
    }

}
