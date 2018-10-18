/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoGroupViewController.h"
#import "PhotoGroupViewModel.h"
#import "PhotoGroupCell.h"
#import "PhotosViewController.h"
#import "PhotosViewModel.h"
#import <objc/message.h>
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"
#import "PhotoCacheManager.h"

static NSString * cellIdentifier = @"PhotoGroupCell";

@interface PhotoGroupViewController ()

@end

@implementation PhotoGroupViewController

- (instancetype)initWithViewModel:(id <RITLTableViewModel>)viewModel{
    if (self = [super init])
    {
        _viewModel = viewModel;
    }
    return self;
}

+ (instancetype)photosViewModelInstance:(id <RITLTableViewModel>)viewModel{
    
    return  [[self alloc] initWithViewModel:viewModel];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self extensionTableView];
    [self extensionNavigation];
    [self bindViewModel];
    //开始获取相片
    ((void(*)(id,SEL))objc_msgSend)(self.viewModel,@selector(fetchDefaultGroups));
}

/// 设置tableView的拓展属性
- (void)extensionTableView{
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView registerClass:[PhotoGroupCell class] forCellReuseIdentifier:cellIdentifier];
}

/// 设置导航栏属性
- (void)extensionNavigation{
    self.navigationItem.title = self.viewModel.title;
    //设置导航条颜色 导航栏颜色
    NSDictionary *stylesDict = [self.paramsDict dictValueForKey:@"styles" defaultValue:nil];
    NSDictionary *navSet = [stylesDict dictValueForKey:@"nav" defaultValue:nil];
    NSString *navBg = [navSet stringValueForKey:@"bg" defaultValue:@"rgba(0,0,0,0.6)"];
    NSString *navTitleColor = [navSet stringValueForKey:@"titleColor" defaultValue:@"#fff"];
    NSString *cancleColor = [navSet stringValueForKey:@"cancelColor" defaultValue:@"#fff"];
    CGFloat titleSize = [navSet floatValueForKey:@"titleSize" defaultValue:18];
    CGFloat cancelSize = [navSet floatValueForKey:@"cancelSize" defaultValue:16];
    self.navigationController.navigationBar.barTintColor = [UZAppUtils colorFromNSString:navBg];
    self.navigationController.navigationBar.tintColor = [UZAppUtils colorFromNSString:cancleColor];
    //修改导航栏标题颜色,文字大小,文字种类
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:titleSize],NSForegroundColorAttributeName:[UZAppUtils colorFromNSString:navTitleColor]}];
    // 回归到viewModel
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self.viewModel action:@selector(dismissGroupController)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:cancelSize], NSFontAttributeName, nil] forState:UIControlStateNormal];
}

/// 绑定viewModel
- (void)bindViewModel{
    __weak typeof(self) weakSelf = self;
    
    if ([self.viewModel isMemberOfClass:[PhotoGroupViewModel class]])
    {
        
        PhotoGroupViewModel * viewModel = self.viewModel;
        
        viewModel.dismissGroupBlock = ^(){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf dismissViewControllerAnimated:true completion:^{}];
            
        };
        
        viewModel.fetchGroupsBlock = ^(NSArray * groups){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.tableView reloadData];

            // 跳入第一个
            BOOL classify = [self.paramsDict boolValueForKey:@"classify" defaultValue:true];
            if (classify == true) {
            }else{
            [strongSelf ritlTableView:strongSelf.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] Animated:false];
            }
          
        };
        
        viewModel.selectedBlock = ^(PHAssetCollection * colletion,NSIndexPath * indexPath,BOOL animate){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            PhotosViewModel * viewModel = [PhotosViewModel new];
            
            //设置标题
            viewModel.navigationTitle = colletion.localizedTitle;
            
            //设置数据源
            viewModel.assetCollection = colletion;
            
            viewModel.paramsDict = strongSelf.paramsDict;
            
            PhotosViewController *pVC = [PhotosViewController photosViewModelInstance:viewModel];
        
            [PhotoCacheManager sharedInstace].numberOfSelectedPhoto = 0;
            //弹出控制器
            [strongSelf.navigationController pushViewController:pVC animated:animate];
        };
    }
}

- (IBAction)cancleItemButtonDidTap:(id)sender{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)dealloc
{
    //        self.groups = nil;
#ifdef RITLDebug
    NSLog(@"Dealloc %@",NSStringFromClass([self class]));
#endif
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    
    return self.viewModel.numberOfGroup;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.viewModel numberOfRowInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PhotoGroupCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PhotoGroupCell class]) forIndexPath:indexPath];
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    //设置
    [(PhotoGroupViewModel *)self.viewModel loadGroupTitleImage:indexPath complete:^(id _Nonnull title, id _Nonnull image, id _Nonnull appendTitle, NSUInteger count) {
        
        
        
        cell.titleLabel.text = appendTitle;
        cell.imageView.image = image;
        
    }];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //消除选择痕迹
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    //    [self.viewModel didSelectRowAtIndexPath:indexPath];
    [self ritlTableView:tableView didSelectRowAtIndexPath:indexPath Animated:true];
    
}

- (void)ritlTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath Animated:(BOOL)animated{
    //进行viewModel转换
    [((PhotoGroupViewModel *)self.viewModel) ritl_didSelectRowAtIndexPath:indexPath animated:animated];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.viewModel heightForRowAtIndexPath:indexPath];
}
#pragma mark -

-(id <RITLTableViewModel>)viewModel{
    if (!_viewModel)
    {
        _viewModel = [PhotoGroupViewModel new];
    }
    
    return _viewModel;
}
@end
