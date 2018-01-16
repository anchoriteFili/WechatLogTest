//
//  Encryption.h
//  微信支付测试2
//
//  Created by MAC on 15/8/18.
//  Copyright (c) 2015年 博思创影. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface Encryption : NSObject<NSXMLParserDelegate>

#pragma mark md5加密
+ (NSString *)md5Encryption:(NSString *)str;
#pragma mark sha1加密
+ (NSString *)sha1Encryption:(NSString *)str;

#pragma mark 将各种请求数据以XML的形式传输到服务器并接收从服务器传回来的值
+ (NSData *)sendXmlData:(NSString *)data withMethod:(NSString *)method toHttp:(NSString *)url;



@end
