/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIChatToolsSingleton : NSObject
@property (nonatomic, strong)UIView *maskView;
@property (nonatomic, strong)NSDictionary *paramsDict;
+(instancetype)sharedSingleton;

@end
