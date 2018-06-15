/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

/// @brief 响应3D Touch出现的控制器
@interface PhotoPreviewController : UIViewController

/// 资源大小
@property (nonatomic, readonly, assign) CGSize assetSize;

/// 当前显示的Image
@property (nonatomic, readonly, strong) PHAsset * showAsset;

/// 便利初始化方法
-(instancetype)initWithShowAsset:(PHAsset *)showAsset;

/// 便利构造器
+(instancetype)previewWithShowAsset:(PHAsset *)showAsset;

@end

