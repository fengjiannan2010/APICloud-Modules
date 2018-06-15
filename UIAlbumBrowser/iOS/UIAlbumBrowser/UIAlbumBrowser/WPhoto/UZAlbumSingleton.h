//
//  UZAlbumSingleton.h
//  UIAlbumBrowser
//
//  Created by wei on 2017/8/28.
//  Copyright © 2017年 wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UZUIAlbumBrowser.h"
#import <UIKit/UIKit.h>

@interface UZAlbumSingleton : NSObject

@property(strong,nonatomic)NSDictionary *stylesInfo;
@property(strong,nonatomic)NSDictionary *navInfo;
@property(assign,nonatomic)NSInteger imagePickerCbId;
@property(strong,nonatomic)UZUIAlbumBrowser *albumBrowser;

+(instancetype)sharedSingleton;
@end
