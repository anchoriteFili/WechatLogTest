//
//  XMLParser.h
//  微信支付测试2
//
//  Created by MAC on 15/8/18.
//  Copyright (c) 2015年 赵宏亚. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark 将从服务器上传回来的XML数据转换成字典形式并返回
@interface XMLParser : NSObject<NSXMLParserDelegate> {
    NSXMLParser *xmlParser; //解析器
    NSMutableArray *xmlElements; //解析元素貌似没用到
    NSMutableDictionary *dictionary; //返回的解析结果
    NSMutableString *contentString; //临时串变量
}

#pragma mark 开始解析，输入参数为xml格式串，初始化解析器
- (void)startParse:(NSData *)data;

#pragma mark 从解析器中获取解析后的字典
- (NSMutableDictionary *)dictionaryFromParser;







@end
