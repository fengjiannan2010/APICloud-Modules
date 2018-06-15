/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoStoreConfiguraion.h"
#import "AlbumBrowserSinglen.h"

NSString * ConfigurationCameraRoll = @"Camera Roll";
NSString * ConfigurationAllPhotos = @"All Photos";
NSString * ConfigurationHidden = @"Hidden";
NSString * ConfigurationSlo_mo = @"Slo-mo";
NSString * ConfigurationScreenshots = @"Screenshots";
NSString * ConfigurationVideos = @"Videos";
NSString * ConfigurationPanoramas = @"Panoramas";
NSString * ConfigurationTime_lapse = @"Time-lapse";
NSString * ConfigurationRecentlyAdded = @"Recently Added";
NSString * ConfigurationRecentlyDeleted = @"Recently Deleted";
NSString * ConfigurationBursts = @"Bursts";
NSString * ConfigurationFavorite = @"Favorite";
NSString * ConfigurationSelfies = @"Selfies";


static NSArray <NSString *>*  groupNames;

@implementation PhotoStoreConfiguraion

+(void)initialize
{
    if (self == [PhotoStoreConfiguraion class])
    {
   
//        if ( [AlbumBrowserSinglen.sharedSingleton.openType  isEqualToString:@"image"]) {
//               groupNames = @[@"所有照片",@"相机胶卷",@"隐藏",@"慢动作",@"屏幕快照",@"全景照片",@"定时拍照",@"最近添加",@"最近删除",@"连拍快照",@"喜爱",@"自拍"];
//        }else{
//
//              groupNames = @[@"所有照片",@"相机胶卷",@"隐藏",@"慢动作",@"屏幕快照",@"视频",@"全景照片",@"定时拍照",@"最近添加",@"最近删除",@"连拍快照",@"喜爱",@"自拍"];
//        }
//         groupNames = @[@"所有照片",@"相机胶卷",@"隐藏",@"慢动作",@"屏幕快照",@"视频",@"全景照片",@"定时拍照",@"最近添加",@"最近删除",@"连拍快照",@"喜爱",@"自拍"];
        
    }
}

-(NSArray *)groupNamesConfig
{
            if ( [AlbumBrowserSinglen.sharedSingleton.openType  isEqualToString:@"image"]) {
                   groupNames = @[@"所有照片",@"相机胶卷",@"隐藏",@"慢动作",@"屏幕快照",@"全景照片",@"定时拍照",@"最近添加",@"最近删除",@"连拍快照",@"喜爱",@"自拍"];
            }else{
    
                  groupNames = @[@"所有照片",@"相机胶卷",@"隐藏",@"慢动作",@"屏幕快照",@"视频",@"全景照片",@"定时拍照",@"最近添加",@"最近删除",@"连拍快照",@"喜爱",@"自拍"];
            }
    return groupNames;
}

-(void)setGroupNames:(NSArray<NSString *> *)newGroupNames
{
    groupNames = newGroupNames;
    
    [self localizeHandle];
}

//初始化方法
-(instancetype)initWithGroupNames:(NSArray<NSString *> *)groupNames
{
    if (self = [super init])
    {
      
        [self setGroupNames:groupNames];
              
    }
    
    return self;
}


+(instancetype)storeConfigWithGroupNames:(NSArray<NSString *> *)groupNames
{
    return [[self alloc]initWithGroupNames:groupNames];
}



/** 本地化语言处理 */
- (void)localizeHandle
{
    NSMutableArray <NSString *> * localizedHandle = [NSMutableArray arrayWithArray:groupNames];
    
    for (NSUInteger i = 0; i < localizedHandle.count; i++)
    {
        [localizedHandle replaceObjectAtIndex:i withObject:NSLocalizedString(localizedHandle[i], @"")];
    }
    
    groupNames = [NSArray arrayWithArray:localizedHandle];
}


@end




