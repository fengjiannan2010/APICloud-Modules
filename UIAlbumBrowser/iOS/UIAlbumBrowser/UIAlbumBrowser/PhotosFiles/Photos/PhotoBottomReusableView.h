/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <UIKit/UIKit.h>


@interface PhotoBottomReusableView : UICollectionReusableView

/// @brief simple method to set the number of asset in the assCountlabel
@property (nonatomic, assign)NSUInteger numberOfAsset;

/// @brief the custom title in the assetCountLabel
@property (nullable ,nonatomic, copy)NSString * customText;

/// @brief show the title with the number if asset,default text is 共有375张照片
@property (strong, nonatomic) IBOutlet UILabel * assetCountLabel;

@end

