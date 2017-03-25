/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import "NVTabBar.h"
#import "NSDictionaryUtils.h"
#import "NVTabBarView.h"

@interface NVTabBar ()
<NVTabBarViewDelegate>{
    NSInteger openCbId;
}

@property (nonatomic, strong) NVTabBarView *NVTabBarView;
@end

@implementation NVTabBar

- (void)dealloc {
    
}

- (void)open:(NSDictionary *)paramsDict {
    if (self.NVTabBarView) {
        return;
    }
    openCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSDictionary *stylesInfo = [paramsDict dictValueForKey:@"styles" defaultValue:@{}];
    NSArray *barItems =  [paramsDict arrayValueForKey:@"items" defaultValue:@[]];
    CGFloat barHeight = [stylesInfo floatValueForKey:@"h" defaultValue:50.0];
    NSInteger selectedIdx = [paramsDict integerValueForKey:@"selectedIndex" defaultValue:-1];
    //CGSize windowSize = [UIScreen mainScreen].bounds.size;
    CGSize windowSize = self.viewController.view.bounds.size;
    CGRect tabBarFrame = CGRectMake(0, windowSize.height-barHeight, windowSize.width, barHeight);
    _NVTabBarView = [[NVTabBarView alloc]initWithFrame:tabBarFrame withDelegate:self withStyle:stylesInfo];
    _NVTabBarView.selectedIndex = selectedIdx;
    _NVTabBarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.NVTabBarView.itemsArray = barItems;
    NSString * fixedOn = [paramsDict stringValueForKey:@"fixedOn" defaultValue:nil];
    BOOL fixed = [paramsDict boolValueForKey:@"fixed" defaultValue:YES];
    [self addSubview:self.NVTabBarView fixedOn:fixedOn fixed:fixed];
    UIView *superv = _NVTabBarView.superview;
    NSLog(@"%s",__func__);
    windowSize = _NVTabBarView.superview.bounds.size;
    tabBarFrame = CGRectMake(0, windowSize.height-barHeight, windowSize.width, barHeight);
    _NVTabBarView.frame = tabBarFrame;
    //    [self.viewController.view addSubview:self.NVTabBarView];
    [self sendResultEventWithCallbackId:openCbId dataDict:@{@"eventType":@"show"} errDict:nil doDelete:NO];
}

- (void)hide:(NSDictionary *)paramsDict {
    if (!self.NVTabBarView) {
        return;
    }
    self.NVTabBarView.hidden = YES;
}

- (void)show:(NSDictionary *)paramsDict {
    if (!self.NVTabBarView) {
        return;
    }
    self.NVTabBarView.hidden = NO;
}

- (void)close:(NSDictionary *)paramsDict {
    if (!self.NVTabBarView) {
        return;
    }
    [self.NVTabBarView removeFromSuperview];
    self.NVTabBarView = nil;
}

- (void)setBadge:(NSDictionary *)paramsDict {
    NSUInteger badgeIndex = [paramsDict integerValueForKey:@"index" defaultValue:0];
    NSString *badgeTitle = [paramsDict stringValueForKey:@"badge" defaultValue:nil];
    [self.NVTabBarView setBadgeAtIndex:badgeIndex title:badgeTitle];
}

- (void)setSelect:(NSDictionary *)paramsDict {
    NSInteger curIndex = [paramsDict integerValueForKey:@"index" defaultValue:0];
    BOOL selectState = [paramsDict boolValueForKey:@"selected" defaultValue:true];
    NSMutableArray *iconsArray = [paramsDict arrayValueForKey:@"icons" defaultValue:nil];
    CGFloat interval = [paramsDict floatValueForKey:@"interval" defaultValue:300];

    [self.NVTabBarView setSelectedIconOfIndex:curIndex selectState:selectState selectGifIcons:iconsArray selectInterval:interval];
}

- (void)bringToFront:(NSDictionary *)paramsDict {
    if (!self.NVTabBarView) {
        return;
    }
    [self.NVTabBarView.superview bringSubviewToFront:self.NVTabBarView];
}

#pragma mark - NVTabBarViewDelegate -

- (NSString *)getRealPath:(NSString *)souPath {
    return [self getPathWithUZSchemeURL:souPath];
}

- (void)callBack:(NSDictionary *)resultDict {
    [self sendResultEventWithCallbackId:openCbId dataDict:resultDict errDict:nil doDelete:NO];
}

@end
