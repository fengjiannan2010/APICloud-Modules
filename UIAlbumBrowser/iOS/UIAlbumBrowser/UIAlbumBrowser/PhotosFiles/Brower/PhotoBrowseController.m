/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoBrowseController.h"
#import "PhotoBrowseViewModel.h"
#import "PhotoBrowseCell.h"

#import "UIKit+YPPhotoDemo.h"
#import "UIButton+RITLBlockButton.h"
#import "UIViewController+RITLPhotoAlertController.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import "UIView+Category.h"
#import "UIViewController+Frame.h"

#import "PhotosViewModel.h"
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"

#define PhotoBrowerDeselectedColor ([UIColor darkGrayColor])
#define PhotoBrowerSelectedColor (UIColorFromRGB(0x2dd58a))
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)


static NSString * const cellIdentifier = @"PhotoBrowerCell";

@interface PhotoBrowseController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

/// @brief 展示图片的collectionView
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

/// @brief 底部的tabBar
@property (nonatomic, strong) UITabBar * bottomBar;

/// @brief 顶部的bar
@property (nonatomic, strong)UINavigationBar * topBar;

/// @brief 返回
@property (nonatomic, strong)UIButton * backButtonItem;

/// @brief 选择
@property (nonatomic, strong)UIButton * selectButtonItem;

/// @brief 高清图的响应Control
@property (strong, nonatomic) IBOutlet UIControl * highQualityControl;

/// @brief 选中圆圈
@property (strong, nonatomic) IBOutlet UIImageView * hignSignImageView;

/// @brief 原图:
@property (strong, nonatomic) IBOutlet UILabel * originPhotoLabel;

/// @brief 等待风火轮
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView * activityIndicatorView;

/// @brief 照片大小
@property (strong, nonatomic) IBOutlet UILabel *photoSizeLabel;

/// @brief 发送按钮
@property (strong, nonatomic) UIButton * sendButton;

/// @brief 显示数目
@property (strong, nonatomic) UILabel * numberOfLabel;


@end

@implementation PhotoBrowseController


-(instancetype)initWithViewModel:(id <RITLCollectionViewModel> )viewModel
{
    if (self = [super init])
    {
        _viewModel = viewModel;
    }
    
    return self;
}


+(instancetype)photosViewModelInstance:(id <RITLCollectionViewModel> )viewModel
{
    return [[self alloc] initWithViewModel:viewModel];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [UIApplication sharedApplication].statusBarHidden = true;
    
    //绑定viewModel
    [self bindViewModel];
    
    PhotoBrowseViewModel *pViewModel = self.viewModel;
    NSDictionary *stylesDict = [pViewModel.paramsDict dictValueForKey:@"styles" defaultValue:nil];
    NSDictionary *navSet = [stylesDict dictValueForKey:@"nav" defaultValue:nil];
    NSString *finishColor = [navSet stringValueForKey:@"finishColor" defaultValue:@"#fff"];
    CGFloat finishSize = [navSet floatValueForKey:@"finishSize" defaultValue:18];
    [self.sendButton setTitleColor:[UZAppUtils colorFromNSString:finishColor] forState:UIControlStateNormal];
    [self.sendButton.titleLabel setFont:[UIFont systemFontOfSize:finishSize]];
    //添加集合视图
    [self.view addSubview:self.collectionView];
    
    //添加自定义导航栏
    [self.view addSubview:self.topBar];
    
    //添加自定义tab
    [self.view addSubview:self.bottomBar];
    
    //滚动到最后一个
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:((PhotoBrowseViewModel *)self.viewModel).currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    //检测选择的数量
    ((void(*)(id,SEL))objc_msgSend)(self.viewModel,NSSelectorFromString(@"ritl_checkPhotoSendStatusChanged"));
    
    //检测高清状态
    ((void(*)(id,SEL))objc_msgSend)(self.viewModel,NSSelectorFromString(@"ritl_checkHightQuaratyStatus"));
}


-(BOOL)prefersStatusBarHidden
{
    return true;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController != nil)
    {
        self.navigationController.navigationBarHidden = true;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //执行viewModel
    [self scrollViewDidEndDecelerating:self.collectionView];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.navigationController != nil)
    {
        self.navigationController.navigationBarHidden = false;
    }
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    ((void(*)(id,SEL))objc_msgSend)(self.viewModel,NSSelectorFromString(@"controllerViewWillDisAppear"));
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - lazy


#pragma mark - Create Views
-(UICollectionView *)collectionView
{
    if (_collectionView == nil)
    {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-5, 0, self.width + 10, self.height) collectionViewLayout:flowLayout];
        //初始化collectionView属性
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
#ifdef __IPHONE_10_0
        
        //        _collectionView.prefetchDataSource = _browerPreDataSource;
#endif
        _collectionView.pagingEnabled = true;
        _collectionView.showsHorizontalScrollIndicator = false;
        [_collectionView registerClass:[PhotoBrowseCell class] forCellWithReuseIdentifier:cellIdentifier];
    }
    
    return _collectionView;
}


-(UINavigationBar *)topBar
{
    if (_topBar == nil)
    {
        if (iPhoneX) {
            
         
            _topBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 94)];

        }else{
        
            _topBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 64)];

        }
        _topBar.barStyle = UIBarStyleBlack;
        
        [_topBar setViewColor:[[UIColor blackColor] colorWithAlphaComponent:1]];
        
        [_topBar addSubview:self.backButtonItem];
        [_topBar addSubview:self.selectButtonItem];
    }
    
    return _topBar;
}

-(UIButton *)backButtonItem
{
    if (_backButtonItem == nil)
    {
        
        if (iPhoneX) {
            _backButtonItem = [[UIButton alloc]initWithFrame:CGRectMake(5, 44, 64, 64)];

        }else{
            _backButtonItem = [[UIButton alloc]initWithFrame:CGRectMake(5, 20, 64, 64)];
            _backButtonItem.center = CGPointMake(_backButtonItem.center.x, _topBar.center.y);

        }
        NSString *imgPath = [[NSBundle mainBundle]pathForResource:@"res_UIAlbumBrowser/back@2x"ofType:@"png"];
        [_backButtonItem setImage:[UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
        [_backButtonItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backButtonItem.titleLabel setFont:[UIFont systemFontOfSize:30]];
        [_backButtonItem.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        __weak typeof(self) weakSelf = self;
        
        [_backButtonItem controlEvents:UIControlEventTouchUpInside handle:^(UIControl * _Nonnull sender) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf.navigationController popViewControllerAnimated:true];
            
        }];
    }
    
    return _backButtonItem;
}


-(UIButton *)selectButtonItem
{
    if(_selectButtonItem == nil)
    {
        
        if (iPhoneX) {
            _selectButtonItem = [[UIButton alloc]initWithFrame:CGRectMake(_topBar.width - 64 - 10, 44, 64, 64)];

        }else{
            _selectButtonItem = [[UIButton alloc]initWithFrame:CGRectMake(_topBar.width - 64 - 10, 0, 64, 64)];
            _selectButtonItem.center = CGPointMake(_selectButtonItem.center.x, _topBar.center.y);

            
        }
        [_selectButtonItem setImageEdgeInsets:UIEdgeInsetsMake(12, 5, 8, 5)];
        NSString *imgPath = [[NSBundle mainBundle]pathForResource:@"res_UIAlbumBrowser/unSelected@2x"ofType:@"png"];
        [_selectButtonItem setImage: [UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        
        [_selectButtonItem controlEvents:UIControlEventTouchUpInside handle:^(UIControl * _Nonnull sender) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [((PhotoBrowseViewModel *)strongSelf.viewModel) selectedPhotoInScrollView:strongSelf.collectionView];
            
        }];
        
    }
    
    return _selectButtonItem;
}

- (UITabBar *)bottomBar
{
    if (_bottomBar == nil)
    {
        _bottomBar = [[UITabBar alloc]initWithFrame:CGRectMake(0, self.height - 44, self.width, 44)];
        _bottomBar.barStyle = UIBarStyleBlack;
        [_bottomBar setViewColor:[[UIColor blackColor] colorWithAlphaComponent:1]];
        [_bottomBar addSubview:self.highQualityControl];
        [_bottomBar addSubview:self.sendButton];
        [_bottomBar addSubview:self.numberOfLabel];
    }
    
    return _bottomBar;
}


- (UIControl *)highQualityControl
{
    if (_highQualityControl == nil)
    {
        _highQualityControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, 150, _bottomBar.height)];
        [_highQualityControl addSubview:self.hignSignImageView];
        [_highQualityControl addSubview:self.originPhotoLabel];
        [_highQualityControl addSubview:self.activityIndicatorView];
        [_highQualityControl addSubview:self.photoSizeLabel];
        
        
        __weak typeof(self) weakSelf = self;
        
        [_highQualityControl controlEvents:UIControlEventTouchUpInside handle:^(UIControl * _Nonnull sender) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [((PhotoBrowseViewModel *)strongSelf.viewModel) highQualityStatusShouldChanged:strongSelf.collectionView];
            
        }];
        
    }
    
    return _highQualityControl;
}








-(UIActivityIndicatorView *)activityIndicatorView
{
    if (_activityIndicatorView == nil)
    {
        _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicatorView.frame = CGRectMake(_originPhotoLabel.maxX + 5, 0, 15, 15);
        _activityIndicatorView.center = CGPointMake(_activityIndicatorView.center.x, _highQualityControl.center.y);
        _activityIndicatorView.hidesWhenStopped = true;
    }
    
    return _activityIndicatorView;
}



-(UILabel *)photoSizeLabel
{
    if (_photoSizeLabel == nil)
    {
        _photoSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(_originPhotoLabel.maxX + 5, 0, _highQualityControl.width - _photoSizeLabel.originX , 25)];
        _photoSizeLabel.center = CGPointMake(_photoSizeLabel.center.x, _highQualityControl.center.y);
        _photoSizeLabel.font = [UIFont systemFontOfSize:13];
        _photoSizeLabel.textColor = PhotoBrowerDeselectedColor;
        _photoSizeLabel.text = @"";
    }
    
    return _photoSizeLabel;
}

-(UIButton *)sendButton
{
    if (_sendButton == nil)
    {
        _sendButton = [[UIButton alloc]initWithFrame:CGRectMake(_bottomBar.width - 50 - 5, 0, 50, 40)];
        _sendButton.center = CGPointMake(_sendButton.center.x, _bottomBar.center.y - _bottomBar.originY);
        [_sendButton setTitle:@"完成" forState:UIControlStateNormal];
        [_sendButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        __weak typeof(self) weakSelf = self;
        
        [_sendButton controlEvents:UIControlEventTouchUpInside handle:^(UIControl * _Nonnull sender) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            
            ((void(*)(id,SEL,id))objc_msgSend)(strongSelf.viewModel,NSSelectorFromString(@"photoDidSelectedComplete:"),strongSelf.collectionView);
            
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
        _numberOfLabel.textAlignment = NSTextAlignmentCenter;
        _numberOfLabel.font = [UIFont boldSystemFontOfSize:14];
        _numberOfLabel.text = @"9";
        _numberOfLabel.backgroundColor = UIColorFromRGB(0x2dd58a);
        _numberOfLabel.textColor = [UIColor whiteColor];
        _numberOfLabel.layer.cornerRadius = _numberOfLabel.width / 2.0;
        _numberOfLabel.clipsToBounds = true;
        
        _numberOfLabel.hidden = true;
    }
    
    return _numberOfLabel;
}


#pragma mark - ViewModel

-(id<RITLCollectionViewModel>)viewModel
{
    if (!_viewModel)
    {
        _viewModel = [PhotoBrowseViewModel new];
    }
    
    return _viewModel;
}


/// 绑定viewModel
- (void)bindViewModel
{
    if ([self.viewModel isMemberOfClass:[PhotoBrowseViewModel class]])
    {
        PhotoBrowseViewModel * viewModel = self.viewModel;
        
        __weak typeof(self) weakSelf = self;
        
        // 显示清晰图的回调
        viewModel.ritl_BrowerCellShouldRefreshBlock = ^(UIImage * image,PHAsset * asset,NSIndexPath * indexPath){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            PhotoBrowseCell * cell = (PhotoBrowseCell *)[strongSelf.collectionView cellForItemAtIndexPath:indexPath];
    
            
//            [UIView animateWithDuration:0.5 delay:0. options:UIViewAnimationOptionCurveLinear animations:^{
//
//                cell.imageView.image = image;
//
//            } completion:nil];
        };
   
        // 刷新选中按钮状态
        viewModel.ritl_BrowerSelectedBtnShouldRefreshBlock = ^(UIImage * image){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf.selectButtonItem setImage:image forState:UIControlStateNormal];
        };
        
        
        // 弹出警告提示框
        viewModel.warningBlock = ^(BOOL result,NSUInteger maxCount){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf presentAlertController:maxCount];
        };
        
        // 模态弹出
        viewModel.dismissBlock = ^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf dismissViewController];
            
        };
        
        // 显示选择的数量
        viewModel.ritl_BrowerSendStatusChangedBlock = ^(BOOL hiddenNumberLabel,NSUInteger count){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf updateNumbersForSelectAssets:count];
        };
        
        
        // 设置barView的hidden
        viewModel.ritl_BrowerBarHiddenStatusChangedBlock = ^(BOOL hidden){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            strongSelf.topBar.hidden = hidden;
            strongSelf.bottomBar.hidden = hidden;
            
        };
        
        
        
        // hight quarity
        viewModel.ritl_browerQuarityChangedBlock = ^(BOOL isHightQuarity){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf updateSizeLabelForIsHightQuarity:isHightQuarity];
        };
        
        
        viewModel.ritl_browerRequestQuarityBlock = ^(BOOL result,NSString * selectorName){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            ((void(*)(id,SEL))objc_msgSend)(strongSelf.activityIndicatorView,NSSelectorFromString(selectorName));
            
            strongSelf.photoSizeLabel.hidden = result;
        };
        
        
        viewModel.ritl_browerQuarityCompleteBlock = ^(NSString * imageSize){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            strongSelf.photoSizeLabel.text = imageSize;
            
        };
        
    }
}

-(void)dismissViewController
{
    return [super dismissViewControllerAnimated:true completion:nil];
}




#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel numberOfItemsInSection:section];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoBrowseCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if ([self.viewModel isMemberOfClass:[PhotoBrowseViewModel class]])
    {
        PhotoBrowseViewModel * viewModel = self.viewModel;
        
        
        [viewModel imageForIndexPath:indexPath collection:collectionView isThumb:false complete:^(UIImage * _Nonnull image, PHAsset * _Nonnull asset) {
            
            cell.imageView.image = image;
            
        }];
        
        
        
        
        cell.ritl_PhotoBrowerSimpleTapHandleBlock = ^(PhotoBrowseCell * cell){
            
            [viewModel sendViewBarDidChangedSignal];
            
        };
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel sizeForItemAtIndexPath:indexPath inCollection:collectionView];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [self.viewModel minimumInteritemSpacingForSectionAtIndex:section];
}


#pragma mark - UICollectionDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    Nothing..
    printf("didEndDisplayingCell\n");
//        [self.viewModel didEndDisplayingCellForItemAtIndexPath:indexPath];
}




#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [(PhotoBrowseViewModel *)self.viewModel viewModelScrollViewDidEndDecelerating:scrollView];
}

@end


@implementation PhotoBrowseController (UpdateNumberOfLabel)

-(void)updateNumbersForSelectAssets:(NSUInteger)number
{
    BOOL hidden = (number == 0);
    
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


@implementation PhotoBrowseController (UpdateSizeLabel)

-(void)updateSizeLabelForIsHightQuarity:(BOOL)isHightQuarity
{
    if (isHightQuarity)//如果是高清状态
    {
        //
        [self ritlChangeToHightQualityStatus];
        
    }
    
    else //如果不是高清状态
    {
        [self ritlChangeToThumiStatus];
    }
}



/**
 变为高清状态
 */
- (void)ritlChangeToHightQualityStatus
{
    UIColor * currentColor = PhotoBrowerSelectedColor;
    
    self.hignSignImageView.backgroundColor = currentColor;
    
    self.originPhotoLabel.textColor = [UIColor whiteColor];
    self.photoSizeLabel.textColor = [UIColor whiteColor];
    
    NSLog(@"高清图!");
}


/**
 变为缩略状态
 */
- (void)ritlChangeToThumiStatus
{
    UIColor * currentColor = PhotoBrowerDeselectedColor;
    
    self.hignSignImageView.backgroundColor = currentColor;
    self.originPhotoLabel.textColor = currentColor;
    self.photoSizeLabel.textColor = currentColor;
    [self.activityIndicatorView stopAnimating];
    self.photoSizeLabel.text = @"";
    
}

@end

