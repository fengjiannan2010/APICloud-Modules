/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import "NVTBBadgeView.h"
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"

@implementation NVTBBadgeView {
    CGFloat fontSize;
}

@dynamic contentSize;

- (instancetype)initWithTitle:(NSString *)title config:(NSDictionary *)config
{
    self = [super init];
    if (nil != self ) {
        [self setUserInteractionEnabled: NO];        // 关闭用户交互,以免影响徽章所在父视图的点击.
        self.backgroundColor = [UIColor clearColor]; // 设置一个合适的背景色.
        self.title = title;
        self.config = [NSMutableDictionary dictionaryWithDictionary: config];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect: rect];
    /* 设置配置信息. */
    NSString *bgPath = [self.config stringValueForKey:@"bgColor" defaultValue:@"#ff0"];
    NSString *numColorPath = [self.config stringValueForKey:@"numColor" defaultValue:@"#fff"];
    if (bgPath.length <= 0) {
        bgPath = @"#ff0";
    }
    if (numColorPath.length <= 0) {
        numColorPath = @"#fff";
    }
    UIColor *bgColor = [UZAppUtils colorFromNSString:bgPath];
    UIColor *titleColor = [UZAppUtils colorFromNSString:numColorPath];
    CGSize contentSize = self.contentSize;   // 内容尺寸.
    float width = contentSize.width;         // 内容宽度.
    float height = contentSize.height;       // 内容高度.
    //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    CGContextRef context = UIGraphicsGetCurrentContext();
    //填充颜色
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    // 徽章为空时,只保留一个标准 badgeSize*badgeSize 圆点 即可.
    
    if ([self.title isEqualToString:@"0"] || self.title == nil) {
        return;
    }
    if([self.title isEqualToString: @""]){
        //画圆
        CGContextAddArc(context, height/2.0, height/2.0, height/2.0, 0, 2*M_PI, 0);
        //绘制填充
        CGContextDrawPath(context, kCGPathFill);
    } else {
        
        //画左半圆
        CGContextAddArc(context, height/2.0, height/2.0, height/2.0, M_PI/2.0, M_PI/2.0+M_PI, 0);
        CGContextDrawPath(context, kCGPathFill);
        //画矩形
        CGContextSetStrokeColorWithColor(context, bgColor.CGColor);
        CGContextAddRect(context,CGRectMake(height/2.0, 0, width-height, height));
        CGContextDrawPath(context, kCGPathFillStroke);
        //画右半圆
        CGContextAddArc(context, width-height/2.0, height/2.0, height/2.0, M_PI/2.0, M_PI/2.0+M_PI, 1);
        CGContextDrawPath(context, kCGPathFill);
        //画数字
        CGSize titleSize = [self.title sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, MAXFLOAT)];
        CGContextSetFillColorWithColor(context, titleColor.CGColor);  //填充颜色
        [self.title drawInRect:CGRectMake((width-titleSize.width)/2.0, (height-titleSize.height)/2.0, width, height) withFont: [UIFont systemFontOfSize:fontSize]];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    /* 根据风格类型,强制调整在父视图的相对位置. */
    if(nil == self.superview){
        return;
    }
    CGFloat w = self.contentSize.width;
    CGFloat h = self.contentSize.height;
    CGFloat x = self.superview.frame.size.width-w/2.0;
    CGFloat y = -h/2.0;
    if (self.superview.frame.origin.x < 0) {
        x -= fabs(self.superview.frame.origin.x) ;
    }
    if (self.superview.frame.origin.y < 0) {
        y += fabs(self.superview.frame.origin.y);
    }
    self.frame = CGRectMake(x, y, w, h);

    NSNumber * centerX = [self.config objectForKey:@"centerX"];
    NSNumber * centerY = [self.config objectForKey:@"centerY"];
    
    CGFloat centerXValue = centerX ? [centerX floatValue ]: self.center.x;
    CGFloat centerYValue = centerY ? [centerY floatValue] : self.center.y;
    self.center = CGPointMake(centerXValue, centerYValue);
}

- (CGSize)contentSize {
    if (nil == self.superview) { // 尚未添加到父视图,不做处理.
        return CGSizeMake(0, 0);
    }
    CGFloat badgeSize = [self.config floatValueForKey:@"size" defaultValue:6.0];
    fontSize = badgeSize*2.0 - 2.0;
    CGSize size = [self.title sizeWithFont:[UIFont systemFontOfSize:fontSize]
                         constrainedToSize:CGSizeMake(190,200)];
    // 考虑左右两端还各需要一个半圆.
    size.width += badgeSize;
    if (size.width < badgeSize*2.0) {
        size.width = badgeSize*2.0;
    }
    size.height = badgeSize * 2.0;
    // 徽章为空时,只保留一个标准 badgeSize*badgeSize 圆点 即可.
    if([self.title isEqualToString: @""]){
        size = CGSizeMake(badgeSize, badgeSize);
        return size;
    }
    return CGSizeMake(size.width,badgeSize*2.0);
}

@end
