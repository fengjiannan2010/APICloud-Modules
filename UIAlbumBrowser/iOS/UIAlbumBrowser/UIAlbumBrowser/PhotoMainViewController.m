//
//  PhotoMainViewController.m
//  UIAlbumBrowser
//
//  Created by lihaiwei on 2017/3/17.
//  Copyright © 2017年 wei. All rights reserved.
//

#import "PhotosCell.h"
#import "PhotoMainViewController.h"

#import "PhotoNavigationViewController.h"
#import "PhotoNavigationViewModel.h"

@interface PhotoMainViewController ()
<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) CGSize assetSize;
@property (nonatomic, copy)NSArray <UIImage *> * assets;

@end

@implementation PhotoMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    CGFloat sizeHeight = (self.collectionView.frame.size.width - 3) / 4;
    _assetSize = CGSizeMake(sizeHeight, sizeHeight);
    
    [self.view addSubview:self.collectionView];
    
    //    //检测是否存在new的相册
    //    RITLPhotoStore * store = [RITLPhotoStore new];
    //
    //    [store checkGroupExist:@"new" result:^(BOOL isExist, PHAssetCollection * _Nullable collection) {
    //
    ////        if (isExist)  NSLog(@"exist!");
    //
    ////        else NSLog(@"not exist!");
    //
    //    }];
    
}
- (IBAction)refresh:(id)sender
{
    self.assets = @[];
    
    [self.collectionView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)photosItemDidTap:(id)sender
{
    PhotoNavigationViewModel * viewModel = [PhotoNavigationViewModel new];
    
    __weak typeof(self) weakSelf = self;
    
    //    设置需要图片剪切的大小，不设置为图片的原比例大小
    //    viewModel.imageSize = _assetSize;
    
    viewModel.BridgeGetImageBlock = ^(NSArray <UIImage *> * images){
        
        //获得图片
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.assets = images;
        
        [strongSelf.collectionView reloadData];
        
    };
    
    viewModel.BridgeGetImageDataBlock = ^(NSArray <NSData *> * datas){
        
        //可以进行数据上传操作..
        
        
    };
    
    PhotoNavigationViewController * viewController = [PhotoNavigationViewController photosViewModelInstance:viewModel];
    
    [self presentViewController:viewController animated:true completion:^{}];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.imageView.image = self.assets[indexPath.item];
    cell.chooseImageView.hidden = true;
    
    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.assetSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}


-(UICollectionView *)collectionView
{
    if (_collectionView == nil)
    {
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor redColor];
        
        [_collectionView registerClass:[PhotosCell class] forCellWithReuseIdentifier:@"Cell"];
    }
    
    return _collectionView;
}



@end

