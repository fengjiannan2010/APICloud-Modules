/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import <UIKit/UIKit.h>

@interface UZUIChatToolsImageModel : NSObject

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) NSUInteger count;

@property (nonatomic, assign) CGPoint offset;

@property (nonatomic, copy) NSString *imagePath;

@property (nonatomic, copy) NSString *imageName;

@end
