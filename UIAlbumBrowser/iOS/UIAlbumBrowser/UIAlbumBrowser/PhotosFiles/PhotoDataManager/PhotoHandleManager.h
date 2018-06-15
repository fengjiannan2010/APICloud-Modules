/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

/// 对选择后的图片进行筛选的管理者
@interface PhotoHandleManager : NSObject

/**
 获得选择的图片数组
 
 @param assets 所有的图片数组
 @param status 选中状态
 @return
 */
+ (NSArray <PHAsset *> *)assetForAssets:(NSArray <PHAsset *> *)assets status:(BOOL *)status
                                 orders:(int *)orders;


@end


@interface PhotoHandleManager (DurationTime)


/**
 将时间戳转换为当前的总时间，格式为00:00:00
 
 @param timeInterval 转换的时间戳
 @return 转换后的格式化字符串
 */
+ (NSString *) timeStringWithTimeDuration:(NSTimeInterval)timeInterval;


@end


