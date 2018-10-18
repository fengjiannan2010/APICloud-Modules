/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

/// 负责缓存选择图片对象的管理者
@interface PhotoCacheManager : NSObject

/// 最大允许选择的图片数目，默认为MAX
@property (nonatomic, assign) NSUInteger maxNumberOfSelectedPhoto;

/// 记录当前选择的数量
@property (nonatomic, assign) NSUInteger numberOfSelectedPhoto;

/// 图片的大小，默认为RITLPhotoOriginSize
@property (nonatomic, assign) CGSize imageSize;

/// 是否为高清图，默认为false
@property (nonatomic, assign) BOOL isHightQuarity;

/// 资源是否为图片的标志位
@property (nonatomic, assign) BOOL * assetIsPictureSignal;

/// 资源是否被选中的标志位
@property (nonatomic, assign) BOOL * assetIsSelectedSignal;

/*
资源状态变化的顺序.每次选中操作都会导致资源的的状态变化顺序递增1. 资源顺序可以不连续,但是一定要符合从小到大的趋势.
 不必连续的原因的原因是: 只有相对顺序才是最重要的.
 */
@property (nonatomic, assign) int * assetSelectedStatusChangeOrderSignal;

@property (nonatomic, assign) int statusChangeOrder;

/// 获得单例对象
+ (instancetype)sharedInstace;


/**
 初始化资源是否为图片的标志位
 
 @param count 初始化长度
 */
- (void)allocInitAssetIsPictureSignal:(NSUInteger)count;


/**
 初始化资源是否被选中的标志位
 
 @param count 初始化长度
 */
- (void)allocInitAssetIsSelectedSignal:(NSUInteger)count;


/**
 修改index位置的选中状态

 */
- (BOOL)changeAssetIsSelectedSignal:(NSUInteger)index;


/**
 释放除了最大限制的所有属性
 */
- (void)freeSignalIngnoreMax;



/**
 重置默认的最大选择数量
 */
- (void)resetMaxSelectedCount;

/**
 释放所有的信号资源
 */
- (void)freeAllSignal __deprecated_msg("no safe");


@end

