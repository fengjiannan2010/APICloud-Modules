/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoNavigationViewController.h"
#import "PhotoNavigationViewModel.h"
#import "PhotoGroupViewController.h"
#import "PhotoGroupViewModel.h"
#import "PhotosViewController.h"
@interface PhotoNavigationViewController ()


@end

@implementation PhotoNavigationViewController

- (instancetype)initWithViewModel:(id <RITLPublicViewModel>)viewModel{
    if (self = [super init])
    {
        _viewModel = viewModel;
    }
    return self;
}

+ (instancetype)photosViewModelInstance:(id <RITLPublicViewModel>)viewModel{
    
    return [[self alloc] initWithViewModel:viewModel];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //分组
   PhotoGroupViewController *pgVC =  [[PhotoGroupViewController alloc]init];
   pgVC.paramsDict = self.viewModel.paramsDict;
   self.viewControllers = @[pgVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    if (self.isRotation) {
        return YES;
    } else {
        return NO;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.isRotation) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
#pragma mark -

- (id <RITLPublicViewModel>)viewModel
{
    if (!_viewModel)
    {
        _viewModel = [PhotoNavigationViewModel new];
    }
    
    return _viewModel;
}

@end
