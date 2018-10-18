/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import <UIKit/UIKit.h>
#import "UZUIChatToolsImageModel.h"


@class UZUIChatToolsImagePickerView;
@protocol UZUIChatToolsImagePickerViewDelegate <NSObject>

- (void)imagePickerView:(UZUIChatToolsImagePickerView *)imagePickerView didClickedButton:(UIButton *)button isOriginalImage:(BOOL)isOriginalImage selectedArray:(NSArray *)selectedArray;

@end

@interface UZUIChatToolsImagePickerView : UIView

@property (nonatomic, copy) NSArray *dataArr;
@property (nonatomic, weak) id<UZUIChatToolsImagePickerViewDelegate> delegate;
@end
