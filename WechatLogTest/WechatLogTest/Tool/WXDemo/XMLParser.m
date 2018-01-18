//
//  XMLParser.m
//  微信支付测试2
//
//  Created by MAC on 15/8/18.
//  Copyright (c) 2015年 赵宏亚. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

#pragma mark 开始解析，输入参数为xml格式串，初始化解析器
- (void)startParse:(NSData *)data {
    
    dictionary = [NSMutableDictionary dictionary]; //初始化解析结果
    contentString = [NSMutableString string]; //初始化xml临时串变量
    xmlElements = [[NSMutableArray alloc] init]; //初始化xml解析实例 貌似没用
    
    xmlParser = [[NSXMLParser alloc] initWithData:data]; //初始化解析器
    [xmlParser setDelegate:self];
    [xmlParser parse]; //开始进行解析
    
}

#pragma mark 从解析器中获取解析后的字典
- (NSMutableDictionary *)dictionaryFromParser {
    return dictionary;
}

#pragma mark ------------------代理方法------------------------
#pragma mark 发现字符方法，将发现的字符存储到临时串变量中，用于后期处理
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [contentString setString:string]; //多次调用，断续传值
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if (![contentString isEqualToString:@"\n"] && ![elementName isEqualToString:@"root"]) {
        [dictionary setObject:[contentString copy] forKey:elementName];
    }
}



@end
