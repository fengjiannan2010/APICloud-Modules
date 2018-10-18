/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import <UIKit/UIKit.h>

@interface UZUIChatToolsAppendCell : UICollectionViewCell

@property (nonatomic, weak) UIImageView *icon;
@property (nonatomic, weak) UILabel *title;
@property (nonatomic, copy) NSString *emotionName;
@property (nonatomic, copy) NSString *text;

@end
