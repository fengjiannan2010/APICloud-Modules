/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import "UZUIChatToolsAppendCell.h"

@implementation UZUIChatToolsAppendCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews {
    CGFloat magin = 5;
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(magin, 0, self.contentView.bounds.size.width - 2 * magin, self.contentView.bounds.size.width - 2 * magin)];
    [self.contentView addSubview:icon];
    self.icon = icon;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(icon.frame) + 5, self.contentView.bounds.size.width, self.contentView.bounds.size.height - 5 -  CGRectGetMaxY(icon.frame))];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:10];
    title.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:title];
    self.title = title;
}

@end
