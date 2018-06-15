/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationBar (YPPhotoDemo)

/// 设置 背景色
- (void)setViewColor:(UIColor * _Nonnull)color;

/// 设置透明度
- (void)setViewAlpha:(CGFloat)alpha;

/// 清除图层,视图消失时需要调用该方法，不然会影响其他页面的效果
- (void)relieveCover;

@end


@interface UITabBar (YPPhotoDemo)

/// 设置 背景色
- (void)setViewColor:(UIColor * _Nonnull)color;

/// 设置透明度
- (void)setViewAlpha:(CGFloat)alpha;

/// 清除图层,视图消失时需要调用该方法，不然会影响其他页面的效果
- (void)relieveCover;

@end


NS_ASSUME_NONNULL_END
