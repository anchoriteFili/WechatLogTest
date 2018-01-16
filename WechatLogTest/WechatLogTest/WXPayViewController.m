//
//  WXPayViewController.m
//  WechatLogTest
//
//  Created by zetafin on 2018/1/16.
//  Copyright © 2018年 赵宏亚. All rights reserved.
//

#import "WXPayViewController.h"

#define SP_URL @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php"

@interface WXPayViewController ()

@end

@implementation WXPayViewController

@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"md5Encryption = %@",[Encryption md5Encryption:@"hahahahhaahhaha"]);
    NSLog(@"sha1Encryption = %@",[Encryption sha1Encryption:@"hahahahhaahhaha"]);
    
    
    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn4 setTitle:@"微信支付" forState:UIControlStateNormal];
    btn4.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn4 setFrame:CGRectMake(10, 180, 145, 40)];
    [btn4 addTarget:self action:@selector(sendPay_demo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn4];
}

/**
 发送请求并从服务器得到相应的数据，如果获取的数据不为空，则将数据传给PayReq进行+(BOOL) sendReq:(BaseReq*)req;处理
 */
- (void)sendPay
{
    //从服务器获取支付参数，服务端自定义处理逻辑和格式
    //订单标题
    NSString *ORDER_NAME    = @"Ios服务器端签名支付 测试";
    //订单金额，单位（元）
    NSString *ORDER_PRICE   = @"0.01";
    
    //根据服务器端编码确定是否转码
    NSStringEncoding enc;
    //if UTF8编码
    //enc = NSUTF8StringEncoding;
    //if GBK编码
    enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *urlString = [NSString stringWithFormat:@"%@?plat=ios&order_no=%@&product_name=%@&order_price=%@",
                           SP_URL,
                           [[NSString stringWithFormat:@"%ld",time(0)] stringByAddingPercentEscapesUsingEncoding:enc],
                           [ORDER_NAME stringByAddingPercentEscapesUsingEncoding:enc],
                           ORDER_PRICE];
    
    //解析服务端返回json数据
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if ( response != nil) {
        NSMutableDictionary *dict = NULL;
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        
        NSLog(@"url:%@",urlString);
        if(dict != nil){
            NSMutableString *retcode = [dict objectForKey:@"retcode"];
            if (retcode.intValue == 0){
                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
                
                //调起微信支付
                PayReq* req             = [[PayReq alloc] init];
                req.openID              = [dict objectForKey:@"appid"];
                req.partnerId           = [dict objectForKey:@"partnerid"];
                req.prepayId            = [dict objectForKey:@"prepayid"];
                req.nonceStr            = [dict objectForKey:@"noncestr"];
                req.timeStamp           = stamp.intValue;
                req.package             = [dict objectForKey:@"package"];
                req.sign                = [dict objectForKey:@"sign"];
                [WXApi sendReq:req];
                //日志输出
                NSLog(@"日志输出 appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                
                //                [self alert:@"提示信息" msg:@"支付成功"];
                
            }else{
                [self alert:@"提示信息" msg:[dict objectForKey:@"retmsg"]];
            }
        }else{
            [self alert:@"提示信息" msg:@"服务器返回错误，未获取到json对象"];
        }
    }else{
        [self alert:@"提示信息" msg:@"服务器返回错误"];
    }
}

- (void)sendPay_demo {
    
    WXPayDemo *payDemo = [[WXPayDemo alloc] init]; //初始化demo，启用demo方法
    [payDemo setApp_id:APP_ID mach_id:MCH_ID andKey:PARTNER_ID]; //设置开发平台id、商户号和私钥
    NSMutableDictionary *dic = [payDemo payWithOrderName:@"微信支付测试" andOrderPrice:@"1"]; //提交商品描述和商品价格，价格单位为分，第二次签名信息
    
    if (dic == nil) {
        NSString *debug = [payDemo getDebugInfo]; //如果第二次签名失败，返回调试信息，进行调试
        [self alert:@"提示信息" msg:debug];
        
    } else {
        [self alert:@"确认" msg:@"下单成功，点击OK后调起支付"];
        
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
}

//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
