/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import <UIKit/UIKit.h>

typedef void(^CF_textHeightChangedBlock)(NSString *text,CGFloat textHeight);


@interface UZUIChatToolsInputView : UITextView

@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic,strong) UIFont *placeholderFont;

@property (nonatomic, assign) NSUInteger maxNumberOfLines;

@property (nonatomic, strong) CF_textHeightChangedBlock textHeightChangedBlock;

@property (nonatomic, assign) NSUInteger cornerRadius;

@property (nonatomic, copy) void(^textChangeBlock)();

- (void)textHeightDidChanged:(CF_textHeightChangedBlock)block;


@end

