/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import "RITLPublicViewModel.h"
#import "RITLPhotoConfig.h"

typedef PhotoBlock          ShouldDismissBlock;
typedef PhotoCompleteBlock6 ShouldAlertToWarningBlock;

/// 基础的viewModel
@interface BaseViewModel : NSObject <RITLPublicViewModel>

/// 选择图片达到最大上限，需要提醒的block
@property (nonatomic, copy, nullable)ShouldAlertToWarningBlock warningBlock;

/// 模态弹出的回调
@property (nonatomic, copy, nullable)ShouldDismissBlock dismissBlock;


/// 选择图片完成
- (void)photoDidSelectedComplete;

@end

