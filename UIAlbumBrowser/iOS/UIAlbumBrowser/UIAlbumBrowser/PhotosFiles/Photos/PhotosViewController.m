/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotosViewController.h"
#import "PhotosCell.h"
#import "PhotoBottomReusableView.h"
#import "PhotosViewModel.h"
#import "PhotoBrowseController.h"
#import "PhotoBrowseViewModel.h"
#import "PhotoPreviewController.h"
#import "PhotoHandleManager.h"
#import "UIButton+RITLBlockButton.h"
#import "UIViewController+RITLPhotoAlertController.h"
#import <objc/message.h>
#import "UIViewController+Frame.h"
#import "UIView+Category.h"
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"
#import "PhotoBridgeManager.h"
#import "PhotoCacheManager.h"
#import "AlbumBrowserSinglen.h"

#define IS_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define SafeAreaTopHeight (IS_iPhoneX ? 88 : 64)

#define SafeAreaBottomHeight (IS_iPhoneX  ? 64 : 64)

static NSString * cellIdentifier = @"PhotosCell";
static NSString * reusableViewIdentifier = @"PhotoBottomReusableView";

#ifdef __IPHONE_10_0
@interface PhotosViewController ()<UIViewControllerPreviewingDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching>
#else

#ifdef __IPHONE_9_0
@interface PhotosViewController ()<UIViewControllerPreviewingDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
#else
@interface PhotosViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
#endif
#endif

/// @brief 显示的集合视图
@property (nonatomic, strong) UICollectionView * collectionView;
/// @brief 底部的tabBar
@property (nonatomic, strong) UITabBar * bottomBar;
/// @brief 发送按钮
@property (strong, nonatomic) UIButton * sendButton;
/// @brief 显示数目
@property (strong, nonatomic) UILabel * numberOfLabel;
/// @brief 预览按钮
@property (strong, nonatomic) UIButton * bowerButton;

@property (strong, nonatomic) NSString *finishColor;

@property (assign, nonatomic) CGFloat finishSize;
@property (assign, nonatomic) BOOL hasSelectedImg;

@end

@implementation PhotosViewController


-(instancetype)initWithViewModel:(id<RITLCollectionViewModel>)viewModel
{
    if (self = [super init])
    {
        self.viewModel = viewModel;
    }
    
    return self;
}

+(instancetype)photosViewModelInstance:(id<RITLCollectionViewModel>)viewModel
{
    return [[self alloc]initWithViewModel:viewModel];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.viewModel.title;
    //绑定viewModel
    [self bindViewModel];
    PhotosViewModel *pViewModel = self.viewModel;
    NSDictionary *stylesDict = [pViewModel.paramsDict dictValueForKey:@"styles" defaultValue:nil];
    NSDictionary *navSet = [stylesDict dictValueForKey:@"nav" defaultValue:nil];
    CGFloat cancelSize = [navSet floatValueForKey:@"cancelSize" defaultValue:16];
    NSString *collectionBg = [stylesDict stringValueForKey:@"bg" defaultValue:@"#FFFFFF"];
    NSString *finishColor = [navSet stringValueForKey:@"finishColor" defaultValue:@"#fff"];
    CGFloat finishSize = [navSet floatValueForKey:@"finishSize" defaultValue:18];
    
    //设置navigationItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewControllerForCancel)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:cancelSize], NSFontAttributeName, nil] forState:UIControlStateNormal];
    //添加视图
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UZAppUtils colorFromNSString:collectionBg];
    [self.view addSubview:self.bottomBar];
    //获得资源数
    NSUInteger items = [self.viewModel numberOfItemsInSection:0];
    if (items >= 1)
    {
        //滚动到最后一个
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:items-1  inSection:0]atScrollPosition:UICollectionViewScrollPositionBottom animated:false];
        
        //重置偏移量
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y + 64)];
    }
    
    //完成按钮设置
    [self.sendButton setTitleColor:[UZAppUtils  colorFromNSString:finishColor] forState:UIControlStateNormal];
    [self.sendButton.titleLabel setFont:[UIFont systemFontOfSize:finishSize]];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:true];
    [PhotoCacheManager sharedInstace].numberOfSelectedPhoto = 0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;

    
#ifdef __IPHONE_10_0
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
    {
        _collectionView.prefetchDataSource = nil;
    }
    
#endif
    
#ifdef RITLDebug
    NSLog(@"Dealloc %@",NSStringFromClass([self class]));
#endif
}



- (void)bindViewModel
{
    if ([self.viewModel isMemberOfClass:[PhotosViewModel class]])
    {
        PhotosViewModel * viewModel = self.viewModel;
        
        __weak typeof(self) weakSelf = self;
        
        // 跳转至预览视图
        viewModel.photoDidTapShouldBrowerBlock = ^(PHFetchResult * result,NSArray <PHAsset *> * allAssets,NSArray <PHAsset *> * allPhotoAssets,PHAsset * asset,NSUInteger index){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            /// 创建viewModel
            PhotoBrowseViewModel * viewModel = [PhotoBrowseViewModel new];
            
            /// 设置所有的属性
            viewModel.allAssets = allAssets;
            viewModel.allPhotoAssets = allPhotoAssets;
            viewModel.currentIndex = index;
            
            //记录刷新当前的视图
            viewModel.ritl_BrowerWillDisAppearBlock = ^{
                
                [strongSelf.collectionView reloadData];
                
                // 检测发送按钮可用性
                ((void(*)(id,SEL))objc_msgSend)(strongSelf.viewModel,NSSelectorFromString(@"ritl_checkPhotoSendStatusChanged"));
                
            };
            
            //进入一个浏览控制器
            if (AlbumBrowserSinglen.sharedSingleton.isOpenPreview) {
                [strongSelf.navigationController pushViewController:[PhotoBrowseController photosViewModelInstance:viewModel] animated:true];
            }
            
        };
        
        // 发送数目标签响应变化
        viewModel.photoSendStatusChangedBlock = ^(BOOL enable,NSUInteger count){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            strongSelf.bowerButton.enabled = enable;
            strongSelf.sendButton.enabled = enable;
            
            //设置标签数目
            [strongSelf updateNumbersForSelectAssets:count];
        };
        
        // 弹出警告框
        viewModel.warningBlock = ^(BOOL result,NSUInteger maxCount){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf presentAlertController:maxCount];
        };
        
        // 模态弹出
        viewModel.dismissBlock = ^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf dismissViewController];
            
            
        };
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.viewModel.numberOfSection;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotosCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    if ([self.viewModel isMemberOfClass:[PhotosViewModel class]])
    {
        PhotosViewModel * viewModel = self.viewModel;
        
        NSDictionary *stylesDict = [viewModel.paramsDict dictValueForKey:@"styles" defaultValue:nil];
        
        NSDictionary *markDict = [stylesDict dictValueForKey:@"mark" defaultValue:nil];
        
        cell.markDict = markDict;
        
        // 获得图片对象
        [viewModel imageForIndexPath:indexPath collection:collectionView complete:^(UIImage * _Nonnull image, PHAsset * _Nonnull asset, BOOL isImage,NSTimeInterval durationTime) {
            
            cell.imageView.image = image;
            cell.imageView.hidden = NO;
            // 如果不是图片
            if (!isImage)
            {
                if (AlbumBrowserSinglen.sharedSingleton.selectAll && [AlbumBrowserSinglen.sharedSingleton.openType isEqualToString:@"all"]) {
                    cell.chooseImageView.hidden = YES;
                }else{
                    cell.chooseImageView.hidden = YES;
                }
                cell.messageView.hidden = isImage;
                cell.messageLabel.text =  [PhotoHandleManager timeStringWithTimeDuration:durationTime];
            }
            // 响应选择
            cell.chooseImageDidSelectBlock = ^(PhotosCell * cell){
                // 修改数据源成功
                if (isImage) {
                    self.hasSelectedImg = true;
                    if([viewModel didSelectImageAtIndexPath:indexPath])
                    {
                        // 修改UI
                        int order =  [PhotoCacheManager sharedInstace].statusChangeOrder ++;
                        NSInteger item = indexPath.item;
                        [PhotoCacheManager sharedInstace].assetSelectedStatusChangeOrderSignal[item] = order;
                        [cell cellSelectedAction:[viewModel imageDidSelectedAtIndexPath:indexPath]];
                        
                    }
                    
                }else{
                    BOOL hasSelectedImg = self.hasSelectedImg;
                    
                    if(!hasSelectedImg){
                        if([viewModel didSelectImageAtIndexPath:indexPath] )
                        {
                            [cell cellSelectedAction:[viewModel imageDidSelectedAtIndexPath:indexPath]];
                            [viewModel photoDidSelectedComplete];
                        }
                    }
                }
            };
            
            
        }];
        
        
        
    }
    
    
    
#ifdef __IPHONE_9_0
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
    {
        NSUInteger item = indexPath.item;
        
        //获得当前的资源对象
        PHAsset * asset = [((PhotosViewModel *)self.viewModel).assetResult objectAtIndex:item];
        
        BOOL isPhoto = (asset.mediaType == PHAssetMediaTypeImage);
        
        //确定为图片并且3D Touch可用
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable && isPhoto == true)
        {
            [self registerForPreviewingWithDelegate:self sourceView:cell];
        }
    }
    
#endif
    
    return cell;
}

//设置footerView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    PhotoBottomReusableView * resuableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reusableViewIdentifier forIndexPath:indexPath];
    
    resuableView.numberOfAsset = ((PhotosViewModel *)self.viewModel).assetCount;
    
    return resuableView;
}


#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel sizeForItemAtIndexPath:indexPath inCollection:collectionView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return [self.viewModel referenceSizeForFooterInSection:section inCollection:collectionView];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [self.viewModel minimumLineSpacingForSectionAtIndex:section];
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return [self.viewModel minimumInteritemSpacingForSectionAtIndex:section];
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel shouldSelectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.viewModel didSelectItemAtIndexPath:indexPath];
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    //是否显示选中标志
    [((PhotosCell *)cell) cellSelectedAction:[((PhotosViewModel *)self.viewModel) imageDidSelectedAtIndexPath:indexPath]];
}


#pragma mark - <UICollectionViewDataSourcePrefetching>

#ifdef __IPHONE_10_0

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.viewModel prefetchItemsAtIndexPaths:indexPaths];
}

- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.viewModel cancelPrefetchingForItemsAtIndexPaths:indexPaths];
}


#endif

#pragma mark - <UIViewControllerPreviewingDelegate>

#ifdef  __IPHONE_9_0

//#warning 会出现内存泄露，临时不使用
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    //获取当前cell的indexPath
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:(PhotosCell *)previewingContext.sourceView];
    
    NSUInteger item = indexPath.item;
    
    //获得当前的资源
    PHAsset * asset = [((PhotosViewModel *)self.viewModel).assetResult objectAtIndex:item];
    
    if (asset.mediaType != PHAssetMediaTypeImage)
    {
        return nil;
    }
    
    PhotoPreviewController * viewController = [PhotoPreviewController previewWithShowAsset:asset];
    
    return viewController;
}


- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    //获取当前cell的indexPath
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:(PhotosCell *)previewingContext.sourceView];
    
    
    [self.viewModel didSelectItemAtIndexPath:indexPath];
}
#endif



#pragma mark - Getter Function
-(UICollectionView *)collectionView
{
    if(_collectionView == nil)
    {
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height) collectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
        
        //protocol
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
#ifdef __IPHONE_10_0
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
        {
            _collectionView.prefetchDataSource = self;
        }
        
#endif
        
        //property
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        //register View
        [_collectionView registerClass:[PhotosCell class] forCellWithReuseIdentifier:cellIdentifier];
        [_collectionView registerClass:[PhotoBottomReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reusableViewIdentifier];
    }
    
    return _collectionView;
}

-(UITabBar *)bottomBar
{
    if (_bottomBar == nil)
    {
        
        if (IS_iPhoneX) {
            _bottomBar = [[UITabBar alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-74, self.width, 0)];
            
            UIView *eightView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-34, self.width, 34)];
            eightView.backgroundColor = [UIColor colorWithRed:250/255.0 green:245/255.0 blue:245/255.0 alpha:0.90];
            [self.view addSubview:eightView];
            
        }else{
            _bottomBar = [[UITabBar alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-44, self.width, 44)];
            
        }
        
        //add subviews
        [_bottomBar addSubview:self.sendButton];
        [_bottomBar addSubview:self.numberOfLabel];
        [_bottomBar addSubview:self.bowerButton];
        
    }
    
    return _bottomBar;
}

-(UIButton *)bowerButton
{
    if (_bowerButton == nil)
    {
        _bowerButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 60, 30)];
        
        if (AlbumBrowserSinglen.sharedSingleton.isOpenPreview) {
            [_bowerButton setTitle:@"预览" forState:UIControlStateNormal];
            [_bowerButton setTitle:@"预览" forState:UIControlStateDisabled];
        }else{
            [_bowerButton setTitle:@"" forState:UIControlStateNormal];
            [_bowerButton setTitle:@"" forState:UIControlStateDisabled];
        }
        
        
        [_bowerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_bowerButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.25] forState:UIControlStateDisabled];
        
        [_bowerButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_bowerButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        _bowerButton.showsTouchWhenHighlighted = true;
        
        //默认不可点击
        _bowerButton.enabled = false;
        
        __weak typeof(self) weakSelf = self;
        
        [_bowerButton controlEvents:UIControlEventTouchUpInside handle:^(UIControl * _Nonnull sender) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            //跳转至预览视图
            ((void(*)(id,SEL))objc_msgSend)(strongSelf.viewModel,NSSelectorFromString(@"pushBrowerControllerByBrowerButtonTap"));
            
        }];
        
        
    }
    return _bowerButton;
}




-(UIButton *)sendButton
{
    if (_sendButton == nil)
    {
        
        
        _sendButton = [[UIButton alloc]initWithFrame:CGRectMake(_bottomBar.width - 50 - 5, 5, 50, 30)];
        // _sendButton.center = CGPointMake(_sendButton.center.x, _bottomBar.center.y - _bottomBar.originY);
        
        [_sendButton setTitle:@"完成" forState:UIControlStateNormal];
        [_sendButton setTitle:@"完成" forState:UIControlStateDisabled];
        
        
        [_sendButton setTitleColor:[UIColorFromRGB(0x2DD58A) colorWithAlphaComponent:0.25] forState:UIControlStateDisabled];
        
        [_sendButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        _sendButton.showsTouchWhenHighlighted = true;
        
        //默认为不可点击
        _sendButton.enabled = false;
        
        __weak typeof(self) weakSelf = self;
        
        [_sendButton controlEvents:UIControlEventTouchUpInside handle:^(UIControl * _Nonnull sender) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            NSLog(@"发送!");
            
            // 选择完毕
            [((PhotosViewModel *)strongSelf.viewModel) photoDidSelectedComplete];
            
        }];
        
    }
    
    return _sendButton;
}

-(UILabel *)numberOfLabel
{
    if (_numberOfLabel == nil)
    {
        _numberOfLabel = [[UILabel alloc]initWithFrame:CGRectMake(_sendButton.originX - 20, 0, 20, 20)];
        _numberOfLabel.center = CGPointMake(_numberOfLabel.center.x, _sendButton.center.y);
        _numberOfLabel.backgroundColor = UIColorFromRGB(0x2dd58a);
        _numberOfLabel.textAlignment = NSTextAlignmentCenter;
        _numberOfLabel.font = [UIFont boldSystemFontOfSize:14];
        _numberOfLabel.text = @"";
        _numberOfLabel.hidden = true;
        _numberOfLabel.textColor = [UIColor whiteColor];
        _numberOfLabel.layer.cornerRadius = _numberOfLabel.width / 2.0;
        _numberOfLabel.clipsToBounds = true;
    }
    return _numberOfLabel;
}


-(PhotosViewModel *)viewModel
{
    if (!_viewModel)
    {
        _viewModel = [PhotosViewModel new];
    }
    
    return _viewModel;
}

- (void)dismissViewControllerForCancel
{
    if ([[PhotoBridgeManager sharedInstance]BridgeGetAssetBlock]) {
        [[PhotoBridgeManager sharedInstance]BridgeGetAssetBlock](@[]);
    }
    return [self dismissViewController];
    
    
}

-(void)dismissViewController
{
    return [super dismissViewControllerAnimated:true completion:nil];
    
    
}




@end



@implementation PhotosViewController (updateNumberOfLabel)

-(void)updateNumbersForSelectAssets:(NSUInteger)number
{
    BOOL hidden = (number == 0);
    
    if(0 == number){
        self.hasSelectedImg = false;
    }
    
    _numberOfLabel.hidden = hidden;
    
    if (!hidden)
    {
        _numberOfLabel.text = [NSString stringWithFormat:@"%@",@(number)];
        
        //设置放射以及动画
        _numberOfLabel.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        
        [UIView animateWithDuration:0.3 animations:^{
            
            _numberOfLabel.transform = CGAffineTransformIdentity;
            
        }];
    }
}


@end

