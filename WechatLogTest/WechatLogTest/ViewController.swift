//
//  ViewController.swift
//  WechatLogTest
//
//  Created by zetafin on 2017/12/21.
//  Copyright © 2017年 赵宏亚. All rights reserved.
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
    
    
    @IBAction func loginClick(_ sender: UIButton) {
        WXLogTool.shared.weChatLogin()
    }
    
    
    
    @IBAction func PayButtonClick(_ sender: Any) {
        
//        WXLogTool.shared.pay(orderName: "微信支付测试", orderPrice: "1")
        
        
        self.present(WXPayViewController(), animated: true, completion: nil)
        
    }
    


}

