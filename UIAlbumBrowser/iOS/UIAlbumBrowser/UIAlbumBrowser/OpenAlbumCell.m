/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "OpenAlbumCell.h"
#import "Masonry.h"
#import "AlbumBrowserSinglen.h"
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"


@implementation OpenAlbumCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.paramsDict = AlbumBrowserSinglen.sharedSingleton.openAlbumDict;
        NSString *normal = [self.paramsDict stringValueForKey:@"normal" defaultValue:@""];
        NSString *active = [self.paramsDict stringValueForKey:@"active" defaultValue:@""];
        CGFloat size = [self.paramsDict floatValueForKey:@"size" defaultValue:20];
        self.topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.topBtn.frame =self.contentView.bounds;
        [self.contentView addSubview:self.topBtn];
        self.signBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *normalImg =[UIImage imageNamed: [UZAppUtils getPathWithUZSchemeURL:normal]];
        UIImage *activeImg =[UIImage imageNamed: [UZAppUtils getPathWithUZSchemeURL:active]];
        if (normalImg) {
            [self.signBtn setImage:normalImg forState:UIControlStateNormal];
        }else{
            [self.signBtn setImage:[UIImage imageNamed:@"res_UIAlbumBrowser/openAlbumUnSelect1.png"] forState:UIControlStateNormal];
        }

        if (activeImg) {
            [self.signBtn setImage:activeImg forState:UIControlStateSelected];

        }else{
            [self.signBtn setImage:[UIImage imageNamed:@"res_UIAlbumBrowser/openAlbumSelect.png"] forState:UIControlStateSelected];

        }
        [self.topBtn addSubview:self.signBtn];

        [self.signBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-3);
                make.top.mas_equalTo(3);
                make.width.height.mas_equalTo(size);
        }];
   
        
        self.videoImg = [[UIImageView alloc]initWithFrame:CGRectMake(3, self.frame.size.width-23, 20, 20)];
        self.videoImg.image = [UIImage imageNamed:@"res_UIAlbumBrowser/openAlbumUnVodio.png"];
        [self.topBtn addSubview:self.videoImg];
        
    }
    
    return self;
}



//-(void)setSignBtn:(UIButton *)signBtn{
//    _signBtn = signBtn;
//
//
//
//}

-(void)setAsset:(PHAsset *)asset{
    _asset = asset;
    
    [self requestImageForAsset:asset size:CGSizeMake(100, 100) resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
        [self.topBtn setImage:image forState:UIControlStateNormal];
    }];
}

#pragma mark - 获取asset对应的图片
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    option.resizeMode = resizeMode;//控制照片尺寸
    option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;//控制照片质量
    option.synchronous = YES;
    option.networkAccessAllowed = YES;
    option.version = PHImageRequestOptionsVersionCurrent;


    
    float scale = [UIScreen mainScreen].scale;
    //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(size.width*scale, size.height*scale) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        completion(image);
    }];
    
    
}

- (void)prepareForReuse{
    [super prepareForReuse];
//    self.topBtn = nil;
//    [self.signBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//    [self.signBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
//    self.signBtn = nil;


    
}
@end
