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
#import "GroupCell.h"
#import "OpenAlbumCell.h"
#import "OpenAlbumDetailController.h"
#import "UIView+Toast.h"

#define Start_X          5.0f      // 第一个按钮的X坐标
#define Start_Y          5.0f     // 第一个按钮的Y坐标
#define Width_Space      5.0f      // 2个按钮之间的横间距
#define Height_Space     5.0f     // 竖间距
#define Button_Height   97.0f    // 高


@interface UZUIAlbumBrowser () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>{
    NSInteger opencbId, cbScannerId, fecthCbId ,requestCbId,openGroupCbId,changeGroupCbId,openAlbumCbId;
    NSInteger capicity;          //每页数据容量
    NSMutableArray *_photosArr, *_cBAll;
}
/** 颜色变化 */


@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) NSMutableArray *assetCollections;
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
@property (nonatomic, copy)NSArray <NSString *> *saveAssetIds;

//openGroup
@property (nonatomic, strong)UIScrollView *groupView;
@property (nonatomic, strong)NSMutableArray *openGroupArray;
@property (nonatomic, strong)NSDictionary *openGroupDict;
@property (nonatomic, strong)UICollectionView *mainCollectionView;
@property (nonatomic, strong)NSMutableArray *selectedPaths;
@property (nonatomic, strong)NSString *groupId;

//openAlbum
@property (nonatomic, strong)UIScrollView *openAlbumGroupView;
@property (nonatomic, strong)NSMutableArray *openAlbumArray;
@property (nonatomic, strong)NSDictionary *openAlbumDict;
@property (nonatomic, strong)UICollectionView *albumCollectionView;
@property (nonatomic, strong)NSMutableArray *openAlbumSelectedPaths;
@property (nonatomic, strong)NSMutableArray *openAlbumSelectedVideoPaths;
@property (nonatomic, strong)NSString *openAlbumGroupId;
@property (nonatomic, assign) CGFloat openAlbumWidth;
@property (nonatomic, assign) BOOL isOpenAlbum;
@property (nonatomic, assign) BOOL videoPreview;
@property (strong, nonatomic) NSString *openAlbumPosition;
@property (strong, nonatomic) NSDictionary *albumSelectDict;
@property (assign, nonatomic) NSInteger openAlbumMax;
@property (strong, nonatomic) NSMutableArray *openAlbumSelectMax;
@property (nonatomic, strong) NSMutableDictionary *cellOpenAlbumDic;

@end

@implementation UZUIAlbumBrowser

@synthesize assets = _assets;
static int fetchPosition = 0;

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
- (NSMutableDictionary *)cellOpenAlbumDic {
    if ( ! _cellOpenAlbumDic) {
        _cellOpenAlbumDic = [NSMutableDictionary dictionaryWithCapacity:42];
    }
    return _cellOpenAlbumDic;
}

- (NSMutableArray *)selectedPaths {
    if ( ! _selectedPaths) {
        _selectedPaths = [NSMutableArray arrayWithCapacity:42];
    }
    return _selectedPaths;
}
- (NSMutableArray *)openAlbumSelectedVideoPaths {
    if ( ! _openAlbumSelectedVideoPaths) {
        _openAlbumSelectedVideoPaths = [NSMutableArray arrayWithCapacity:42];
    }
    return _openAlbumSelectedVideoPaths;
}
- (NSMutableArray *)openAlbumSelectedPaths {
    if ( ! _openAlbumSelectedPaths) {
        _openAlbumSelectedPaths = [NSMutableArray arrayWithCapacity:42];
    }
    return _openAlbumSelectedPaths;
}
- (NSMutableArray *)openAlbumSelectMax {
    if ( ! _openAlbumSelectMax) {
        _openAlbumSelectMax = [NSMutableArray arrayWithCapacity:42];
    }
    return _openAlbumSelectMax;
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

#pragma mark - openAlbum closeAlbum
-(void)openAlbum:(NSDictionary *)paramsDict_{
  
    self.isOpenAlbum = YES;
    openAlbumCbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    __block NSString *albumCollectionId = @"";
    __block NSString *albumCollectionName =@"";
    
    self.openAlbumGroupId = [paramsDict_ stringValueForKey:@"groupId" defaultValue:@""];
    if ([self.openAlbumGroupId isEqualToString:@""]) {
        [self.photoStore fetchDefaultAllPhotosGroup:^(NSArray<PHAssetCollection *> * _Nonnull groups, PHFetchResult * _Nonnull collections) {
            for (int i = 0; i < groups.count; i++) {
                PHAssetCollection * collection = groups[i];
                NSLog(@"localizedTitlealbum%@,%@",collection.localizedTitle,collection.localIdentifier);
                if ([collection.localizedTitle isEqualToString:@"所有照片"]||[collection.localizedTitle isEqualToString:@"相机胶卷"]) {
                    albumCollectionId = collection.localIdentifier;
                    albumCollectionName = collection.localizedTitle;
                    self.openAlbumGroupId = albumCollectionId;
                }
            }
            
        }];
    }
    
    
    NSDictionary *rectInfo = [paramsDict_ dictValueForKey:@"rect" defaultValue:@{}];
    NSString * openAlbumType = [paramsDict_ stringValueForKey:@"type" defaultValue:@"image"];
    self.openAlbumDict = paramsDict_;
    CGFloat x = [rectInfo floatValueForKey:@"x" defaultValue:0];
    CGFloat y = [rectInfo floatValueForKey:@"y" defaultValue:30];
    CGFloat w = [rectInfo floatValueForKey:@"w" defaultValue:self.viewController.view.frame.size.width];
    self.openAlbumWidth = w;
    CGFloat h = [rectInfo floatValueForKey:@"h" defaultValue:300];
    NSString * fixedOn = [paramsDict_ stringValueForKey:@"fixedOn" defaultValue:nil];
    BOOL fixed = [paramsDict_ boolValueForKey:@"fixed" defaultValue:YES];
    
    NSDictionary *stylesInfo = [paramsDict_ dictValueForKey:@"styles" defaultValue:@{}];
    int column = [stylesInfo intValueForKey:@"column" defaultValue:3];
    self.openAlbumMax = [paramsDict_ integerValueForKey:@"max" defaultValue:9];
    self.videoPreview = [paramsDict_ integerValueForKey:@"videoPreview" defaultValue:true];

    CGFloat interval = [stylesInfo floatValueForKey:@"interval" defaultValue:5];
    AlbumBrowserSinglen.sharedSingleton.openAlbumDict = [stylesInfo dictValueForKey:@"selector" defaultValue:@{}];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake((SelfView_W-(column+1)*interval)/column, (SelfView_W-(column+1)*interval)/column)];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    layout.sectionInset = UIEdgeInsetsMake(0, interval, 0, interval);
    layout.minimumInteritemSpacing = interval;
    layout.minimumLineSpacing = interval; //上下的间距 可以设置0看下效果
    self.albumCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(x, y, w, h) collectionViewLayout:layout];
    [self addSubview:self.albumCollectionView fixedOn:fixedOn fixed:fixed];
    self.albumCollectionView.backgroundColor = [UIColor whiteColor];
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [self.albumCollectionView registerClass:[OpenAlbumCell class] forCellWithReuseIdentifier:@"OpenAlbumCell"];
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
//    [self.albumCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
    //4.设置代理
    self.albumCollectionView.delegate = self;
    self.albumCollectionView.dataSource = self;
    /* 从资源id --> 本地资源的转换 */
    PHFetchResult<PHAssetCollection *>  * fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[self.openAlbumGroupId] options:nil];
    if (0 == fetchResult.count) {
        return;
    }
    PHAssetCollection * assetCollection = fetchResult.firstObject;
    self.openAlbumArray = [NSMutableArray arrayWithArray:[self getAssetsInAssetCollection:assetCollection
                                                                                ascending:true type:openAlbumType]];
    if (![albumCollectionId isEqualToString:@""]) {
        [self sendResultEventWithCallbackId:openAlbumCbId dataDict:@{@"eventType":@"show",@"groupName":albumCollectionName} errDict:nil doDelete:NO];
    }else{
        [self sendResultEventWithCallbackId:openAlbumCbId dataDict:@{@"eventType":@"show"} errDict:nil doDelete:NO];
        
    }
    
}

-(void)closeAlbum:(NSDictionary *)paramsDict_{
    self.albumCollectionView.delegate = nil;
    self.albumCollectionView.dataSource = nil;
    [self.openAlbumSelectMax removeAllObjects];
     [self.openAlbumSelectedPaths removeAllObjects];
    [self.openAlbumSelectedVideoPaths removeAllObjects];

    if (self.albumCollectionView) {
        [self.albumCollectionView removeFromSuperview];
        self.albumCollectionView = nil;

    }
}

#pragma mark - openGroup

-(void)openGroup:(NSDictionary *)paramsDict_{
     self.isOpenAlbum = NO;
    openGroupCbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    __block NSString *groupCollectionId = @"";
     __block NSString *groupCollectionName =@"";
    
    self.groupId = [paramsDict_ stringValueForKey:@"groupId" defaultValue:@""];
    if ([self.groupId isEqualToString:@""]) {
        [self.photoStore fetchDefaultAllPhotosGroup:^(NSArray<PHAssetCollection *> * _Nonnull groups, PHFetchResult * _Nonnull collections) {
            for (int i = 0; i < groups.count; i++) {
                PHAssetCollection * collection = groups[i];
                //NSLog(@"localizedTitle%@",collection.localizedTitle);
                if ([collection.localizedTitle isEqualToString:@"所有照片"]||[collection.localizedTitle isEqualToString:@"相机胶卷"]) {
                    groupCollectionId = collection.localIdentifier;
                    groupCollectionName = collection.localizedTitle;
                }
            }
            
        }];
        self.groupId = groupCollectionId;
    }
 
    
    NSDictionary *rectInfo = [paramsDict_ dictValueForKey:@"rect" defaultValue:@{}];
    self.openGroupDict = paramsDict_;
    CGFloat x = [rectInfo floatValueForKey:@"x" defaultValue:0];
    CGFloat y = [rectInfo floatValueForKey:@"y" defaultValue:30];
    CGFloat w = [rectInfo floatValueForKey:@"w" defaultValue:self.viewController.view.frame.size.width];
    self.openGroupWidth = w;
    CGFloat h = [rectInfo floatValueForKey:@"h" defaultValue:300];
    NSString * fixedOn = [paramsDict_ stringValueForKey:@"fixedOn" defaultValue:nil];
    BOOL fixed = [paramsDict_ boolValueForKey:@"fixed" defaultValue:YES];
     NSArray *selectedPathsArray = [paramsDict_ arrayValueForKey:@"selectedPaths" defaultValue:@[]];
    [self.selectedPaths addObjectsFromArray:selectedPathsArray];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake((SelfView_W-10)/4, (SelfView_W-10)/4)];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    layout.sectionInset = UIEdgeInsetsMake(0, 2, 0, 2);
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2; //上下的间距 可以设置0看下效果
    self.mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(x, y, w, h) collectionViewLayout:layout];
    [self addSubview:self.mainCollectionView fixedOn:fixedOn fixed:fixed];
    self.mainCollectionView.backgroundColor = [UIColor whiteColor];
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [self.mainCollectionView registerClass:[GroupCell class] forCellWithReuseIdentifier:@"cellId"];
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    [self.mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
    //4.设置代理
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    /* 从资源id --> 本地资源的转换 */
    PHFetchResult<PHAssetCollection *>  * fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[self.groupId] options:nil];
    if (0 == fetchResult.count) {
        return;
    }
    PHAssetCollection * assetCollection = fetchResult.firstObject;
    self.openGroupArray = [NSMutableArray arrayWithArray:[self getAssetsInAssetCollection:assetCollection
                                                                                ascending:true type:@"image"]];
    if (![groupCollectionId isEqualToString:@""]) {
        [self sendResultEventWithCallbackId:openGroupCbId dataDict:@{@"eventType":@"show",@"groupName":groupCollectionName} errDict:nil doDelete:NO];
    }else{
        [self sendResultEventWithCallbackId:openGroupCbId dataDict:@{@"eventType":@"show"} errDict:nil doDelete:NO];

    }
    

    
}

-(void)changeGroup:(NSDictionary *)paramsDict_{
    self.groupId = [paramsDict_ stringValueForKey:@"groupId" defaultValue:@""];
    NSArray *seletedArray = [paramsDict_ arrayValueForKey:@"selectedPaths" defaultValue:@[]];
    [self.selectedPaths removeAllObjects];
    [self.selectedPaths addObjectsFromArray:seletedArray];
    /* 从资源id --> 本地资源的转换 */
    PHFetchResult<PHAssetCollection *>  * fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[self.groupId] options:nil];
    if (0 == fetchResult.count) {
        return;
    }
    PHAssetCollection * assetCollection = fetchResult.firstObject;
    NSMutableArray *changeGroupArray = [NSMutableArray arrayWithArray:[self getAssetsInAssetCollection:assetCollection
                                                                                             ascending:true type:@"image"]];
    
    
    [self.openGroupArray removeAllObjects];
    self.openGroupArray = changeGroupArray;
    [self.mainCollectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.mainCollectionView reloadData];
    [self sendResultEventWithCallbackId:openGroupCbId dataDict:@{@"eventType":@"change",@"groupId":self.groupId} errDict:nil doDelete:NO];

}
#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.isOpenAlbum) {
    return  self.openAlbumArray.count;
    }else{
    return self.openGroupArray.count+1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isOpenAlbum) {
        
        NSString *identifier = [NSString stringWithFormat:@"OpenAlbumCell"];
        OpenAlbumCell *albumCell = (OpenAlbumCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
        albumCell.asset = self.openAlbumArray[_openAlbumArray.count-indexPath.row-1];
        //albumCell.asset.mediaType
        if (albumCell.asset.mediaType == PHAssetMediaTypeImage) {
            albumCell.videoImg.hidden = YES;
            albumCell.signBtn.hidden = NO;

            if ([self.openAlbumSelectedPaths containsObject:albumCell.asset.localIdentifier]) {
                albumCell.chooseStatus = YES;
                albumCell.signBtn.selected = YES;
            }else{
                albumCell.chooseStatus = NO;
                albumCell.signBtn.selected = NO;
            }
        }else{
            albumCell.videoImg.hidden = NO;
            albumCell.signBtn.hidden = YES;

        }
        albumCell.chooseStatus = NO;
        albumCell.topBtn.userInteractionEnabled = false;
        albumCell.signBtn.userInteractionEnabled = false;
        return albumCell;
    }else{
        GroupCell *cell = (GroupCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
        
        if (indexPath.row==0) {
            
            [cell.topBtn setImage:[UIImage imageNamed:@"res_UIAlbumBrowser/groupTakePhoto@3x.png"] forState:UIControlStateNormal] ;
            [cell.topBtn.layer addSublayer:cell.borderLayer];
            cell.signBtn.hidden = YES;
            
        }else{
            cell.asset = self.openGroupArray[_openGroupArray.count - indexPath.row];
            
            if ([self.selectedPaths containsObject:cell.asset.localIdentifier]) {
                cell.chooseStatus = YES;
                cell.signBtn.hidden = NO;
            }else{
                cell.chooseStatus = NO;
                cell.signBtn.hidden = YES;
            }
            [cell.borderLayer removeFromSuperlayer];
        }
        cell.topBtn.userInteractionEnabled = false;
        cell.signBtn.userInteractionEnabled = false;
        
        return cell;
    }

}
- (void) cellButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
}


//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isOpenAlbum) {
        OpenAlbumCell *cell = (OpenAlbumCell *)[collectionView cellForItemAtIndexPath:indexPath];
     
            __block  NSMutableDictionary *sendDict = [NSMutableDictionary dictionaryWithCapacity:42];
            [sendDict setObject:self.openAlbumGroupId forKey: @"groupId"];
        
        if (cell.asset.mediaType == PHAssetMediaTypeVideo) {
            
            
            if (self.videoPreview) {
                __block   NSString *videoUrl;
                PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionOriginal;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                options.networkAccessAllowed = YES;
                NSLog(@"%@",cell.asset.localIdentifier);
                [[PHImageManager defaultManager] requestAVAssetForVideo:cell.asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
                    AVURLAsset *videoAsset = (AVURLAsset*)avasset;
                    videoUrl = [NSString stringWithFormat:@"%@",[videoAsset.URL absoluteString]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        __block NSDictionary *targetDict;
                        
                        
                        
                        OpenAlbumDetailController *detailVC = [[OpenAlbumDetailController alloc]init];
                        self.viewController.navigationController.navigationBarHidden = NO;
                        detailVC.localPath = videoUrl ;
                        detailVC.openAlbumCbId = openAlbumCbId;
                        detailVC.groupId = self.openAlbumGroupId;
                        detailVC.module = self;
                        detailVC.asset = cell.asset;
                        detailVC.targetDict = targetDict;
                        [self.viewController.navigationController pushViewController:detailVC animated:false];
                        
                        
                    });
                    
                }];
            }else{
                
                if (self.openAlbumSelectedPaths.count>0) {
                    [self.viewController.navigationController.view makeToast:[NSString stringWithFormat:@"不能同时选择视频和图片"] duration:[CSToastManager defaultDuration] position:@"center"];
                }else{
                [self requestImageForAsset:cell.asset size:CGSizeMake(300, 300) resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage * image) {
                    [self cache:image imagePath:cell.asset.localIdentifier complete:^(NSString * _Nonnull thumPath) {
                        
                        NSDictionary *targetDict = @{
                                                     @"path": cell.asset.localIdentifier ?: @"",
                                                     @"thumbPath": thumPath ?: @"",
                                                     @"type":@"video",
                                                     };
                        [sendDict setObject:targetDict forKey:@"target"];
                        [sendDict setObject:@"select" forKey: @"eventType"];
                        [self sendResultEventWithCallbackId:openAlbumCbId dataDict:sendDict errDict:nil doDelete:NO];
                        [self.openAlbumSelectedVideoPaths addObject:cell.asset.localIdentifier];

                        

                    }];

                }];
                }
           
               

                
            }
 
       
            
        }else{
            
            if (self.openAlbumSelectedVideoPaths.count>0) {
                  [self.viewController.navigationController.view makeToast:[NSString stringWithFormat:@"不能同时选择视频和图片"] duration:[CSToastManager defaultDuration] position:@"center"];
            }else{
            [self transPathOpenGroup:cell.asset.localIdentifier groupImage:[cell.topBtn imageForState:UIControlStateNormal]  withBlock:^(NSString *gifImagePath, NSString *path, NSString *thumPath) {
                if (nil != gifImagePath){
                    [sendDict setObject:@{
                                          @"gifImagePath": gifImagePath ?: @"",
                                          @"type":@"image",
                                          } forKey:@"target"];
                }else{
                    NSDictionary *targetDict = @{
                                                 @"path": path ?: @"",
                                                 @"thumbPath": thumPath ?: @"",
                                                 @"type":@"image",
                                                 };
                    [sendDict setObject:targetDict forKey:@"target"];
                }

                
             
                if (cell.chooseStatus == NO) {
                    
                
                    if (self.openAlbumSelectMax.count> (self.openAlbumMax-1)) {
                        
                        cell.signBtn.selected= NO;
                        cell.chooseStatus = NO;
                        [self.viewController.navigationController.view makeToast:[NSString stringWithFormat:@"图片最多选择%ld张",(long)self.openAlbumMax] duration:[CSToastManager defaultDuration] position:@"center"];

                    }else{
                        [self.openAlbumSelectMax addObject:cell.asset.localIdentifier];
                        cell.chooseStatus = YES;
                        cell.signBtn.selected = YES;
                        [self.openAlbumSelectedPaths addObject:cell.asset.localIdentifier];
                        [sendDict setObject:@"select" forKey: @"eventType"];
                        [self sendResultEventWithCallbackId:openAlbumCbId dataDict:sendDict errDict:nil doDelete:NO];
                    }
                    
          
                    
                }else{
                    cell.signBtn.selected = NO;
                    cell.chooseStatus = NO;
                    [self.openAlbumSelectedPaths removeObject:cell.asset.localIdentifier];
                    [self.openAlbumSelectMax removeObject:cell.asset.localIdentifier];
                    [sendDict setObject:@"cancel" forKey: @"eventType"];
                    [self sendResultEventWithCallbackId:openAlbumCbId dataDict:sendDict errDict:nil doDelete:NO];
                    
                }
                
            
                
                
                
            }];
            
            
        }
        }
        
    }else{
      
        GroupCell *cell = (GroupCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (indexPath.row == 0) {
            [self sendResultEventWithCallbackId:openGroupCbId dataDict:@{@"eventType":@"camera"} errDict:nil doDelete:NO];
        }else{
            __block  NSMutableDictionary *sendDict = [NSMutableDictionary dictionaryWithCapacity:42];
            [sendDict setObject:self.groupId forKey: @"groupId"];
            
            [self transPathOpenGroup:cell.asset.localIdentifier groupImage:[cell.topBtn imageForState:UIControlStateNormal]  withBlock:^(NSString *gifImagePath, NSString *path, NSString *thumPath) {
                if (nil != gifImagePath){
                    
                    [sendDict setObject:@{
                                          @"gifImagePath": gifImagePath ?: @"",
                                          } forKey:@"target"];
                    
                }else{
                    NSDictionary *targetDict = @{
                                                 @"path": path ?: @"",
                                                 @"thumPath": thumPath ?: @""};
                    [sendDict setObject:targetDict forKey:@"target"];
                }
                
                if (cell.chooseStatus == NO) {
                    cell.signBtn.hidden = NO;
                    cell.chooseStatus = YES;
                    
                    [self.selectedPaths addObject:cell.asset.localIdentifier];
                    
                    [sendDict setObject:@"select" forKey: @"eventType"];
                    [self sendResultEventWithCallbackId:openGroupCbId dataDict:sendDict errDict:nil doDelete:NO];
                    
                }else{
                    cell.signBtn.hidden = YES;
                    cell.chooseStatus = NO;
                    [self.selectedPaths removeObject:cell.asset.localIdentifier];
                    
                    [sendDict setObject:@"cancel" forKey: @"eventType"];
                    [self sendResultEventWithCallbackId:openGroupCbId dataDict:sendDict errDict:nil doDelete:NO];
                    
                }
                
            }];
            
            
            
        }
    }

}


-(void)closeGroup:(NSDictionary *)paramsDict_{
    self.mainCollectionView.delegate = nil;
    self.mainCollectionView.dataSource = nil;
    if (self.mainCollectionView) {
        [self.mainCollectionView removeFromSuperview];
        self.mainCollectionView = nil;
     
    }
}

- (void)open:(NSDictionary *)paramsDict_ {
    opencbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    BOOL albumRotation = [paramsDict_ boolValueForKey:@"rotation" defaultValue:false];
    BOOL selectedAll = [paramsDict_ boolValueForKey:@"selectedAll" defaultValue:true];
    PhotoNavigationViewModel * viewModel = [PhotoNavigationViewModel new];
    NSString *openType = [paramsDict_ stringValueForKey:@"type" defaultValue:@"image"];
    BOOL isOpenPreview = [paramsDict_ boolValueForKey:@"isOpenPreview" defaultValue:true];
    //CGFloat thumbW = [paramsDict_ floatValueForKey:@"w" defaultValue:300.0];
    //CGFloat thumbH = [paramsDict_ floatValueForKey:@"h" defaultValue:300.0];
    [viewModel setBridgeGetAssetBlock:^(NSArray<PHAsset *> * assets){
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:42];
        if (0 == assets.count) {
            [self sendResultEventWithCallbackId:opencbId
                                       dataDict:@{@"eventType":@"cancel"}
                                        errDict:nil
                                       doDelete:YES];
        }
        for (NSInteger i = assets.count -1 ; i >= 0; i--) {
            /* 每输出一个,就移除一个,所以此处,总是从 allAssets的开始处取值. */
            PHAsset * asset = assets[i];
            CGFloat thumbW,thumbH;
            if (asset.mediaType == PHAssetMediaTypeImage) {
                thumbW = 300 ;
                thumbH = 300;
            }else{
              
                thumbW = asset.pixelWidth/4;
                thumbH = asset.pixelHeight/4;
            }
            [self requestImageForAsset:asset size:CGSizeMake(thumbW, thumbH) resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage * image) {
                
                __block CGFloat resouceSize;
                if (asset.mediaType == PHAssetMediaTypeImage) {
                    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                        resouceSize = imageData.length; //convert to MB
                    }] ;
                }else{

                    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                    options.version = PHVideoRequestOptionsVersionOriginal;
                    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                        if ([asset isKindOfClass:[AVURLAsset class]]) {
                            AVURLAsset* urlAsset = (AVURLAsset*)asset;
                            NSNumber *size;
                            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                            //NSLog(@"size is %f",[size floatValue]); //size is 43.703005
                            resouceSize = [size floatValue];

                        }}];
                }
             
                [self cache:image imagePath:asset.localIdentifier
                   complete:^(NSString * _Nonnull thumbPath) {
                       CLLocation *newLocation = asset.location;
                       CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
                       NSString * path = asset.localIdentifier;
                       // NSString * time = asset.modificationDate.description; // TODO: 转换成需要的格式 + 用"修改时间"
                       NSInteger timeSp = [asset.modificationDate timeIntervalSince1970] *1000.0;
                       NSTimeInterval duration = asset.duration*1000; // TODO: 建议添加,这样就没必要实现 getVideoDuration 接口了...
                       NSString * mediaType = asset.mediaType ==  PHAssetMediaTypeImage ? @"image":@"video";
                       NSDictionary * listItem;
                       //PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
                       //long long resouceSize = [[resource valueForKey:@"fileSize"] longLongValue];
                   
                       if (asset.mediaType == PHAssetMediaTypeImage) {
                         
                           listItem  = @{@"path":path,
                                         @"thumbPath":thumbPath,
                                         @"time":@(timeSp),
                                         @"mediaType":mediaType,
                                         @"size":@(resouceSize),
                                         @"longitude":@(oldCoordinate.longitude),
                                         @"latitude":@(oldCoordinate.latitude),
                                         };
                       }else
                       {
                           listItem  = @{@"path":path,
                                         @"thumbPath":thumbPath,
                                         @"time":@(timeSp),
                                         @"duration":@(duration),
                                         @"mediaType":mediaType,
                                          @"size":@(resouceSize),
                                         @"longitude":@(oldCoordinate.longitude),
                                         @"latitude":@(oldCoordinate.latitude),
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
    BOOL showCamera = [paramsDict_ boolValueForKey:@"showCamera" defaultValue:true];
    UZAlbumSingleton.sharedSingleton.stylesInfo = stylesInfo;
    UZAlbumSingleton.sharedSingleton.navInfo = navInfo;
    UZAlbumSingleton.sharedSingleton.imagePickerCbId = imagePickerCbId;
    UZAlbumSingleton.sharedSingleton.albumBrowser = self;
    WPhotoViewController *WphotoVC = [[WPhotoViewController alloc] init];
    //选择图片的最大数
    WphotoVC.selectPhotoOfMax = selectMax;
    WphotoVC.showCamera = showCamera;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 在子线程中执行耗时操作.
        
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
                
                __block CGFloat resouceSize;
                if (asset.mediaType == PHAssetMediaTypeImage) {
                    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                        resouceSize = imageData.length; //convert to MB
                    }] ;
                }else{
                    
                    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                    options.version = PHVideoRequestOptionsVersionOriginal;
                    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                        if ([asset isKindOfClass:[AVURLAsset class]]) {
                            AVURLAsset* urlAsset = (AVURLAsset*)asset;
                            NSNumber *size;
                            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                            //NSLog(@"size is %f",[size floatValue]); //size is 43.703005
                            resouceSize = [size floatValue];
                            
                        }}];
                }
                [self cache:image imagePath:asset.localIdentifier
                   complete:^(NSString * _Nonnull thumbPath) {
                       NSString * path = asset.localIdentifier;
                       // NSString * time = asset.modificationDate.description; // TODO: 转换成需要的格式 + 用"修改时间"
                       NSInteger timeSp = [asset.modificationDate timeIntervalSince1970] *1000.0;
                       NSTimeInterval duration = asset.duration*1000; // TODO: 建议添加,这样就没必要实现 getVideoDuration 接口了...
                       NSString * mediaType = asset.mediaType ==  PHAssetMediaTypeImage ? @"image":@"video";
                       NSDictionary * listItem;
                       //PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
                       //long long size = [[resource valueForKey:@"fileSize"] longLongValue];
                       if (asset.mediaType == PHAssetMediaTypeImage) {
                           listItem  = @{@"path":path,
                                         @"thumbPath":thumbPath,
                                         @"time":@(timeSp),
                                         @"mediaType":mediaType,
                                         @"size":@(resouceSize)
                                         };
                       }else
                       {
                           listItem  = @{@"path":path,
                                         @"thumbPath":thumbPath,
                                         @"time":@(timeSp),
                                         @"duration":@(duration),
                                         @"mediaType":mediaType,
                                          @"size":@(resouceSize)
                                         };
                       }
                       
                       [list addObject:listItem];
                       
                       if (list.count == count) {
                           NSDictionary * dataDict = @{
                                                       @"total":@(total),
                                                       @"list": list
                                                       };
                           
                          //
                               /// 切换到主线程,回调结果,或者进行 UI 操作.
                               [self sendResultEventWithCallbackId:cbId
                                                          dataDict:dataDict
                                                           errDict:nil
                                                          doDelete:YES];
                          // });
                       }
                   }];
            }];
        }
    });
    
    
}
- (void)scanGroups:(NSDictionary *)paramsDict_{

    NSInteger cbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    NSDictionary *thumbSizeInfo = [paramsDict_ dictValueForKey:@"thumbnail" defaultValue:@{}];
    CGFloat thumbW = [thumbSizeInfo floatValueForKey:@"w" defaultValue:100.0];
    CGFloat thumbH = [thumbSizeInfo floatValueForKey:@"h" defaultValue:100.0];
    CGSize thumbSize = CGSizeMake(thumbW, thumbH);

    [self.photoStore fetchDefaultAllPhotosGroup:^(NSArray<PHAssetCollection *> * _Nonnull groups, PHFetchResult * _Nonnull collections) {
        //进行回调
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
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
                                NSString * groupType = @"";
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
            
            __block CGFloat resouceSize;
            if (asset.mediaType == PHAssetMediaTypeImage) {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    resouceSize = imageData.length; //convert to MB
                }] ;
            }else{
                
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionOriginal;
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                    if ([asset isKindOfClass:[AVURLAsset class]]) {
                        AVURLAsset* urlAsset = (AVURLAsset*)asset;
                        NSNumber *size;
                        [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                        //NSLog(@"size is %f",[size floatValue]); //size is 43.703005
                        resouceSize = [size floatValue];
                        
                    }}];
            }
            [self cache:image imagePath:asset.localIdentifier
               complete:^(NSString * _Nonnull thumbPath) {
                   NSString * path = asset.localIdentifier;
                   //                   NSString * time = asset.modificationDate.description; // TODO: 转换成需要的格式 + 用"修改时间".
                   NSInteger timeSp = [asset.modificationDate timeIntervalSince1970] *1000.0;                   NSTimeInterval duration = asset.duration*1000; // TODO: 建议添加,这样就没必要实现 getVideoDuration 接口了...
                   NSString * mediaType = asset.mediaType ==  PHAssetMediaTypeImage ? @"image":@"video" ; // TODO: 加上,不会更好吗?
                   //PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
                   //long long size = [[resource valueForKey:@"fileSize"] longLongValue];
                   NSDictionary * listItem;
                   if (asset.mediaType == PHAssetMediaTypeImage) {
                       listItem  = @{@"path":path,
                                     @"thumbPath":thumbPath,
                                     @"time":@(timeSp),
                                     @"mediaType":mediaType,
                                     @"size":@(resouceSize)
                                     };
                   }else
                   {
                       listItem  = @{@"path":path,
                                     @"thumbPath":thumbPath,
                                     @"time":@(timeSp),
                                     @"duration":@(duration),
                                     @"mediaType":mediaType,
                                     @"size":@(resouceSize)
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
            
            __block CGFloat resouceSize;
            if (asset.mediaType == PHAssetMediaTypeImage) {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    resouceSize = imageData.length; //convert to MB
                }] ;
            }else{
                
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionOriginal;
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                    if ([asset isKindOfClass:[AVURLAsset class]]) {
                        AVURLAsset* urlAsset = (AVURLAsset*)asset;
                        NSNumber *size;
                        [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                        //NSLog(@"size is %f",[size floatValue]); //size is 43.703005
                        resouceSize = [size floatValue];
                        
                    }}];
            }
            [self cache:image imagePath:asset.localIdentifier
               complete:^(NSString * _Nonnull thumbPath) {
                   NSString * path = asset.localIdentifier;
                   //NSString * time = asset.modificationDate.description; // TODO: 转换成需要的格式 + 用"修改时间".
                   NSInteger timeSp = [asset.modificationDate timeIntervalSince1970] *1000.0;                   NSTimeInterval duration = asset.duration*1000; // TODO: 建议添加,这样就没必要实现 getVideoDuration 接口了...
                   NSString * mediaType = asset.mediaType ==  PHAssetMediaTypeImage ? @"image":@"video" ; // TODO: 加上,不会更好吗?
                   NSDictionary * listItem;
                  // PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
                   //long long size = [[resource valueForKey:@"fileSize"] longLongValue];
                   if (asset.mediaType == PHAssetMediaTypeImage) {
                       listItem  = @{@"path":path,
                                     @"thumbPath":thumbPath,
                                     @"time":@(timeSp),
                                     @"mediaType":mediaType,
                                     @"size":@(resouceSize)
                                     };
                   }else
                   {
                       listItem  = @{@"path":path,
                                     @"thumbPath":thumbPath,
                                     @"time":@(timeSp),
                                     @"duration":@(duration),
                                     @"mediaType":mediaType,
                                     @"size":@(resouceSize)
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
            __block CGFloat resouceSize;
            if (asset.mediaType == PHAssetMediaTypeImage) {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    resouceSize = imageData.length; //convert to MB
                }] ;
            }else{
                
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionOriginal;
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                    if ([asset isKindOfClass:[AVURLAsset class]]) {
                        AVURLAsset* urlAsset = (AVURLAsset*)asset;
                        NSNumber *size;
                        [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                        //NSLog(@"size is %f",[size floatValue]); //size is 43.703005
                        resouceSize = [size floatValue];
                        
                    }}];
            }
            [self cache:image imagePath:asset.localIdentifier
               complete:^(NSString * _Nonnull thumbPath) {
                   NSString * path = asset.localIdentifier;
                  // NSString * time = asset.modificationDate.description; // TODO: 转换成需要的格式 + 用"修改时间"!
                   NSInteger timeSp = [asset.modificationDate timeIntervalSince1970] *1000.0;
                   NSTimeInterval duration = asset.duration*1000 ; // TODO: 建议添加,这样就没必要实现 getVideoDuration 接口了...
                   
                   
                   NSString * mediaType = asset.mediaType ==  PHAssetMediaTypeImage ? @"image":@"video" ; // TODO: 加上,不会更好吗?
                   NSDictionary * listItem;
                   //PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
                   //long long size = [[resource valueForKey:@"fileSize"] longLongValue];
                   if (asset.mediaType == PHAssetMediaTypeImage) {
                       listItem  =  @{@"path":path,
                                      @"thumbPath":thumbPath,
                                      @"time":@(timeSp),
                                      @"mediaType":mediaType,
                                      @"size":@(resouceSize)
                                      };
                   }else
                   {
                       listItem  =  @{@"path":path,
                                      @"thumbPath":thumbPath,
                                      @"time":@(timeSp),
                                      @"duration":@(duration),
                                      @"mediaType":mediaType,
                                      @"size":@(resouceSize)
                                      };
                   }
                   [list addObject:listItem];
                   if (list.count == count) {
                       NSDictionary * dataDict = @{
                                                   @"list": list
                                                   };
                       // dispatch_sync(dispatch_get_main_queue(), ^{
                       [self sendResultEventWithCallbackId:cbId
                                                  dataDict:dataDict
                                                   errDict:nil
                                                  doDelete:YES];
                        //});
                   }
               }];
        }];
    }
        });
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
    
    //option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
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
    PHFetchResult *result = [self openAlbumfetchAssetsInAssetCollection:assetCollection ascending:ascending];
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

- (PHFetchResult *)openAlbumfetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
//    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    
   // option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

#pragma mark - 获取asset对应的图片
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


#pragma mark - 获取asset对应的图片
- (void)requestImageDataForAsset:(PHAsset *)asset resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *,UIImageOrientation))completion
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
    
    
    [[PHCachingImageManager defaultManager]requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        UIImage *image = [UIImage imageWithData: imageData];
        completion(image,orientation);
    }];
    
}

#pragma mark - 获取相册内所有照片资源
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending type:(NSString *)type
{
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
   // option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = nil;
    if ([type isEqualToString:@"image"]) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
        result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    }else if ([type isEqualToString:@"video"]) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeVideo];
        
        result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:option];
    }else{
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
               
                } else {
                    data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:gifPath]];
              
                }
            }];

        }else{

        }
    }];
    
    if (asset.mediaType == PHAssetMediaTypeImage && [gifPath isEqualToString:@""] ) {
        //创建NSBlockOperation 来执行每一次转换，图片复制等耗时操作
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
               [self requestImageDataForAsset:asset resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, UIImageOrientation orientation) {
                
                  
                   [self cacheTransPath:image imageOrientation:&orientation imagePath:asset.localIdentifier complete:^(NSString * _Nonnull path) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self sendResultEventWithCallbackId:cbId
                                                      dataDict:@{
                                                                 @"path":[NSString stringWithFormat:@"%@",path]
                                                                 }
                                                       errDict:nil
                                                      doDelete:YES];
//                           UIImageView *heicImg2 = [[UIImageView alloc]initWithFrame:CGRectMake(200, 350, 100, 100)];
//                           heicImg2.image = [UIImage imageNamed:path];
//                           [self.viewController.view addSubview:heicImg2];
                           
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
                NSURL  *filePathString;
                if (videoAsset) {
                    filePathString = [self condenseVideoNewUrl:videoAsset.URL];
                }else{
                    [self sendResultEventWithCallbackId:cbId dataDict:@{@"status":[NSNumber numberWithBool:false]} errDict:nil doDelete:NO];
                }
            }];
        }];
        [self.transPathQueue addOperation:operation];
    }
  
}


-(void)transVideoPath:(NSDictionary *)paramsDict_{
    NSInteger transVideoPathCbId = [paramsDict_ integerValueForKey:@"cbId" defaultValue:-1];
    NSString * path = [paramsDict_ stringValueForKey:@"path" defaultValue:nil];
    PHFetchResult<PHAsset *> * fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[path] options:nil];
    if (0 == fetchResult.count) {
        return;
    }
    PHAsset * asset = fetchResult.firstObject;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            options.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
                AVURLAsset *videoAsset = (AVURLAsset*)avasset;
                CMTime   time = [avasset duration];
                int seconds = ceil(time.value/time.timescale);
                NSNumber *size;
                [videoAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                CGFloat fileSize = [size floatValue];

                if (videoAsset) {
                    [self sendResultEventWithCallbackId:transVideoPathCbId dataDict:@{@"status":[NSNumber numberWithBool:true],@"albumVideoPath":[NSString stringWithFormat:@"%@",[videoAsset.URL absoluteString]],@"fileSize":[NSString stringWithFormat:@"%ld",(long)fileSize],@"duration":@(seconds)} errDict:nil doDelete:NO];
                }else{
                    [self sendResultEventWithCallbackId:transVideoPathCbId dataDict:@{@"code":@(-1)} errDict:nil doDelete:NO];
                }
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
   // NSLog(@"压缩前--%.2fk",[self getFileSize:destFilePath]);
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
       // NSLog(@"压缩后---%.2fk",[self getFileSize:resultPath]);
        NSLog(@"视频导出完成");
        NSURL  *filePathString = session.outputURL;
        NSString * urlStr = [filePathString absoluteString];
        urlStr = [urlStr substringFromIndex:7];
        [self sendResultEventWithCallbackId:self.transPathCbId
                                   dataDict:@{@"path":[NSString stringWithFormat:@"%@",urlStr]}
                                    errDict:nil
                                   doDelete:NO];
        
    }];

    return session.outputURL;
}

/* 根据localIdentifier 缓存资源. */

- (void)cache:(UIImage *)img  imagePath:(NSString *)localIdentifier complete:(nonnull void (^)(NSString * _Nonnull))completeBlock {//保存指定图片到临时位置并回调改位置路径
    UIImage *saveImg ;
    if (img.imageOrientation>0) {
        saveImg = [self fixOrientation:img];
    }else{
        saveImg = img;
    }
    NSData * data = UIImagePNGRepresentation(saveImg);
    PHFetchResult<PHAsset *> * fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];

    PHAsset * asset = fetchResult.firstObject;
    //可获取图片名称
    NSString *filename =   [asset valueForKey:@"filename"];
    NSString * typeName;
    if (asset.mediaType == PHAssetMediaTypeImage) {
        typeName = [filename pathExtension];
        if ([typeName isEqualToString:@"heic"]||[typeName isEqualToString:@"HEIC"]||[typeName isEqualToString:@"HEIF"]) {
            typeName = @"jpg";
        }
    }else{
        typeName = @"png";
    }
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


- (void)cacheTransPath:(UIImage *)img  imageOrientation:(UIImageOrientation *)orientation imagePath:(NSString *)localIdentifier complete:(nonnull void (^)(NSString * _Nonnull))completeBlock {//保存指定图片到临时位置并回调改位置路径
    NSLog(@"%ld",(long)img.imageOrientation);
    
    UIImage *saveImg ;
    if (img.imageOrientation>0) {
        saveImg = [self fixOrientation:img];
    }else{
        saveImg = img;
    }

    NSData * data = UIImagePNGRepresentation(saveImg);
    PHFetchResult<PHAsset *> * fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];

    PHAsset * asset = fetchResult.firstObject;
    //可获取图片名称
    NSString *filename =   [asset valueForKey:@"filename"];
    NSString * typeName;
    if (asset.mediaType == PHAssetMediaTypeImage) {
        typeName = [filename pathExtension];
        if ([typeName isEqualToString:@"heic"]||[typeName isEqualToString:@"HEIC"]||[typeName isEqualToString:@"HEIF"]) {
            typeName = @"jpg";
        }
    }else{
        typeName = @"png";
    }
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
    UIImage *saveImg;
    if (image.imageOrientation>0) {
        saveImg = image;
    }else{
        saveImg=[self fixOrientation:image];
        
    }
    NSData * data = UIImageJPEGRepresentation(saveImg, self.scale);
    PHFetchResult<PHAsset *> * fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
//    if (0 == fetchResult.count) {
//        return;
//    }
    PHAsset * asset = fetchResult.firstObject;
    NSString *filename =   [asset valueForKey:@"filename"];
    NSString * typeName;
    if (asset.mediaType == PHAssetMediaTypeImage) {
        typeName = [filename pathExtension];
        if ([typeName isEqualToString:@"heic"]||[typeName isEqualToString:@"HEIC"]||[typeName isEqualToString:@"HEIF"]) {
            typeName = @"jpg";
        }
    }else{
        typeName = @"png";
    }
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





@end
