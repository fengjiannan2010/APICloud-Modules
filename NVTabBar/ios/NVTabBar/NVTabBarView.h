/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import <UIKit/UIKit.h>

@protocol NVTabBarViewDelegate <NSObject>

- (NSString *)getRealPath:(NSString *)souPath;
- (void)callBack:(NSDictionary *)resultDict;

@end

@interface NVTabBarView : UIView

@property (nonatomic, weak) id<NVTabBarViewDelegate> nvTBDelegate;
@property (nonatomic, strong) NSArray *itemsArray;
@property (nonatomic, assign) NSInteger selectedIndex;

- (instancetype)initWithFrame:(CGRect)frame
                 withDelegate:(id<NVTabBarViewDelegate>)delegate
                    withStyle:(NSDictionary *)stylesInfo;

//为指定位置的按钮设置徽章
- (void)setBadgeAtIndex: (NSUInteger) idx
                   title: (NSString *) title;

- (void)setSelectedIconOfIndex:(NSInteger)index
                   selectState:(BOOL)state selectGifIcons:(NSMutableArray *)iconsArray selectInterval:(CGFloat)interval;

@end
