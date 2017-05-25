/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import "UZVividLine.h"
#import "UZAppUtils.h"
#import "NSDictionaryUtils.h"
#import "UZVLScrollView.h"
#import "UZVLineView.h"
#import "UZVLYaxisView.h"

@interface UZVividLine ()
<UIScrollViewDelegate, UZBLineViewDelegate>
{
    NSMutableDictionary *_allBrokenView;
    int lineViewId;
    float xAxisGapLAData, yAxisWidthData;
}

@property (nonatomic, strong) NSMutableDictionary *allBrokenView;

@end

@implementation UZVividLine

@synthesize allBrokenView = _allBrokenView;

#pragma mark - lifeCycle -

- (void)dispose {
    if (_allBrokenView) {
        NSArray *tempKeys = [_allBrokenView allKeys];
        for (NSString *keyTemp in tempKeys) {
            NSMutableDictionary *tempDict = [_allBrokenView objectForKey:keyTemp];
            UIView *tempMainView = [tempDict objectForKey:@"mainView"];
            int cbIdTemp = [[tempDict objectForKey:@"cbId"]intValue];
            [self deleteCallback:cbIdTemp];
            UZVLScrollView *tempScrollView = (UZVLScrollView *)[tempMainView viewWithTag:1025];
            UZVLineView *tempBLView = (UZVLineView *)[tempScrollView viewWithTag:1026];
            tempBLView.delegate = nil;
            [tempMainView removeFromSuperview];
            [tempDict removeAllObjects];
        }
        [_allBrokenView removeAllObjects];
        self.allBrokenView = nil;
    }

}

- (id)initWithUZWebView:(UZWebView *)webView_ {
    self = [super initWithUZWebView:webView_];
    if (self != nil) {
        lineViewId = 0;
        _allBrokenView = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}
#pragma mark - interface -

- (void)open:(NSDictionary *)paramsDict_ {
    NSArray *dataAry = [paramsDict_ arrayValueForKey:@"datas" defaultValue:@[]];
    if (dataAry.count == 0) {
        return;
    }
    lineViewId ++;
    NSInteger openCbid  = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    //父视图配置
    NSString *fixedOn = [paramsDict_ stringValueForKey:@"fixedOn" defaultValue:nil];
    BOOL fixed = [paramsDict_ boolValueForKey:@"fixed" defaultValue:YES];
    UIView *superView = [self getViewByName:fixedOn];
    CGRect rect = [paramsDict_ rectValueForKey:@"rect" defaultValue:CGRectMake(0, 0, 320, 300) relativeToSuperView:superView];
    //视图样式配置
    NSDictionary *styleInfo = [paramsDict_ dictValueForKey:@"styles" defaultValue:@{}];
    //背景间隙配置
    NSString *bgImg = [styleInfo stringValueForKey:@"bg" defaultValue:@"#fff"];
    float xAxisGap = [styleInfo floatValueForKey:@"xAxisGap" defaultValue:rect.size.width/6.5];
    xAxisGapLAData = xAxisGap;
    //y轴标注配置
    NSDictionary *yAxisInfo = [styleInfo dictValueForKey:@"yAxis" defaultValue:@{}];
    float yAxisMax = [yAxisInfo floatValueForKey:@"max" defaultValue:5];
    float yAxisMin = [yAxisInfo floatValueForKey:@"min" defaultValue:1];
    float yAxisStep = [yAxisInfo floatValueForKey:@"step" defaultValue:1];
    NSString *yAxisSuffix = [yAxisInfo stringValueForKey:@"suffix" defaultValue:@""];
    float yAxisWidth = [yAxisInfo floatValueForKey:@"width" defaultValue:rect.size.width/6.5];
    NSString *yAxisColor = [yAxisInfo stringValueForKey:@"color" defaultValue:@"#696969"];
    yAxisWidthData = yAxisWidth;
    float yAxisSize = [yAxisInfo floatValueForKey:@"size" defaultValue:12];
    //x轴标注配置
    NSDictionary *xAxisInfo = [styleInfo dictValueForKey:@"xAxis" defaultValue:@{}];
    NSString *xAxisColor = [xAxisInfo stringValueForKey:@"color" defaultValue:@"#fff"];
    float xAxisSize = [xAxisInfo floatValueForKey:@"size" defaultValue:12];
    float xAxisHeight = [xAxisInfo floatValueForKey:@"height" defaultValue:rect.size.height/6.0];
    //x轴气泡配置
    NSDictionary *bubbleInfo = [xAxisInfo dictValueForKey:@"bubble" defaultValue:@{}];
    float bubbleW = [bubbleInfo floatValueForKey:@"w" defaultValue:rect.size.width/(6.5*2.0)];
    float bubbleH = [bubbleInfo floatValueForKey:@"h" defaultValue:rect.size.height/9.0];
    NSString *bubbleBg = [bubbleInfo stringValueForKey:@"bg" defaultValue:@""];
    float bubbleFontSize = [bubbleInfo floatValueForKey:@"size" defaultValue:14];
    NSString *bubbleFontColor = [bubbleInfo stringValueForKey:@"color" defaultValue:@"#fff"];
    //坐标系样式配置
    NSDictionary *coordInfo = [styleInfo dictValueForKey:@"coordinate" defaultValue:@{}];
    NSDictionary *horizontalInfo = [coordInfo dictValueForKey:@"horizontal" defaultValue:@{}];
    NSString *horizontalColor = [horizontalInfo stringValueForKey:@"color" defaultValue:@"#696969"];
    float horizontalWidth = [horizontalInfo floatValueForKey:@"width" defaultValue:0.5];
    NSString *horizontalStyle = [horizontalInfo stringValueForKey:@"style" defaultValue:@"solid"];
    NSDictionary *verticalInfo = [coordInfo dictValueForKey:@"vertical" defaultValue:@{}];
    NSString *verticalColor = [verticalInfo stringValueForKey:@"color" defaultValue:@"rgba(0,0,0,0)"];
    float verticalWidth = [verticalInfo floatValueForKey:@"width" defaultValue:0.5];
    NSString *verticalStyle = [verticalInfo stringValueForKey:@"style" defaultValue:@"solid"];
    //折线样式
    NSDictionary *lineInfo = [styleInfo dictValueForKey:@"line" defaultValue:@{}];
    NSString *lineColor = [lineInfo stringValueForKey:@"color" defaultValue:@"#fff"];
    float lineWidth = [lineInfo floatValueForKey:@"width" defaultValue:1];
    //结点配置
    NSDictionary *nodeInfo = [styleInfo dictValueForKey:@"node" defaultValue:@{}];
    float nodeSize = [nodeInfo floatValueForKey:@"size" defaultValue:5];
    NSString *nodeColor = [nodeInfo stringValueForKey:@"color" defaultValue:@"#fff"];
    BOOL nodeHollow = [nodeInfo boolValueForKey:@"hollow" defaultValue:NO];
    //提示图标大小
    NSDictionary *iconInfo = [styleInfo dictValueForKey:@"icon" defaultValue:@{}];
    float iconWidth = [iconInfo floatValueForKey:@"width" defaultValue:60];
    float iconHeight = [iconInfo floatValueForKey:@"height" defaultValue:60];
    //主画板/背景设置
    UIView *_mainBoard = [[UIView alloc]init];
    _mainBoard.frame = rect;
    _mainBoard.backgroundColor = [UIColor clearColor];
    [self addSubview:_mainBoard fixedOn:fixedOn fixed:fixed];
    if (![UZAppUtils isValidColor:bgImg]) {
        UIImageView *bg = [[UIImageView alloc]initWithFrame:_mainBoard.bounds];
        bg.image = [UIImage imageWithContentsOfFile:[self getPathWithUZSchemeURL:bgImg]];
        [_mainBoard addSubview:bg];
    }else{
        UIView *bg = [[UIView alloc]initWithFrame:_mainBoard.bounds];
        bg.backgroundColor = [UZAppUtils colorFromNSString:bgImg];
        [_mainBoard addSubview:bg];
    }
    //计算滚动视图的总宽度
    float lineViewWidth;
    lineViewWidth = (dataAry.count-1) * xAxisGap + yAxisWidth;
    if (lineViewWidth < rect.size.width) {
        lineViewWidth = rect.size.width;
    }
    //加载折线可滚动视图的容器（scrollView）
    UZVLScrollView *mainScroll = [[UZVLScrollView alloc]initWithFrame:_mainBoard.bounds];
    mainScroll.backgroundColor = [UIColor clearColor];
    mainScroll.showsVerticalScrollIndicator = NO;
    mainScroll.showsHorizontalScrollIndicator = NO;
    mainScroll.tag = 1025;
    mainScroll.delegate = self;
    mainScroll.viewId = lineViewId;//折线视图id
    if (lineViewWidth > mainScroll.bounds.size.width) {
        [mainScroll setContentSize:CGSizeMake(lineViewWidth+xAxisGap/2.0, mainScroll.bounds.size.height)];
        lineViewWidth += xAxisGap/2.0;
    } else {
        [mainScroll setContentSize:CGSizeMake(lineViewWidth, mainScroll.bounds.size.height)];
    }
    [_mainBoard addSubview:mainScroll];
    //加载折线视图
    CGRect lineviewRect = CGRectMake(0, 0, lineViewWidth, rect.size.height);
    UZVLineView *lineView = [[UZVLineView alloc]initWithFrame:lineviewRect withBubbleSize:CGSizeMake(bubbleW, bubbleH)];
    lineView.dataSource = dataAry;
    lineView.max = yAxisMax;
    lineView.min = yAxisMin;
    lineView.step = yAxisStep;
    lineView.yAxisWidth = yAxisWidth;
    lineView.verticalWidth = verticalWidth;
    lineView.verticalColor = [UZAppUtils colorFromNSString:verticalColor];
    lineView.verticalDash = [verticalStyle isEqualToString:@"dash"];
    lineView.isDash = [horizontalStyle isEqualToString:@"dash"];//横坐标线是否是虚线
    lineView.coordlineWidth = horizontalWidth;//横坐标系粗细
    lineView.coordlineColor = [UZAppUtils colorFromNSString:horizontalColor];//横坐标线颜色
    lineView.brokenlineWidth = lineWidth;//折线粗细
    lineView.brokenlineColor = [UZAppUtils colorFromNSString:lineColor];//折线颜色
    lineView.xStepGap = xAxisGap;//结点横纵间隙
    lineView.nodeSize = nodeSize;//结点大小
    lineView.iconHeight = iconHeight;
    lineView.iconWidth = iconWidth;
    lineView.nodeColor = [UZAppUtils colorFromNSString:nodeColor];//结点颜色
    lineView.isHollow = nodeHollow;//结点是否空心
    lineView.xAxisMrkSize = xAxisSize;//x轴标注字体大小
    lineView.xAxisHeight = xAxisHeight;//x轴高度
    lineView.xAxisMrkColor = [UZAppUtils colorFromNSString:xAxisColor];//x轴标注字体颜色
    lineView.shadowColor = [UZAppUtils colorFromNSString:@"rgba(0,0,0,0)"];//折线阴影部分的颜色
    lineView.blViewID = lineViewId;//折线视图id
    lineView.delegate = self;
    lineView.tag = 1026;
    lineView.bubble.suffix = yAxisSuffix; 
    lineView.bubble.bubbleBg = [self getPathWith:bubbleBg];//气泡背景图片
    lineView.bubble.fontSize = bubbleFontSize;
    lineView.bubble.fontColor = bubbleFontColor;
    [mainScroll addSubview:lineView];
    //加载y轴
    CGRect yAxisRect = CGRectMake(0, 0, yAxisWidth, rect.size.height);
    UZVLYaxisView *yAxisView = [[UZVLYaxisView alloc]initWithFrame:yAxisRect];
    yAxisView.max = yAxisMax;
    yAxisView.min = yAxisMin;
    yAxisView.step = yAxisStep;
    yAxisView.markSize = yAxisSize;
    yAxisView.suffix = yAxisSuffix;
    yAxisView.xAxisHeigh = xAxisHeight;
    yAxisView.dotYSize = 0;//原点标注字体大小
    yAxisView.dotXSize = 0;//原点标注字体大小
    yAxisView.lineWidth = 0;//圆点斜线的粗细
    yAxisView.yTextColor = [UIColor clearColor];//原点标注字体颜色
    yAxisView.xTextColor = [UIColor clearColor];//原点标注字体颜色
    yAxisView.yText = @"原点y";
    yAxisView.xText = @"原点x";
    yAxisView.backgroundColor = [UIColor clearColor];
    yAxisView.markColor = [UZAppUtils colorFromNSString:yAxisColor];
    [_mainBoard addSubview:yAxisView];
    //添加到句柄
    NSMutableDictionary *brokenLineObj = [NSMutableDictionary dictionaryWithCapacity:2];
    [brokenLineObj setObject:_mainBoard forKey:@"mainView"];
    [brokenLineObj setObject:[NSNumber numberWithInteger:openCbid] forKey:@"cbId"];
    NSString *key = [NSString stringWithFormat:@"%d",lineViewId];
    [_allBrokenView setObject:brokenLineObj forKey:key];
    //回调
    if (openCbid >= 0) {
        NSMutableDictionary *sendDict = [NSMutableDictionary dictionary];
        [sendDict setObject:@"show" forKey:@"eventType"];
        [sendDict setObject:[NSNumber numberWithInt:lineViewId] forKey:@"id"];
        [self sendResultEventWithCallbackId:openCbid dataDict:sendDict errDict:nil doDelete:NO];
    }
}

- (void)close:(NSDictionary *)paramsDict_ {
    if ([paramsDict_ objectForKey:@"id"]) {
        NSString *idKey = [NSString stringWithFormat:@"%@",[paramsDict_ objectForKey:@"id"]];
        NSMutableDictionary *tempDict = [_allBrokenView objectForKey:idKey];
        UIView *tempMainView = [tempDict objectForKey:@"mainView"];
        if (tempMainView) {
            int tempCbid = [[tempDict objectForKey:@"cbId"]intValue];
            [self deleteCallback:tempCbid];
            UZVLScrollView *tempScrollView = (UZVLScrollView *)[tempMainView viewWithTag:1025];
            UZVLineView *tempBLView = (UZVLineView *)[tempScrollView viewWithTag:1026];
            tempBLView.delegate = nil;
            [tempMainView removeFromSuperview];
            [tempDict removeAllObjects];
            [_allBrokenView removeObjectForKey:idKey];
        }
    }
}

- (void)hide:(NSDictionary *)paramsDict_ {
    if ([paramsDict_ objectForKey:@"id"]) {
        NSString *idKey = [NSString stringWithFormat:@"%@",[paramsDict_ objectForKey:@"id"]];
        NSMutableDictionary *tempDict = [_allBrokenView objectForKey:idKey];
        UIView *tempMainView =  [tempDict objectForKey:@"mainView"];
        if (tempMainView) {
            tempMainView.hidden = YES;
        }
    }
}

- (void)show:(NSDictionary *)paramsDict_ {
    if ([paramsDict_ objectForKey:@"id"]) {
        NSString *idKey = [NSString stringWithFormat:@"%@",[paramsDict_ objectForKey:@"id"]];
        NSMutableDictionary *tempDict = [_allBrokenView objectForKey:idKey];
        UIView *tempMainView =  [tempDict objectForKey:@"mainView"];
        if (tempMainView) {
            tempMainView.hidden = NO;
        }
    }
}

- (void)reloadData:(NSDictionary *)paramsDict_ {
    if (![paramsDict_ objectForKey:@"id"]) {
        return;
    }
    NSString *idKey = [NSString stringWithFormat:@"%@",[paramsDict_ objectForKey:@"id"]];
    NSMutableDictionary *tempDict = [_allBrokenView objectForKey:idKey];
    UIView *tempMainView =  [tempDict objectForKey:@"mainView"];
    if (tempMainView) {
        UZVLScrollView *tempScrollView = (UZVLScrollView *)[tempMainView viewWithTag:1025];
        UZVLineView *tempBLView = (UZVLineView *)[tempScrollView viewWithTag:1026];
        if (tempBLView) {
            NSArray *dataAry = [paramsDict_ arrayValueForKey:@"datas" defaultValue:nil];
            //计算滚动视图的总宽度
            float lineViewWidth;
            lineViewWidth = (dataAry.count-1) * xAxisGapLAData + yAxisWidthData;
            if (lineViewWidth < tempScrollView.bounds.size.width) {
                lineViewWidth = tempScrollView.bounds.size.width;
            }
            if (lineViewWidth > tempScrollView.bounds.size.width) {
                [tempScrollView setContentSize:CGSizeMake(lineViewWidth+xAxisGapLAData/2.0, tempScrollView.bounds.size.height)];
                lineViewWidth += xAxisGapLAData/2.0;
            } else {
                [tempScrollView setContentSize:CGSizeMake(lineViewWidth, tempScrollView.bounds.size.height)];
            }
            //加载折线视图
            CGRect rect = tempBLView.frame;
            rect.size.width = lineViewWidth;
            rect.size.height = tempScrollView.bounds.size.height;
            tempBLView.frame = rect;
            tempBLView.dataSource = dataAry;
            [tempBLView setNeedsDisplay];
        }
    }
}

- (void)appendData:(NSDictionary *)paramsDict_ {
    if (![paramsDict_ objectForKey:@"id"]) {
        return;
    }
    NSString *idKey = [NSString stringWithFormat:@"%@",[paramsDict_ objectForKey:@"id"]];
    NSMutableDictionary *tempDict = [_allBrokenView objectForKey:idKey];
    UIView *tempMainView =  [tempDict objectForKey:@"mainView"];
    if (tempMainView) {
        UZVLScrollView *tempScrollView = (UZVLScrollView *)[tempMainView viewWithTag:1025];
        UZVLineView *tempBLView = (UZVLineView *)[tempScrollView viewWithTag:1026];
        if (tempBLView) {
            NSArray *dataAry = [paramsDict_ arrayValueForKey:@"datas" defaultValue:nil];
            NSMutableArray *newAry = nil;
            NSString *orientation = [paramsDict_ stringValueForKey:@"orientation" defaultValue:@"right"];
            if ([orientation isEqualToString:@"right"]) {
                newAry = [NSMutableArray arrayWithArray:tempBLView.dataSource];
                for (NSDictionary *tempDict in dataAry) {
                    [newAry addObject:tempDict];
                }
            } else {
                newAry = [NSMutableArray arrayWithArray:dataAry];
                for (NSDictionary *tempDict in tempBLView.dataSource) {
                    [newAry addObject:tempDict];
                }
            }
            //计算滚动视图的总宽度
            float lineViewWidth;
            lineViewWidth = (newAry.count-1) * xAxisGapLAData + yAxisWidthData;
            if (lineViewWidth < tempScrollView.bounds.size.width) {
                lineViewWidth = tempScrollView.bounds.size.width;
            }
            if (lineViewWidth > tempScrollView.bounds.size.width) {
                [tempScrollView setContentSize:CGSizeMake(lineViewWidth+xAxisGapLAData/2.0, tempScrollView.bounds.size.height)];
                lineViewWidth += xAxisGapLAData/2.0;
            } else {
                [tempScrollView setContentSize:CGSizeMake(lineViewWidth, tempScrollView.bounds.size.height)];
            }
            [tempScrollView setContentSize:CGSizeMake(lineViewWidth, tempScrollView.bounds.size.height)];

            //加载折线视图
            CGRect rect = tempBLView.frame;
            rect.size.width = lineViewWidth;
            rect.size.height = tempScrollView.bounds.size.height;
            tempBLView.frame = rect;
            tempBLView.dataSource = newAry;
            [tempBLView setNeedsDisplay];
        }
    }
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    UZVLScrollView *tempScrol = (UZVLScrollView *)scrollView;
    if (scrollView.contentOffset.x < -40) {
        NSString *idKey = [NSString stringWithFormat:@"%d",tempScrol.viewId];
        NSMutableDictionary *tempDict = [_allBrokenView objectForKey:idKey];
        int tempCbid = [[tempDict objectForKey:@"cbId"]intValue];
        if (tempCbid != -1) {
            NSMutableDictionary *sendDict =[NSMutableDictionary dictionaryWithCapacity:2];
            [sendDict setObject:[NSNumber numberWithInt:tempScrol.viewId] forKey:@"id"];
            [sendDict setObject:@"scrollLeft" forKey:@"eventType"];
            [self sendResultEventWithCallbackId:tempCbid dataDict:sendDict errDict:nil doDelete:NO];
        }
    } else if (scrollView.contentOffset.x > scrollView.contentSize.width-scrollView.bounds.size.width+40) {
        NSString *idKey = [NSString stringWithFormat:@"%d",tempScrol.viewId];
        NSMutableDictionary *tempDict = [_allBrokenView objectForKey:idKey];
        int tempCbid = [[tempDict objectForKey:@"cbId"]intValue];
        if (tempCbid != -1) {
            NSMutableDictionary *sendDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [sendDict setObject:[NSNumber numberWithInt:tempScrol.viewId] forKey:@"id"];
            [sendDict setObject:@"scrollRight" forKey:@"eventType"];
            [self sendResultEventWithCallbackId:tempCbid dataDict:sendDict errDict:nil doDelete:NO];
        }
    }
}

#pragma mark - UZBLineViewDelegate -

- (void)didClickedNode:(int)index withBLine:(UZVLineView *)blView {
    NSString *idKey = [NSString stringWithFormat:@"%d",blView.blViewID];
    NSMutableDictionary *tempDict = [_allBrokenView objectForKey:idKey];
    int cbId = [[tempDict objectForKey:@"cbId"]intValue];
    if (cbId != -1) {
        NSMutableDictionary *sendDict =[NSMutableDictionary dictionaryWithCapacity:3];
        [sendDict setObject:[NSNumber numberWithInt:index] forKey:@"index"];
        [sendDict setObject:[NSNumber numberWithInt:blView.blViewID] forKey:@"id"];
        [sendDict setObject:@"nodeClick" forKey:@"eventType"];
        [self sendResultEventWithCallbackId:cbId dataDict:sendDict errDict:nil doDelete:NO];
    }
}

- (NSString *)getPathWith:(NSString *)paht {
    return  [self getPathWithUZSchemeURL:paht];
}

@end
