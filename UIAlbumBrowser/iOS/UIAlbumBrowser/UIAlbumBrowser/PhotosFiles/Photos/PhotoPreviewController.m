/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoPreviewController.h"
#import "PHAsset+RITLPhotoRepresentation.h"

@interface PhotoPreviewController ()

@property (nonatomic, strong)UIImageView * imageView;

@end

@implementation PhotoPreviewController

-(instancetype)initWithShowAsset:(PHAsset *)showAsset
{
    if (self = [super init])
    {
        _showAsset = showAsset;
    }
    
    return self;
}


+(instancetype)previewWithShowAsset:(PHAsset *)showAsset
{
    return [[self alloc]initWithShowAsset:showAsset];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    //获得图片的宽度与高度的比例
    CGFloat scale = _showAsset.pixelHeight * 1.0 / _showAsset.pixelWidth;
    
    _assetSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width * scale);
    //设置当前的大小
    self.preferredContentSize = _assetSize;
    
    //add subview
    //    [self __addImageView];
    
    __weak typeof(self) weakSelf = self;
    
    //获取图片
    [_showAsset representationImageWithSize:_assetSize complete:^(UIImage * _Nullable image, PHAsset * _Nonnull asset) {
        
        //初始化ImageView
        weakSelf.imageView.image = image;
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

