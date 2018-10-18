/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@interface GroupCell : UICollectionViewCell

@property (strong, nonatomic) UIButton *topBtn;
@property (strong, nonatomic) PHAsset * asset;
@property(nonatomic, assign)BOOL chooseStatus;
@property (nonatomic, strong) UIButton *signBtn;
@property(nonatomic, strong) CAShapeLayer *borderLayer;

/* block 属性使用,参考: https://www.jianshu.com/p/073db200b285 */
//@property (nonatomic, copy)  void(^tapCallback) (NSString * path);

@end
