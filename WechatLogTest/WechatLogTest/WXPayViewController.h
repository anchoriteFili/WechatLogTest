//
//  WXPayViewController.h
//  WechatLogTest
//
//  Created by zetafin on 2018/1/16.
//  Copyright © 2018年 赵宏亚. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApiObject.h"
#import "WXApi.h"
#import "Encryption.h"
#import "WXPayDemo.h"

@protocol sendMsgToWeChatViewDelegate <NSObject>
- (void) sendPay;
- (void) sendPay_demo;
@end

@interface WXPayViewController : UIViewController

@property (nonatomic, assign) id<sendMsgToWeChatViewDelegate,NSObject> delegate;

@end
