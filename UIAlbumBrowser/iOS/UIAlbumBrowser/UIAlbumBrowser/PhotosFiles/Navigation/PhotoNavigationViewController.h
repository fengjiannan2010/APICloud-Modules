/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <UIKit/UIKit.h>
#import "RITLPhotoViewController.h"
#import "RITLPublicViewModel.h"

@class PhotoNavigationViewModel;

/// 进入控制器的主导航控制器
 @interface PhotoNavigationViewController : UINavigationController <RITLPhotoViewController>

/// 控制器的viewModel
@property (nonatomic, strong) PhotoNavigationViewModel * viewModel;

@property (nonatomic, assign) BOOL isRotation;


@end


