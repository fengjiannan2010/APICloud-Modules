/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import "UZVLYaxisView.h"

@implementation UZVLYaxisView

@synthesize max, min, step;
@synthesize yText, yTextColor, xText, xTextColor, markColor, suffix;
@synthesize dotXSize, dotYSize, markSize, lineWidth, xAxisHeigh;

- (void)dealloc{
    if (yText) {
        self.yText = nil;
    }
    if (yTextColor) {
        self.yTextColor = nil;
    }
    if (xText) {
        self.xText = nil;
    }
    if (xTextColor) {
        self.xTextColor = nil;
    }
    if (markColor) {
        self.markColor = nil;
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    float distance = self.max - self.min;//最大最小差值
    int markNum = distance/self.step;//计算横线个数
    float stepDist = (rect.size.height-self.xAxisHeigh)/markNum;//计算每条横线间隔
    float orignal = rect.size.height - self.xAxisHeigh;//计算第一条横线的y坐标
    //从下往上添加y轴标注数字
    for (int i=1; i<markNum; i++){
        UILabel *markLabel = [[UILabel alloc]init];
        markLabel.frame = CGRectMake(0, orignal-stepDist*i-self.markSize/2.0, rect.size.width, self.markSize);
        markLabel.backgroundColor = [UIColor clearColor];
        markLabel.textColor = self.markColor;
        markLabel.textAlignment = UITextAlignmentCenter;
        markLabel.font = [UIFont systemFontOfSize:self.markSize];
        NSString *text = [NSString stringWithFormat:@"%.0f%@",self.min + self.step*i,self.suffix];
        markLabel.text = text;
        [self addSubview:markLabel];
    }
    /*
    //画原点标注
    UILabel *markLabelY = [[UILabel alloc]init];
    markLabelY.frame = CGRectMake(5,orignal+5 , rect.size.width/2.0, stepDist/2.0);
    markLabelY.backgroundColor = [UIColor clearColor];
    markLabelY.textColor = self.yTextColor;
    markLabelY.textAlignment = UITextAlignmentCenter;
    markLabelY.font = [UIFont systemFontOfSize:self.dotYSize];
    markLabelY.text = self.yText;
    [self addSubview:markLabelY];
    //中间斜线，颜色和mark一致
    CGContextRef contexts =UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contexts, lineWidth);//画笔粗细
    CGContextSetStrokeColorWithColor(contexts, self.markColor.CGColor);//画笔颜色
    CGPoint cc = CGPointMake(10, rect.size.height-10);
    CGPoint dd = CGPointMake(rect.size.width-10, orignal+10);
    CGFloat lengths[] = {3000,1};
    CGContextSetLineDash(contexts, 0, lengths,2);
    CGContextMoveToPoint(contexts, cc.x, cc.y);
    CGContextAddLineToPoint(contexts, dd.x, dd.y);
    CGContextStrokePath(contexts);
    //原点x
    UILabel *markLabelX = [[UILabel alloc]init];
    markLabelX.frame = CGRectMake(rect.size.width/2.0,rect.size.height-stepDist/2.0-5, rect.size.width/2.0, stepDist/2.0);
    markLabelX.backgroundColor = [UIColor clearColor];
    markLabelX.textColor = self.xTextColor;
    markLabelX.textAlignment = UITextAlignmentCenter;
    markLabelX.font = [UIFont systemFontOfSize:self.dotXSize];
    markLabelX.text = self.xText;
    [self addSubview:markLabelX];
     */
}

@end
