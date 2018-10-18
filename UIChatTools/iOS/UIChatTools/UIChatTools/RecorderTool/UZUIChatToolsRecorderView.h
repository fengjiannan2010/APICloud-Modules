/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ListenType) {
    ListenTypePress,
    ListenTypeAudition,
    ListenTypeAuditionCancel,
    ListenTypeaSend,
    ListenTypeCancel,
    ListenTypeAuditionTouchOn,
    ListenTypeShortTime,
    ListenTypeStart,
    ListenTypeStop,
    ListenTypeAudition_recorder,
    ListenTypeSend_recorder,
    ListenTypeAuditionCancel_recorder,
};

typedef NS_ENUM(NSUInteger, RecorderState) {
    RecorderStateNormal,
    RecorderStateIng,
    RecorderStatePause,
    RecorderStatePlay,
};

typedef NS_ENUM(NSUInteger, TalkbackState) {
    TalkbackStateNormal,
    TalkbackStatePlay,
    TalkbackStatePause,
};

@class UZUIChatToolsRecorderView;
@protocol UZUIChatToolsRecorderViewDelegate <NSObject>

- (void)recorderView: (UZUIChatToolsRecorderView *)recorderView listenType:(ListenType )listenType;

@end

@interface UZUIChatToolsRecorderView : UIView

@property (nonatomic, assign) BOOL isStartTimer;
@property (nonatomic, weak) id<UZUIChatToolsRecorderViewDelegate> delegate;
@property (nonatomic, assign) RecorderState recorderState;
@property (nonatomic, assign) TalkbackState talkbackState;
- (void)creatTimer;

@end
