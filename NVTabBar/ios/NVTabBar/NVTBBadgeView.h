/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import <UIKit/UIKit.h>

/**
 徽章类型.
 */
typedef enum : NSUInteger {
    UZBadgeViewTypeLeft, // 居左.
    UZBadgeViewTypeCenter, // 居中.
    UZBadgeViewTypeRight, // 居右.
} UZBadgeViewType;

/**
 *  徽章.
 */
@class UZWebView;
@interface NVTBBadgeView : UIView

@property (strong, nonatomic) NSString * title;     //!< 徽章内容.
//@property (assign, nonatomic) UZBadgeViewType type; //!< 徽章风格.
@property (strong, nonatomic) NSMutableDictionary * config; //!< 配置: bgColor, titleColor, fontSize, textMarginTop
@property (assign, nonatomic) CGSize contentSize;   //!< 内容尺寸.

/**
 *  便利构造器.
 *
 *  @param badge  徽章内容.
 *  @param config 相关配置.
 *
 *  @return 实例对象本身.
 */
- (instancetype)initWithTitle:(NSString *) title config:(NSDictionary *)config;

/**
 *  获取内容的实际尺寸.
 *
 *  @return 内容的实际尺寸.
 */
- (CGSize) contentSize;

@end
