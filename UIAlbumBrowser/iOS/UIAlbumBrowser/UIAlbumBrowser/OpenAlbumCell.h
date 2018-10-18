/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface OpenAlbumCell : UICollectionViewCell
@property (strong, nonatomic) UIButton *topBtn;
@property (strong, nonatomic) PHAsset * asset;
@property(nonatomic, assign)BOOL chooseStatus;
@property (nonatomic, strong) UIButton *signBtn;
@property (nonatomic, strong) UIImageView *videoImg;

@property(nonatomic,strong)NSDictionary *paramsDict;
@property(nonatomic, strong) CAShapeLayer *borderLayer;

@end
