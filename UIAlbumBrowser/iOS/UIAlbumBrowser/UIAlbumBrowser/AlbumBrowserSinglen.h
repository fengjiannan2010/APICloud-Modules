/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <Foundation/Foundation.h>

@interface AlbumBrowserSinglen : NSObject



@property(strong,nonatomic) NSString *openType;

@property(assign,nonatomic) BOOL isOpenPreview;
@property(assign,nonatomic) BOOL selectAll;


+(instancetype)sharedSingleton;
@end
