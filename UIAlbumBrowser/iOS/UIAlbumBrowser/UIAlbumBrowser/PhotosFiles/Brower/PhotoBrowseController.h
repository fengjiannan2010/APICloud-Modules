/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <UIKit/UIKit.h>
#import "RITLCollectionViewModel.h"
#import "RITLPhotoViewController.h"


@interface PhotoBrowseController : UIViewController <RITLPhotoViewController>

/// 当前控制器的viewModel
@property (nonatomic, strong) id <RITLCollectionViewModel> viewModel;

@end


@interface PhotoBrowseController (UpdateNumberOfLabel)

/**
 更新选中的图片数
 
 @param number 选中的图片数
 */
- (void)updateNumbersForSelectAssets:(NSUInteger)number;

@end


@interface PhotoBrowseController (UpdateSizeLabel)


/**
 更新高清显示的状态
 
 @param isHightQuarity 是否为高清状态
 */
- (void)updateSizeLabelForIsHightQuarity:(BOOL)isHightQuarity;

@end


@interface PhotoBrowseController (PhotosViewController)

@end


