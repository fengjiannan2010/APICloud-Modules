//
//  NavView.m
//  photoDemo
//
//  Created by wangxinxu on 2017/6/6.
//  Copyright © 2017年 wangxinxu. All rights reserved.
//

#import "NavView.h"
#import "UZAlbumSingleton.h"
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"
#import <Photos/Photos.h>
#import "Masonry.h"
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

@implementation NavView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self createNavViewTitle:WPhoto_Center_Text];
        
    }
    return self;
}
#pragma mark 创建nav
-(void)createNavViewTitle:(NSString *)title {
    
    NSDictionary *navgationDict = UZAlbumSingleton.sharedSingleton.navInfo;
    NSString *navBackgroudColor =[navgationDict stringValueForKey:@"bg" defaultValue:@"rgba(0,0,0,0.6)"];
    NSString *cancelColor = [navgationDict stringValueForKey:@"cancelColor" defaultValue:@"#fff"];
    CGFloat cancleSize = [navgationDict floatValueForKey:@"cancelSize" defaultValue:18];
    NSString *nextStepColor = [navgationDict stringValueForKey:@"nextStepColor" defaultValue:@"#fff"];
    CGFloat nextStepSize = [navgationDict floatValueForKey:@"nextStepSize" defaultValue:18];
    UIView *nav = [[UIView alloc]init];
    if (iPhoneX) {
      
        UIView *blackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SelfView_W , 44)];
        blackView.backgroundColor =  [UZAppUtils colorFromNSString:navBackgroudColor];
        [self addSubview:blackView];
        nav.frame = CGRectMake(0, 44, SelfView_W, 44);
    }else{
        nav.frame = CGRectMake(0, 0, SelfView_W, navView_H);

    }
    nav.backgroundColor = [UZAppUtils colorFromNSString:navBackgroudColor];
    [self addSubview:nav];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 80, navView_H-20)];
    titleLab.text = title;
    titleLab.font = [UIFont systemFontOfSize:36/2];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = WPhoto_TopText_Color;
    [nav addSubview:titleLab];
    
 
    
    titleLab.center = CGPointMake(nav.center.x, (navView_H-20)/2+20);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
   // btn.frame= CGRectMake(10, 0, 50, 25);
    [btn addTarget:self action:@selector(btnClickBack) forControlEvents:UIControlEventTouchUpInside];
//    [btn setImage:[[UIImage imageNamed:@"res_UIAlbumBrowser/wphoto_back@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UZAppUtils colorFromNSString:cancelColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:cancleSize];
    [nav addSubview:btn];
    
    if (iPhoneX) {
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.width.mas_equalTo(50);
            make.centerY.equalTo(nav.mas_centerY).offset(0);
        }];
    }else{
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.width.mas_equalTo(50);
            make.top.mas_equalTo(25);
        }];
    }

    //btn.center = CGPointMake(25, titleLab.center.y);
    
    UIButton *rightItem = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightItem.frame= CGRectMake(SelfView_W-60, 0, 60, 25);
//    rightItem.center = CGPointMake(SelfView_W-35, titleLab.center.y);
    [rightItem addTarget:self action:@selector(quitChoose)forControlEvents:UIControlEventTouchUpInside];
    rightItem.titleLabel.font = [UIFont systemFontOfSize:nextStepSize];
    [rightItem setTitleColor:[UZAppUtils colorFromNSString:nextStepColor] forState:UIControlStateNormal];
    [rightItem setTitle:WPhoto_Right_Text forState:UIControlStateNormal];
    [nav addSubview:rightItem];
    if (iPhoneX) {
        [rightItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.width.mas_equalTo(60);
            make.centerY.equalTo(nav.mas_centerY).offset(0);
        }];
    }else{
        [rightItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.width.mas_equalTo(60);
            make.top.mas_equalTo(25);
        }];
    }

}



-(void)btnClickBack
{
    _navViewBack();
}

-(void)quitChoose
{
    _quitChooseBack();
}


@end
