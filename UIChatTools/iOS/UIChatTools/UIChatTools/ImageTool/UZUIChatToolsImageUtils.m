/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import "UZUIChatToolsImageUtils.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UZUIChatToolsImageModel.h"

@implementation UZUIChatToolsImageUtils

+ (void)loadImagesFromCamerarollSucess:(void(^)(NSArray *images))sucessBlock failure:(void(^)(NSError *error))failureBlock{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSString *groupName =(NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
        NSLog(@"%@",groupName);
        if ([groupName isEqualToString:@"相机胶卷"] ||[groupName isEqualToString:@"Camera Roll"]||[groupName isEqualToString:@"所有照片"] ||[groupName isEqualToString:@"All Photos"]) {
            NSArray *imagesArray = [self getImagesFromGroup:group];
            if (sucessBlock) {
                sucessBlock(imagesArray);
            }
        }
    } failureBlock:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
    
}


+ (void)loadLimitImagesFromCamerarollSucess:(void(^)(NSArray *images))sucessBlock failure:(void(^)(NSError *error))failureBlock{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSString *groupName =(NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
        //NSLog(@"%@",groupName);
        //相机胶卷
        
        if ([groupName isEqualToString:@"相机胶卷"] ||[groupName isEqualToString:@"Camera Roll"]||[groupName isEqualToString:@"所有照片"] ||[groupName isEqualToString:@"All Photos"]) {
            
            NSArray *imagesArray = [self getLimitImagesFromGroup:group];
            if (sucessBlock) {
                sucessBlock(imagesArray);
            }
        }
    } failureBlock:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
    
}

/////获取所有照片
//+ (void)loadAllPhotoSucess:(void(^)(NSArray *photos))sucessBlock failure:(void(^)(NSError *error))failureBlock{
//    ALAssetsLibrary *library = [ALAssetsLibrary new];
//    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:10];
//    __block NSInteger count = 0;
//    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//        NSString *groupName =(NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
//        NSLog(@"groupName:%@",groupName);
//        if (groupName) {
//            DXPhotoGroupModel *model = [DXPhotoGroupModel new];
//            model.groupName = groupName;
//            model.images =  [self getImagesFromGroup:group];
//            [arrayM addObject:model];
//        }
//        count ++;
//        if (count != arrayM.count) {
//            if (sucessBlock) {
//                sucessBlock([[arrayM reverseObjectEnumerator] allObjects]);
//            }
//        }
//        
//        
//    } failureBlock:^(NSError *error) {
//        if (failureBlock) {
//            failureBlock(error);
//        }
//    }];
//    
//}


+ (NSArray *)getLimitImagesFromGroup:(ALAssetsGroup *)group{
    NSMutableArray *imagesArray = [NSMutableArray arrayWithCapacity:42];
    
    __block int i = 10;// 只获取十张.

    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        UIImage *thumbnail = [UIImage imageWithCGImage:[result aspectRatioThumbnail]];
        NSString *imagePath = [result.defaultRepresentation.url absoluteString];
        NSString *imageName = result.defaultRepresentation.filename;
        if (thumbnail) {
            thumbnail = [self imageCompressForHeight:thumbnail targetHeight:180];
            UZUIChatToolsImageModel *model = [[UZUIChatToolsImageModel alloc] init];
            model.image = thumbnail;
            model.count = 0;
            model.imageName = imageName;
            model.imagePath = imagePath;
            [imagesArray addObject:model];
            i --;
            if (i == 0) {
                * stop = YES;
            }
        }
        
        
    }];
    
    return [imagesArray copy];
}


+ (NSArray *)getImagesFromGroup:(ALAssetsGroup *)group{
    NSMutableArray *imagesArray = [NSMutableArray arrayWithCapacity:10];
    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        UIImage *thumbnail = [UIImage imageWithCGImage:[result aspectRatioThumbnail]];
        NSString *imagePath = [result.defaultRepresentation.url absoluteString];
        NSString *imageName = result.defaultRepresentation.filename;
        if (thumbnail) {
            thumbnail = [self imageCompressForHeight:thumbnail targetHeight:180];
            UZUIChatToolsImageModel *model = [[UZUIChatToolsImageModel alloc] init];
            model.image = thumbnail;
            model.count = 0;
            model.imageName = imageName;
            model.imagePath = imagePath;
            [imagesArray addObject:model];
        }
    }];
    return [imagesArray copy];
}

//指定高度按比例缩放
+ (UIImage *)imageCompressForHeight:(UIImage *)sourceImage targetHeight:(CGFloat)defineHeight {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetHeight = defineHeight;
    CGFloat targetWidth = defineHeight * (width / height);
    
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil) {
        NSLog(@"scale image");
    }
    UIGraphicsEndImageContext();
    return newImage;
}


@end
