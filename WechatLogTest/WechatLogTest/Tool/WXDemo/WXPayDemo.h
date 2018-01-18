//
//  WXPayDemo.h
//  微信支付测试2
//
//  Created by MAC on 15/8/18.
//  Copyright (c) 2015年 赵宏亚. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Encryption.h"
#import "XMLParser.h"
#import "WXApi.h"

#define APP_ID          @"wx427a2f57bc4456d1" //公众账号ID 微信分配的公众账号ID
#define APP_SECRET      @"" //appsecret
//商户号，填写商户对应参数
#define MCH_ID          @"1242316102" //商户号 微信支付分配的商户号
//商户API密钥，填写相应参数
#define PARTNER_ID      @"12345678901234567890123456789020"
//支付结果回调页面
#define NOTIFY_URL      @"http://wxpay.weixin.qq.com/pub_v2/pay/notify.v2.php"
//获取服务器端支付数据地址（商户自定义）
#define SP_URL          @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php"

@interface WXPayDemo : NSObject {
    NSString *payUrl; //预支付网关url
    long last_errcode; //最后一个错误代码
    NSMutableString *debugInfo; //调试信息
    NSString *appid,*machid,*spkey;
}

#pragma mark 对外支付调用接口
- (NSMutableDictionary *)payWithOrderName:(NSString *)orderName andOrderPrice:(NSString *)orderPrice;
#pragma mark 设置开发平台id、商户号、商户私钥
- (void)setApp_id:(NSString *)app_id mach_id:(NSString *)mach_id andKey:(NSString *)key;
#pragma mark 获取调试信息方法
- (NSString *)getDebugInfo;
#pragma mark 获取最后一个错误代码
- (long)getLastErrcode;
#pragma mark 采用md5加密获取package签名
- (NSString *)createMd5WithSign:(NSMutableDictionary *)dic;
#pragma mark 将packageParams转化成xml形式的签名包，用于上传服务器
- (NSString *)getPackage:(NSMutableDictionary *)packageParams;
#pragma mark 提交预支付
- (NSString *)sendPrepay:(NSMutableDictionary *)prePayParams;







@end
