/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoGroupViewModel.h"
#import "PhotoCacheManager.h"
#import "PHAssetCollection+UZPhotoRepresentation.h"
#import "PhotoStore.h"
#import "PhotoBridgeManager.h"
#import "AlbumBrowserSinglen.h"
@interface PhotoGroupViewModel ()

@property (nonatomic, strong) PhotoStore * photoStore;
@property (nonatomic, strong) NSArray<PHAssetCollection *> * groups;

@end

@implementation PhotoGroupViewModel

-(instancetype)init
{
    if (self = [super init])
    {
        _photoStore = [PhotoStore new];
    }
    
    return self;
}

-(void)dealloc
{
    [[PhotoCacheManager sharedInstace] resetMaxSelectedCount];
#ifdef RITLDebug
    NSLog(@"Dealloc %@",NSStringFromClass([self class]));
#endif
}



-(NSUInteger)numberOfGroup
{
    return 1;
}


-(NSUInteger)numberOfRowInSection:(NSUInteger)section
{
    return self.groups.count;
}


-(CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


-(void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    //回调当前的PHAssetCollection
    //    if (self.selectedBlock)
    //    {
    //        self.selectedBlock([self assetCollectionIndexPath:indexPath],indexPath);
    //    }
}


-(void)ritl_didSelectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animate
{
    if (self.selectedBlock)
    {
        self.selectedBlock([self assetCollectionIndexPath:indexPath],indexPath,animate);
    }
}


-(PHAssetCollection *)assetCollectionIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
//  // NSLog(@"groups%d",self.groups.count);
    if (row > self.groups.count)
    {
        return nil;
    }else if(row == self.groups.count){
        row = row-1;
    }
    
    return self.groups[row];
}
- (void)dismissGroupController{
    
    if ([[PhotoBridgeManager sharedInstance]BridgeGetAssetBlock]) {
        [[PhotoBridgeManager sharedInstance]BridgeGetAssetBlock](@[]);
    }
    
    if (self.dismissGroupBlock) self.dismissGroupBlock();
}

-(void)fetchDefaultGroups
{
    __weak typeof(self) weakSelf = self;
    
    
    [_photoStore fetchDefaultAllPhotosGroup:^(NSArray<PHAssetCollection *> * _Nonnull groups, PHFetchResult * _Nonnull collections) {
        

        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        
        strongSelf.groups = groups;
        
        //进行回调
        if (strongSelf.fetchGroupsBlock)
        {
            if ([NSThread isMainThread])
            {
                strongSelf.fetchGroupsBlock(strongSelf.groups); return;
            }
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    strongSelf.fetchGroupsBlock(strongSelf.groups);
                    
                });
            });
        }
        
    }];
    
    //   [_photoStore fetchPhotosGroup:^(NSArray<PHAssetCollection *> * _Nonnull groups) {
    //
    //       __strong typeof(weakSelf) strongSelf = weakSelf;
    //
    //       strongSelf.groups = groups;
    //
    //       //进行回调
    //       if (strongSelf.fetchGroupsBlock)  strongSelf.fetchGroupsBlock(strongSelf.groups);
    //
    //   }];
}

-(CGSize)imageSize
{
    if (_imageSize.width == 0 && _imageSize.height == 0)
    {
        return CGSizeMake(60, 60);
    }
    
    return _imageSize;
}

-(void)loadGroupTitleImage:(NSIndexPath *)indexPath
                  complete:(PhotoGroupMessageBlock)competeBlock
{
    PhotoGroupMessageBlock complete  = [competeBlock copy];
    
    //获取对象
    PHAssetCollection * collection = [self assetCollectionIndexPath:indexPath];
    
    
    [collection representationImageWithSize:self.imageSize complete:^(NSString * _Nonnull title, NSUInteger count, UIImage * _Nullable image) {
        
        //
        NSString * appendTitle = [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(title,@""),@(count)];
        
        complete(title,image,appendTitle,count);
        
    }];
    
}

-(PHFetchResult *)fetchPhotos:(NSIndexPath *)indexPath;
{

    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.wantsIncrementalChangeDetails = YES;
    options.includeAllBurstAssets = YES;
    options.includeHiddenAssets = YES;
    // 只取图片
    if ([AlbumBrowserSinglen.sharedSingleton.openType isEqualToString:@"image"]) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    }else if([AlbumBrowserSinglen.sharedSingleton.openType isEqualToString:@"video"]){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeVideo];

    }else{
        
    }
    return [PHAsset fetchAssetsInAssetCollection:[self assetCollectionIndexPath:indexPath] options:options];
}

-(NSString *)title
{
    return @"相册";
}

@end

