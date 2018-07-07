/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import "NVTabBar.h"
#import "NSDictionaryUtils.h"
#import "NVTabBarView.h"

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
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
    self.viewController.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    openCbId = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    NSDictionary *stylesInfo = [paramsDict dictValueForKey:@"styles" defaultValue:@{}];
    NSArray *barItems =  [paramsDict arrayValueForKey:@"items" defaultValue:@[]];
    CGFloat barHeight = [stylesInfo floatValueForKey:@"h" defaultValue:50.0];
    NSInteger selectedIdx = [paramsDict integerValueForKey:@"selectedIndex" defaultValue:-1];
    CGSize windowSize = self.viewController.view.bounds.size;
    CGRect tabBarFrame = CGRectMake(0, windowSize.height-barHeight, windowSize.width, barHeight);
    _NVTabBarView = [[NVTabBarView alloc]initWithFrame:tabBarFrame withDelegate:self withStyle:stylesInfo];
    _NVTabBarView.selectedIndex = selectedIdx;
    _NVTabBarView.animatedRepetitions = [paramsDict intValueForKey:@"animatedRepetitions" defaultValue:0];
    _NVTabBarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.NVTabBarView.itemsArray = barItems;
    NSString * fixedOn = [paramsDict stringValueForKey:@"fixedOn" defaultValue:nil];
    BOOL fixed = [paramsDict boolValueForKey:@"fixed" defaultValue:YES];
    [self addSubview:self.NVTabBarView fixedOn:fixedOn fixed:fixed];
    
    
    // !!!: 临时测试.
//    UIView * centerView = [UIView alloc] initWithFrame:<#(CGRect)#>
    
    
    NSLog(@"%s",__func__);
    windowSize = _NVTabBarView.superview.bounds.size;
    if (iPhoneX) {
        barHeight = barHeight +34;
    }else{
        barHeight = barHeight;
    }
    tabBarFrame = CGRectMake(0, windowSize.height-barHeight, windowSize.width, barHeight);
    _NVTabBarView.frame = tabBarFrame;
    [self sendResultEventWithCallbackId:openCbId dataDict:@{@"eventType":@"show"} errDict:nil doDelete:NO];
}

- (void)hide:(NSDictionary *)paramsDict {
    if (!self.NVTabBarView) {
        return;
    }
 BOOL animation = [paramsDict boolValueForKey:@"animation" defaultValue:false];
 if (animation == true) {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^ {

        self.NVTabBarView.alpha = 0.0;
        NSLog(@"in animate start");
    } completion:^(BOOL finished) {
        NSLog(@"in animate completion");
        self.NVTabBarView.hidden = YES;

    }];
 }else{
     self.NVTabBarView.hidden = YES;

 }
}

- (void)show:(NSDictionary *)paramsDict {
    if (!self.NVTabBarView) {
        return;
    }
    
    BOOL animation = [paramsDict boolValueForKey:@"animation" defaultValue:false];
    if (animation == true) {
        self.NVTabBarView.hidden = NO;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
            self.NVTabBarView.alpha = 1.0;
            NSLog(@"in animate start");
        } completion:^(BOOL finished) {
            NSLog(@"in animate completion");
            
        }];
    }else{
        self.NVTabBarView.hidden = NO;

    }

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
    [self.NVTabBarView setBadgeViewAtIndex:badgeIndex title:badgeTitle];
}

- (void)setSelect:(NSDictionary *)paramsDict {
    NSInteger curIndex = [paramsDict integerValueForKey:@"index" defaultValue:0];
    BOOL selectState = [paramsDict boolValueForKey:@"selected" defaultValue:true];
    NSArray *iconsArray = [paramsDict arrayValueForKey:@"icons" defaultValue:@[]];
    CGFloat interval = [paramsDict floatValueForKey:@"interval" defaultValue:300];
    int animatedRepetitions = [paramsDict intValueForKey:@"animatedRepetitions" defaultValue:0];
    [self.NVTabBarView setSelectedIconOfIndex:curIndex selectState:selectState selectGifIcons:iconsArray selectInterval:interval setAnimatedRepetitions:animatedRepetitions];
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
