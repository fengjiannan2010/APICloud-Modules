//
//  WPhotoViewController.m
//  photoDemo
//
//  Created by wangxinxu on 2017/6/1.
//  Copyright © 2017年 wangxinxu. All rights reserved.
//

#import "WPhotoViewController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"
#import "UZAlbumSingleton.h"
#import "UZModule.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIView+Toast.h"
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

@interface WPhotoViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
    
    @property (nonatomic, strong) UIButton *finishBtn;
    
    //显示照片
    @property (nonatomic, strong) UICollectionView *ado_collectionView;
    
    //所有照片组的数组（内部是所有相册的组）
    @property (nonatomic, strong) NSMutableArray *photoGroupArr;
    
    //所有照片组内的url数组（内部是最大的相册的照片url，这个相册一般名字是 所有照片或All Photos）
    @property (nonatomic, strong) NSMutableArray *allPhotoArr;
    
    //所选择的图片数组
    @property (nonatomic, strong) NSMutableArray *chooseArray;
    
    //所选择的图片所在cell的序列号数组
    @property (nonatomic, strong) NSMutableArray *chooseCellArray;
    
    @property (nonatomic, strong) NSMutableArray *choosePhotoArr;
    
    
    @property (nonatomic, strong) PHCachingImageManager *imageManager;
    @property (nonatomic, assign) BOOL isShowToast;
    
    @end

@implementation WPhotoViewController
    
#pragma mark - **************** 懒加载
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeNav];
    self.view.backgroundColor = UIColorFromRGB(0xffffff);
    [self.view addSubview:[self ado_collectionView]];
    
    [self getAllPhotos];
    
}
    
#pragma mark GetAllPhotos
- (void)getAllPhotos {
    
    if ([phoneVersion integerValue] >= 8) {
        //高版本使用PhotoKit框架
        [self getHeightVersionAllPhotos];
    }
    else {
        //低版本使用ALAssetsLibrary框架
        [self getLowVersionAllPhotos];
    }
}
    
#pragma mark 高版本使用PhotoKit框架
- (void)getHeightVersionAllPhotos {
    
    [WPFunctionView getHeightVersionAllPhotos:^(PHFetchResult *allPhotos) {
        
        _imageManager = [[PHCachingImageManager alloc]init];
        
        if (!_allPhotoArr) {
            _allPhotoArr = [[NSMutableArray alloc]init];
        }
        
        for (NSInteger i = 0; i < allPhotos.count; i++) {
            
            PHAsset *asset = allPhotos[i];
            if (asset.mediaType == PHAssetMediaTypeImage) {
                [_allPhotoArr addObject:asset];
            }
            
            NSString *cellId = [NSString stringWithFormat:@"cell%ld", (long)i];
            [self.ado_collectionView registerClass:[myPhotoCell class] forCellWithReuseIdentifier:cellId];
            
        }
        [self.ado_collectionView reloadData];
    }];
}
    
#pragma mark 低版本使用ALAssetsLibrary框架
- (void)getLowVersionAllPhotos {
    
    [WPFunctionView getLowVersionAllPhotos:^(ALAssetsGroup *group) {
        if (!_photoGroupArr) {
            _photoGroupArr = [[NSMutableArray alloc]init];
        }
        
        if (group!=nil) {
            [_photoGroupArr addObject:group];
        }
        else{
            ALAssetsGroup* allPhotoGroup = _photoGroupArr[_photoGroupArr.count-1];
            
            if (!_allPhotoArr) {
                _allPhotoArr = [[NSMutableArray alloc]init];
            }
            
            //获取相册分组里面的照片内容
            [allPhotoGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result&&[[result valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto]) {
                    
                    //照片内容url加入数组
                    [_allPhotoArr addObject:result.defaultRepresentation.url];
                }
                else{
                    //刷新显示
                    if (_allPhotoArr.count) {
                        for (NSInteger i = 0; i<_allPhotoArr.count; i++) {
                            NSString *cellId = [NSString stringWithFormat:@"cell%ld", (long)i];
                            [self.ado_collectionView registerClass:[myPhotoCell class] forCellWithReuseIdentifier:cellId];
                        }
                        [self.ado_collectionView reloadData];
                    }
                }
            }];
        }
    }];
}
    
#pragma mark Collection
-(UICollectionView *)ado_collectionView
    {
        if (!_ado_collectionView) {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            [layout setItemSize:CGSizeMake(SelfView_W/4, (SelfView_W)/4)];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
            layout.minimumInteritemSpacing = 0;
            layout.minimumLineSpacing = 0; //上下的间距 可以设置0看下效果
            if (iPhoneX) {
                _ado_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 44+44, SelfView_W, SelfView_H - 44) collectionViewLayout:layout];

            }else{
                _ado_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, navView_H, SelfView_W, SelfView_H - navView_H) collectionViewLayout:layout];

            }
            _ado_collectionView.backgroundColor = [UIColor whiteColor];
            _ado_collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            _ado_collectionView.dataSource = self;
            _ado_collectionView.delegate = self;
            
            [self.ado_collectionView registerClass:[myPhotoCell class] forCellWithReuseIdentifier:@"cellId"];
        }
        return _ado_collectionView;
    }
    
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
    {
        if (self.showCamera) {
            return self.allPhotoArr.count +1;

        }else{
            return self.allPhotoArr.count;

        }
    }
    
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
    {
        
        NSDictionary *stylesInfo = UZAlbumSingleton.sharedSingleton.stylesInfo;
        NSString *cameraImg = [stylesInfo stringValueForKey:@"cameraImg" defaultValue:@""];
        NSString *cameraPath = [UZAppUtils getPathWithUZSchemeURL:cameraImg];

        if (self.showCamera) {
            if (_allPhotoArr.count >indexPath.row-1) {
                NSString *cellId = [NSString stringWithFormat:@"cell%ld", (long)indexPath.row-1];
                myPhotoCell *cell = (myPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];

                
                if ([phoneVersion integerValue] >= 8) {
                    
                    
                    if (indexPath.row == 0) {
                        if (![cameraPath isEqualToString:@""]) {
                            
                            cell.photoView.image = [UIImage imageWithContentsOfFile:cameraPath];
                            
                        }else{
                            
                            cell.photoView.image = [UIImage imageNamed:@"res_UIAlbumBrowser/CAM1.png"];
                            
                        }
                        cell.signImage.hidden = YES;
                    }else{
                        PHAsset *asset = _allPhotoArr[_allPhotoArr.count - indexPath.item];
                        cell.progressView.hidden = YES;
                        cell.representedAssetIdentifier = asset.localIdentifier;
                        CGFloat scale = [UIScreen mainScreen].scale;
                        CGSize cellSize = cell.frame.size;
                        CGSize AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
                        [_imageManager requestImageForAsset:asset
                                                 targetSize:AssetGridThumbnailSize
                                                contentMode:PHImageContentModeDefault
                                                    options:nil
                                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                  if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                                      cell.photoView.image = result;
                                                  }
                                              }];
                    }
                    
                } else {
                    
                    
                    if (!cell.photoView.image) {
                        cell.progressView.hidden = YES;
                        NSURL *url = self.allPhotoArr[self.allPhotoArr.count - indexPath.row+1 ];
                        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
                        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
                            cell.photoView.image = image;
                        } failureBlock:^(NSError *error) {
                            NSLog(@"error=%@", error);
                        }];
                    }
                }
                
                return cell;
            }
            else {
                myPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
                
                cell.backgroundColor = [UIColor whiteColor];
                if (![cameraPath isEqualToString:@""] ) {
                    
                    cell.photoView.image = [UIImage imageWithContentsOfFile:cameraPath];
                    
                }else{
                    
                    cell.photoView.image = [UIImage imageNamed:@"res_UIAlbumBrowser/CAM1.png"];
                    
                }
                cell.signImage.hidden = YES;
                //
                return cell;
            }
        }else{
           
            myPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
            PHAsset *asset = _allPhotoArr[_allPhotoArr.count - indexPath.item-1];
            cell.progressView.hidden = YES;
            cell.representedAssetIdentifier = asset.localIdentifier;
            CGFloat scale = [UIScreen mainScreen].scale;
            CGSize cellSize = cell.frame.size;
            CGSize AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
            [_imageManager requestImageForAsset:asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeDefault
                                        options:nil
                                  resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                      if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                          cell.photoView.image = result;
                                      }
                                  }];
            return cell;
        }
  

    }
    
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
    {
        
        
        NSDictionary *stylesInfo = UZAlbumSingleton.sharedSingleton.stylesInfo;
        NSDictionary *markInfo = [stylesInfo dictValueForKey:@"mark" defaultValue:@{}];
        NSString *icon = [markInfo stringValueForKey:@"icon" defaultValue:@""];
        NSString *position = [markInfo stringValueForKey:@"position" defaultValue:@"bottom_left"];
        NSString *realPath = [UZAppUtils getPathWithUZSchemeURL:icon];
        CGFloat size = [markInfo floatValueForKey:@"size" defaultValue:20];
        
        if (!_chooseArray) {
            _chooseArray = [[NSMutableArray alloc]init];
        }
        if (!_chooseCellArray) {
            _chooseCellArray = [[NSMutableArray alloc]init];
        }
        
        myPhotoCell *cell = (myPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        if (self.showCamera) {
            if ([phoneVersion integerValue] >= 8) {
                
                if (indexPath.row == 0) {
                    [self useCamera];
                }else{
                    
                    cell.progressView.hidden = NO;
                    PHAsset *asset = _allPhotoArr[_allPhotoArr.count-indexPath.row];
                    [WPFunctionView getChoosePicPHImageManager:^(double progress) {
                        cell.progressFloat = progress;
                        
                    } manager:^(UIImage *result) {
                        // Hide the progress view now the request has completed.
                        
                        cell.progressView.hidden = YES;
                        
                        // Check if the request was successful.
                        if (!result) {
                            return;
                        } else {
                            
                            if (cell.chooseStatus == NO) {
                                if ((_chooseArray.count+_choosePhotoArr.count)< _selectPhotoOfMax) {
                                    [_chooseArray addObject:result];
                                    [_chooseCellArray addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                                    [self finishColorAndTextChange:_chooseArray.count+_choosePhotoArr.count];
                                    
                                    UIImageView *signImage = [[UIImageView alloc]init];
                                    
                                    if ([position isEqualToString:@"top_right"]) {
                                        signImage.frame = CGRectMake(cell.frame.size.width-size-3,3, size, size);
                                    }else if ([position isEqualToString:@"top_left"]){
                                        signImage.frame = CGRectMake(3, 3, size, size);
                                        
                                    }else if ([position isEqualToString:@"bottom_left"]){
                                        
                                        signImage.frame = CGRectMake(3, cell.frame.size.width-size-3, size, size);
                                        
                                    }else if ([position isEqualToString:@"bottom_right"]){
                                        signImage.frame = CGRectMake(cell.frame.size.width-size-3, cell.frame.size.width-size-3, size, size);
                                        
                                    }
                                    if ([realPath isEqualToString:@""]) {
                                        
                                        signImage.image = [UIImage imageNamed:@"res_UIAlbumBrowser/wphoto_select_yes@2x.png"];
                                    }else{
                                        
                                        signImage.image = [UIImage imageWithContentsOfFile:realPath];
                                    }
                                    signImage.layer.masksToBounds = YES;
                                    signImage.layer.cornerRadius = size/2;
                                    
                                    [cell addSubview:signImage];
                                    
                                    [WPFunctionView shakeToShow:signImage];
                                    
                                    
                                    cell.chooseStatus = YES;
                                }else{
                                    if ( ! self.isShowToast) {
                                        self.isShowToast = YES;
                                        
                                        [self.navigationController.view makeToast:@"已经达到最高选择数量"
                                                                         duration:[CSToastManager defaultDuration] position:[CSToastManager defaultPosition] title:nil image:nil style:nil completion:^(BOOL didTap) {
                                                                             self.isShowToast = NO;
                                                                         }];
                                    }
                                    
                                    
                                    
                                    
                                }
                                
                            } else{
                                for (NSInteger i = 2; i<cell.subviews.count; i++) {
                                    [cell.subviews[i] removeFromSuperview];
                                }
                                for (NSInteger j = 0; j<_chooseCellArray.count; j++) {
                                    
                                    NSIndexPath *ip = [NSIndexPath indexPathForRow:[_chooseCellArray[j] integerValue] inSection:0];
                                    
                                    if (indexPath.row == ip.row) {
                                        [_chooseArray removeObjectAtIndex:j];
                                    }
                                }
                                [_chooseArray removeObject:result];
                                [_chooseCellArray removeObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                                //                        [self finishColorAndTextChange:_chooseArray.count+_choosePhotoArr.count];
                                
                                cell.chooseStatus = NO;
                            }
                        }
                    } asset:asset viewSize:self.view.bounds.size];
                    
                }
                
            } else {
                if (cell.chooseStatus == NO) {
                    if ((_chooseArray.count+_choosePhotoArr.count) < _selectPhotoOfMax) {
                        [_chooseArray addObject:_allPhotoArr[_allPhotoArr.count-indexPath.row]];
                        [_chooseCellArray addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        //                    [self finishColorAndTextChange:_chooseArray.count+_choosePhotoArr.count];
                        
                        UIImageView *signImage = [[UIImageView alloc]initWithFrame:CGRectMake(cell.frame.size.width-22-5, 5, 22, 22)];
                        signImage.layer.cornerRadius = 22/2;
                        signImage.image = [UIImage imageNamed:@"res_UIAlbumBrowser/wphoto_select_yes@2x.png"];
                        signImage.layer.masksToBounds = YES;
                        [cell addSubview:signImage];
                        
                        [WPFunctionView shakeToShow:signImage];
                        
                        cell.chooseStatus = YES;
                    }
                } else{
                    for (NSInteger i = 2; i<cell.subviews.count; i++) {
                        [cell.subviews[i] removeFromSuperview];
                    }
                    [_chooseArray removeObject:_allPhotoArr[_allPhotoArr.count-indexPath.row]];
                    [_chooseCellArray removeObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                    //                [self finishColorAndTextChange:_chooseArray.count+_choosePhotoArr.count];
                    cell.chooseStatus = NO;
                }
            }
        }else{
            cell.progressView.hidden = NO;
            PHAsset *asset = _allPhotoArr[_allPhotoArr.count-indexPath.row-1];
            [WPFunctionView getChoosePicPHImageManager:^(double progress) {
                cell.progressFloat = progress;
                
            } manager:^(UIImage *result) {
                // Hide the progress view now the request has completed.
                
                cell.progressView.hidden = YES;
                
                // Check if the request was successful.
                if (!result) {
                    return;
                } else {
                    
                    if (cell.chooseStatus == NO) {
                        if ((_chooseArray.count+_choosePhotoArr.count)< _selectPhotoOfMax) {
                            [_chooseArray addObject:result];
                            [_chooseCellArray addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [self finishColorAndTextChange:_chooseArray.count+_choosePhotoArr.count];
                            
                            UIImageView *signImage = [[UIImageView alloc]init];
                            
                            if ([position isEqualToString:@"top_right"]) {
                                signImage.frame = CGRectMake(cell.frame.size.width-size-3,3, size, size);
                            }else if ([position isEqualToString:@"top_left"]){
                                signImage.frame = CGRectMake(3, 3, size, size);
                                
                            }else if ([position isEqualToString:@"bottom_left"]){
                                
                                signImage.frame = CGRectMake(3, cell.frame.size.width-size-3, size, size);
                                
                            }else if ([position isEqualToString:@"bottom_right"]){
                                signImage.frame = CGRectMake(cell.frame.size.width-size-3, cell.frame.size.width-size-3, size, size);
                                
                            }
                            if ([realPath isEqualToString:@""]) {
                                
                                signImage.image = [UIImage imageNamed:@"res_UIAlbumBrowser/wphoto_select_yes@2x.png"];
                            }else{
                                
                                signImage.image = [UIImage imageWithContentsOfFile:realPath];
                            }
                            signImage.layer.masksToBounds = YES;
                            signImage.layer.cornerRadius = size/2;
                            
                            [cell addSubview:signImage];
                            
                            [WPFunctionView shakeToShow:signImage];
                            
                            
                            cell.chooseStatus = YES;
                        }else{
                            if ( ! self.isShowToast) {
                                self.isShowToast = YES;
                                
                                [self.navigationController.view makeToast:@"已经达到最高选择数量"
                                                                 duration:[CSToastManager defaultDuration] position:[CSToastManager defaultPosition] title:nil image:nil style:nil completion:^(BOOL didTap) {
                                                                     self.isShowToast = NO;
                                                                 }];
                            }
                            
                            
                            
                            
                        }
                        
                    } else{
                        for (NSInteger i = 2; i<cell.subviews.count; i++) {
                            [cell.subviews[i] removeFromSuperview];
                        }
                        for (NSInteger j = 0; j<_chooseCellArray.count; j++) {
                            
                            NSIndexPath *ip = [NSIndexPath indexPathForRow:[_chooseCellArray[j] integerValue] inSection:0];
                            
                            if (indexPath.row == ip.row) {
                                [_chooseArray removeObjectAtIndex:j];
                            }
                        }
                        [_chooseArray removeObject:result];
                        [_chooseCellArray removeObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        //                        [self finishColorAndTextChange:_chooseArray.count+_choosePhotoArr.count];
                        
                        cell.chooseStatus = NO;
                    }
                }
            } asset:asset viewSize:self.view.bounds.size];
            
        }
        
    }


    
-(void)finishColorAndTextChange:(NSInteger)choosePhotoCount
    {
        
    }
    
    
    -(void)useCamera
    {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
        pickerController.delegate = self;
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        [self presentViewController:pickerController animated:YES completion:nil];
    }
    
    
    
#pragma mark -- UIImagePickerControllerDelegate
#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}
    
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (image == nil){
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        UIImage *nomalImg =  [self fixOrientation:image];
        
        [self saveImageToPhotos:nomalImg];
        
        NSData *imageData = UIImagePNGRepresentation(nomalImg);
        if(imageData == nil)
        {
            imageData = UIImageJPEGRepresentation(nomalImg, 1.0);
        }
        
        NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        
        NSString *documentsDirectory=[paths objectAtIndex:0];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
        //设置时区,这个对于时间的处理有时很重要
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        [formatter setTimeZone:timeZone];
        NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
        
        NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",timeSp]];
        
        [imageData writeToFile:savedImagePath atomically:YES];
        
        NSLog(@"-------------%ld",(long)UZAlbumSingleton.sharedSingleton.imagePickerCbId);
        
        [UZAlbumSingleton.sharedSingleton.albumBrowser sendResultEventWithCallbackId:UZAlbumSingleton.sharedSingleton.imagePickerCbId
                                                                            dataDict:@{@"originalPath":savedImagePath}
                                                                             errDict:nil
                                                                            doDelete:YES];
        
        [self.navigationController popViewControllerAnimated:NO];
        
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
    
- (NSURL *)applicationDocumentsDirectory {
    NSString *documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [NSURL URLWithString:documentsDirectoryPath];
}
    
    
- (void)saveImageToPhotos:(UIImage*)savedImage
    
    {
        UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
    }
    
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
    
    {
        
        
        NSString *msg = nil ;
        
        if(error != NULL){
            
            msg = @"保存图片失败" ;
            
            NSLog(@"%@",msg);
            
        }else{
            
            msg = @"保存图片成功" ;
            
            NSLog(@"%@",msg);
            
        }
        
    }
    
    // 取消图片选择调用此方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // dismiss UIImagePickerController
    [picker dismissViewControllerAnimated:YES completion:nil];
}
    
    
    
#pragma mark createNav
-(void)makeNav {
    NavView *navVC = [[NavView alloc] init];
  
        navVC.frame = self.view.bounds;


    [navVC setNavViewBack:^{
        [self btnClickBack];
    }];
    [navVC setQuitChooseBack:^{
        [self quitChoose];
    }];
    [self.view addSubview:navVC];
}
    
#pragma mark 取消全部选择
-(void)quitChoose{
    
    if (_chooseCellArray.count == 0) {
        [UZAlbumSingleton.sharedSingleton.albumBrowser sendResultEventWithCallbackId:UZAlbumSingleton.sharedSingleton.imagePickerCbId
                                                                            dataDict:@{@"eventType":@"nextStep"}
                                                                             errDict:nil
                                                                            doDelete:NO];
    }else{
        
        
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:42];
        
        PHAsset *asset;
        
        for (int i =0 ; i < _chooseCellArray.count; i++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_chooseCellArray[i] integerValue] inSection:0];
            
            asset = _allPhotoArr[_allPhotoArr.count-indexPath.row];
            [self cache:_chooseArray[i] imagePath:asset.localIdentifier
               complete:^(NSString * _Nonnull thumbPath) {
                   NSDictionary * listItem;
                   if (asset.mediaType == PHAssetMediaTypeImage) {
                       listItem  =  @{@"path":asset.localIdentifier,
                                      @"thumbPath":thumbPath,
                                      };
                   }else
                   {
                       listItem  =  @{@"path":asset.localIdentifier,
                                      @"thumbPath":thumbPath,
                                      };
                   }
                   [list addObject:listItem];
                   if (list.count == _chooseArray.count) {
                       [UZAlbumSingleton.sharedSingleton.albumBrowser sendResultEventWithCallbackId:UZAlbumSingleton.sharedSingleton.imagePickerCbId dataDict:@{@"eventType":@"nextStep",@"list":list} errDict:nil doDelete:NO];
                   }
             
               }];
            
            
        }
        
    }
    
    
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
        
        float scale = [UIScreen mainScreen].scale;
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(size.width*scale, size.height*scale) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            completion(image);
        }];
    }
    
    
    /* 根据localIdentifier 缓存资源. */
    
- (void)cache:(UIImage *)img imagePath:(NSString *)localIdentifier complete:(nonnull void (^)(NSString * _Nonnull))completeBlock {//保存指定图片到临时位置并回调改位置路径
    NSDictionary *thumbnail = [UZAlbumSingleton.sharedSingleton.stylesInfo dictValueForKey:@"thumbnail" defaultValue:@{}];
    CGFloat w = [thumbnail floatValueForKey:@"w" defaultValue:img.size.width];
    CGFloat h = [thumbnail floatValueForKey:@"h" defaultValue:img.size.height];
    UIImage *saveImg = [self image:img centerInSize:CGSizeMake(w, h)];
    NSString *name = [self md5:localIdentifier];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UZUIAlbumBrowser"];
    NSString *imgPath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@",name]];
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
    NSData * data = UIImageJPEGRepresentation(saveImg, 1.0);
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

-(UIImage *) image: (UIImage *) image centerInSize: (CGSize) viewsize{
    CGSize size = image.size;
    
    CGFloat scalex = viewsize.width / size.width;
    CGFloat scaley = viewsize.height / size.height;
    CGFloat scale = MAX(scalex, scaley);
    
    UIGraphicsBeginImageContext(viewsize);
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    
    float dwidth = ((viewsize.width - width) / 2.0f);
    float dheight = ((viewsize.height - height) / 2.0f);
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
    [image drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;

}
- (NSString *)md5:(NSString *)str{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    
}
    
    
    
#pragma mark 返回
-(void)btnClickBack
    {
        [self.navigationController popViewControllerAnimated:YES];
        //    [self dismissViewControllerAnimated:YES completion:nil];
        [UZAlbumSingleton.sharedSingleton.albumBrowser sendResultEventWithCallbackId:UZAlbumSingleton.sharedSingleton.imagePickerCbId dataDict:@{@"eventType":@"cancel"} errDict:nil doDelete:NO];
    }
    
    @end
