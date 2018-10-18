/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoRequestStore.h"

#import "PHImageRequestOptions+RITLPhotoRepresentation.h"
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width
@implementation PhotoRequestStore


+(void)imagesWithAssets:(NSArray<PHAsset *> *)assets
                 status:(BOOL)status
                   Size:(CGSize)size
             ignoreSize:(BOOL)isIgnoreSize
               complete:(nonnull void (^)(NSArray<UIImage *> * _Nonnull))imagesBlock

{
    __block NSMutableArray <UIImage *> * images = [NSMutableArray arrayWithCapacity:assets.count];
    
    
    
    for (NSUInteger i = 0; i < assets.count; i++)
    {
        //获取资源
        PHAsset * asset = assets[i];
        
        if (isIgnoreSize)
        {
            size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        }
        
        if (status)
        {
            printf("\n\n高清图！！！！！！\n\n");
        }
        
        //获取图片类型
        PHImageRequestOptionsDeliveryMode mode = status ? PHImageRequestOptionsDeliveryModeHighQualityFormat : PHImageRequestOptionsDeliveryModeOpportunistic;
         __block BOOL isPhotoInICloud = NO;
        PHImageRequestOptions * option = [PHImageRequestOptions imageRequestOptionsWithDeliveryMode:mode];
        option.synchronous = true;
        option.networkAccessAllowed = YES;
        option.version = PHImageRequestOptionsVersionCurrent;

        option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            isPhotoInICloud = YES;
           
        };
        //请求图片
        [[PHImageManager defaultManager]requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (isPhotoInICloud) {
                [self  showMessage:@"已保存系统相册"];
                
            }else
            {
            [images addObject:result];
            
            if (images.count == assets.count)//表示已经添加完毕
            {
                //回调
                imagesBlock([images mutableCopy]);
            }
            }
        }];
    }
}

+(void)dataWithAssets:(NSArray<PHAsset *> *)assets
               status:(BOOL)status
             complete:(void (^)(NSArray<NSData *> * _Nonnull))dataBlock
{
    __block NSMutableArray <NSData *> * datas = [NSMutableArray arrayWithCapacity:assets.count];
    
    for (NSUInteger i = 0; i < assets.count; i++)
    {
        //获取资源
        PHAsset * asset = assets[i];
        
        //获取图片类型
        PHImageRequestOptionsDeliveryMode mode = status ? PHImageRequestOptionsDeliveryModeHighQualityFormat : PHImageRequestOptionsDeliveryModeOpportunistic;
         __block BOOL isPhotoInICloud = NO;
        PHImageRequestOptions * option = [PHImageRequestOptions imageRequestOptionsWithDeliveryMode:mode];
        option.synchronous = true;
        option.networkAccessAllowed = YES;
        option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            isPhotoInICloud = YES;
        };
        
        if (status)
        {
            printf("高清数据!\n");
        }
        
        
        //请求数据
        [[PHImageManager defaultManager]requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            if (isPhotoInICloud) {
                [self  showMessage:@"已保存系统相册"];
                
                
            }else
            {
            [datas addObject:imageData];
            
            if (datas.count == assets.count)
            {
                dataBlock([datas copy]);
            }
            }
        }];
    }
}

+(void)showMessage:(NSString *)message
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview = [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    CGSize LabelSize = [message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(290, 9000)];
    label.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    [showview addSubview:label];
    showview.frame = CGRectMake((SCREEN_WIDTH - LabelSize.width - 20)/2, SCREEN_HEIGHT - 100, LabelSize.width+20, LabelSize.height+10);
    [UIView animateWithDuration:1.5 animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
    
}


@end
