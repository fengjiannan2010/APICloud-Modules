/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import <UIKit/UIKit.h>

@class UZUIChatToolsImageModel;
@class UZUIChatToolsImageCell;
@protocol UZUIChatToolsImageCellDelegate <NSObject>

///点击选择照片或者取消选择的小按钮
- (void)imageCell:(UZUIChatToolsImageCell *)imageCell didClickedButton:(UIButton *)button;
@end

@interface UZUIChatToolsImageCell : UICollectionViewCell

@property (nonatomic, strong) UZUIChatToolsImageModel *model;
@property (nonatomic, weak) id <UZUIChatToolsImageCellDelegate>delegate;

@end
