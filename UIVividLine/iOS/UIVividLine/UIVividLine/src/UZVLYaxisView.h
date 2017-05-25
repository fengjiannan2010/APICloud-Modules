/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import <UIKit/UIKit.h>

@interface UZVLYaxisView : UIView

@property (nonatomic, assign) float max;
@property (nonatomic, assign) float min;
@property (nonatomic, assign) float step;
@property (nonatomic, assign) float dotXSize;
@property (nonatomic, assign) float dotYSize;
@property (nonatomic, assign) float markSize;
@property (nonatomic, assign) float lineWidth;
@property (nonatomic, assign) float xAxisHeigh;
@property (nonatomic, strong) NSString *yText;
@property (nonatomic, strong) NSString *xText;
@property (nonatomic, strong) NSString *suffix;
@property (nonatomic, strong) UIColor *yTextColor;
@property (nonatomic, strong) UIColor *xTextColor;
@property (nonatomic, strong) UIColor *markColor;

@end
