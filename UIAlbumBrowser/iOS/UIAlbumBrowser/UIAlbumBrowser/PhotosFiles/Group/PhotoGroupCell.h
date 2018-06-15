/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <UIKit/UIKit.h>

/// 组的自定义cell
@interface PhotoGroupCell : UITableViewCell
/// 显示图片的imageView
@property (strong, nonatomic) IBOutlet UIImageView * imageView;

/// 分组的名称
@property (strong, nonatomic) IBOutlet UILabel * titleLabel;

/// @brief 种类类别的ImageView,暂时无用
@property (strong, nonatomic) IBOutlet UIImageView * categoryImageView;

@end

