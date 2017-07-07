//
//  UZApp.h
//  UZEngine
//
//  Created by 邹 达 on 13-11-12.
//  Copyright (c) 2013年 broad.zou. All rights reserved.
//

#import <Foundation/Foundation.h>

#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define isIOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0

@class UZWebView;
@interface UZAppUtils : NSObject

#pragma mark - Device info
+ (BOOL)isSimulator;
+ (BOOL)popoverSupported;
+ (NSString *)getUUID;

#pragma mark - Paths
+ (NSString *)bundlePath;
+ (NSString *)filePathInBundle:(NSString *)fileName_;
+ (NSURL *)fileURLInBundle:(NSString *)fileName_;
+ (NSString *)filePathInWidget:(NSString *)fileName_;
+ (NSURL *)fileURLInWidget:(NSString *)fileName_;
+ (NSString *)appDocumentPath;
+ (NSString *)filePathInDocument:(NSString*)fileName_;
+ (NSString *)uzfsPath;
+ (NSString *)filePathInUZFS:(NSString *)fileName_;
+ (NSString *)filePathInWidgetFS:(NSString *)fileName_;
+ (NSString *)getPathWithUZSchemeURL:(NSString *)urlStr_;
+ (BOOL)isFileReadOnly:(NSString*)filePath;

#pragma mark - Util
+ (UIColor *)colorFromNSString:(NSString*)colorStr_;

@end
