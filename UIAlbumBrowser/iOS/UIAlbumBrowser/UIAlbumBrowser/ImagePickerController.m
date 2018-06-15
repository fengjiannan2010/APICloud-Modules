//
//  ImagePickerController.m
//  UIAlbumBrowser
//
//  Created by wei on 2017/8/28.
//  Copyright © 2017年 wei. All rights reserved.
//

#import "ImagePickerController.h"
#import "WPhotoViewController.h"
#define phoneScale [UIScreen mainScreen].bounds.size.width/720.0

@interface ImagePickerController ()<UITableViewDelegate, UITableViewDataSource>
{
    UIButton *_addBut;
    UITableView *_tableView;
    NSMutableArray *_photosArr;
}


@end

@implementation ImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     [self createTableView];
    
    _addBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _addBut.frame = CGRectMake((self.view.frame.size.width-160*phoneScale)/2, self.view.frame.size.height-(60+160)*phoneScale, 160*phoneScale, 160*phoneScale);
    _addBut.layer.cornerRadius = 160*phoneScale/2;
    _addBut.layer.masksToBounds = YES;
    [_addBut setImage:[UIImage imageNamed:@"res_UIAlbumBrowser/1.2.1-CreateNew.png"] forState:UIControlStateNormal];
    [_addBut addTarget:self action:@selector(addButClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addBut];
    
    

    // Do any additional setup after loading the view.
}

-(void)addButClick
{
    WPhotoViewController *WphotoVC = [[WPhotoViewController alloc] init];
    //选择图片的最大数
    WphotoVC.selectPhotoOfMax = 8;
    [WphotoVC setSelectPhotosBack:^(NSMutableArray *phostsArr) {
        _photosArr = phostsArr;
        [_tableView reloadData];
    }];
    [self presentViewController:WphotoVC animated:YES completion:nil];
}

-(void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _photosArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = [NSString stringWithFormat:@"cellId%ld", (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat photoSize = [UIScreen mainScreen].bounds.size.width - 20;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(10, 10, photoSize, photoSize);
    imageView.image = [[_photosArr objectAtIndex:indexPath.row] objectForKey:@"image"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    [cell addSubview:imageView];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIScreen mainScreen].bounds.size.width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
