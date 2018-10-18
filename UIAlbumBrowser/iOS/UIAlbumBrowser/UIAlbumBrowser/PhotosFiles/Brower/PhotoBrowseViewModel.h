/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "BaseViewModel.h"
#import "RITLCollectionViewModel.h"
#import <Photos/Photos.h>
typedef PhotoCompleteBlock8 BrowerRequestQuarityBlock;
typedef PhotoCompleteBlock0 BrowerQuarityCompleteBlock;
typedef PhotoCompleteBlock9 BrowerQuarityStatusChangeBlock;

@interface PhotoBrowseViewModel : BaseViewModel <RITLCollectionViewModel>

@property (nonatomic, strong)NSDictionary *paramsDict;
/// 当前图片的位置指数
@property (nonatomic, assign)NSUInteger currentIndex;

/// 存储图片选择的所有资源对象
@property (nonatomic, copy)NSArray <PHAsset *> * _Nullable allAssets;

/// 所有的图片资源
@property (nonatomic, copy)NSArray <PHAsset *> * _Nullable allPhotoAssets;

/// 当前位置的cell应该显示清晰图的block
@property (nonatomic, copy, nullable)void(^ritl_BrowerCellShouldRefreshBlock)(UIImage *_Nullable,PHAsset *_Nullable,NSIndexPath *_Nullable);

/// 当前的选中按钮刷新成当前图片的block
@property (nonatomic, copy, nullable)void(^ritl_BrowerSelectedBtnShouldRefreshBlock)(UIImage *_Nullable);

/// 当前控制器将要消失的block
@property (nonatomic, copy, nullable)void(^ritl_BrowerWillDisAppearBlock)(void);

/// 响应是否显示当前数目标签以及数目的block
@property (nonatomic, copy, nullable)void(^ritl_BrowerSendStatusChangedBlock)(BOOL,NSUInteger);

/// 当前控制器的bar对象是否隐藏的block
@property (nonatomic, copy, nullable)void(^ritl_BrowerBarHiddenStatusChangedBlock)(BOOL);


#pragma mark - hightQuarity

/// 高清状态发生变化的block
@property (nonatomic, copy, nullable)BrowerQuarityStatusChangeBlock ritl_browerQuarityChangedBlock;

/// 请求高清数据过程的block
@property (nonatomic, copy, nullable)BrowerRequestQuarityBlock ritl_browerRequestQuarityBlock;

/// 请求高清数据完毕的block
@property (nonatomic, copy, nullable)BrowerQuarityCompleteBlock ritl_browerQuarityCompleteBlock;


/**
 点击选择按钮,触发ritl_BrowerSelectedBtnShouldRefreshBlock
 
 @param scrollView 当前的collectionView
 */
- (void)selectedPhotoInScrollView:(UICollectionView *_Nullable)scrollView;


/**
 控制器将要消失的方法
 */
- (void)controllerViewWillDisAppear;


/**
 点击发送执行的方法
 
 @param collection 当前的collectionView
 */
- (void)photoDidSelectedComplete:(UICollectionView *_Nullable)collection;


/**
 获得当前的位置的图片对象
 
 @param indexPath 当前的位置
 @param collection collectionView
 @param isThumb 是否为缩略图，如果为false，则按照图片原始比例获得
 @param completeBlock 完成后的回调
 */
- (void)imageForIndexPath:(NSIndexPath *_Nullable)indexPath
               collection:(UICollectionView *_Nullable)collection
                  isThumb:(BOOL)isThumb
                 complete:(void(^_Nullable)(UIImage *_Nullable,PHAsset *_Nullable)) completeBlock;


/**
 滚动视图结束滚动的方法
 */
- (void)viewModelScrollViewDidEndDecelerating:(UIScrollView *_Nullable)scrollView;



/**
 高清状态发生变化
 */
- (void)highQualityStatusShouldChanged:(UIScrollView *_Nullable)scrollView;



/**
 发送控制器应该处理bar对象隐藏与否的信号
 */
- (void)sendViewBarDidChangedSignal;


@end


