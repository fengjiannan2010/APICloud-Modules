/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import "UZVLBubbleView.h"
#import "UZAppUtils.h"

@interface UZVLBubbleView ()

@property (nonatomic, strong) UILabel *titleLable;
@end

@implementation UZVLBubbleView

@synthesize fontSize;
@synthesize bubbleBg, fontColor, suffix;
@synthesize title;
@synthesize titleLable;

- (void)dealloc {
    if (bubbleBg) {
        self.bubbleBg = nil;
    }
    if (fontColor) {
        self.fontColor = nil;
    }
    if (suffix) {
        self.suffix = nil;
    }
    if (titleLable) {
        [titleLable removeFromSuperview];
        self.titleLable = nil;
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //label
        CGRect lableRect = CGRectMake(0, 0, frame.size.width, frame.size.height-2);
        UILabel *titlelab = [[UILabel alloc]initWithFrame:lableRect];
        titlelab.backgroundColor = [UIColor clearColor];
        titlelab.textAlignment = UITextAlignmentCenter;
        [self addSubview:titlelab];
        self.titleLable = titlelab;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //背景
    UIImage *bgImg = [UIImage imageWithContentsOfFile:self.bubbleBg];
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    bgView.image = bgImg;
    [self addSubview:bgView];
    
    [self bringSubviewToFront:self.titleLable];
}

- (void)setTitle:(float)newTitle {
    NSString *showTitle = [self valueTransStr:newTitle];
    self.titleLable.textColor = [UZAppUtils colorFromNSString:self.fontColor];
    self.titleLable.font = [UIFont systemFontOfSize:self.fontSize];
    self.titleLable.text = showTitle;
}

- (NSString *)valueTransStr:(float)value {
    NSString *str = [NSString stringWithFormat:@"%g",value];
    str = [NSString stringWithFormat:@"%@%@", str, self.suffix];
    return str;
}

@end
