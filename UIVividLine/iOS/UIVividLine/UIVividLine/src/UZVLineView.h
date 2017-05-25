/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import <UIKit/UIKit.h>
#import "UZVLBubbleView.h"

@protocol UZBLineViewDelegate;

@interface UZVLineView : UIView

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) float max;
@property (nonatomic, assign) float min;
@property (nonatomic, assign) float step;
@property (nonatomic, assign) BOOL isDash, verticalDash;
@property (nonatomic, strong) UIColor *coordlineColor, *brokenlineColor, *verticalColor;
@property (nonatomic, assign) float coordlineWidth, brokenlineWidth, verticalWidth;
@property (nonatomic, assign) float xStepGap;
@property (nonatomic, assign) float xAxisHeight, yAxisWidth;
@property (nonatomic, assign) float nodeSize;
@property (nonatomic, strong) UIColor *nodeColor;
@property (nonatomic, assign) BOOL isHollow;
@property (nonatomic, strong) UIColor *xAxisMrkColor;
@property (nonatomic, assign) float xAxisMrkSize;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) id <UZBLineViewDelegate> delegate;
@property (nonatomic, assign) int blViewID;
@property (nonatomic, strong) UZVLBubbleView *bubble;
@property (nonatomic, assign) float iconWidth, iconHeight;

- (id)initWithFrame:(CGRect)frame withBubbleSize:(CGSize)size;

@end

@protocol UZBLineViewDelegate <NSObject>

- (void)didClickedNode:(int)index withBLine:(UZVLineView *)blView;
- (NSString *)getPathWith:(NSString *)paht;

@end
