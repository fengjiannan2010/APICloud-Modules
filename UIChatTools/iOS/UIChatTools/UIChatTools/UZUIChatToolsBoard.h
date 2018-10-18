/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import <UIKit/UIKit.h>
#import "UZUIChatTools.h"
#import "UZUIChatToolsImagePickerView.h"
#import "UZUIChatToolsRecorderView.h"


@interface UZUIChatToolsBoard : UIView

@property (nonatomic, weak) UIView *emojiBoard;
@property (nonatomic, weak) UIScrollView *appendBoard;
@property (nonatomic, weak) UZUIChatToolsRecorderView *recorderBoard;
@property (nonatomic, weak) UZUIChatToolsImagePickerView *imageBoard;

@property (nonatomic, strong) NSMutableArray *emojiPathes;
@property (nonatomic, weak) UZUIChatTools *chatTools;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, copy) NSDictionary *appendButtonDict;
@property (nonatomic, assign) BOOL isOpenImageBoard;

@property (nonatomic, copy) void (^sendContent)(NSString *content);
@property (nonatomic, copy) void (^faceListenerCallback)(NSString *emoticonName, NSString *text);
@property (nonatomic, copy) void (^addFaceCallback)();
@property (nonatomic, copy) void (^appendBtnClickCallback)(NSInteger index);

- (void)addFace:(NSString *)path;

- (void)setupImageBoard;

@end
