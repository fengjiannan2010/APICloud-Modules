/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "OpenAlbumDetailController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UZAppUtils.h"
@interface OpenAlbumDetailController ()
@property (nonatomic, strong) MPMoviePlayerController *mpVideoPlayer;
@property (nonatomic, strong) NSString *thumImgPath;

@end

@implementation OpenAlbumDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    UIButton *rightbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 20)];
    [rightbutton setTitle:@"完成" forState:UIControlStateNormal];
    [rightbutton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [rightbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightbutton.titleLabel.font = [UIFont systemFontOfSize:14];
    UIBarButtonItem *rightitem=[[UIBarButtonItem alloc]initWithCustomView:rightbutton];
    self.navigationItem.rightBarButtonItem=rightitem;
    
    UIButton *leftbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 20)];
    [leftbutton setImage:[UIImage imageNamed:@"res_UIAlbumBrowser/back@2x.png"] forState:UIControlStateNormal];
    leftbutton.titleLabel.font = [UIFont systemFontOfSize:14];
    [leftbutton addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftitem=[[UIBarButtonItem alloc]initWithCustomView:leftbutton];
    self.navigationItem.leftBarButtonItem=leftitem;
    [self openMoviePlayer];
    [self getThumPath];
    // Do any additional setup after loading the view.
}



-(void)openMoviePlayer{
   
    CGRect defaultFrame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    UIView  *bgView = [[UIView alloc]initWithFrame:defaultFrame];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    //获取本地视频路径或网络视频路径
    //file:///var/mobile/Media/DCIM/105APPLE/IMG_5964.MOV
    NSString *videoPath = self.localPath;
    __block NSURL *videoUrl = nil;
    if ([videoPath isKindOfClass:[NSString class]] && videoPath.length > 0) {
        videoUrl = [NSURL fileURLWithPath:[UZAppUtils getPathWithUZSchemeURL:videoPath]];
        }
       self.mpVideoPlayer =[[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
       self.mpVideoPlayer.scalingMode = MPMovieScalingModeAspectFit;
       self.mpVideoPlayer.shouldAutoplay = YES;
       [self.mpVideoPlayer prepareToPlay];
        [bgView addSubview:self.mpVideoPlayer.view];
        self.mpVideoPlayer.view.frame = bgView.bounds;
        self.mpVideoPlayer.view.backgroundColor  = [UIColor whiteColor];
        self.mpVideoPlayer.backgroundView.backgroundColor =[UIColor whiteColor];
        self.mpVideoPlayer.view.userInteractionEnabled = NO;       //让播放器触摸失效
        self.mpVideoPlayer.controlStyle = MPMovieControlStyleNone;
    
}

-(void)getThumPath{
  
    
    [self requestImageForAsset:self.asset size:CGSizeMake(300, 300) resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage * image) {
        [self cache:image imagePath:self.asset.localIdentifier complete:^(NSString * _Nonnull thumPath) {
            
            self.thumImgPath = thumPath;
        }];
    }];
}
-(void)rightBtnClick{
    [self.navigationController popViewControllerAnimated:NO];
    
   NSDictionary *targetDict = @{
                   @"path": self.asset.localIdentifier ?: @"",
                   @"thumbPath": self.thumImgPath ?: @"",
                   @"type":@"video"
                   };
    
    NSLog(@"%@",targetDict);
    [self.module sendResultEventWithCallbackId:self.openAlbumCbId dataDict:@{@"eventType":@"select",@"groupId":self.groupId,@"target":targetDict} errDict:nil doDelete:NO];
}

- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion
{
    __block BOOL isPhotoInICloud = NO;
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
    //float scale = [UIScreen mainScreen].scale;
    // 下载iCloud 图片的进度回调 只要图片是在icloud中 然后去请求图片就会走这个回调 如果图片没有在iCloud中不回走这个回调
    //里面的会调中的参数重 NSDictionary *info 是否有cloudKey 来判断是否是  iCloud 处理UI放到主线程
    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        isPhotoInICloud = YES;
    };
    
    //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(size.width, size.height) contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        if (isPhotoInICloud) {
            // Photo is in iCloud.
        }else{
            completion(image);
        }
    }];
    
    
    
}

- (void)cache:(UIImage *)img imagePath:(NSString *)localIdentifier complete:(nonnull void (^)(NSString * _Nonnull))completeBlock {//保存指定图片到临时位置并回调改位置路径
    UIImage *saveImg;
    if (img.imageOrientation>0) {
        saveImg = img;
    }else{
        saveImg=[self fixOrientation:img];
        
    }
    NSData * data = UIImagePNGRepresentation(saveImg);
    PHFetchResult<PHAsset *> * fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];

    PHAsset * asset = fetchResult.firstObject;
    //可获取图片名称
    NSString *filename =   [asset valueForKey:@"filename"];
    NSString * typeName;
    if (asset.mediaType == PHAssetMediaTypeImage) {
        typeName = [filename pathExtension];
    }else{
        typeName = @"png";
    }
    NSString *name = [self getCurrentTime];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UZUIAlbumBrowser"];
   // self.realPath = filePath;
    NSString *imgPath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@.%@",name,typeName]];
    // 是否已经存在缓存图片了?
    if ([fileManager fileExistsAtPath:imgPath]) {
        if (completeBlock) {
            completeBlock(imgPath);
        }
        return;
    }
    if (![fileManager fileExistsAtPath:filePath]) {        //创建路径
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //创建文件
    if (data) {
        [fileManager createFileAtPath:imgPath contents:data attributes:nil];
    }else{// 说明没有有效的图片数据,比如相册中图片为0时,是没有对应的缩略图的.
        if (completeBlock) {
            completeBlock(@"");
        }
        return;
    }
    //回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completeBlock) {
            completeBlock(imgPath);
        }
    });
}


-(void)leftBtnClick{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
- (NSString *)getCurrentTime{
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
    
}

@end
