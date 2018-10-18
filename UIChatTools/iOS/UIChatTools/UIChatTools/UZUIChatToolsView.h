/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import <UIKit/UIKit.h>
#import "UZUIChatTools.h"
#import "UZUIChatToolsInputView.h"

#define screenH  [UIScreen mainScreen].bounds.size.height
#define screenW  [UIScreen mainScreen].bounds.size.width

@class UZUIChatToolsView;

@protocol UZUIChatToolsViewDelegate <NSObject>

@optional
- (void)chatToolsView:(UZUIChatToolsView *)chatToolsView didClickButton:(UIButton *)button;

@end

@interface UZUIChatToolsView : UIView

@property (nonatomic, weak) id<UZUIChatToolsViewDelegate> delegate;
@property (nonatomic, weak) UZUIChatTools *chatTools;
@property (nonatomic, weak) UZUIChatToolsInputView *chatBoxView;
@property (nonatomic, weak) UIView *toolView;
@property (nonatomic, weak) UIButton *faceButton;
@property (nonatomic, weak) UIButton *appendButton;
@property (nonatomic, copy) void(^sendMessage)(NSString *message);



- (instancetype)initWithParams:(NSDictionary *)params chatTools:(UZUIChatTools *)chatTools;

- (void)clickAction:(UIButton *)btn;
@end
