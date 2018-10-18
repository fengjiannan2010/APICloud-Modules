/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "GroupCell.h"

@implementation GroupCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.topBtn.frame =self.contentView.bounds;
        [self.contentView addSubview:self.topBtn];
        self.signBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.signBtn.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
        self.signBtn.frame = self.contentView.bounds;
        [self.signBtn setImage:[UIImage imageNamed:@"res_UIAlbumBrowser/circleGroup@3x.png"] forState:UIControlStateNormal];
        [self.signBtn setImage:[UIImage imageNamed:@"res_UIAlbumBrowser/circleGroup@3x.png"] forState:UIControlStateSelected];
        [self.topBtn addSubview:self.signBtn];
        self.borderLayer = [CAShapeLayer layer];
        self.borderLayer.bounds = self.topBtn.bounds;
        self.borderLayer.position = CGPointMake(CGRectGetMidX(self.topBtn.bounds),CGRectGetMidY(self.topBtn.bounds));
        self.borderLayer.path = [UIBezierPath bezierPathWithRect:self.borderLayer.bounds].CGPath;//矩形路径
        self.borderLayer.lineWidth = 1. / [[UIScreen mainScreen] scale];//虚线宽度
        //虚线边框
        self.borderLayer.lineDashPattern = @[@5, @5];
        //实线边框
        self.borderLayer.fillColor = [UIColor clearColor].CGColor;
        self.borderLayer.strokeColor = [UIColor redColor].CGColor;
        

    }
    
    return self;
}

-(void)setSignBtn:(UIButton *)signBtn{
    _signBtn = signBtn;
}

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
@end
