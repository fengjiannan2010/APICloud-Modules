//
//  PHAssetCollection+UZPhotoRepresentation.h
//  UIAlbumBrowser
//
//  Created by wei on 2018/6/4.
//  Copyright © 2018年 wei. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAssetCollection (UZPhotoRepresentation)

/**
 获取PHAssetCollection的详细信息
 
 @param size 获得封面图片的大小
 @param completeBlock 取组的标题、照片资源的预估个数以及封面照片,默认为最新的一张
 */
- (void)representationImageWithSize:(CGSize)size
                           complete:(void (^_Nullable)(NSString *_Nullable,NSUInteger,UIImage * __nullable)) completeBlock;
@end
