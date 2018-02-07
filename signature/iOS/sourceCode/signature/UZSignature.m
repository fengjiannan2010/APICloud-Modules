/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import "UZSignature.h"
#import "NSDictionaryUtils.h"
#import <CommonCrypto/CommonDigest.h> 
#import <CommonCrypto/CommonCryptor.h> 
#import "GTMBaseSignature64.h"
#import "NSData+AES256.h"
#import "AESCrypt.h"
#import "UZEncryptionTools.h"
#import "UZConvertUtil.h"

static Byte ivBuff[]   = {0xA,1,0xB,5,4,0xF,7,9,0x17,3,1,6,8,0xC,0xD,91};

@implementation UZSignature
//sha256加密方式
- (NSString *)getSha256String:(NSString *)srcString {
//    const char *s = [srcString cStringUsingEncoding:NSASCIIStringEncoding];
//    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
//
//    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
//    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
//    NSData *out = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
//    NSString *hash = [out description];
//    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
//    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
//    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
//    return hash;
    
    const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:srcString.length];
    unsigned int length = (unsigned int)data.length;
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, length, digest);
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    return result;
}
#pragma mark - async -
- (void)sha256:(NSDictionary *)paramsDict {
    NSInteger sha1EncCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:sha1EncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSString *outString = [self getSha256String:inString];
        if (outString.length <= 0) {
            //err:-1
            [self sendResultEventWithCallbackId:sha1EncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        } else {
            //true
            [self sendResultEventWithCallbackId:sha1EncCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":outString} errDict:nil doDelete:NO];
        }
    }
}

- (NSString *)sha256Sync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        NSString *outString = [self getSha256String:inString];
        return outString;
    }
}

- (void)md5:(NSDictionary *)paramsDict {
    NSInteger md5EncCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:md5EncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        const char *cStrValue = [inString UTF8String];
        unsigned char outResult[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cStrValue, strlen(cStrValue), outResult);
        NSString *outString = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                               outResult[0], outResult[1], outResult[2], outResult[3],
                               outResult[4], outResult[5], outResult[6], outResult[7],
                               outResult[8], outResult[9], outResult[10], outResult[11],
                               outResult[12], outResult[13], outResult[14], outResult[15]];
        BOOL isUpper = [paramsDict boolValueForKey:@"uppercase" defaultValue:true];
        outString = isUpper ? [outString uppercaseString] : [outString lowercaseString];
        if (outString.length <= 0) {
            //err:-1
            [self sendResultEventWithCallbackId:md5EncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        } else {
            //true
            [self sendResultEventWithCallbackId:md5EncCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":outString} errDict:nil doDelete:NO];
        }
    }
}

- (void)sha1:(NSDictionary *)paramsDict {
    NSInteger sha1EncCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:sha1EncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
//        const char *cstr = [inString cStringUsingEncoding:NSUTF8StringEncoding];
//        NSData *inData = [NSData dataWithBytes:cstr length:inString.length];
        NSData *inData = [inString dataUsingEncoding:NSUTF8StringEncoding];
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(inData.bytes, inData.length, digest);
        
        NSMutableString *outString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
            [outString appendFormat:@"%02x", digest[i]];
        }
        BOOL isUpper = [paramsDict boolValueForKey:@"uppercase" defaultValue:true];
        outString = isUpper ? [NSMutableString stringWithString:[outString uppercaseString]] : [NSMutableString stringWithString:[outString lowercaseString]];
        if (outString.length <= 0) {
            //err:-1
            [self sendResultEventWithCallbackId:sha1EncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        } else {
            //true
            [self sendResultEventWithCallbackId:sha1EncCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":outString} errDict:nil doDelete:NO];
        }
    }
}

- (void)aes:(NSDictionary *)paramsDict {
    NSInteger aesEncCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:aesEncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSString *AESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        
        NSData *plainText = [inString dataUsingEncoding:NSUTF8StringEncoding];
        // 'key' should be 32 bytes for AES256, will be null-padded otherwise
        char keyPtr[kCCKeySizeAES256+1];      // room for terminator (unused)
        bzero(keyPtr, sizeof(keyPtr));      // fill with zeroes (for padding)
        NSUInteger dataLength = [plainText length];
        
        size_t bufferSize = dataLength + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        bzero(buffer, sizeof(buffer));
        size_t numBytesEncrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                              kCCOptionPKCS7Padding,
                                              [[NSData AESKeyForPassword:AESkey] bytes],
                                              kCCKeySizeAES256,
                                              ivBuff,   //initialization vector (optional)
                                              [plainText bytes], dataLength,       //input
                                              buffer, bufferSize,                 //output
                                              &numBytesEncrypted);
        if (cryptStatus == kCCSuccess) {
            NSData *encryptData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
            NSString *outString = [encryptData base64Encoding];
            [self sendResultEventWithCallbackId:aesEncCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":outString} errDict:nil doDelete:NO];
        } else {
            free(buffer);
            //err:-1
            [self sendResultEventWithCallbackId:aesEncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        }
    }
}

- (void)aesDecode:(NSDictionary *)paramsDict {
    NSInteger aesDecCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:aesDecCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSString *AESDeckey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        NSData *cipherData = [NSData dataWithBase64EncodedString:inString];
        // 'key' should be 32 bytes for AES256, will be null-padded otherwise
        char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
        bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
        
        NSUInteger dataLength = [cipherData length];
        size_t bufferSize = dataLength + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        size_t numBytesDecrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                              kCCOptionPKCS7Padding,
                                              [[NSData AESKeyForPassword:AESDeckey] bytes],
                                              kCCKeySizeAES256,
                                              ivBuff ,      //initialization vector (optional)
                                              [cipherData bytes], dataLength,          //input
                                              buffer, bufferSize,                     //output
                                              &numBytesDecrypted);
        
        if (cryptStatus == kCCSuccess) {
            NSData *outData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
            NSMutableString *outString = [[NSMutableString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
            //如果没有进行加密直接解密，outString 将为 nil
            if (!outString && outData && outData.length > 0) {
                Byte *datas = (Byte*)[outData bytes];
                outString = [NSMutableString stringWithCapacity:outData.length * 2];
                for(int i = 0; i < outData.length; i++){
                    [outString appendFormat:@"%02x", datas[i]];
                }
            }
            [self sendResultEventWithCallbackId:aesDecCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":outString} errDict:nil doDelete:NO];
        } else {
            free(buffer);
            //err:-1
            [self sendResultEventWithCallbackId:aesDecCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        }
    }
}

- (void)aesCBC:(NSDictionary *)paramsDict {
    NSInteger aescbcCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:aescbcCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSString *AESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        NSString *offset = [paramsDict stringValueForKey:@"iv" defaultValue:@""];
        NSString *klength = [paramsDict stringValueForKey:@"keyLength" defaultValue:@""];
        NSData *plainText = [inString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encode = [self AES128operation:kCCEncrypt data:plainText key:AESkey iv:offset length:klength];
        if (encode) {
            encode = [encode uppercaseString];
            [self sendResultEventWithCallbackId:aescbcCbId dataDict:@{@"status":@(YES),@"value":encode} errDict:nil doDelete:NO];
        } else {
            [self sendResultEventWithCallbackId:aescbcCbId dataDict:@{@"status":@(NO)} errDict:@{@"code":@(-1)} doDelete:NO];
        }
    }
}
- (void)aesDecodeCBC:(NSDictionary *)paramsDict {
    NSInteger aescbcCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:aescbcCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        inString = [inString lowercaseString];
        NSString *AESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        NSString *offset = [paramsDict stringValueForKey:@"iv" defaultValue:@""];
        NSString *klength = [paramsDict stringValueForKey:@"keyLength" defaultValue:@""];
        NSData *plainText = [self hex2data:inString];//[inString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encode = [self AES128operation:kCCDecrypt data:plainText key:AESkey iv:offset length:klength];
        if (encode) {
            [self sendResultEventWithCallbackId:aescbcCbId dataDict:@{@"status":@(YES),@"value":encode} errDict:nil doDelete:NO];
        } else {
            [self sendResultEventWithCallbackId:aescbcCbId dataDict:@{@"status":@(NO)} errDict:@{@"code":@(-1)} doDelete:NO];
        }
    }
}

- (void)aesECBAsymmetric:(NSDictionary *)paramsDict {
    NSInteger aesEncCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:aesEncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSString *AESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        NSData *data = [inString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *key = [AESkey dataUsingEncoding:NSUTF8StringEncoding];
        NSData *aesData = [NSData doCipher:data key:key context:kCCEncrypt];
        NSString *aesStr = [aesData newStringInBase64FromData];
        if (aesStr) {
            [self sendResultEventWithCallbackId:aesEncCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":aesStr} errDict:nil doDelete:NO];
        } else {
            //err:-1
            [self sendResultEventWithCallbackId:aesEncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        }
    }
}

- (void)aesECB:(NSDictionary *)paramsDict {
    NSInteger aesEncCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:aesEncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSString *AESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        NSString *aesStr = [AESCrypt encrypt:inString password:AESkey];
        if (aesStr) {
            [self sendResultEventWithCallbackId:aesEncCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":aesStr} errDict:nil doDelete:NO];
        } else {
            //err:-1
            [self sendResultEventWithCallbackId:aesEncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        }
    }
}

- (void)aesDecodeECB:(NSDictionary *)paramsDict {
    NSInteger aesDecCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:aesDecCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSString *AESDeckey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        NSString *aesStr = [AESCrypt decrypt:inString password:AESDeckey];
        if (aesStr) {
            [self sendResultEventWithCallbackId:aesDecCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":aesStr} errDict:nil doDelete:NO];
        } else {
            //err:-1
            [self sendResultEventWithCallbackId:aesDecCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        }
    }
}

- (void)base64:(NSDictionary *)paramsDict {
    NSInteger base64EncCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:base64EncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSData *inData = [inString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSData *outData = [GTMBaseSignature64 encodeData:inData];
        NSString *outString = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];

        if (outString.length <= 0) {
            //err:-1
            [self sendResultEventWithCallbackId:base64EncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        } else {
            //true
            [self sendResultEventWithCallbackId:base64EncCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":outString} errDict:nil doDelete:NO];
        }
    }
}

- (void)base64Decode:(NSDictionary *)paramsDict {
    NSInteger base64DecCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:base64DecCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSData *inData = [inString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *outData = [GTMBaseSignature64 decodeData:inData];
        NSMutableString *outString = [[NSMutableString alloc]initWithData:outData encoding:NSUTF8StringEncoding];
        //如果没有进行加密直接解密，outString 将为 nil
        if (!outString && outData && outData.length > 0) {
            Byte *datas = (Byte*)[outData bytes];
            outString = [NSMutableString stringWithCapacity:outData.length * 2];
            for(int i = 0; i < outData.length; i++){
                [outString appendFormat:@"%02x", datas[i]];
            }
        }
        if (outString.length <= 0) {
            //err:-1
            [self sendResultEventWithCallbackId:base64DecCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        } else {
            //true
            [self sendResultEventWithCallbackId:base64DecCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":outString} errDict:nil doDelete:NO];
        }
    }
}

- (void)rsa:(NSDictionary *)paramsDict {
    NSInteger rsaCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:rsaCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        static SecKeyRef _public_key = nil;
        // 从公钥证书文件中获取到公钥的SecKeyRef指针:  @"public_key" ofType:@"der"
        NSString *publicKeyPath = [paramsDict stringValueForKey:@"publicKey" defaultValue:@""];
        publicKeyPath = [self getPathWithUZSchemeURL:publicKeyPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:publicKeyPath]) {
            [self sendResultEventWithCallbackId:rsaCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
            return;
        }
        NSData *certificateData = [[NSData alloc]initWithContentsOfFile:publicKeyPath];
        SecCertificateRef myCertificate =  SecCertificateCreateWithData(kCFAllocatorDefault, (CFDataRef)certificateData);
        SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
        SecTrustRef myTrust;
        OSStatus status = SecTrustCreateWithCertificates(myCertificate,myPolicy,&myTrust);
        SecTrustResultType trustResult;
        if (status == noErr) {
            status = SecTrustEvaluate(myTrust, &trustResult);
        }
        _public_key = SecTrustCopyPublicKey(myTrust);
        CFRelease(myCertificate);
        CFRelease(myPolicy);
        CFRelease(myTrust);

        SecKeyRef key = _public_key;
        size_t cipherBufferSize = SecKeyGetBlockSize(key);
        uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
        NSData *stringBytes = [inString dataUsingEncoding:NSUTF8StringEncoding];
        size_t blockSize = cipherBufferSize - 11;
        size_t blockCount = (size_t)ceil([stringBytes length] / (double)blockSize);
        NSMutableData *encryptedData = [[NSMutableData alloc] init];
        NSString *outString = [[NSString alloc] init];
        for (int i=0; i<blockCount; i++) {
            int bufferSize = MIN(blockSize,[stringBytes length] - i * blockSize);
            NSData *buffer = [stringBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
            OSStatus status = SecKeyEncrypt(key, kSecPaddingPKCS1, (const uint8_t *)[buffer bytes],
                                            [buffer length], cipherBuffer, &cipherBufferSize);
            if (status == noErr){
                NSData *encryptedBytes = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
                [encryptedData appendData:encryptedBytes];
            } else{
                outString = @"";
            }
        }
        if (cipherBuffer) {
            free(cipherBuffer);
        }
        outString = [encryptedData base64Encoding];
        [self sendResultEventWithCallbackId:rsaCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":outString} errDict:nil doDelete:NO];
    }
}

- (void)rsaDecode:(NSDictionary *)paramsDict {
    NSInteger rsaDecodeCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *password = [paramsDict stringValueForKey:@"password" defaultValue:@""];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:rsaDecodeCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        // 从私钥证书文件中获取到公钥的SecKeyRef指针:  @"private_key" ofType:@"pem"
        NSString *privateKeyPath = [paramsDict stringValueForKey:@"privateKey" defaultValue:@""];
        privateKeyPath = [self getPathWithUZSchemeURL:privateKeyPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:privateKeyPath]) {
            [self sendResultEventWithCallbackId:rsaDecodeCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
            return;
        }
        NSData *p12Data = [[NSData alloc]initWithContentsOfFile:privateKeyPath];
        SecKeyRef privateKeyRef = NULL;
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setObject:password forKey:(__bridge id)kSecImportExportPassphrase];
        CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
        OSStatus securityError = SecPKCS12Import((__bridge CFDataRef) p12Data, (__bridge CFDictionaryRef)options, &items);
        if (securityError == noErr && CFArrayGetCount(items) > 0) {
            CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
            SecIdentityRef identityApp = (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
            securityError = SecIdentityCopyPrivateKey(identityApp, &privateKeyRef);
            if (securityError != noErr) {
                privateKeyRef = NULL;
            }
        } else {
            [self sendResultEventWithCallbackId:rsaDecodeCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
            return;
        }
        CFRelease(items);

        NSData *cipherData = [NSData dataWithBase64EncodedString:inString];
        size_t cipherLen = [cipherData length];
        void *cipher = malloc(cipherLen);
        [cipherData getBytes:cipher length:cipherLen];
        size_t plainLen = SecKeyGetBlockSize(privateKeyRef) - 12;
        void *plain = malloc(plainLen);
        OSStatus status = SecKeyDecrypt(privateKeyRef, kSecPaddingPKCS1, cipher, cipherLen, plain, &plainLen);
        if (status != noErr) {
            [self sendResultEventWithCallbackId:rsaDecodeCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        }
        NSData *decryptedData = [[NSData alloc] initWithBytes:(const void *)plain length:plainLen];
        NSMutableString *outString = [[NSMutableString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        //如果没有进行加密直接解密，outString 将为 nil
        if (!outString && decryptedData && decryptedData.length > 0) {
            Byte *datas = (Byte*)[decryptedData bytes];
            outString = [NSMutableString stringWithCapacity:decryptedData.length * 2];
            for(int i = 0; i < decryptedData.length; i++){
                [outString appendFormat:@"%02x", datas[i]];
            }
        }
        [self sendResultEventWithCallbackId:rsaDecodeCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":outString} errDict:nil doDelete:NO];
    }
}

- (void)desECB:(NSDictionary *)paramsDict {
    NSInteger desEncCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:desEncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSString *DESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        [UZEncryptionTools sharedEncryptionTools].algorithm = kCCAlgorithmDES;
        NSString *desStr = [[UZEncryptionTools sharedEncryptionTools] encryptString:inString keyString:DESkey iv:nil];
        if (desStr) {
            [self sendResultEventWithCallbackId:desEncCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":desStr} errDict:nil doDelete:NO];
        } else {
            //err:-1
            [self sendResultEventWithCallbackId:desEncCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        }
    }
}

- (void)desDecodeECB:(NSDictionary *)paramsDict {
    NSInteger desDecCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:desDecCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSString *DESDeckey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        [UZEncryptionTools sharedEncryptionTools].algorithm = kCCAlgorithmDES;
        NSString *desStr = [[UZEncryptionTools sharedEncryptionTools] decryptUseDES:inString key:DESDeckey];
        if (desStr) {
            [self sendResultEventWithCallbackId:desDecCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":desStr} errDict:nil doDelete:NO];
        } else {
            //err:-1
            [self sendResultEventWithCallbackId:desDecCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        }
    }
}

- (void)hmacSha1:(NSDictionary *)paramsDict {
    NSInteger desDecCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        [self sendResultEventWithCallbackId:desDecCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(1)} doDelete:NO];
    } else {
        NSString *DESDeckey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        NSString *desStr = [self hmacSha1:DESDeckey text:inString];
        if (desStr) {
            [self sendResultEventWithCallbackId:desDecCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"value":desStr} errDict:nil doDelete:NO];
        } else {
            //err:-1
            [self sendResultEventWithCallbackId:desDecCbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:@{@"code":@(-1)} doDelete:NO];
        }
    }
}

- (NSString *)hmacSha1Sync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        NSString *AESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        NSString *desStr = [self hmacSha1:AESkey text:inString];
        if ([desStr isKindOfClass:[NSString class]] && desStr.length>0) {
            return desStr;
        } else {
            return @"";
        }
    }
}

#pragma mark - sync -

- (NSString *)md5Sync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        const char *cStrValue = [inString UTF8String];
        unsigned char outResult[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cStrValue, strlen(cStrValue), outResult);
        NSString *value = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                               outResult[0], outResult[1], outResult[2], outResult[3],
                               outResult[4], outResult[5], outResult[6], outResult[7],
                               outResult[8], outResult[9], outResult[10], outResult[11],
                               outResult[12], outResult[13], outResult[14], outResult[15]];
        BOOL isUpper = [paramsDict boolValueForKey:@"uppercase" defaultValue:true];
        value = isUpper ? [value uppercaseString] : [value lowercaseString];
        return value;
    }
}

- (NSString *)sha1Sync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        const char *cstr = [inString cStringUsingEncoding:NSUTF8StringEncoding];
        NSData *inData = [NSData dataWithBytes:cstr length:inString.length];
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(inData.bytes, inData.length, digest);
        
        NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
            [result appendFormat:@"%02x", digest[i]];
        }
        BOOL isUpper = [paramsDict boolValueForKey:@"uppercase" defaultValue:true];
        NSString *value = isUpper ? [result uppercaseString] : [result lowercaseString];

        return value;
    }
}

- (NSString *)aesSync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        NSString *AESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        
        NSData *plainText = [inString dataUsingEncoding:NSUTF8StringEncoding];
        // 'key' should be 32 bytes for AES256, will be null-padded otherwise
        char keyPtr[kCCKeySizeAES256+1];      // room for terminator (unused)
        bzero(keyPtr, sizeof(keyPtr));        // fill with zeroes (for padding)
        NSUInteger dataLength = [plainText length];
        
        size_t bufferSize = dataLength + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        bzero(buffer, sizeof(buffer));
        size_t numBytesEncrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                              kCCOptionPKCS7Padding,
                                              [[NSData AESKeyForPassword:AESkey] bytes],
                                              kCCKeySizeAES256,
                                              ivBuff,   //initialization vector (optional)
                                              [plainText bytes], dataLength,       //input
                                              buffer, bufferSize,                 //output
                                              &numBytesEncrypted);
        if (cryptStatus == kCCSuccess) {
            NSData *encryptData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
            NSString *value = [encryptData base64Encoding];
            return value;
        } else {
            free(buffer);
            return @"";
        }
    }
}

- (NSString *)aesDecodeSync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        NSString *AESDeckey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        NSData *cipherData = [NSData dataWithBase64EncodedString:inString];
        // 'key' should be 32 bytes for AES256, will be null-padded otherwise
        char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
        bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
        
        NSUInteger dataLength = [cipherData length];
        size_t bufferSize = dataLength + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        size_t numBytesDecrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                              kCCOptionPKCS7Padding,
                                              [[NSData AESKeyForPassword:AESDeckey] bytes],
                                              kCCKeySizeAES256,
                                              ivBuff ,      //initialization vector (optional)
                                              [cipherData bytes], dataLength,          //input
                                              buffer, bufferSize,                     //output
                                              &numBytesDecrypted);
        
        if (cryptStatus == kCCSuccess) {
            NSData *outData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
            NSMutableString *value = [[NSMutableString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
            //如果没有进行加密直接解密，outString 将为 nil
            if (!value && outData && outData.length > 0) {
                Byte *datas = (Byte*)[outData bytes];
                value = [NSMutableString stringWithCapacity:outData.length * 2];
                for(int i = 0; i < outData.length; i++){
                    [value appendFormat:@"%02x", datas[i]];
                }
            }
            return value;
        } else {
            free(buffer);
            return @"";
        }
    }
}

- (NSString *)aesECBSync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        NSString *AESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        
        NSString *aesStr = [AESCrypt encrypt:inString password:AESkey];
        if (aesStr) {
            return aesStr;
        } else {
            return @"";
        }
    }
}

- (NSString *)aesDecodeECBSync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        NSString *AESDeckey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        
        NSString *aesStr = [AESCrypt decrypt:inString password:AESDeckey];
        if (aesStr) {
            return aesStr;
        } else {
            return @"";
        }
    }
}

- (NSString *)base64Sync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        NSData *inData = [inString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSData *outData = [GTMBaseSignature64 encodeData:inData];
        NSString *value = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
        return value;
    }
}

- (NSString *)base64DecodeSync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        NSData *inData = [inString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSData *outData = [GTMBaseSignature64 decodeData:inData];
        NSString *value = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
        return value;
    }
}

- (NSString *)rsaSync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    NSString *value = [[NSString alloc] initWithString:@""];
    if (inString.length <= 0) {
        //err:1
        return value;
    } else {
        static SecKeyRef _public_key=nil;
        // 从公钥证书文件中获取到公钥的SecKeyRef指针:  @"public_key" ofType:@"der"
        NSString *publicKeyPath = [paramsDict stringValueForKey:@"publicKey" defaultValue:@""];
        publicKeyPath = [self getPathWithUZSchemeURL:publicKeyPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:publicKeyPath]) {
            return value;
        }
        NSData *certificateData = [[NSData alloc]initWithContentsOfFile:publicKeyPath];
        SecCertificateRef myCertificate =  SecCertificateCreateWithData(kCFAllocatorDefault, (CFDataRef)certificateData);
        SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
        SecTrustRef myTrust;
        OSStatus status = SecTrustCreateWithCertificates(myCertificate,myPolicy,&myTrust);
        SecTrustResultType trustResult;
        if (status == noErr) {
            status = SecTrustEvaluate(myTrust, &trustResult);
        }
        _public_key = SecTrustCopyPublicKey(myTrust);
        CFRelease(myCertificate);
        CFRelease(myPolicy);
        CFRelease(myTrust);
        
        SecKeyRef key = _public_key;
        size_t cipherBufferSize = SecKeyGetBlockSize(key);
        uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
        NSData *stringBytes = [inString dataUsingEncoding:NSUTF8StringEncoding];
        size_t blockSize = cipherBufferSize - 11;
        size_t blockCount = (size_t)ceil([stringBytes length] / (double)blockSize);
        NSMutableData *encryptedData = [[NSMutableData alloc] init];
        for (int i=0; i<blockCount; i++) {
            int bufferSize = MIN(blockSize,[stringBytes length] - i * blockSize);
            NSData *buffer = [stringBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
            OSStatus status = SecKeyEncrypt(key, kSecPaddingPKCS1, (const uint8_t *)[buffer bytes],
                                            [buffer length], cipherBuffer, &cipherBufferSize);
            if (status == noErr){
                NSData *encryptedBytes = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
                [encryptedData appendData:encryptedBytes];
            } else{
                value = @"";
            }
        }
        if (cipherBuffer) {
            free(cipherBuffer);
        }
        value = [encryptedData base64Encoding];
        return value;
    }
}

- (NSString *)rsaDecodeSync:(NSDictionary *)paramsDict {
    NSString *password = [paramsDict stringValueForKey:@"password" defaultValue:@""];
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    NSString *value = @"";
    if (inString.length <= 0) {
        //err:1
        return value;
    } else {
        // 从私钥证书文件中获取到公钥的SecKeyRef指针:  @"private_key" ofType:@"pem"
        NSString *privateKeyPath = [paramsDict stringValueForKey:@"privateKey" defaultValue:@""];
        privateKeyPath = [self getPathWithUZSchemeURL:privateKeyPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:privateKeyPath]) {
            return value;
        }
        NSData *p12Data = [[NSData alloc]initWithContentsOfFile:privateKeyPath];
        SecKeyRef privateKeyRef = NULL;
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setObject:password forKey:(__bridge id)kSecImportExportPassphrase];
        CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
        OSStatus securityError = SecPKCS12Import((__bridge CFDataRef) p12Data, (__bridge CFDictionaryRef)options, &items);
        if (securityError == noErr && CFArrayGetCount(items) > 0) {
            CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
            SecIdentityRef identityApp = (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
            securityError = SecIdentityCopyPrivateKey(identityApp, &privateKeyRef);
            if (securityError != noErr) {
                privateKeyRef = NULL;
            }
        } else {
            return value;
        }
        CFRelease(items);
        
        NSData *cipherData = [NSData dataWithBase64EncodedString:inString];
        //        NSData* decryptData = [self rsaDecryptData: data];
        size_t cipherLen = [cipherData length];
        void *cipher = malloc(cipherLen);
        [cipherData getBytes:cipher length:cipherLen];
        size_t plainLen = SecKeyGetBlockSize(privateKeyRef) - 12;
        void *plain = malloc(plainLen);
        OSStatus status = SecKeyDecrypt(privateKeyRef, kSecPaddingPKCS1, cipher, cipherLen, plain, &plainLen);
        if (status != noErr) {
            return value;
        }
        NSData *decryptedData = [[NSData alloc] initWithBytes:(const void *)plain length:plainLen];
        value = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        NSMutableString *outString = [[NSMutableString alloc] init];
        //如果没有进行加密直接解密，outString 将为 nil
        if (!value && decryptedData && decryptedData.length > 0) {
            Byte *datas = (Byte*)[decryptedData bytes];
            outString = [NSMutableString stringWithCapacity:decryptedData.length * 2];
            for(int i = 0; i < decryptedData.length; i++){
                [outString appendFormat:@"%02x", datas[i]];
            }
            value = [outString copy];
        }
        return value;
    }
}

- (NSString *)desECBSync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        NSString *DESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        
        [UZEncryptionTools sharedEncryptionTools].algorithm = kCCAlgorithmDES;
        NSString *desStr = [[UZEncryptionTools sharedEncryptionTools] encryptString:inString keyString:DESkey iv:nil];
        if (desStr) {
            return desStr;
        } else {
            return @"";
        }
    }
}

- (NSString *)desDecodeECBSync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        return @"";
    } else {
        NSString *DESDeckey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        
        [UZEncryptionTools sharedEncryptionTools].algorithm = kCCAlgorithmDES;
        NSString *desStr = [[UZEncryptionTools sharedEncryptionTools] decryptUseDES:inString key:DESDeckey];
        if (desStr) {
            return desStr;
        } else {
            return @"";
        }
    }
}

- (NSString *)aesCBCSync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        return @"";
    } else {
        NSString *AESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        NSString *offset = [paramsDict stringValueForKey:@"iv" defaultValue:@""];
        NSString *klength = [paramsDict stringValueForKey:@"keyLength" defaultValue:@""];
        NSData *plainText = [inString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encode = [self AES128operation:kCCEncrypt data:plainText key:AESkey iv:offset length:klength];
        if (encode) {
            encode = [encode uppercaseString];
            return encode;
        } else {
            return @"";
        }
    }
}
- (NSString *)aesDecodeCBCSync:(NSDictionary *)paramsDict {
    NSString *inString = [paramsDict stringValueForKey:@"data" defaultValue:@""];
    if (inString.length <= 0) {
        //err:1
        return @"";
    } else {
        inString = [inString lowercaseString];
        NSString *AESkey = [paramsDict stringValueForKey:@"key" defaultValue:@""];
        NSString *offset = [paramsDict stringValueForKey:@"iv" defaultValue:@""];
        NSString *klength = [paramsDict stringValueForKey:@"keyLength" defaultValue:@""];
        NSData *plainText = [self hex2data:inString];//[inString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encode = [self AES128operation:kCCDecrypt data:plainText key:AESkey iv:offset length:klength];
        if (encode) {
            return encode;
        } else {
            return @"";
        }
    }
}
# pragma mark - utility
- (NSString *)AES128operation:(CCOperation)operation data:(NSData *)data key:(NSString *)key iv:(NSString *)iv length:(NSString *)keyLenth {
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // IV
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    
    CCCryptorStatus cryptorStatus = CCCrypt(operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                            keyPtr, kCCKeySizeAES128,
                                            ivPtr,
                                            [data bytes], [data length],
                                            buffer, bufferSize,
                                            &numBytesEncrypted);
    
    if(cryptorStatus == kCCSuccess){
        //NSLog(@"Success");
        NSData *result = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        if (operation == 0) {
            Byte *bb = (Byte*)[result bytes];
            NSString *ciphertext = [UZConvertUtil parseByteArray2HexString:bb andCount:numBytesEncrypted];
            return ciphertext;
        }
        NSString *resultStr = [[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding];
        return resultStr;
    }else{
        //NSLog(@"Error");
    }
    
    free(buffer);
    return nil;
}

- (NSData *)hex2data:(NSString *)hex {
    NSMutableData *data = [NSMutableData dataWithCapacity:hex.length / 2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < hex.length / 2; i++) {
        byte_chars[0] = [hex characterAtIndex:i*2];
        byte_chars[1] = [hex characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

- (NSString *) hmacSha1:(NSString*)key text:(NSString*)text {
    //    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    //    const char *cData = [text cStringUsingEncoding:NSASCIIStringEncoding];
    //    //Sha256:
    //    // unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    //    //CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    //
    //    //sha1
    //    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    //    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    //
    //    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
    //                                          length:sizeof(cHMAC)];
    //
    //    NSString *hash = [HMAC base64EncodedStringWithOptions:0];//将加密结果进行一次BASE64编码。
    //    return hash;
    
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", cHMAC[i]];
    }
    hash = output;
    
    return hash;
}
@end
