
//
//  PHAssetCollection+UZPhotoRepresentation.m
//  UIAlbumBrowser
//
//  Created by wei on 2018/6/4.
//  Copyright © 2018年 wei. All rights reserved.
//

#import "PHAssetCollection+UZPhotoRepresentation.h"
#import <objc/runtime.h>
#import "AlbumBrowserSinglen.h"
@implementation PHAssetCollection (UZPhotoRepresentation)
- (void)representationImageWithSize:(CGSize)size
                           complete:(void (^_Nullable)(NSString *_Nullable,NSUInteger,UIImage * __nullable)) completeBlock
{
    //    __weak typeof(self) copy_self = self;
    //获取照片资源
        PHFetchResult * assetResult = [PHAsset fetchAssetsInAssetCollection:self options:nil];
    
        NSUInteger count= 0;
        if([AlbumBrowserSinglen.sharedSingleton.openType isEqualToString:@"image"]){
           count =  [assetResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];;
        }
        else if ([AlbumBrowserSinglen.sharedSingleton.openType isEqualToString:@"video"]){

            count =  [assetResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];;

        }
        else{
            count = assetResult.count;
        }
    

    
    
        if (assetResult.count == 0)
        {
            completeBlock(self.localizedTitle,0,[UIImage new]);
            return;
        }
    
        UIImage * representationImage = objc_getAssociatedObject(self, &@selector(representationImageWithSize:complete:));
    
    
        if (representationImage != nil)
        {
            completeBlock(self.localizedTitle,count,representationImage);return;
        }
    
        //获取屏幕的点
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize newSize = CGSizeMake(size.width * scale, size.height * scale);
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    __block BOOL isPhotoInICloud = NO;
    option.resizeMode = PHImageRequestOptionsResizeModeExact;//控制照片尺寸
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;//控制照片质量
    option.synchronous = YES;
    option.networkAccessAllowed = YES;
    option.version = PHImageRequestOptionsVersionCurrent;

    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        isPhotoInICloud = YES;
    };
    
        //开始截取照片
        [[PHCachingImageManager defaultManager] requestImageForAsset:assetResult.lastObject targetSize:newSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
    
            if (isPhotoInICloud) {
                // Photo is in iCloud.
            }else{
             
                objc_setAssociatedObject(self, &@selector(representationImageWithSize:complete:), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                //block to trans image
                completeBlock(self.localizedTitle,count,result);
            }
          
    
        }];
}


-(void)dealloc
{
        objc_setAssociatedObject(self, &@selector(representationImageWithSize:complete:), nil, OBJC_ASSOCIATION_ASSIGN);
    objc_removeAssociatedObjects(self);
}
@end
