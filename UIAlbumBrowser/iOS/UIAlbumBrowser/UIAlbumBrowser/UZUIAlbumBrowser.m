/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "UZUIAlbumBrowser.h"
#import "NSDictionaryUtils.h"
#import "PhotoNavigationViewModel.h"
#import "PhotoNavigationViewController.h"
#import "PhotosCell.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
#import "PhotoStore.h"
#import "PHAssetCollection+UZPhotoRepresentation.h"
#import "PhotoGroupViewController.h"
#import "WPhotoViewController.h"
#import "UZAlbumSingleton.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlbumBrowserSinglen.h"
#import "UIBlockButtonForAlbumBrowser.h"


//#import "RITLPhotosViewController.h"
//#import "RITLPhotosCell.h"
//#import <Photos/Photos.h>
//#import "RITLKit.h"

#define Start_X          5.0f      // 第一个按钮的X坐标
#define Start_Y          5.0f     // 第一个按钮的Y坐标
#define Width_Space      5.0f      // 2个按钮之间的横间距
#define Height_Space     5.0f     // 竖间距
#define Button_Height   97.0f    // 高


@interface UZUIAlbumBrowser () <UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSInteger opencbId, cbScannerId, fecthCbId ,requestCbId,openGroupCbId,changeGroupCbId;
    NSMutableDictionary *_scanDict;
    NSMutableArray *_picAry, *_vidAry, *_allAry, *_cBAll;
    NSInteger capicity;          //每页数据容量
    BOOL preparedData;           //所需数据是否准备完
    UIButton *_addBut;
    UITableView *_tableView;
    NSMutableArray *_photosArr;
}

@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) NSMutableArray *assetCollections;
@property (strong, nonatomic) NSMutableDictionary *scanDict;
@property (strong, nonatomic) NSOperationQueue *transPathQueue;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) PhotoStore * photoStore;
@property (strong, nonatomic) NSMutableArray * allAssets;
@property (assign, nonatomic) NSInteger countForAll;
@property (strong, nonatomic) NSMutableArray * groupAssets;
@property (assign, nonatomic) NSInteger countForGroup;
@property (assign, nonatomic) CGSize thumbSizeForAll;
@property (assign, nonatomic) CGSize thumbSizeForGroup;
@property (strong, nonatomic) NSString *videoPath;
@property (strong, nonatomic) NSString *transPathQuality;
@property (assign, nonatomic) NSInteger transPathCbId;
@property (assign, nonatomic) CGFloat scale;
@property (assign, nonatomic) NSString *realPath;


@property (nonatomic, assign) CGSize assetSize;
@property (nonatomic, assign) CGFloat openGroupWidth;
//@property (nonatomic, copy)NSArray <UIImage *> * assets;
@property (nonatomic, copy)NSArray <NSString *> *saveAssetIds;


@property (nonatomic, strong)UIScrollView *groupView;
@property (nonatomic, strong)NSMutableArray *openGroupArray;
@property (nonatomic, strong)NSDictionary *openGroupDict;
@end

@implementation UZUIAlbumBrowser

@synthesize assets = _assets;
@synthesize scanDict = _scanDict;
static int fetchPosition = 0;
//static char extendKey;

-(void)dispose {
    if (self.transPathQueue) {
        [self.transPathQueue cancelAllOperations];
        self.transPathQueue = nil;
    }
}

- (NSMutableArray *)groupAssets {
    if ( ! _groupAssets) {
        _groupAssets = [NSMutableArray arrayWithCapacity:42];
    }
    return _groupAssets;
}

- (PhotoStore *)photoStore {
    if( ! _photoStore){
        _photoStore  = [PhotoStore new];
    }
    return _photoStore;
}

- (NSMutableArray *)allAssets {
    if ( ! _allAssets) {
        _allAssets = [NSMutableArray arrayWithCapacity:42];
    }
    return _allAssets;
}
- (NSOperationQueue *)transPathQueue {
    if (!_transPathQueue) {
        _transPathQueue = [[NSOperationQueue alloc]init];
        NSInteger maxOperation = 1;//[[NSProcessInfo processInfo]activeProcessorCount];
        [_transPathQueue setMaxConcurrentOperationCount:maxOperation];
    }
    return _transPathQueue;
}

- (void)openGroup:(NSDictionary *)paramsDict_{
    
    NSString * groupId = [paramsDict_ stringValueForKey:@"groupId" defaultValue:nil];
    NSDictionary *rectInfo = [paramsDict_ dictValueForKey:@"rect" defaultValue:@{}];
    self.openGroupDict = paramsDict_;
    CGFloat x = [rectInfo floatValueForKey:@"x" defaultValue:0];
    CGFloat y = [rectInfo floatValueForKey:@"y" defaultValue:0];
    CGFloat w = [rectInfo floatValueForKey:@"w" defaultValue:self.viewController.view.frame.size.width];
    CGFloat h = [rectInfo floatValueForKey:@"h" defaultValue:300];
    NSString * fixedOn = [paramsDict_ stringValueForKey:@"fixedOn" defaultValue:nil];
    BOOL fixed = [paramsDict_ boolValueForKey:@"fixed" defaultValue:YES];
    self.openGroupWidth = w;
    if ( ! groupId) {
        return;
    }
    openGroupCbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    NSArray *selectedPaths = [paramsDict_ arrayValueForKey:@"selectedPaths" defaultValue:@[]];
    /* 从资源id --> 本地资源的转换 */
    PHFetchResult<PHAssetCollection *>  * fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[groupId] options:nil];
    if (0 == fetchResult.count) {
        return;
    }
    PHAssetCollection * assetCollection = fetchResult.firstObject;
    self.openGroupArray = [NSMutableArray arrayWithArray:[self getAssetsInAssetCollection:assetCollection
                                                                                           ascending:true type:@"image"]];
    /* 先计算下total,因为循环开始后,会动态删除元素. */
    //NSInteger total = self.groupAssets.count;
    if ( self.openGroupArray.count == 0) { // 兼容一种已经没有更多数据的情况.
        return;
    };
    
    self.groupView = [[UIScrollView alloc]initWithFrame:CGRectMake(x, y, w, h)];
    NSInteger rowCount =ceilf(( self.openGroupArray.count+1)/4);
    CGFloat openGroupCellWidth = (w-5)/4-5;
    self.groupView.contentSize = CGSizeMake(w,102*(rowCount+1));
    self.groupView.backgroundColor = [UIColor whiteColor];
    self.groupView.clipsToBounds = YES;
    [self addSubview:self.groupView fixedOn:fixedOn fixed:fixed];
//    [self.viewController.view addSubview:self.groupView];
    for (NSInteger i =  self.openGroupArray.count  ; i >= 0; i--) {
        NSInteger index = i % 4;
        NSInteger page = i / 4;
        if (0 ==  self.openGroupArray.count) {
            UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            cameraBtn.frame = CGRectMake(5, 5, openGroupCellWidth, Button_Height);
            [cameraBtn setImage:[UIImage imageNamed:@"res_UIAlbumBrowser/groupTakePhoto.png"] forState:UIControlStateNormal];
            CAShapeLayer *borderLayer = [CAShapeLayer layer];
            borderLayer.bounds = CGRectMake(5, 5, openGroupCellWidth, Button_Height);//虚线框的大小
            borderLayer.position = CGPointMake(CGRectGetMidX(cameraBtn.bounds),CGRectGetMidY(cameraBtn.bounds));//虚线框锚点
            borderLayer.path = [UIBezierPath bezierPathWithRect:borderLayer.bounds].CGPath;//矩形路径
            borderLayer.lineWidth = 1. / [[UIScreen mainScreen] scale];//虚线宽度
            //虚线边框
            borderLayer.lineDashPattern = @[@5, @5];
            //实线边框
            borderLayer.fillColor = [UIColor clearColor].CGColor;
            borderLayer.strokeColor = [UIColor redColor].CGColor;
            [cameraBtn.layer addSublayer:borderLayer];
            [self.groupView addSubview: cameraBtn];
            //按钮点击方法
            [cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        /* 每输出一个,就移除一个,所以此处,总是从 allAssets的开始处取值. */
        PHAsset * asset =  self.openGroupArray[0];
        [ self.openGroupArray removeObjectAtIndex:0];
        UIImageView *imageAlbum = [[UIImageView alloc]init];
        UIBlockButtonForAlbumBrowser *pictureBtn = [UIBlockButtonForAlbumBrowser buttonWithType:UIButtonTypeCustom];
        [self requestImageForAsset:asset size:CGSizeMake(60, 60) resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage * image) {
            imageAlbum.frame = CGRectMake(index * (openGroupCellWidth + Width_Space) + Start_X, page  * (Button_Height + Height_Space)+Start_Y,openGroupCellWidth, Button_Height);
            imageAlbum.image = image;
            [self.groupView addSubview:imageAlbum];
            pictureBtn.frame = imageAlbum.frame;
            [pictureBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [pictureBtn setImage:[UIImage imageNamed:@"res_UIAlbumBrowser/circleGroup@3x.png"] forState:UIControlStateSelected];
            [self.groupView addSubview: pictureBtn];
            [pictureBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^{
                NSString   *path =  asset.localIdentifier;
                pictureBtn.selected = !pictureBtn.selected;
                if (pictureBtn.selected) {
                    pictureBtn.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
                    [self transPathOpenGroup:path groupImage:image  withBlock:^(NSString *gifImagePath, NSString *path, NSString *thumPath) {
                        if (nil != gifImagePath){
                            [self sendResultEventWithCallbackId:openGroupCbId
                                                       dataDict:@{
                                                                  @"eventType":@"select",
                                                                  @"target":@{
                                                               @"gifImagePath": gifImagePath ?: @"",
                                                                },
                                                                  @"groupId":groupId
                                                                 
                                                                  }
                                                        errDict:nil
                                                       doDelete:NO];

                        }else{
                            [self sendResultEventWithCallbackId:openGroupCbId
                                                       dataDict:@{
                                                                  @"eventType":@"select",
                                                                  @"target":@{
                                                                          @"path": path ?: @"",
                                                                          @"thumPath": thumPath ?: @""},
                                                                   @"groupId":groupId,
                                                                  }
                                                        errDict:nil
                                                       doDelete:NO];
                        }
                    }];
                
                    
                }else{
                    pictureBtn.backgroundColor = [UIColor clearColor];
                    
                    [self transPathOpenGroup:path groupImage:image  withBlock:^(NSString *gifImagePath, NSString *path, NSString *thumPath) {
                        if (nil != gifImagePath){
                            [self sendResultEventWithCallbackId:openGroupCbId
                                                       dataDict:@{
                                                                  @"eventType":@"cancel",
                                                                  @"target":@{
                                                                          @"gifImagePath": gifImagePath ?: @"",
                                                                          },
                                                                  @"groupId":groupId
                                                                  
                                                                  }
                                                        errDict:nil
                                                       doDelete:NO];
                            
                        }else{
                            [self sendResultEventWithCallbackId:openGroupCbId
                                                       dataDict:@{
                                                                  @"eventType":@"cancel",
                                                                  @"target":@{
                                                                          @"path": path ?: @"",
                                                                          @"thumPath": thumPath ?: @""},
                                                                  @"groupId":groupId,
                                                                  }
                                                        errDict:nil
                                                       doDelete:NO];
                        }
                    }];
                    
                }
            }];
            
            for (int i = 0; i < selectedPaths.count; i++) {
                
                if ([asset.localIdentifier isEqualToString:selectedPaths[i]]) {
                    pictureBtn.selected = YES;
                }
            }
        }];
    }
    
    [self sendResultEventWithCallbackId:openGroupCbId dataDict:@{@"eventType":@"show"} errDict:nil doDelete:NO];
    
    
}

-(void)cameraBtnClick:(UIButton*)sender{
    
    [self sendResultEventWithCallbackId:openGroupCbId dataDict:@{@"eventType":@"camera"} errDict:nil doDelete:NO];
}

-(void)changeGroup:(NSDictionary *)paramsDict_{
    
    if (self.groupView) {
        [self.groupView removeFromSuperview];
        self.groupView = nil;
    }
    NSDictionary *rectInfo =[self.openGroupDict dictValueForKey:@"rect" defaultValue:@{}];
    CGFloat x = [rectInfo floatValueForKey:@"x" defaultValue:0];
    CGFloat y = [rectInfo floatValueForKey:@"y" defaultValue:0];
    CGFloat w = [rectInfo floatValueForKey:@"w" defaultValue:self.viewController.view.frame.size.width];
    CGFloat h = [rectInfo floatValueForKey:@"h" defaultValue:300];
    NSString * fixedOn = [self.openGroupDict stringValueForKey:@"fixedOn" defaultValue:nil];
    BOOL fixed = [self.openGroupDict boolValueForKey:@"fixed" defaultValue:YES];
    NSString *groupId = [paramsDict_ stringValueForKey:@"groupId" defaultValue:@""];
    NSArray *selectedPaths = [paramsDict_ arrayValueForKey:@"selectedPaths" defaultValue:@[]];
    /* 从资源id --> 本地资源的转换 */
    PHFetchResult<PHAssetCollection *>  * fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[groupId] options:nil];
    if (0 == fetchResult.count) {
        return;
    }
    PHAssetCollection * assetCollection = fetchResult.firstObject;
    NSMutableArray *changeGroupArray = [NSMutableArray arrayWithArray:[self getAssetsInAssetCollection:assetCollection
                                                                                             ascending:true type:@"image"]];
    
    self.groupView = [[UIScrollView alloc]initWithFrame:CGRectMake(x, y, w, h)];
    NSInteger rowCount =ceilf(( changeGroupArray.count+1)/4);
    CGFloat changeGroupCellWidth = (w-5)/4-5;
    self.groupView.contentSize = CGSizeMake(w,102*(rowCount+1));
    self.groupView.backgroundColor = [UIColor whiteColor];
    self.groupView.clipsToBounds = YES;
//    [self.viewController.view addSubview:self.groupView];
    [self addSubview:self.groupView fixedOn:fixedOn fixed:fixed];
    /* 先计算下total,因为循环开始后,会动态删除元素. */
    //NSInteger total = self.groupAssets.count;
    if (changeGroupArray.count == 0) { // 兼容一种已经没有更多数据的情况.
        return;
    };
    for (NSInteger i = changeGroupArray.count  ; i >= 0; i--) {
        
        NSInteger index = i % 4;
        NSInteger page = i / 4;
        if (0 == changeGroupArray.count) {
            UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            cameraBtn.frame = CGRectMake(5, 5, changeGroupCellWidth, Button_Height);
            [cameraBtn setImage:[UIImage imageNamed:@"res_UIAlbumBrowser/groupTakePhoto.png"] forState:UIControlStateNormal];
            CAShapeLayer *borderLayer = [CAShapeLayer layer];
            borderLayer.bounds = CGRectMake(5, 5, changeGroupCellWidth, Button_Height);//虚线框的大小
            borderLayer.position = CGPointMake(CGRectGetMidX(cameraBtn.bounds),CGRectGetMidY(cameraBtn.bounds));//虚线框锚点
            borderLayer.path = [UIBezierPath bezierPathWithRect:borderLayer.bounds].CGPath;//矩形路径
            borderLayer.lineWidth = 1. / [[UIScreen mainScreen] scale];//虚线宽度
            //虚线边框
            borderLayer.lineDashPattern = @[@5, @5];
            //实线边框
            borderLayer.fillColor = [UIColor clearColor].CGColor;
            borderLayer.strokeColor = [UIColor redColor].CGColor;
            [cameraBtn.layer addSublayer:borderLayer];
            [self.groupView addSubview: cameraBtn];
            //按钮点击方法
            [cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        /* 每输出一个,就移除一个,所以此处,总是从 allAssets的开始处取值. */
        PHAsset * asset = changeGroupArray[0];
        [changeGroupArray removeObjectAtIndex:0];
        
        [self requestImageForAsset:asset size:CGSizeMake(60, 60) resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage * image) {
            
            UIImageView *imageAlbum = [[UIImageView alloc]init];
            imageAlbum.frame = CGRectMake(index * (changeGroupCellWidth + Width_Space) + Start_X, page  * (Button_Height + Height_Space)+Start_Y, changeGroupCellWidth, Button_Height);

            imageAlbum.image = image;
            [self.groupView addSubview:imageAlbum];
            
            UIBlockButtonForAlbumBrowser *pictureBtn = [UIBlockButtonForAlbumBrowser buttonWithType:UIButtonTypeCustom];
            pictureBtn.frame = imageAlbum.frame;
            
            [pictureBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [pictureBtn setImage:[UIImage imageNamed:@"res_UIAlbumBrowser/circleGroup@3x.png"] forState:UIControlStateSelected];
            [self.groupView addSubview: pictureBtn];
            
            [pictureBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^{
                NSString   *path =  asset.localIdentifier;
                pictureBtn.selected = !pictureBtn.selected;
                if (pictureBtn.selected) {
                    pictureBtn.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
                    [self transPathOpenGroup:path groupImage:image  withBlock:^(NSString *gifImagePath, NSString *path, NSString *thumPath) {
                        if (nil != gifImagePath){
                            [self sendResultEventWithCallbackId:openGroupCbId
                                                       dataDict:@{
                                                                  @"eventType":@"select",
                                                                  @"target":@{
                                                                          @"gifImagePath": gifImagePath ?: @"",
                                                                          },
                                                                  @"groupId":groupId
                                                                  
                                                                  }
                                                        errDict:nil
                                                       doDelete:NO];
                            
                        }else{
                            [self sendResultEventWithCallbackId:openGroupCbId
                                                       dataDict:@{
                                                                  @"eventType":@"select",
                                                                  @"target":@{
                                                                          @"path": path ?: @"",
                                                                          @"thumPath": thumPath ?: @""},
                                                                  @"groupId":groupId,
                                                                  }
                                                        errDict:nil
                                                       doDelete:NO];
                        }
                    }];
                    
                }else{
                    pictureBtn.backgroundColor = [UIColor clearColor];
                    [self transPathOpenGroup:path groupImage:image  withBlock:^(NSString *gifImagePath, NSString *path, NSString *thumPath) {
                        if (nil != gifImagePath){
                            [self sendResultEventWithCallbackId:openGroupCbId
                                                       dataDict:@{
                                                                  @"eventType":@"cancel",
                                                                  @"target":@{
                                                                          @"gifImagePath": gifImagePath ?: @"",
                                                                          },
                                                                  @"groupId":groupId
                                                                  
                                                                  }
                                                        errDict:nil
                                                       doDelete:NO];
                            
                        }else{
                            [self sendResultEventWithCallbackId:openGroupCbId
                                                       dataDict:@{
                                                                  @"eventType":@"cancel",
                                                                  @"target":@{
                                                                          @"path": path ?: @"",
                                                                          @"thumPath": thumPath ?: @""},
                                                                  @"groupId":groupId,
                                                                  }
                                                        errDict:nil
                                                       doDelete:NO];
                        }
                    }];
                }
            }];
            for (int i = 0; i < selectedPaths.count; i++) {
                if ([asset.localIdentifier isEqualToString:selectedPaths[i]]) {
                    pictureBtn.selected = YES;
                }
            }
        }];
    }
    [self sendResultEventWithCallbackId:openGroupCbId dataDict:@{@"eventType":@"change",@"groupId":groupId} errDict:nil doDelete:NO];
    
}

-(void)closeGroup:(NSDictionary *)paramsDict_{
    [self.groupView removeFromSuperview];
    self.groupView = nil;
}
- (void)open:(NSDictionary *)paramsDict_ {
    opencbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    BOOL albumRotation = [paramsDict_ boolValueForKey:@"rotation" defaultValue:false];
    BOOL selectedAll = [paramsDict_ boolValueForKey:@"selectedAll" defaultValue:true];
    PhotoNavigationViewModel * viewModel = [PhotoNavigationViewModel new];
    NSString *openType = [paramsDict_ stringValueForKey:@"type" defaultValue:@"image"];
    BOOL isOpenPreview = [paramsDict_ boolValueForKey:@"isOpenPreview" defaultValue:true];
    CGFloat thumbW = [paramsDict_ floatValueForKey:@"w" defaultValue:100.0];
    CGFloat thumbH = [paramsDict_ floatValueForKey:@"h" defaultValue:100.0];
    [viewModel setBridgeGetAssetBlock:^(NSArray<PHAsset *> * assets){
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:42];
        if (0 == assets.count) {
            [self sendResultEventWithCallbackId:opencbId
                                       dataDict:@{@"eventType":@"cancle"}
                                        errDict:nil
                                       doDelete:YES];
        }
        for (NSInteger i = assets.count -1 ; i >= 0; i--) {
            /* 每输出一个,就移除一个,所以此处,总是从 allAssets的开始处取值. */
            PHAsset * asset = assets[i];
            [self requestImageForAsset:asset size:CGSizeMake(thumbW, thumbH) resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage * image) {
                [self cache:image imagePath:asset.localIdentifier
                   complete:^(NSString * _Nonnull thumbPath) {
                       NSString * path = asset.localIdentifier;
                       // NSString * time = asset.modificationDate.description; // TODO: 转换成需要的格式 + 用"修改时间"
                       NSInteger timeSp = [asset.modificationDate timeIntervalSince1970] *1000.0;
                       NSTimeInterval duration = asset.duration*1000; // TODO: 建议添加,这样就没必要实现 getVideoDuration 接口了...
                       NSString * mediaType = asset.mediaType ==  PHAssetMediaTypeImage ? @"image":@"video";
                       NSDictionary * listItem;
                       if (asset.mediaType == PHAssetMediaTypeImage) {
                           listItem  = @{@"path":path,
                                         @"thumbPath":thumbPath,
                                         @"time":@(timeSp),
                                         @"mediaType":mediaType,
                                         };
                       }else
                       {
                           listItem  = @{@"path":path,
                                         @"thumbPath":thumbPath,
                                         @"time":@(timeSp),
                                         @"duration":@(duration),
                                         @"mediaType":mediaType,
                                         };
                       }
                       [list addObject:listItem];
                       if (list.count == assets.count) {
                           NSDictionary * dataDict = @{
                                                       @"eventType":@"confirm",
                                                       @"list": list
                                                       };
                           [self sendResultEventWithCallbackId:opencbId
                                                      dataDict:dataDict
                                                       errDict:nil
                                                      doDelete:YES];
                       }
                   }];
            }];
        }
    }];
    viewModel.paramsDict = paramsDict_;
    AlbumBrowserSinglen.sharedSingleton.openType = openType;
    AlbumBrowserSinglen.sharedSingleton.isOpenPreview = isOpenPreview;
    AlbumBrowserSinglen.sharedSingleton.selectAll = selectedAll;
    PhotoNavigationViewController * viewController = [PhotoNavigationViewController photosViewModelInstance:viewModel];
    viewController.isRotation = albumRotation;
    [self.viewController presentViewController:viewController animated:true completion:^{}];

}



- (void)imagePicker:(NSDictionary *)paramsDict_ {
    
    NSInteger imagePickerCbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    NSInteger selectMax = [paramsDict_ integerValueForKey:@"max" defaultValue:9];
    NSDictionary *stylesInfo = [paramsDict_ dictValueForKey:@"styles" defaultValue:@{}];
    NSDictionary *navInfo = [stylesInfo dictValueForKey:@"nav" defaultValue:@{}];
    UZAlbumSingleton.sharedSingleton.stylesInfo = stylesInfo;
    UZAlbumSingleton.sharedSingleton.navInfo = navInfo;
    UZAlbumSingleton.sharedSingleton.imagePickerCbId = imagePickerCbId;
    UZAlbumSingleton.sharedSingleton.albumBrowser = self;
    WPhotoViewController *WphotoVC = [[WPhotoViewController alloc] init];
    //选择图片的最大数
    WphotoVC.selectPhotoOfMax = selectMax;
    [WphotoVC setSelectPhotosBack:^(NSMutableArray *phostsArr) {
        _photosArr = phostsArr;
    }];
    [self.viewController.navigationController pushViewController:WphotoVC animated:YES];
    
}

-(void)closePicker:(NSDictionary *)paramsDict_ {
    
    [self.viewController.navigationController popViewControllerAnimated:YES];
    
}


- (void)requestAlbumPermissions:(NSDictionary *)paramsDict_{
    
    requestCbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    //获取权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    //switch 判定
    switch (status)
    {
            //准许
        case PHAuthorizationStatusAuthorized:
            [self sendResultEventWithCallbackId:requestCbId dataDict:@{@"isAccessPermissions":@(YES)} errDict:nil doDelete:YES];
            break;
            //待获取
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized)//允许，进行回调
                {
                    [self sendResultEventWithCallbackId:requestCbId dataDict:@{@"isAccessPermissions":@(YES)} errDict:nil doDelete:YES];
                }
                else
                {
                    [self sendResultEventWithCallbackId:requestCbId dataDict:@{@"isAccessPermissions":@(NO)} errDict:nil doDelete:YES];
                }
            }];
        }
            break;
            //不允许,进行无权限回调
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            [self sendResultEventWithCallbackId:requestCbId dataDict:@{@"isAccessPermissions":@(NO)} errDict:nil doDelete:YES];
            break;
    }
    
}

- (void)scan:(NSDictionary *)paramsDict_ {
    NSString * type = [paramsDict_ stringValueForKey:@"type" defaultValue:@"all"];
    NSUInteger count = [paramsDict_ integerValueForKey:@"count" defaultValue: NSUIntegerMax];
    NSDictionary *sort = [paramsDict_ dictValueForKey:@"sort" defaultValue:@{}];
    NSString * order = [sort stringValueForKey:@"order" defaultValue:@"desc"];
    NSInteger cbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    BOOL ascending = false;
    if ([order isEqualToString:@"asc"]) {
        ascending = true;
    }
    NSDictionary *thumbSizeInfo = [paramsDict_ dictValueForKey:@"thumbnail" defaultValue:@{}];
    CGFloat thumbW = [thumbSizeInfo floatValueForKey:@"w" defaultValue:100.0];
    CGFloat thumbH = [thumbSizeInfo floatValueForKey:@"h" defaultValue:100.0];
    CGSize thumbSize = CGSizeMake(thumbW, thumbH);
    self.thumbSizeForAll = thumbSize;
    self.allAssets = [NSMutableArray arrayWithArray: [self getAllAssetInPhotoAblumWithAscending:ascending type:type]];
    if (count == NSUIntegerMax) {
        count = self.allAssets.count;
    }
    self.countForAll = count;
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:count];
    /* 先计算下total,因为循环开始后,会动态删除元素. */
    NSInteger total = self.allAssets.count;
    if (self.allAssets.count == 0) { // 兼容一种已经没有更多数据的情况.
        NSDictionary * dataDict = @{
                                    @"total":@(total),
                                    @"list": @[]
                                    };
        
        [self sendResultEventWithCallbackId:cbId
                                   dataDict:dataDict
                                    errDict:nil
                                   doDelete:YES];
        return;
    };
    
    if (count > self.allAssets.count) {
        count = self.allAssets.count;
    }
    
    NSLog(@"%lu",(unsigned long)self.allAssets.count);
    for (int i = 0; i < count; i++) {
        /* 每输出一个,就移除一个,所以此处,总是从 allAssets的开始处取值. */
        if (0 == self.allAssets.count) {
            break;
        }
        PHAsset * asset = self.allAssets[0];
        [self.allAssets removeObjectAtIndex:0];
        [self requestImageForAsset:asset size:thumbSize resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage * image) {
            
            [self cache:image imagePath:asset.localIdentifier
               complete:^(NSString * _Nonnull thumbPath) {
                   NSString * path = asset.localIdentifier;
                   // NSString * time = asset.modificationDate.description; // TODO: 转换成需要的格式 + 用"修改时间"
                   NSInteger timeSp = [asset.modificationDate timeIntervalSince1970] *1000.0;
                   NSTimeInterval duration = asset.duration*1000; // TODO: 建议添加,这样就没必要实现 getVideoDuration 接口了...
                   NSString * mediaType = asset.mediaType ==  PHAssetMediaTypeImage ? @"image":@"video";
                   NSDictionary * listItem;
                   if (asset.mediaType == PHAssetMediaTypeImage) {
                       listItem  = @{@"path":path,
                                     @"thumbPath":thumbPath,
                                     @"time":@(timeSp),
                                     @"mediaType":mediaType,
                                     };
                   }else
                   {
                       listItem  = @{@"path":path,
                                     @"thumbPath":thumbPath,
                                     @"time":@(timeSp),
                                     @"duration":@(duration),
                                     @"mediaType":mediaType,
                                     };
                   }
                   
                   [list addObject:listItem];
                   
                   if (list.count == count) {
                       NSDictionary * dataDict = @{
                                                   @"total":@(total),
                                                   @"list": list
                                                   };
                       
                       [self sendResultEventWithCallbackId:cbId
                                                  dataDict:dataDict
                                                   errDict:nil
                                                  doDelete:YES];
                   }
               }];
        }];
    }
}


- (void)scanGroups:(NSDictionary *)paramsDict_{
    
    NSInteger cbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    NSDictionary *thumbSizeInfo = [paramsDict_ dictValueForKey:@"thumbnail" defaultValue:@{}];
    CGFloat thumbW = [thumbSizeInfo floatValueForKey:@"w" defaultValue:100.0];
    CGFloat thumbH = [thumbSizeInfo floatValueForKey:@"h" defaultValue:100.0];
    CGSize thumbSize = CGSizeMake(thumbW, thumbH);
    //NSString *fullpath = [NSString stringWithFormat:@"%@",[[self getPathWithUZSchemeURL:self.realPath] stringByDeletingLastPathComponent]];
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    [fileManager removeItemAtPath:self.realPath error:nil];
    [self.photoStore fetchDefaultAllPhotosGroup:^(NSArray<PHAssetCollection *> * _Nonnull groups, PHFetchResult * _Nonnull collections) {
        //进行回调
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //            dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray * list = [NSMutableArray arrayWithCapacity: groups.count];
            for (int i = 0; i < groups.count; i++) {
                PHAssetCollection * collection = groups[i];
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    [collection representationImageWithSize:thumbSize complete:^(NSString * _Nonnull title, NSUInteger count, UIImage * _Nullable image)
                     {
                         [self cache:image imagePath:collection.localIdentifier
                            complete:^(NSString * _Nonnull thumbPath) {
                                NSString * groupId = collection.localIdentifier;
                                NSString * groupName = collection.localizedTitle;
                                NSString * groupType = @""; // TODO: iOS 有两个类型属性,每个属性对应多个值,不是简单的 视频与图片,详见: PHAssetCollection 类的 assetCollectionType 和 assetCollectionSubtype 属性.
                                NSDictionary * item = @{
                                                        @"thumbPath":thumbPath,
                                                        @"groupId":groupId,
                                                        @"groupName":groupName,
                                                        @"groupType":groupType,
                                                        @"imgCount":@(count)
                                                        };
                                [list addObject:item];
                                if (list.count == groups.count) {
                                    NSDictionary * dataDict = @{
                                                                @"total":@(groups.count),
                                                                @"list":list
                                                                };
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self sendResultEventWithCallbackId:cbId
                                                                   dataDict:dataDict
                                                                    errDict:nil
                                                                   doDelete:YES];
                                    });
                                }
                                
                            }];
                     }];
                    
                }
            }
            //
        });
        
    }];
}

- (void)scanByGroupId:(NSDictionary *)paramsDict_ {
    
    NSString * groupId = [paramsDict_ stringValueForKey:@"groupId" defaultValue:nil];
    if ( ! groupId) {
        return;
    }
    NSString * type = [paramsDict_ stringValueForKey:@"type" defaultValue:@"all"];
    NSUInteger count = [paramsDict_ integerValueForKey:@"count" defaultValue: NSUIntegerMax];
    NSDictionary *sort = [paramsDict_ dictValueForKey:@"sort" defaultValue:@{}];
    NSString * order = [sort stringValueForKey:@"order" defaultValue:@"desc"];
    NSInteger cbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    BOOL ascending = false;
    if ([order isEqualToString:@"asc"]) {
        ascending = true;
    }
    NSDictionary *thumbSizeInfo = [paramsDict_ dictValueForKey:@"thumbnail" defaultValue:@{}];
    CGFloat thumbW = [thumbSizeInfo floatValueForKey:@"w" defaultValue:100.0];
    CGFloat thumbH = [thumbSizeInfo floatValueForKey:@"h" defaultValue:100.0];
    CGSize thumbSize = CGSizeMake(thumbW, thumbH);
    self.thumbSizeForGroup = thumbSize;
    /* 从资源id --> 本地资源的转换 */
    PHFetchResult<PHAssetCollection *>  * fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[groupId] options:nil];
    if (0 == fetchResult.count) {
        return;
    }
    PHAssetCollection * assetCollection = fetchResult.firstObject;
    self.groupAssets = [NSMutableArray arrayWithArray:[self getAssetsInAssetCollection:assetCollection
                                                                             ascending:ascending type:type]];
    if (count == NSUIntegerMax) {
        count = self.groupAssets.count;
    }
    self.countForGroup = count;
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:count];
    /* 先计算下total,因为循环开始后,会动态删除元素. */
    NSInteger total = self.groupAssets.count;
    if (self.groupAssets.count == 0) { // 兼容一种已经没有更多数据的情况.
        NSDictionary * dataDict = @{
                                    @"total":@(total),
                                    @"list": @[]
                                    };
        [self sendResultEventWithCallbackId:cbId
                                   dataDict:dataDict
                                    errDict:nil
                                   doDelete:YES];
        return;
    };
    if (count > self.groupAssets.count) {
        count = self.groupAssets.count;
    }
    for (int i = 0; i < count; i++) {
        /* 每输出一个,就移除一个,所以此处,总是从 allAssets的开始处取值. */
        if (0 == self.groupAssets.count) {
            break;
        }
        PHAsset * asset = self.groupAssets[0];
        [self.groupAssets removeObjectAtIndex:0];
        [self requestImageForAsset:asset size:thumbSize resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage * image) {
            [self cache:image imagePath:asset.localIdentifier
               complete:^(NSString * _Nonnull thumbPath) {
                   NSString * path = asset.localIdentifier;
                   //                   NSString * time = asset.modificationDate.description; // TODO: 转换成需要的格式 + 用"修改时间".
                   NSInteger timeSp = [asset.modificationDate timeIntervalSince1970] *1000.0;                   NSTimeInterval duration = asset.duration*1000; // TODO: 建议添加,这样就没必要实现 getVideoDuration 接口了...
                   NSString * mediaType = asset.mediaType ==  PHAssetMediaTypeImage ? @"image":@"video" ; // TODO: 加上,不会更好吗?
                   
                   NSDictionary * listItem;
                   if (mediaType == PHAssetMediaTypeImage) {
                       listItem  = @{@"path":path,
                                     @"thumbPath":thumbPath,
                                     @"time":@(timeSp),
                                     @"mediaType":mediaType,
                                     
                                     };
                   }else
                   {
                       listItem  = @{@"path":path,
                                     @"thumbPath":thumbPath,
                                     @"time":@(timeSp),
                                     @"duration":@(duration),
                                     @"mediaType":mediaType,
                                     };
                   }
                   [list addObject:listItem];
                   
                   if (list.count == count) {
                       NSDictionary * dataDict = @{
                                                   @"total":@(total),
                                                   @"list": list
                                                   };
                       
                       [self sendResultEventWithCallbackId:cbId
                                                  dataDict:dataDict
                                                   errDict:nil
                                                  doDelete:YES];
                   }
               }];
        }];
    }
}

- (void)fetchGroup:(NSDictionary *)paramsDict_ {
    NSInteger cbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    CGSize thumbSize = self.thumbSizeForGroup;
    if (self.groupAssets.count == 0) { // 兼容一种已经没有更多数据的情况.
        NSDictionary * dataDict = @{
                                    @"list": @[]
                                    };
        [self sendResultEventWithCallbackId:cbId
                                   dataDict:dataDict
                                    errDict:nil
                                   doDelete:YES];
        return;
    };
    NSInteger count = self.countForGroup;
    if (count > self.groupAssets.count) {
        count = self.groupAssets.count;
    }
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:42];
    for (int i = 0; i < count; i++) {
        /* 每输出一个,就移除一个,所以此处,总是从 allAssets的开始处取值. */
        if (0 == self.groupAssets.count) {
            break;
        }
        PHAsset * asset = self.groupAssets[0];
        [self.groupAssets removeObjectAtIndex:0];
        [self requestImageForAsset:asset size:thumbSize resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage * image) {
            [self cache:image imagePath:asset.localIdentifier
               complete:^(NSString * _Nonnull thumbPath) {
                   NSString * path = asset.localIdentifier;
                   //NSString * time = asset.modificationDate.description; // TODO: 转换成需要的格式 + 用"修改时间".
                   NSInteger timeSp = [asset.modificationDate timeIntervalSince1970] *1000.0;                   NSTimeInterval duration = asset.duration*1000; // TODO: 建议添加,这样就没必要实现 getVideoDuration 接口了...
                   NSString * mediaType = asset.mediaType ==  PHAssetMediaTypeImage ? @"image":@"video" ; // TODO: 加上,不会更好吗?
                   NSDictionary * listItem;
                   if (asset.mediaType == PHAssetMediaTypeImage) {
                       listItem  = @{@"path":path,
                                     @"thumbPath":thumbPath,
                                     @"time":@(timeSp),
                                     @"mediaType":mediaType,
                                     };
                   }else
                   {
                       listItem  = @{@"path":path,
                                     @"thumbPath":thumbPath,
                                     @"time":@(timeSp),
                                     @"duration":@(duration),
                                     @"mediaType":mediaType,
                                     };
                   }
                   [list addObject:listItem];
                   if (list.count == count) {
                       NSDictionary * dataDict = @{
                                                   @"list": list
                                                   };
                       [self sendResultEventWithCallbackId:cbId
                                                  dataDict:dataDict
                                                   errDict:nil
                                                  doDelete:YES];
                   }
               }];
        }];
    }
}

- (void)fetch:(NSDictionary *)paramsDict_ {
    NSInteger cbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    NSUInteger count = self.countForAll;
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:count];
    if (self.allAssets.count == 0) { // 兼容一种已经没有更多数据的情况.
        NSDictionary * dataDict = @{
                                    @"list": @[]
                                    };
        [self sendResultEventWithCallbackId:cbId
                                   dataDict:dataDict
                                    errDict:nil
                                   doDelete:YES];
        return;
    };
    if (count > self.allAssets.count) {
        count = self.allAssets.count;
    }
    for (int i = 0; i < count; i++) {
        /* 每输出一个,就移除一个,所以此处,总是从 allAssets的开始处取值. */
        if (0 == self.allAssets.count) {
            break;
        }
        PHAsset * asset = self.allAssets[0];
        [self.allAssets removeObjectAtIndex:0];
        [self requestImageForAsset:asset size:self.thumbSizeForAll resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage * image) {
            [self cache:image imagePath:asset.localIdentifier
               complete:^(NSString * _Nonnull thumbPath) {
                   NSString * path = asset.localIdentifier;
                   NSString * time = asset.modificationDate.description; // TODO: 转换成需要的格式 + 用"修改时间"!
                   NSInteger timeSp = [asset.modificationDate timeIntervalSince1970] *1000.0;
                   NSTimeInterval duration = asset.duration*1000 ; // TODO: 建议添加,这样就没必要实现 getVideoDuration 接口了...
                   
                   
                   NSString * mediaType = asset.mediaType ==  PHAssetMediaTypeImage ? @"image":@"video" ; // TODO: 加上,不会更好吗?
                   NSDictionary * listItem;
                   if (asset.mediaType == PHAssetMediaTypeImage) {
                       listItem  =  @{@"path":path,
                                      @"thumbPath":thumbPath,
                                      @"time":@(timeSp),
                                      @"mediaType":mediaType,
                                      };
                   }else
                   {
                       listItem  =  @{@"path":path,
                                      @"thumbPath":thumbPath,
                                      @"time":@(timeSp),
                                      @"duration":@(duration),
                                      @"mediaType":mediaType,
                                      };
                   }
                   [list addObject:listItem];
                   if (list.count == count) {
                       NSDictionary * dataDict = @{
                                                   @"list": list
                                                   };
                       [self sendResultEventWithCallbackId:cbId
                                                  dataDict:dataDict
                                                   errDict:nil
                                                  doDelete:YES];
                   }
               }];
        }];
    }
}
- (void)fetchCallBack {//遍历接口回调
    NSMutableArray *callBackArr = [NSMutableArray array];
    for (int i = fetchPosition; i < capicity+fetchPosition; i++) {
        if (i >= _cBAll.count) {
            break;
        }
        [callBackArr addObject:_cBAll[i]];
    }
    fetchPosition += capicity;
    NSMutableDictionary *sendDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [sendDict setObject:callBackArr forKey:@"list"];
    [self sendResultEventWithCallbackId:fecthCbId dataDict:sendDict errDict:nil doDelete:YES];
}

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}


- (void)loadDataSource:(NSString *)path {//加载本地相册里的数据
    
}
#pragma mark - 获取指定相册内的所有图片
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                                         ascending:(BOOL)ascending
                                              type:(NSString *)type
{
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([type isEqualToString:@"all"]) {
            [arr addObject:obj];
        }
        if ([type isEqualToString:@"image"] && ((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [arr addObject:obj];
        }
        if ([type isEqualToString:@"video"] && ((PHAsset *)obj).mediaType == PHAssetMediaTypeVideo) {
            [arr addObject:obj];
        }
    }];
    return arr;
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



#pragma mark - 获取相册内所有照片资源
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending type:(NSString *)type
{
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = nil;
    if ([type isEqualToString:@"image"]) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
        result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    }else if ([type isEqualToString:@"video"]) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeVideo];
        
        result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:option];
    }else{
        // option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeUnknown];
        result = [PHAsset fetchAssetsWithOptions:option];
    }
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [assets addObject:asset];
    }];
    return assets;
}

//排序

#pragma mark - 修改 thumbnail 大小

- (UIImage *)setNewSizeWithOriginImage:(UIImage *)oriImage toSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [oriImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (void)transPath:(NSDictionary *)paramsDict_ {
    NSInteger cbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    self.transPathCbId = cbId;
    NSString * path = [paramsDict_ stringValueForKey:@"path" defaultValue:nil];
    self.transPathQuality = [paramsDict_ stringValueForKey:@"quality" defaultValue:@"medium"];
    self.scale = [paramsDict_ floatValueForKey:@"scale" defaultValue:1.0];
    /* 从资源id --> 本地资源的转换 */
    PHFetchResult<PHAsset *> * fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[path] options:nil];
    if (0 == fetchResult.count) {
        return;
    }
    PHAsset * asset = fetchResult.firstObject;
    NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
    __block NSString *gifPath = @"";
    
    [resourceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetResource *resource = obj;
        PHAssetResourceRequestOptions *option = [[PHAssetResourceRequestOptions alloc]init];
        option.networkAccessAllowed = YES;
        if ([resource.uniformTypeIdentifier isEqualToString:@"com.compuserve.gif"]) {
            // 首先,需要获取沙盒路径
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            // 拼接图片名为resource.originalFilename的路径
            gifPath = [path stringByAppendingPathComponent:resource.originalFilename];
            [self sendResultEventWithCallbackId:cbId
                                       dataDict:@{
                                                  @"path":gifPath
                                                  }
                                        errDict:nil
                                       doDelete:YES];
            __block NSData *data = [[NSData alloc]init];
            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:gifPath]  options:option completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"error:%@",error);
                    if(error.code == -1){//文件已存在
                        data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:gifPath]];
                    }
                    //NSLog(@"data%@",data);
                    //if (completion) completion(data,nil,NO);
                } else {
                    data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:gifPath]];
                    //NSLog(@"data%@",data);
                    //if (completion) completion(data,nil,NO);
                }
            }];

        }else{

        }
    }];
    
    if (asset.mediaType == PHAssetMediaTypeImage && [gifPath isEqualToString:@""] ) {
        //创建NSBlockOperation 来执行每一次转换，图片复制等耗时操作
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self requestImageForAsset:asset size:CGSizeMake(asset.pixelWidth, asset.pixelHeight) resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage * image) {
                [self cache:image imagePath:asset.localIdentifier
                   complete:^(NSString * _Nonnull path) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self sendResultEventWithCallbackId:cbId
                                                      dataDict:@{
                                                                 @"path":path
                                                                 }
                                                       errDict:nil
                                                      doDelete:YES];
                       });
                   }];
            }];
            
        }];
        [self.transPathQueue addOperation:operation];
        
    }else if(asset.mediaType == PHAssetMediaTypeVideo && [gifPath isEqualToString:@""]){
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            options.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
                AVURLAsset *videoAsset = (AVURLAsset*)avasset;
                NSURL  *filePathString = [self condenseVideoNewUrl:videoAsset.URL];
                NSLog(@"%@",filePathString);
            }];
        }];
        [self.transPathQueue addOperation:operation];
    }
  
    
}


- (void)transPathOpenGroup:(NSString *)path groupImage:(UIImage *)image
                 withBlock:(void (^)(NSString * gifImagePath, NSString * path, NSString * thumPath))block{
    /* 从资源id --> 本地资源的转换 */
    PHFetchResult<PHAsset *> * fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[path] options:nil];
    if (0 == fetchResult.count) {
        return;
    }
    
    __block NSString *gifImageFilePath = @"";
    PHAsset * asset = fetchResult.firstObject;
    NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
    [resourceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetResource *resource = obj;
        PHAssetResourceRequestOptions *option = [[PHAssetResourceRequestOptions alloc]init];
        option.networkAccessAllowed = YES;
        if ([resource.uniformTypeIdentifier isEqualToString:@"com.compuserve.gif"]) {
            // 首先,需要获取沙盒路径
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            // 拼接图片名为resource.originalFilename的路径
            NSString *imageFilePath = [path stringByAppendingPathComponent:resource.originalFilename];

            gifImageFilePath = imageFilePath;
            block(imageFilePath, nil, nil);
            __block NSData *data = [[NSData alloc]init];
            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:imageFilePath]  options:option completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    if(error.code == -1){//文件已存在
                        data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFilePath]];
                    }
                    
                } else {
                    data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFilePath]];
                }
            }];
            
        }
    }];
    if (asset.mediaType == PHAssetMediaTypeImage && [gifImageFilePath isEqualToString:@""]) {
        //创建NSBlockOperation 来执行每一次转换，图片复制等耗时操作
        [self cacheOpenGroup:image imagePath:asset.localIdentifier
           complete:^(NSString * _Nonnull path) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   
                   block(nil, asset.localIdentifier, path);
               });
           }];
    }
}


- (NSString *)getCurrentTime{
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
    
}
- (NSURL *)condenseVideoNewUrl: (NSURL *)url{
    // 沙盒目录
    NSString *docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *mimeType = [[[url.absoluteString componentsSeparatedByString:@"."] lastObject] lowercaseString];
    NSString *destFilePath = [docuPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",[self getCurrentTime],mimeType]];
    NSURL *destUrl = [NSURL fileURLWithPath:destFilePath];
    //将视频文件copy到沙盒目录中
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    [manager copyItemAtURL:url toURL:destUrl error:&error];
    NSLog(@"压缩前--%.2fk",[self getFileSize:destFilePath]);
    
    // 进行压缩
    AVAsset *asset = [AVAsset assetWithURL:url];
    //创建视频资源导出会话
    
    AVAssetExportSession *session;
    if ([self.transPathQuality isEqualToString:@"low"]) {
        session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    }else if([self.transPathQuality isEqualToString:@"medium"]){
        session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    }else{
        session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    }
    
    // 创建导出的url
    NSString *resultPath = [docuPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",[self getCurrentTime],mimeType]];
    session.outputURL = [NSURL fileURLWithPath:resultPath];
    // 必须配置输出属性
    session.outputFileType = @"com.apple.quicktime-movie";
    // 导出视频
    [session exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"压缩后---%.2fk",[self getFileSize:resultPath]);
        NSLog(@"视频导出完成");
        
        NSURL  *filePathString = session.outputURL;
        NSString * urlStr = [filePathString absoluteString];
        urlStr = [urlStr substringFromIndex:7];
        [self sendResultEventWithCallbackId:self.transPathCbId
                                   dataDict:@{@"path":[NSString stringWithFormat:@"%@",urlStr]}
                                    errDict:nil
                                   doDelete:NO];
        
    }];
    
    NSLog(@"%@",session.outputURL);
    
    
    
    return session.outputURL;
}

// 获取视频的大小
- (CGFloat) getFileSize:(NSString *)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init] ;
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }
    return filesize;
}

/* 根据localIdentifier 缓存资源. */

- (void)cache:(UIImage *)img imagePath:(NSString *)localIdentifier complete:(nonnull void (^)(NSString * _Nonnull))completeBlock {//保存指定图片到临时位置并回调改位置路径
    UIImage *saveImg = img;
    NSData * data = UIImageJPEGRepresentation(saveImg, self.scale);
    NSString *typeName = [self imageTypeWithData:data];
    //NSString *name = [self md5:localIdentifier];
    NSString *name = [self getCurrentTime];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UZUIAlbumBrowser"];
    self.realPath = filePath;
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

- (void)cacheOpenGroup:(UIImage *)image imagePath:(NSString *)localIdentifier complete:(nonnull void (^)(NSString * _Nonnull))completeBlock {//保存指定图片到临时位置并回调改位置路径
    UIImage *saveImg = image;
    NSData * data = UIImageJPEGRepresentation(saveImg, self.scale);
    NSString *typeName = [self imageTypeWithData:data];
    NSString *name = [self md5:localIdentifier];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UZUIAlbumBrowser"];
    self.realPath = filePath;
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


/** 根据图片二进制流获取图片格式 */
- (NSString *)imageTypeWithData:(NSData *)data {
    uint8_t type;
    [data getBytes:&type length:1];
    switch (type) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            return nil;
    }
    return nil;
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


#pragma mark -
#pragma mark  AssetsViewCallBackDelegate
#pragma mark -

- (void)previewCallback:(NSDictionary *)listDict {
    if (opencbId != -1) {
        NSDictionary *sendDict = [[NSDictionary alloc]initWithDictionary:listDict];
        [self sendResultEventWithCallbackId:opencbId dataDict:sendDict errDict:nil doDelete:NO];
    }
}

- (void)callBack:(NSDictionary *)listDict {
    if (opencbId != -1) {
        NSDictionary *sendDict = [[NSDictionary alloc]initWithDictionary:listDict];
        [self sendResultEventWithCallbackId:opencbId dataDict:sendDict errDict:nil doDelete:NO];
    }
}





@end
