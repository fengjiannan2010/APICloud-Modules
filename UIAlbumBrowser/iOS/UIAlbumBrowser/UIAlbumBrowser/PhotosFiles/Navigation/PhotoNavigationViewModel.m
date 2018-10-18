/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoNavigationViewModel.h"
#import "PhotoCacheManager.h"
#import "PhotoBridgeManager.h"
#import "NSDictionaryUtils.h"
CGSize const PhotoOriginSize = {-100,-100};


@implementation PhotoNavigationViewModel

-(instancetype)init
{
    if (self = [super init])
    {
        self.maxNumberOfSelectedPhoto = 9;
        self.imageSize = PhotoOriginSize;
    }
    
    return self;
}
-(void)setParamsDict:(NSDictionary *)paramsDict
{
    _paramsDict = paramsDict;
    
    NSUInteger max = [paramsDict intValueForKey:@"max" defaultValue:9];
    
    [PhotoCacheManager sharedInstace].maxNumberOfSelectedPhoto = max;
    
}


-(void)setBridgeGetImageBlock:(void (^)(NSArray<UIImage *> * _Nonnull))BridgeGetImageBlock
{
    _BridgeGetImageBlock = BridgeGetImageBlock;
    
    [PhotoBridgeManager sharedInstance].BridgeGetImageBlock = BridgeGetImageBlock;
}


-(void)setBridgeGetImageDataBlock:(void (^)(NSArray<NSData *> * _Nonnull))BridgeGetImageDataBlock
{
    _BridgeGetImageDataBlock = BridgeGetImageDataBlock;
    
    [PhotoBridgeManager sharedInstance].BridgeGetImageDataBlock = BridgeGetImageDataBlock;
}

-(void)setBridgeGetAssetBlock:(void (^)(NSArray<PHAsset *> * _Nonnull))BridgeGetAssetBlock
{
    _BridgeGetAssetBlock = BridgeGetAssetBlock;
    
    [PhotoBridgeManager sharedInstance].BridgeGetAssetBlock = BridgeGetAssetBlock;
}


-(void)setImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    
    [PhotoCacheManager sharedInstace].imageSize = imageSize;
}




@end

