/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <UIKit/UIKit.h>
#import "UZModule.h"
#import <Photos/Photos.h>

@interface OpenAlbumDetailController : UIViewController
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, assign) NSInteger openAlbumCbId;
@property (nonatomic, strong)UZModule *module;
@property (nonatomic, strong)NSDictionary *targetDict;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, strong) PHAsset *asset;


@end
