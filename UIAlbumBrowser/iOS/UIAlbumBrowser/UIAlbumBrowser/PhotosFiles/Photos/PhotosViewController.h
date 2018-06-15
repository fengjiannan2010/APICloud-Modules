/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <UIKit/UIKit.h>
#import "RITLCollectionViewModel.h"
#import "RITLPhotoViewController.h"

/// 选择图片的一级界面控制器
 @interface PhotosViewController : UIViewController <RITLPhotoViewController>

/// 当前控制器的viewModel
@property (nonatomic, strong) id <RITLCollectionViewModel> viewModel;



@end


@interface PhotosViewController (updateNumberOfLabel)

/**
 更新选中的图片数
 
 @param number 选中的图片数
 */
- (void)updateNumbersForSelectAssets:(NSUInteger)number;

@end




