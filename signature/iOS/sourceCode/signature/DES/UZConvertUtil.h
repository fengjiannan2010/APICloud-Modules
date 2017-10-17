//
//  ConvertUtil.h
//  DESDemo
//
//  Created by zhengcuan on 16/9/3.
//  Copyright © 2016年 Bing Ma (CQ). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UZConvertUtil : NSObject
/**
 64编码
 */
+ (NSString *)base64Encoding:(NSData *)text;

/**
 字节转化为16进制数
 */
+ (NSString *)parseByte2HexString:(Byte *)bytes;

/**
 字节数组转化16进制数
 */
+ (NSString *)parseByteArray2HexString:(Byte[])bytes;

/**
 字节数组转化16进制数
 */
+ (NSString *)parseByteArray2HexString:(Byte[])bytes andCount:(long)count;

/*
 将16进制数据转化成NSData 数组
 */
+ (NSData *)parseHexToByteArray:(NSString *)hexString;

@end
