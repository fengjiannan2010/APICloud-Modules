/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import <Foundation/Foundation.h>

@interface UZUIChatToolsImageUtils : NSObject

///获取相册图片的头十张.
+ (void)loadLimitImagesFromCamerarollSucess:(void(^)(NSArray *images))sucessBlock failure:(void(^)(NSError *error))failureBlock;

///获取相册图片
+ (void)loadImagesFromCamerarollSucess:(void(^)(NSArray *images))sucessBlock failure:(void(^)(NSError *error))failureBlock;
///获取所有照片
+ (void)loadAllPhotoSucess:(void(^)(NSArray *photos))sucessBlock failure:(void(^)(NSError *error))failureBlock;
@end
