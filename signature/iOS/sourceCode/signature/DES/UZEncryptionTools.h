//
//  EncryptionTools.h
//  DESDemo
//
//  Created by Bing Ma on 6/24/16.
//  Copyright © 2016 Bing Ma (CQ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

/**
 *  终端测试指令
 *
 *  DES(ECB)加密
 *  $ echo -n hello | openssl enc -des-ecb -K 616263 -nosalt | base64
 *
 *  DES(CBC)加密
 *  $ echo -n hello | openssl enc -des-cbc -iv 0102030405060708 -K 616263 -nosalt | base64
 *
 
 *  DES(ECB)解密
 *  $ echo -n HQr0Oij2kbo= | base64 -D | openssl enc -des-ecb -K 616263 -nosalt -d
 *
 *  DES(CBC)解密
 *  $ echo -n alvrvb3Gz88= | base64 -D | openssl enc -des-cbc -iv 0102030405060708 -K 616263 -nosalt -d
 
 *  提示：
 *      1> 加密过程是先加密，再base64编码
 *      2> 解密过程是先base64解码，再解密
 */
@interface UZEncryptionTools : NSObject

+ (instancetype)sharedEncryptionTools;

@property (nonatomic, assign) uint32_t algorithm;

- (NSString *)encryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv;
- (NSString *)decryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv;

- (NSString *)decryptUseDES:(NSString *)plainText key:(NSString *)key;
+ (NSString *)StoredecryptUseDES:(NSString *)plainText key:(NSString *)key;
@end
