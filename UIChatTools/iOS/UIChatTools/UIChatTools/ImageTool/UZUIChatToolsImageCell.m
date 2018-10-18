/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import "UZUIChatToolsImageCell.h"
#import "UZUIChatToolsImageModel.h"
#define KCountLabelWidth 27

@interface UZUIChatToolsImageCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *seletedButton;

@end

@implementation UZUIChatToolsImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc]initWithFrame:frame];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        
        [self addSubview:self.imageView];
        self.seletedButton = [[UIButton alloc]init];
        self.seletedButton.bounds = CGRectMake(0, 0, KCountLabelWidth, KCountLabelWidth);
        self.seletedButton.layer.masksToBounds = YES;
        self.seletedButton.layer.cornerRadius = KCountLabelWidth *0.5;
        self.seletedButton.titleLabel.font = [UIFont systemFontOfSize:12];
        self.seletedButton.backgroundColor = [UIColor grayColor];
        self.seletedButton.alpha = 0.5;
        [self.seletedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self.seletedButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.seletedButton.layer.borderWidth = 2;
        [self addSubview:self.seletedButton];
        [self.seletedButton addTarget:self action:@selector(seletedButtonDidSelected:) forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
}

- (void)pointSeleteButton:(CGPoint )offset{
    CGPoint rightPoint = CGPointMake(offset.x + [UIScreen mainScreen].bounds.size.width, 40);
    CGFloat rightPoint_x = offset.x + [UIScreen mainScreen].bounds.size.width;
    if (CGRectContainsPoint(self.frame, rightPoint)) {
        CGPoint newCenter = CGPointMake(rightPoint_x - self.frame.origin.x - KCountLabelWidth * 0.5 -3   , KCountLabelWidth * 0.5);
        if ( newCenter.x < KCountLabelWidth *0.5 + 3) {
            newCenter = CGPointMake( KCountLabelWidth *0.5 + 3 , KCountLabelWidth * 0.5);
        }
        self.seletedButton.center = newCenter;
    }else{
        
        self.seletedButton.center =CGPointMake(self.frame.size.width - KCountLabelWidth *0.5 -3, KCountLabelWidth *0.5);
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

- (void)setModel:(UZUIChatToolsImageModel *)model{
    _model = model;
    self.imageView.image = model.image;
    [self pointSeleteButton:model.offset];
    if (model.count > 0) {
        self.seletedButton.alpha = 0.9;
        self.seletedButton.selected = YES;
        self.seletedButton.backgroundColor = [UIColor colorWithRed:46 / 255.0 green:178 / 255.0 blue:243 / 255.0 alpha:1.0];
        [self.seletedButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)model.count] forState:UIControlStateSelected];
    }else{
        self.seletedButton.alpha = 0.5;
        self.seletedButton.selected = NO;
        self.seletedButton.backgroundColor = [UIColor grayColor];
        [self.seletedButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)seletedButtonDidSelected:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(imageCell:didClickedButton:)]) {
        [self.delegate imageCell:self didClickedButton:button];
    }
}




@end
