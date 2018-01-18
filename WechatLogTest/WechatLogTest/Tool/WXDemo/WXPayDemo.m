//
//  WXPayDemo.m
//  微信支付测试2
//
//  Created by MAC on 15/8/18.
//  Copyright (c) 2015年 赵宏亚. All rights reserved.
//

#import "WXPayDemo.h"

@implementation WXPayDemo

#pragma mark 对外支付调用接口
- (NSMutableDictionary *)payWithOrderName:(NSString *)orderName andOrderPrice:(NSString *)orderPrice {
    
    NSString *order_name = orderName; //订单描述/标题，展示给用户
    NSString *order_price = orderPrice; //订单金额，单位分
    
    //预订单参数设置
    srand((unsigned)time(0));
    NSString *nonceStr = [NSString stringWithFormat:@"%d", rand()]; //随机串
    NSString *orderNumber = [NSString stringWithFormat:@"%ld",time(0)]; //商户订单号 根据现在的时间来制定的，一直在改变
    
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary]; //创建承载参数字典
    
    [packageParams setObject: appid             forKey:@"appid"];       //开放平台appid
    [packageParams setObject: machid            forKey:@"mch_id"];      //商户号
    [packageParams setObject: @"APP-001"        forKey:@"device_info"]; //支付设备号或门店号
    [packageParams setObject: nonceStr          forKey:@"nonce_str"];   //随机串
    [packageParams setObject: @"APP"            forKey:@"trade_type"];  //支付类型，固定为APP
    [packageParams setObject: order_name        forKey:@"body"];        //订单描述，展示给用户
    [packageParams setObject: NOTIFY_URL        forKey:@"notify_url"];  //支付结果异步通知
    [packageParams setObject: orderNumber       forKey:@"out_trade_no"];//商户订单号
    [packageParams setObject: @"196.168.1.1"    forKey:@"spbill_create_ip"];//发起支付的机器ip
    [packageParams setObject: order_price       forKey:@"total_fee"];       //订单金额，单位为分
    
#pragma mark  根据上面的预付单的参数，提交预支付，获取prepayId（预支付交易会话标识）
    NSString *prePayId = [self sendPrepay:packageParams];
    if (prePayId != nil) {
        NSString *package, *time_stamp, *nonce_str;
        
        time_t now;
        time(&now);
        time_stamp = [NSString stringWithFormat:@"%ld", now]; //获取时间戳
        nonce_str = [Encryption md5Encryption:time_stamp]; //根据时间戳获取随机字符串
        package = @"Sign=WXPay"; //对package进行重新赋值，用于第二次签名
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary]; //创建承载第二次签名的字典
        [signParams setObject: appid        forKey:@"appid"];
        [signParams setObject: nonce_str    forKey:@"noncestr"];
        [signParams setObject: package      forKey:@"package"];
        [signParams setObject: machid       forKey:@"partnerid"];
        [signParams setObject: time_stamp   forKey:@"timestamp"];
        [signParams setObject: prePayId     forKey:@"prepayid"];
        
        NSString *sign = [self createMd5WithSign:signParams]; //将参数进行md5加密，生成标签
        
        [signParams setObject: sign forKey:@"sign"]; //将标签加入到参数字典中
        
        [debugInfo appendFormat:@"第二步签名成功，sign＝%@\n",sign]; //返回调试信息
        
        [self WXPayWithDic:signParams];
//        return signParams; //将参数返回
    } else {
        [self alert:@"提示信息" msg:debugInfo];
        NSLog(@"debugInfo ======== %@",debugInfo);
        [debugInfo appendFormat:@"获取prepayid失败！！！"];
    }
    return nil;
}

#pragma mark 如果二次签名成功，则直接调取微信支付
- (void)WXPayWithDic:(NSMutableDictionary *)dic {
    
    //调起微信支付
    PayReq *req     = [[PayReq alloc] init];
    req.openID      = [dic objectForKey:@"appid"];
    req.partnerId   = [dic objectForKey:@"partnerid"];
    req.prepayId    = [dic objectForKey:@"prepayid"];
    req.nonceStr    = [dic objectForKey:@"noncestr"];
    req.timeStamp   = [[dic objectForKey:@"timestamp"] intValue];
    req.package     = [dic objectForKey:@"package"];
    req.sign        = [dic objectForKey:@"sign"];
    [WXApi sendReq:req];
}

#pragma mark 设置开发平台id、商户号、商户私钥
- (void)setApp_id:(NSString *)app_id mach_id:(NSString *)mach_id andKey:(NSString *)key {
    
    payUrl = @"https://api.mch.weixin.qq.com/pay/unifiedorder"; //预支付网关赋值
    if (debugInfo == nil){
        debugInfo = [NSMutableString string]; //初始化调试信息
    }
    [debugInfo setString:@""]; //用来传递debug信息
    appid = app_id; //将两个参数传入进行处理
    machid = mach_id; //对商户号进行赋值
    spkey = [NSString stringWithString:key];
}

#pragma mark 获取调试信息方法
- (NSString *)getDebugInfo {
    
    NSString *res = [NSString stringWithString:debugInfo];
    [debugInfo setString:@""]; //清空进行下一轮儿的使用
    return res;
}

#pragma mark 获取最后一个错误代码
- (long)getLastErrcode {
    
    return last_errcode;
}

#pragma mark 采用md5加密获取package签名 //先排序再加密
- (NSString *)createMd5WithSign:(NSMutableDictionary *)dic {
    
    NSMutableString *contentString = [NSMutableString string]; //创建一个随机串，用于中间的处理值的作用
    NSArray *keys = [dic allKeys]; //获取字典中的所有的key值
    //将所有的键值对进行排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    //遍历所有有序的键key，根据有序的key值进行有序的拼接，拼接条件：key对应的值不能为空，key不能为sign和key
    for (NSString *key in sortedArray) {
        if (![[dic objectForKey:key] isEqualToString:@""] &&
            ![key isEqualToString:@"sign"] &&
            ![key isEqualToString:@"key"]) {
            //根据键值对拼接成临时串
            [contentString appendFormat:@"%@=%@&", key, [dic objectForKey:key]];
        }
    }
    
    [contentString appendFormat:@"key=%@",spkey]; //拼接商户私钥
    NSString *md5Sign = [Encryption md5Encryption:contentString]; //将临时串进行md5加密并返回
    [debugInfo appendFormat:@"MD5加密前字符串：\n%@\n",contentString]; //对调试信息进行赋值
    
    return md5Sign;
}

#pragma mark 将packageParams转化成xml形式的签名包，用于上传服务器
- (NSString *)getPackage:(NSMutableDictionary *)packageParams {
    
    NSMutableString *package = [NSMutableString string]; //创建用于承载XML的字符串
    NSString *sign = [self createMd5WithSign:packageParams]; //将签名包参数加密成签名sign
    NSArray *keys = [packageParams allKeys];
    [package appendString:@"<xml>\n"]; //先添加一个XML头
    for (NSString *key in keys) {
        [package appendFormat:@"<%@>%@</%@>\n", key, [packageParams objectForKey:key],key];
    }
    [package appendFormat:@"<sign>%@</sign>\n</xml>", sign]; //添加sign和XML结束标记
    
    return [NSString stringWithString:package];
}

#pragma mark 提交预支付
/**
 直接将xml格式的prePayParams上传网络,网络返回一个xml形式的数据，对xml进行解析，获取字典形式的数据
 然后对数据进行判断，"result_code" = SUCCESS;"return_code" = SUCCESS;才可正常进行，然后将返回
 的数据进行MD5加密，得到一个send_sign，和服务器获得的sign进行比较，如果两者相等，则返回服务器中的
 prepayid，一项不符就支付失败。
 */
- (NSString *)sendPrepay:(NSMutableDictionary *)prePayParams {
    
    NSString *prepayid = nil;
    
    NSString *prePayParamsXml = [self getPackage:prePayParams]; //获取xml形式的预支付参数
    NSLog(@"prePayParamsXml ========= %@",prePayParamsXml);
    
    [debugInfo appendFormat:@"API链接:%@\n", payUrl]; //将参数添加到调试信息中
    [debugInfo appendFormat:@"发送的xml:%@\n", prePayParamsXml];
    
    NSData *serverData = [Encryption sendXmlData:prePayParamsXml withMethod:@"POST" toHttp:payUrl]; //post的形式向服务器传输XML形式的数据，并从服务器中获取返回数据
    
    XMLParser *parser = [[XMLParser alloc] init]; //开始调用XML解析
    [parser startParse:serverData]; //对服务器申请下来的数据进行解析
    NSMutableDictionary *serverParseDic = [parser dictionaryFromParser]; //获取XML解析后的服务器返回数据
    
#pragma mark 验证代码获得的sign和服务器返回的sign是否一致，如果一致则进行二次签名直接支付，不相等则支付失败
    NSString *return_code = [serverParseDic objectForKey:@"return_code"];
    NSString *result_code = [serverParseDic objectForKey:@"result_code"];
    
    if ([return_code isEqualToString:@"SUCCESS"])
    {
        //sign对resParams直接进行MD5加密获取，send_sign将resParams中的元素排序进行再次加密
        NSString *sign  = [self createMd5WithSign:serverParseDic];
        NSString *send_sign =[serverParseDic objectForKey:@"sign"] ;
        
        //验证签名正确性 如果代码加密获得的send_sign和服务器给的sign一样，则正确
        if([sign isEqualToString:send_sign]){
            if( [result_code isEqualToString:@"SUCCESS"]) {
                //验证业务处理状态
                prepayid = [serverParseDic objectForKey:@"prepay_id"];
                return_code = 0;
                
                [debugInfo appendFormat:@"获取预支付交易标示成功！\n"];
            }
        }else{
            last_errcode = 1;
            [debugInfo appendFormat:@"gen_sign=%@\n   _sign=%@\n",sign,send_sign];
            [debugInfo appendFormat:@"服务器返回签名验证错误！！！\n"];
        }
    }else{
        last_errcode = 2;
        [debugInfo appendFormat:@"接口返回错误！！！\n"];
    }
    
    return prepayid;
}

//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
}


@end
