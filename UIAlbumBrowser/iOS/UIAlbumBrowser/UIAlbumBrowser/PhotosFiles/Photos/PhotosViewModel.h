/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "BaseViewModel.h"
#import "RITLCollectionCellViewModel.h"
#import "RITLCollectionViewModel.h"

typedef PhotoCompleteBlock7 PhotoDidTapHandleBlock;
typedef PhotoCompleteBlock6 PhotoSendStatusBlock;

/// 选择图片的一级界面控制器的viewModel
@interface PhotosViewModel : BaseViewModel <RITLCollectionViewModel>

/// 当前显示的导航标题
@property (nonatomic, copy) NSString * navigationTitle;

/// 当前显示的组对象
@property (nonatomic, strong) PHAssetCollection * assetCollection;

/// 存储该组所有的asset对象的集合
@property (nonatomic, strong, readonly) PHFetchResult * assetResult;

/// 图片被点击进入浏览控制器的block
@property (nonatomic, copy)PhotoDidTapHandleBlock photoDidTapShouldBrowerBlock;

/// 响应是否能够点击预览以及发送按钮的block
@property (nonatomic, copy)PhotoSendStatusBlock photoSendStatusChangedBlock;

/// 点击预览进入浏览控制器的block，暂时使用photoDidTapShouldBrowerBlock替代
@property (nonatomic, copy)PhotoDidTapHandleBlock pushBrowerControllerByBrowerButtonBlock;

@property (nonatomic, strong) NSDictionary * paramsDict;
/**
 通过点击浏览按钮弹出浏览控制器，触发pushBrowerControllerByBrowerButton
 */
- (void)pushBrowerControllerByBrowerButtonTap;


/// 资源数
- (NSUInteger)assetCount;

/// 请求当前图片对象
- (void)imageForIndexPath:(NSIndexPath *)indexPath
               collection:(UICollectionView *)collection
                 complete:(void(^)(UIImage *,PHAsset *,BOOL,NSTimeInterval)) completeBlock;


/**
 图片被选中的处理方法
 
 @param indexPath
 */
- (BOOL)didSelectImageAtIndexPath:(NSIndexPath *)indexPath;


/**
 该位置的图片是否选中
 
 @param indexPath
 @return
 */
- (BOOL)imageDidSelectedAtIndexPath:(NSIndexPath *)indexPath;


@end

