/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import "UZVLineView.h"
#import "NSDictionaryUtils.h"

@interface UZVLineView(){
  NSMutableArray *_allNodeRect;
}

@property (nonatomic,strong) NSMutableArray *allNodeRect;
@property (nonatomic, assign) float bubbleHeight;
@end

@implementation UZVLineView

@synthesize dataSource;
@synthesize max, min, step, isDash, verticalDash, xStepGap;
@synthesize coordlineColor, coordlineWidth, brokenlineWidth, brokenlineColor, verticalColor, verticalWidth;
@synthesize nodeSize, nodeColor, isHollow;
@synthesize xAxisMrkColor, xAxisMrkSize;
@synthesize shadowColor;
@synthesize allNodeRect = _allNodeRect;
@synthesize blViewID;
@synthesize bubble;
@synthesize xAxisHeight, yAxisWidth;
@synthesize bubbleHeight;
@synthesize iconWidth, iconHeight;

- (void)dealloc {
    if (dataSource) {
        self.dataSource = nil;
    }
    if (coordlineColor) {
        self.coordlineColor = nil;
    }
    if (brokenlineColor) {
        self.brokenlineColor = nil;
    }
    if (nodeColor) {
        self.nodeColor = nil;
    }
    if (xAxisMrkColor) {
        self.xAxisMrkColor = nil;
    }
    if (shadowColor) {
        self.shadowColor = nil;
    }
    if (_allNodeRect) {
        [_allNodeRect removeAllObjects];
        self.allNodeRect = nil;
    }
    if (bubble) {
        [bubble removeFromSuperview];
        self.bubble = nil;
    }
}

- (id)initWithFrame:(CGRect)frame withBubbleSize:(CGSize)size {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.allNodeRect = [NSMutableArray arrayWithCapacity:2];
        //x轴上的气泡
        if (!self.bubble) {
            UZVLBubbleView *bubbleView = [[UZVLBubbleView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            bubbleView.hidden = YES;
            bubbleView.userInteractionEnabled = NO;
            bubbleView.backgroundColor = [UIColor clearColor];
            [self addSubview:bubbleView];
            self.bubble = bubbleView;
            self.bubbleHeight = size.height;
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    NSArray *subViews = [self subviews];
    for (id targetView in subViews) {
        if ([targetView isKindOfClass:[UZVLBubbleView class]]) {
            continue;
        }
        if ([targetView isKindOfClass:[UIImageView class]]) {
            [targetView removeFromSuperview];
        }
        if ([targetView isKindOfClass:[UILabel class]]) {
            [targetView removeFromSuperview];
        }
    }
    // Drawing code
    float distance = self.max - self.min;//最大和最小值的差值
    int markNum = distance/self.step;//计算横线个数
    float stepDist = (rect.size.height-self.xAxisHeight)/markNum;//计算每条横线间隔
    float orignal = rect.size.height - self.xAxisHeight;//计算第一条横线的y坐标
    CGContextRef context =UIGraphicsGetCurrentContext();//获取上下文
    //画横线
    for (int i=0; i<markNum; i++){
        CGContextBeginPath(context);
        CGContextSetLineWidth(context, coordlineWidth);
        CGContextSetStrokeColorWithColor(context, self.coordlineColor.CGColor);
        if (isDash) {
            CGFloat lengths[] = {2,2};
            CGContextSetLineDash(context, 0, lengths,2);
            CGContextMoveToPoint(context, 0, orignal-stepDist*i);
            CGContextAddLineToPoint(context, rect.size.width,orignal-stepDist*i);
            CGContextStrokePath(context);
        }else{
            CGContextMoveToPoint(context, 0, orignal-stepDist*i);
            CGContextAddLineToPoint(context, rect.size.width,orignal-stepDist*i);
            CGContextStrokePath(context);
        }
    }
    if (self.dataSource==nil || self.dataSource.count==0) {
        return;
    }
    //画折线
    if (self.dataSource.count>1) {
        for (int i=0; i<self.dataSource.count-1; i++){
            NSDictionary *dotDataInfoS = [self.dataSource objectAtIndex:i];
            float valueS = [dotDataInfoS floatValueForKey:@"value" defaultValue:self.min];
            NSDictionary *dotDataInfoE = [self.dataSource objectAtIndex:i+1];
            float valueE = [dotDataInfoE floatValueForKey:@"value" defaultValue:self.min];
            float dotSx,dotEx,dotSy,dotEy;
            dotSx = self.xStepGap * i + self.yAxisWidth;
            dotSy = (self.max-valueS) * orignal/distance;
            dotEx = self.xStepGap * (i+1) + self.yAxisWidth;
            dotEy =(self.max-valueE) * orignal/distance;
            //折线
            CGContextBeginPath(context);
            CGContextSetLineWidth(context, self.brokenlineWidth);
            CGContextSetStrokeColorWithColor(context, self.brokenlineColor.CGColor);
            CGFloat lengths[] = {2000,1};
            CGContextSetLineDash(context, 0, lengths,2);
            CGContextMoveToPoint(context, dotSx, dotSy);
            CGContextAddLineToPoint(context, dotEx,dotEy);
            CGContextStrokePath(context);
            /*画阴影
             [self drawShadow];
             */
        }
    }
    //画竖线
    if (self.dataSource.count>1) {
        for (int i=0; i<self.dataSource.count; i++){
            float dotSx,dotEx,dotSy,dotEy;
            dotSx = self.xStepGap * i + self.yAxisWidth;
            dotSy = 0;
            dotEx = self.xStepGap * i + self.yAxisWidth;
            dotEy = rect.size.height - self.xAxisHeight;
            //竖线
            CGContextBeginPath(context);
            CGContextSetLineWidth(context, verticalWidth);
            CGContextSetStrokeColorWithColor(context, self.verticalColor.CGColor);
            if (verticalDash) {
                CGFloat lengths[] = {2,2};
                CGContextSetLineDash(context, 0, lengths,2);
                CGContextMoveToPoint(context, dotSx, dotSy);
                CGContextAddLineToPoint(context, dotEx, dotEy);
                CGContextStrokePath(context);
            } else {
                CGContextMoveToPoint(context, dotSx, dotSy);
                CGContextAddLineToPoint(context, dotEx,dotEy);
                CGContextStrokePath(context);
            }
        }
    }
    //画结点圆圈
    if (_allNodeRect.count > 0) {
        [_allNodeRect removeAllObjects];
    }
    for(int i = 0; i<self.dataSource.count; i++){
        NSDictionary *dotDataInfoS = [self.dataSource objectAtIndex:i];
        float valueS = [dotDataInfoS floatValueForKey:@"value" defaultValue:self.min];
        float dotSx,dotSy;
        dotSx = self.xStepGap * i+ self.yAxisWidth;
        dotSy = (self.max-valueS) * orignal/distance;
        //边框圆
        CGContextSetFillColorWithColor(context,self.nodeColor.CGColor);
        CGContextAddArc(context, dotSx, dotSy, self.nodeSize, 0, 2*M_PI, 0); //添加一个圆
        CGContextDrawPath(context, kCGPathFill); //绘制路径
        //将结点所在区域添加到句柄
        CGRect access_touch_point = CGRectMake(dotSx-15,dotSy-15, 30, 30);
        [_allNodeRect addObject:[NSValue valueWithCGRect:access_touch_point]];
        //添加结点上的icon图标
        NSString *iconPath = [dotDataInfoS stringValueForKey:@"icon" defaultValue:@""];
        NSString *realPath = [self.delegate getPathWith:iconPath];
        UIImage *iconImg = [UIImage imageWithContentsOfFile:realPath];
        UIImageView *iconView = [[UIImageView alloc]initWithImage:iconImg];
        iconView.frame = CGRectMake(0, 0, self.iconWidth, self.iconHeight);
        [self addSubview:iconView];
        float iconCenterY = dotSy - self.nodeSize - (self.iconHeight/2.0);
        iconView.center = CGPointMake(dotSx, iconCenterY);
    }
    //空心结点圆
    if (self.isHollow) {
        //清空结点处圆心
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, 2);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextSetStrokeColorWithColor(context, [[UIColor clearColor] CGColor]);
        //CGContextSetFillColor(context, CGColorGetComponents( [[UIColor redColor] CGColor]));
        CGContextBeginPath(context);
        for(int i = 0; i < self.dataSource.count; i++){
            NSDictionary *dotDataInfoS = [self.dataSource objectAtIndex:i];
            float valueS = [dotDataInfoS floatValueForKey:@"value" defaultValue:self.min];
            float dotSx,dotSy;
            dotSx = self.xStepGap * i + self.yAxisWidth;
            dotSy = (self.max-valueS) * orignal/distance;
            CGContextAddArc(context, dotSx, dotSy, self.nodeSize-1, 0, 2*M_PI, 0);
            CGContextDrawPath(context, kCGPathFill);
            CGContextStrokePath(context);
            CGContextFlush(context);
        }
    }
    //x轴标注
    for(int i = 0; i < self.dataSource.count; i++) {
        NSDictionary *dotDataInfoS = [self.dataSource objectAtIndex:i];
        NSString *markStr = [dotDataInfoS stringValueForKey:@"mark" defaultValue:@"未知标注"];
        float dotSx,dotSy;
        dotSx = self.xStepGap * i + self.yAxisWidth;
        float markLableH = self.xAxisMrkSize + 5.0;
        dotSy = orignal + (self.xAxisHeight - markLableH)/2.0;
        //标签
        UILabel *markLabel = [[UILabel alloc]init];
        markLabel.frame = CGRectMake(dotSx-self.xStepGap/2.0,dotSy,self.xStepGap, markLableH);
        markLabel.backgroundColor = [UIColor clearColor];
        markLabel.textColor = self.xAxisMrkColor;
        markLabel.textAlignment = UITextAlignmentCenter;
        markLabel.font = [UIFont systemFontOfSize:self.xAxisMrkSize];
        markLabel.text = markStr;
        [self addSubview:markLabel];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];//获取点击点
    CGPoint where = [t locationInView:self];//获取点击点坐标
    for (int i=0; i<[_allNodeRect count]; i++) {//遍历各个节点
        NSValue *rectValue = [_allNodeRect objectAtIndex:i];//结点触发区域
        CGRect r = [rectValue CGRectValue];//转换为rect
        if (CGRectContainsPoint(r, where)){//判断点击点是否在结点触发区域内
            float bubbleCenterX = self.xStepGap * i + self.yAxisWidth;
            float bubbbleCenterY = self.frame.size.height - self.xAxisHeight - self.bubbleHeight/2.0;
            if ([self.delegate respondsToSelector:@selector(didClickedNode: withBLine:)]) {
                [self.delegate didClickedNode:i withBLine:self];
            }
            self.bubble.center = CGPointMake(bubbleCenterX, bubbbleCenterY);
            self.bubble.hidden = NO;
            
            NSDictionary *dotDataInfoS = [self.dataSource objectAtIndex:i];
            float valueS = [dotDataInfoS floatValueForKey:@"value" defaultValue:self.min];
            self.bubble.title = valueS;
            return;
        } else {
            self.bubble.hidden = YES;
        }
    }
}

- (void)drawShadow {
    /*
    //画阴影
    float angleX,angleY;
    angleX = dotEx;
    angleY = dotSy;
    if (dotEy >= dotSy) {
        angleX = dotSx;
        angleY = dotEy;
    }
    float dotSy1,dotEy1;
    dotSy1 = dotSy + self.brokenlineWidth/2.0;
    dotEy1 = dotEy + self.brokenlineWidth/2.0;
    angleY += self.brokenlineWidth/2.0;
    CGPoint sPoints[3];//坐标点
    if (dotEy1 > orignal) {
        dotEy1 = orignal;
    }
    if (dotSy1 > orignal) {
        dotSy1 = orignal;
    }
    if (angleY > orignal) {
        angleY = orignal;
    }
    sPoints[0] = CGPointMake(dotSx, dotSy1);//坐标1
    sPoints[1] = CGPointMake(dotEx, dotEy1);//坐标2
    sPoints[2] = CGPointMake(angleX, angleY);//坐标3
    CGContextSetFillColorWithColor(context, self.shadowColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.shadowColor.CGColor);
    CGContextSetLineWidth(context, 0.15);
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextClosePath(context);//封起来
    CGContextDrawPath(context, kCGPathFillStroke);
    float rectX, rectY, rectW, rectH;
    rectX = dotSx;
    rectY = dotSy;
    rectY += self.brokenlineWidth/2.0;
    rectW = dotEx-dotSx;
    rectH = orignal-dotSy;
    if (dotEy >= dotSy) {
        rectX = angleX;
        rectY = angleY;
        rectW = dotEx-dotSx;
        rectH = orignal-angleY;
    }
    rectW += 0.2;
    rectY += 0.03;
    if (rectY > orignal) {
        rectY = orignal;
    }
    if (rectY + rectH > orignal) {
        rectH = orignal - rectY;
    }
    CGContextSetFillColorWithColor(context,self.shadowColor.CGColor);
    CGContextFillRect(context,CGRectMake(rectX, rectY, rectW, rectH));//填充矩形
    CGContextStrokePath(context);
     */
}

@end
