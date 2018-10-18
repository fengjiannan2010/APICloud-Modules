/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "BaseViewModel.h"
@class UZUIAlbumBrowser;

/// 图片的原始大小
extern CGSize const PhotoOriginSize;

/// 主导航控制器的viewModel
 @interface PhotoNavigationViewModel : BaseViewModel

/// 最大允许选择的图片数目，默认为9
@property (nonatomic, assign) NSUInteger maxNumberOfSelectedPhoto;

/// 图片的大小，默认为RITLPhotoOriginSize
@property (nonatomic, assign) CGSize imageSize;

/// 获取图片之后的回调
@property (nonatomic, copy, nullable)void(^BridgeGetImageBlock)(NSArray <UIImage *> *_Nullable);

/// 获取图片的data
@property (nonatomic, copy, nullable)void(^BridgeGetImageDataBlock)(NSArray <NSData *> *_Nullable);

/// 获取图片的data
@property (nonatomic, copy, nullable)void(^BridgeGetAssetBlock)(NSArray <PHAsset *> *_Nullable);


@property (nonatomic, strong) NSDictionary * _Nullable paramsDict;



@end


