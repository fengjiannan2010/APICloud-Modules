 //
//  EncryptionTools.m
//  DESDemo
//
//  Created by Bing Ma on 6/24/16.
//  Copyright © 2016 Bing Ma (CQ). All rights reserved.
//

#import "UZEncryptionTools.h"
#import "UZConvertUtil.h"
#import "GTMBaseSignature64.h"

@interface UZEncryptionTools()
@property (nonatomic, assign) int keySize;
@property (nonatomic, assign) int blockSize;
@end

@implementation UZEncryptionTools

+ (instancetype)sharedEncryptionTools {
    static UZEncryptionTools *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.algorithm = kCCAlgorithmAES;
    });
    
    return instance;
}

- (void)setAlgorithm:(uint32_t)algorithm {
    _algorithm = algorithm;
    switch (algorithm) {
        case kCCAlgorithmAES:
            self.keySize = kCCKeySizeAES128;
            self.blockSize = kCCBlockSizeAES128;
            break;
        case kCCAlgorithmDES:
            self.keySize = kCCKeySizeDES;
            self.blockSize = kCCBlockSizeDES;
            break;
        default:
            break;
    }
}

/**
 * DES 加密，先base64加密-》DES ECB加密-》转换为16进制字符串
 */
- (NSString *)encryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv {
    NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t cKey[self.keySize];
    bzero(cKey, sizeof(cKey));
    [keyData getBytes:cKey length:self.keySize];
    
    uint8_t cIv[self.blockSize];
    bzero(cIv, self.blockSize);
    int option = 0;
    /**
     kCCOptionPKCS7Padding                      CBC encrypt
     kCCOptionPKCS7Padding | kCCOptionECBMode   ECB encrypt
     */
    if (iv) {
        [iv getBytes:cIv length:self.blockSize];
        option = kCCOptionPKCS7Padding;
    } else {
        option = kCCOptionPKCS7Padding | kCCOptionECBMode;
    }
    
    //先base64转码
    NSData *inData = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSData *data = [GTMBaseSignature64 encodeData:inData];
    //NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    size_t bufferSize = [data length] + self.blockSize;
    void *buffer = malloc(bufferSize);
    
    size_t encryptedSize = 0;
    
    // encrypt method.
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          self.algorithm,
                                          option,
                                          cKey,
                                          self.keySize,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    
    NSData *result = nil;
    NSString *ciphertext = nil;
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:encryptedSize];
        Byte *bb = (Byte*)[result bytes];
        ciphertext = [UZConvertUtil parseByteArray2HexString:bb andCount:encryptedSize];
    } else {    
        free(buffer);
        //NSLog(@"[Error] encrypt | crypt status: %d", cryptStatus);
    }
    
    return ciphertext;//[result base64EncodedStringWithOptions:0];
}

/**
 * DES 解密
 */
- (NSString *)decryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv {
    NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t cKey[self.keySize];
    bzero(cKey, sizeof(cKey));
    [keyData getBytes:cKey length:self.keySize];
    
    uint8_t cIv[self.blockSize];
    bzero(cIv, self.blockSize);
    int option = 0;
    if (iv) {
        [iv getBytes:cIv length:self.blockSize];
        option = kCCOptionPKCS7Padding;
    } else {
        option = kCCOptionPKCS7Padding | kCCOptionECBMode;
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    size_t bufferSize = [data length] + self.blockSize;
    void *buffer = malloc(bufferSize);
    
    size_t decryptedSize = 0;
    
    // dencrypt method.
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          self.algorithm,
                                          option,
                                          cKey,
                                          self.keySize,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &decryptedSize);
    
    NSData *result = nil;
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:decryptedSize];
    } else {
        free(buffer);
        NSLog(@"[Error] decrypt | crypt status: %d", cryptStatus);
    }
    
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

/**
 * DES 解密，先从16进制字符串解密-》再 DES ECB 解密 -> 最后 base64 解密
 */
- (NSString *)decryptUseDES:(NSString *)plainText key:(NSString *)key {
    NSData *textData = [UZConvertUtil parseHexToByteArray:plainText];
    
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t cKey[self.keySize];
    bzero(cKey, sizeof(cKey));
    [keyData getBytes:cKey length:self.keySize];
    
    int option = 0;
    option = kCCOptionPKCS7Padding | kCCOptionECBMode;
    
    NSUInteger dataLength = [textData length];
    
    size_t bufferSize = dataLength + self.blockSize;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          self.algorithm,
                                          option,
                                          cKey,
                                          self.keySize,
                                          nil,
                                          [textData bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    NSString *cleartext = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        cleartext = [[NSString alloc] initWithData:[GTMBaseSignature64 decodeData:data] encoding:NSUTF8StringEncoding];
    }
    return cleartext;
}

/**
 * DES 解密，先从16进制字符串解密-》再 DES ECB 解密 -> 最后 base64 解密
 */
+ (NSString *)StoredecryptUseDES:(NSString *)plainText key:(NSString *)key {
    NSData *textData = [UZConvertUtil parseHexToByteArray:plainText];
    NSUInteger dataLength = [textData length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    
    size_t numBytesEncrypted = 0;
    
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionECBMode | kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [textData bytes],
                                          dataLength,
                                          buffer,
                                          1024,
                                          &numBytesEncrypted);
    NSString *cleartext = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        cleartext = [[NSString alloc] initWithData:[GTMBaseSignature64 decodeData:data] encoding:NSUTF8StringEncoding];
    }
    return cleartext;
}
@end
