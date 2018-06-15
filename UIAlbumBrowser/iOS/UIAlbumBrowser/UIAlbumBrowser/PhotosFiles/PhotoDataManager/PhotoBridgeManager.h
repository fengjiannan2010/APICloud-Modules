/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
#import <Foundation/Foundation.h>

#import <Photos/Photos.h>
/// 进行桥接进行回调的Manager
@interface PhotoBridgeManager : NSObject

/// 获取图片之后的回调
@property (nonatomic, copy, nullable)void(^BridgeGetImageBlock)(NSArray <UIImage *> *);

/// 获取图片的data
@property (nonatomic, copy, nullable)void(^BridgeGetImageDataBlock)(NSArray <NSData *> *);

/// 获取图片assets
@property (nonatomic, copy, nullable)void(^BridgeGetAssetBlock)(NSArray <PHAsset *> *);

/// 单例对象
+ (instancetype)sharedInstance;

/// 开始获取图片，触发RITLBridgeGetImageBlock
- (void)startRenderImage:(NSArray <PHAsset *> *)assets;

@end

