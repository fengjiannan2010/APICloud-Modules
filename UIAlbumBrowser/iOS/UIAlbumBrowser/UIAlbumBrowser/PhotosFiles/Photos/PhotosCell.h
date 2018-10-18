/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */


#import <UIKit/UIKit.h>

@class PhotosCell;

typedef void(^PhotosCellOperationBlock)(PhotosCell * __nullable cell);


@interface PhotosCell : UICollectionViewCell


/// display backgroundImage
@property (strong, nonatomic) IBOutlet UIImageView * _Nullable imageView;

/// default hidden is true
@property (strong, nonatomic) IBOutlet UIView * _Nullable messageView;

/// imageView in messageView to show the kind of asset
@property (strong, nonatomic) IBOutlet UIImageView * _Nullable messageImageView;

/// label in messageVie to show the information
@property (strong, nonatomic) IBOutlet UILabel * _Nullable messageLabel;

/// 负责显示选中的按钮
@property (strong, nonatomic) UIImageView * _Nullable chooseImageView;

/// 负责响应点击事件的Control对象
@property (strong, nonatomic) UIControl * _Nullable chooseControl;

@property (strong, nonatomic) NSDictionary * _Nullable markDict;

/// control对象点击的回调
@property (nullable, copy, nonatomic)PhotosCellOperationBlock chooseImageDidSelectBlock;

#pragma mark - Deprecated

/// button in order to display the selected image
@property (strong, nonatomic) IBOutlet UIButton * _Nullable chooseImageViewBtn __deprecated_msg("Use chooseImageView");

@end

@interface PhotosCell (RITLPhotosViewModel)
/**
 cell进行点击
 
 @param isSelected 是否已经选中过
 */
- (void) cellSelectedAction:(BOOL)isSelected;
@end

