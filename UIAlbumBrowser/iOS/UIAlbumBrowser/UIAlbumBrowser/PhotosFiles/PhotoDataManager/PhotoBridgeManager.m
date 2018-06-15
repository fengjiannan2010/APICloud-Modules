/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoBridgeManager.h"
#import "PhotoRequestStore.h"
#import "PhotoCacheManager.h"

@implementation PhotoBridgeManager


+(instancetype)sharedInstance
{
    static PhotoBridgeManager * bridgeManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        bridgeManager = [self new];
        
    });
    
    return bridgeManager;
}



-(void)startRenderImage:(NSArray<PHAsset *> *)assets
{
    //获得想要的size
    CGSize imageSize =  [PhotoCacheManager sharedInstace].imageSize;
    
    BOOL isIgnore = (imageSize.width == -100);
    
    //获得当前的高清图否
    BOOL isHightQuarity = [PhotoCacheManager sharedInstace].isHightQuarity;
    
    
    [PhotoRequestStore imagesWithAssets:assets status:isHightQuarity Size:imageSize ignoreSize:isIgnore complete:^(NSArray<UIImage *> * _Nonnull images) {
        
        //进行回调
        if (self.BridgeGetImageBlock)
        {
            self.BridgeGetImageBlock(images);
        }
    }];
    
    
    if (self.BridgeGetImageDataBlock)
    {
        //请求数据
        [PhotoRequestStore dataWithAssets:assets status:isHightQuarity complete:^(NSArray<NSData *> * _Nonnull datas) {
            
            self.BridgeGetImageDataBlock(datas);
            
        }];
    }
    
    
    
}

@end

