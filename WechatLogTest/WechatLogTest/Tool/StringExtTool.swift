//
//  StringExtTool.swift
//  特快金服
//
//  Created by zetafin on 2017/12/12.
//  Copyright © 2017年 赵宏亚. All rights reserved.
//

//import Foundation
import UIKit


// 扩充String
extension String {
    
    /*
     * 将json字符串在转化为json字典
     */
    static func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    
    /*
     * 将json字典转化为json字符串
     */
    static func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData!
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
}
