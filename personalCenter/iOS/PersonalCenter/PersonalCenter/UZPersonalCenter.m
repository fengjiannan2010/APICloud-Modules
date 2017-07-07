/**
 * APICloud Modules
 * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "UZPersonalCenter.h"
#import "UZAppUtils.h"
#import "UIImageView+LBBlurredImage.h"
#import "PAImageView.h"
#import "NSDictionaryUtils.h"
#import "ZASyncURLConnection.h"
#import "DKLiveBlurView.h"

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define mainBoarde 987
#define usernameLabel 986
#define usercountLabel 985
#define leftModBtn 984
#define rightSetBtn 983
#define collectionSet 982
#define browseSet 981
#define downLoadSet 980
#define activitySet 979

@interface UZPersonalCenter() {
    BOOL showLeft, showRight, showModButton;
    UIView *_mainBoard;
    NSInteger currentButtonIndex, openCbid;
    NSArray *_dataSource;
}

@property (nonatomic, strong) UIView *mainBoard;
@property (nonatomic, retain) DKLiveBlurView *backGround;
@property (nonatomic, retain) NSMutableData *recivedData;
@property (nonatomic, retain) NSMutableURLRequest *requests;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation UZPersonalCenter

@synthesize backGround;
@synthesize recivedData;
@synthesize requests;
@synthesize mainBoard = _mainBoard;
@synthesize dataSource = _dataSource;

#pragma mark - lifeCycle -

- (void)dispose {
    if (openCbid >= 0) {
        [self deleteCallback:openCbid];
    }
    if (backGround) {
        self.backGround = nil;
    }
    [self close:nil];
    if (recivedData) {
        self.recivedData = nil;
    }
    if (requests) {
        self.requests = nil;
    }
    if (_mainBoard) {
        [_mainBoard removeFromSuperview];
        self.mainBoard = nil;
    }
    if (_dataSource) {
        self.dataSource = nil;
    }
}

#pragma mark-
#pragma mark interface
#pragma mark-

- (void)close:(NSDictionary *)paramsDict {
    if (_mainBoard) {
        NSArray *views = [_mainBoard subviews];
        for (UIView  *temp in views) {
            [temp removeFromSuperview];
        }
        [_mainBoard removeFromSuperview];
        self.mainBoard = nil;
    }
}

- (void)open:(NSDictionary *)paramsDict {
    if (_mainBoard) {
        [[_mainBoard superview] bringSubviewToFront:_mainBoard];
        _mainBoard.hidden = NO;
        return;
    }
    openCbid = [paramsDict integerValueForKey:@"cbId" defaultValue:-1];
    BOOL clearBtn = [paramsDict boolValueForKey:@"clearBtn" defaultValue:NO];
    float  x = 0;
    float y = [paramsDict floatValueForKey:@"y" defaultValue:0];
    float height ;
    if ([paramsDict objectForKey:@"h"]){
        height = [paramsDict floatValueForKey:@"h" defaultValue:220];
    } else if ([paramsDict objectForKey:@"height"]) {
        height = [paramsDict floatValueForKey:@"height" defaultValue:220];
    } else {
        height = 220;
    }
    float width  = [UIScreen mainScreen].bounds.size.width;
    float mainScreenHeight = [UIScreen mainScreen].bounds.size.height;
    if (isPad) {
        if (height < 400) {
            height = 400;
        }
    } else {
        if (height < 220) {
            height = 220;
        }
        if (width>320 && height<260) {
            height = 260;
        }
    }
    if (height > mainScreenHeight-64) {
        height = mainScreenHeight - 64;
    }
    NSString *userColor = [paramsDict stringValueForKey:@"userColor" defaultValue:@"#FFFFFF"];
    NSString *imgPath = [paramsDict objectForKey:@"imgPath"];
    NSString *placehoderImgStr = nil;
    if ([paramsDict objectForKey:@"placeholderImg"]) {
        placehoderImgStr = [paramsDict stringValueForKey:@"placeholderImg" defaultValue:nil];
    } else if ([paramsDict objectForKey:@"placeHoldImg"]){
        placehoderImgStr = [paramsDict stringValueForKey:@"placeHoldImg" defaultValue:nil];
    } else {
        placehoderImgStr = [[NSBundle mainBundle]pathForResource:@"res_personalCenter/placeholder" ofType:@"jpg"];
    }
    NSString *realImgPath = [self getPathWithUZSchemeURL:placehoderImgStr];
    if (imgPath.length>0 && [imgPath isKindOfClass:[NSString class]] && ![imgPath hasPrefix:@"http"]) {
        realImgPath = [self getPathWithUZSchemeURL:imgPath];
        imgPath = nil;
    }
    if (imgPath.length>0 && [imgPath isKindOfClass:[NSString class]]) {
         //缓存
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentPath = [UZAppUtils appDocumentPath];
        NSString *cachPath = [documentPath stringByAppendingString:@"/cacheHeadIMG"];
        if (![fileManager fileExistsAtPath:cachPath isDirectory:nil]) {
            [fileManager createDirectoryAtPath:cachPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSArray *pathes = [self subFilePath:imgPath];
        NSString *name = [pathes objectAtIndex:1];
        NSString *suffix = [pathes objectAtIndex:2];
        NSString *cachImgPath = [cachPath stringByAppendingFormat:@"/%@.%@",name,suffix];
        if ([fileManager fileExistsAtPath:cachImgPath]) {
            realImgPath = cachImgPath;
        } else {
           [self getTokenAsynchronous:imgPath andSecret:nil];
        }
    }
    NSString *fixedOn = [paramsDict stringValueForKey:@"fixedOn" defaultValue:nil];
    BOOL fixed = [paramsDict boolValueForKey:@"fixed" defaultValue:YES];
    _mainBoard = [[UIView alloc]initWithFrame:CGRectMake(x, y, width, height)];
    [self addSubview:_mainBoard fixedOn:fixedOn fixed:fixed];
    //模糊背景图片
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        UIImageView *backGrounde = [[UIImageView alloc]init];
        backGrounde.frame = CGRectMake(0, 0, width, height);
        backGrounde.tag = 6786;
        backGrounde.image = [UIImage imageWithContentsOfFile:realImgPath];
        [_mainBoard addSubview:backGrounde];
        [backGrounde setImageToBlur:[UIImage imageWithContentsOfFile:realImgPath] blurRadius:8.0 completionBlock:nil];
    } else {
        backGround = [[DKLiveBlurView alloc]init];
        backGround.frame = CGRectMake(0, 0, width, height);
        backGround.originalImage = [UIImage imageWithContentsOfFile:realImgPath];
        [_mainBoard addSubview:backGround];
        [backGround setBlurLevel:1];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(change) userInfo:nil repeats:NO];
    }
    showLeft = [paramsDict boolValueForKey:@"showLeftBtn" defaultValue:YES ];
    showRight = [paramsDict boolValueForKey:@"showRightBtn" defaultValue:YES];
    NSDictionary *buttonTitleDict = [paramsDict dictValueForKey:@"buttonTitle" defaultValue:@{}];
    NSString *leftTitle = [buttonTitleDict stringValueForKey:@"left" defaultValue:@"修改"];
    NSString *rightTitle = [buttonTitleDict stringValueForKey:@"right" defaultValue:@"设置"];
    UILabel *modLabeltemp = [[UILabel alloc]init];
    CGSize leftSize = [leftTitle sizeWithAttributes:@{NSFontAttributeName : modLabeltemp.font}];
    CGSize rightSize = [rightTitle sizeWithAttributes:@{NSFontAttributeName : modLabeltemp.font}];
    CGSize standSize = [@"修改" sizeWithAttributes:@{NSFontAttributeName : modLabeltemp.font}];
    float leftChargeSize = 0;
    float rightChargeSize = 0;
    if (leftSize.width-standSize.width > 0) {
        leftChargeSize = leftSize.width-standSize.width;
    }
    if (rightSize.width-standSize.width > 0) {
        rightChargeSize = rightSize.width-standSize.width;
    }
    float chargeSeze = (leftChargeSize>rightChargeSize)?leftChargeSize:rightChargeSize;
    float leftMody = (10.0/440.0)*height;
    //左按钮
    UIButton *leftMod = [[UIButton alloc]init];
    leftMod.tag = leftModBtn;
    leftMod.frame = CGRectMake(15, leftMody, 80+chargeSeze, 23);
    NSString *leftPaht =[[NSBundle mainBundle]pathForResource:@"res_personalCenter/set_nomal" ofType:@"png"];
    [leftMod setImage:[UIImage imageWithContentsOfFile:leftPaht] forState:UIControlStateNormal];
    NSString *leftPath =[[NSBundle mainBundle]pathForResource:@"res_personalCenter/set_select" ofType:@"png"];
    [leftMod setImage:[UIImage imageWithContentsOfFile:leftPath] forState:UIControlStateSelected];
    [leftMod addTarget:self action:@selector(leftMod:) forControlEvents:UIControlEventTouchUpInside];
    [_mainBoard addSubview:leftMod];
    UIImageView *leftModimg = [[UIImageView alloc]init];
    leftModimg.frame = CGRectMake(12, 2.5, 18, 18);
    NSString *lftModimgPath = [[NSBundle mainBundle]pathForResource:@"res_personalCenter/mod"ofType:@"png"];
    leftModimg.image = [UIImage imageWithContentsOfFile:lftModimgPath];
    [leftMod addSubview:leftModimg];
    UILabel *modLabel = [[UILabel alloc]init];
    modLabel.frame = CGRectMake(35, 2.5, 45+chargeSeze, 18);
    [leftMod addSubview:modLabel];
    modLabel.text = leftTitle;
    modLabel.textColor = [UIColor whiteColor];
    modLabel.backgroundColor = [UIColor clearColor];
    //右按钮
    UIButton *rightMod = [[UIButton alloc]init];
    rightMod.tag = rightSetBtn;
    rightMod.frame = CGRectMake(width-80-15-chargeSeze, leftMody, 80+chargeSeze, 23);
    NSString *rightPaht =[[NSBundle mainBundle]pathForResource:@"res_personalCenter/set_nomal" ofType:@"png"];
    [rightMod setImage:[UIImage imageWithContentsOfFile:rightPaht] forState:UIControlStateNormal];
    NSString *rightPath =[[NSBundle mainBundle]pathForResource:@"res_personalCenter/set_select" ofType:@"png"];
    [rightMod setImage:[UIImage imageWithContentsOfFile:rightPath] forState:UIControlStateSelected];
    [rightMod addTarget:self action:@selector(rightSet:) forControlEvents:UIControlEventTouchUpInside];
    [_mainBoard addSubview:rightMod];
    UIImageView *rightModimg = [[UIImageView alloc]init];
    rightModimg.frame = CGRectMake(12, 2.5, 18, 18);
    NSString *rightModimgPath = [[NSBundle mainBundle]pathForResource:@"res_personalCenter/set"ofType:@"png"];
    rightModimg.image = [UIImage imageWithContentsOfFile:rightModimgPath];
    [rightMod addSubview:rightModimg];
    UILabel *setLabel = [[UILabel alloc]init];
    setLabel.frame = CGRectMake(35, 2.5, 45+chargeSeze, 18);
    [rightMod addSubview:setLabel];
    setLabel.text = rightTitle;
    setLabel.textColor = [UIColor whiteColor];
    setLabel.backgroundColor = [UIColor clearColor];
    if (showLeft) {
        leftMod.hidden = NO;
    } else {
        leftMod.hidden = YES;
    }
    if (showRight) {
        rightMod.hidden = NO;
    } else {
        rightMod.hidden=YES;
    }
   
    //头像
    float headImgWidth  = (200.0/640)*width;
    float headY = (10.0/160.0)*headImgWidth;
    PAImageView *avaterImageView = [[PAImageView alloc]initWithFrame:CGRectMake((width-headImgWidth)/2, headY, headImgWidth, headImgWidth) backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
    avaterImageView.tag = 6787;
    [_mainBoard addSubview:avaterImageView];
    [avaterImageView setImageURL:realImgPath];
    _dataSource = [paramsDict arrayValueForKey:@"btnArray" defaultValue:nil];
    if (_dataSource) {
        NSDictionary *modButtonInfo = [paramsDict dictValueForKey:@"modButton" defaultValue:nil];
        if (modButtonInfo) {
            showModButton = YES;
            NSString *btnNormalImg = [modButtonInfo stringValueForKey:@"bgImg" defaultValue:nil];
            NSString *btnHighlightImg = [modButtonInfo stringValueForKey:@"lightImg" defaultValue:nil];
            if (btnNormalImg) {
                btnNormalImg = [self getPathWithUZSchemeURL:btnNormalImg];
            }
            if (btnHighlightImg) {
                btnHighlightImg = [self getPathWithUZSchemeURL:btnHighlightImg];
            }
            //头像修改按钮
            UIButton *modperson = [[UIButton alloc]init];
            modperson.frame = CGRectMake(avaterImageView.frame.origin.x + avaterImageView.bounds.size.width-35, avaterImageView.frame.origin.y + avaterImageView.bounds.size.height-35, 42, 42);
            [modperson addTarget:self action:@selector(modpersonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [modperson setImage:[UIImage imageWithContentsOfFile:btnNormalImg] forState:UIControlStateNormal];
            [modperson setImage:[UIImage imageWithContentsOfFile:btnHighlightImg] forState:UIControlStateHighlighted];
            [_mainBoard addSubview:modperson];
        }
    } else {
        //头像修改按钮
        UIImageView *modHeadImg = [[UIImageView alloc]init];
        modHeadImg.frame = CGRectMake(avaterImageView.frame.origin.x + avaterImageView.bounds.size.width-25, avaterImageView.frame.origin.y + avaterImageView.bounds.size.height-25, 21, 21);
        NSString * modpersonPath =[[NSBundle mainBundle]pathForResource:@"res_personalCenter/mod_person" ofType:@"png"];
        modHeadImg.image = [UIImage imageWithContentsOfFile:modpersonPath];
        [_mainBoard addSubview:modHeadImg];
        UIButton *modperson = [[UIButton alloc]init];
        modperson.frame = CGRectMake(avaterImageView.frame.origin.x + avaterImageView.bounds.size.width-42, avaterImageView.frame.origin.y + avaterImageView.bounds.size.height-42, 42, 42);
        [modperson addTarget:self action:@selector(modpersonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_mainBoard addSubview:modperson];
    }
    NSString *usernameStr= nil;
    if ([paramsDict objectForKey:@"userName"]) {
        usernameStr = [paramsDict stringValueForKey:@"userName" defaultValue:nil];
    } else if ([paramsDict objectForKey:@"username"]){
        usernameStr = [paramsDict stringValueForKey:@"username" defaultValue:nil];
    } else {
        usernameStr = @"username";
    }
    if (usernameStr==nil) {
        usernameStr = @"";
    }
    float userNameSize = [paramsDict floatValueForKey:@"userNameSize" defaultValue:13.0];
    NSString *countStr = [paramsDict stringValueForKey:@"subTitle" defaultValue:@""];
    float subTitleSize = [paramsDict floatValueForKey:@"subTitleSize" defaultValue:13.0];
    NSString *subTitleColor = [paramsDict stringValueForKey:@"subTitleColor" defaultValue:@"#FFFFFF"];
    //用户名
    UILabel *username = [[UILabel alloc]init];
    username.frame = CGRectMake(0, headY+headImgWidth+10, width, 18);
    [_mainBoard addSubview:username];
    username.text = usernameStr;
    username.tag = usernameLabel;
    username.font = [UIFont systemFontOfSize:userNameSize];
    username.textColor = [UZAppUtils colorFromNSString:userColor];
    username.textAlignment = UITextAlignmentCenter;
    username.backgroundColor = [UIColor clearColor];
    //积分
    UILabel *countLabel = [[UILabel alloc]init];
    countLabel.frame = CGRectMake(0, username.frame.origin.y+20, width, 18);
    [_mainBoard addSubview:countLabel];
    countLabel.text = countStr;
    countLabel.font = [UIFont systemFontOfSize:subTitleSize];
    countLabel.tag = usercountLabel;
    countLabel.textAlignment = UITextAlignmentCenter;
    countLabel.textColor = [UZAppUtils colorFromNSString:subTitleColor];
    countLabel.backgroundColor = [UIColor clearColor];
    if (_dataSource) {
        if (!clearBtn) {
            [self addButtonAtView];
        }
    } else {
        //下栏详情参数
        float backImgHeight = (309.0/440.0)*height;
        UIView *details = [[UIView alloc]initWithFrame:CGRectMake(0, backImgHeight, width, height-backImgHeight)];
        details.backgroundColor = [UIColor clearColor];
        details.alpha = 0.8;
        if (!clearBtn) {
            [_mainBoard addSubview:details];
        }
        float lineHeight = details.frame.size.height-20;
        float  buttonWidt = width/4;
        for (int i=0; i<4; i++) {
            UIButton *detailBtn = [[UIButton alloc]init];
            detailBtn.tag = i;
            detailBtn.frame = CGRectMake(buttonWidt*i, 0, buttonWidt, height-backImgHeight);
            NSString *leftPaht =[[NSBundle mainBundle]pathForResource:@"res_personalCenter/count_nomal" ofType:@"png"];
            [detailBtn setImage:[UIImage imageWithContentsOfFile:leftPaht] forState:UIControlStateNormal];
            NSString *leftPath =[[NSBundle mainBundle]pathForResource:@"res_personalCenter/count_select" ofType:@"png"];
            [detailBtn setImage:[UIImage imageWithContentsOfFile:leftPath] forState:UIControlStateSelected];
            [detailBtn addTarget:self action:@selector(detailsClicked:) forControlEvents:UIControlEventTouchUpInside];
            [details addSubview:detailBtn];
            
            UILabel *state = [[UILabel alloc]init];
            state.frame = CGRectMake((detailBtn.frame.size.width-45)/2+8, detailBtn.frame.size.height-30 , 45, 18);
            [detailBtn addSubview:state];
            switch (i) {
                case 0:
                    state.text = @"收藏";
                    break;
                    
                case 1:
                    state.text = @"浏览";
                    break;
                    
                case 2:
                    state.text = @"下载";
                    break;
                    
                case 3:
                    state.text = @"活动";
                    break;
                    
                default:
                    state.text = @"活动";
                    break;
            }
            state.textColor = [UIColor whiteColor];
            state.font = [UIFont systemFontOfSize:14.0];
            state.backgroundColor = [UIColor clearColor];
        }
        for (int i=0; i<4; i++) {
            UILabel *state = [[UILabel alloc]init];
            state.frame = CGRectMake(buttonWidt*i+5, 10 , buttonWidt-10, details.frame.size.height-33);
            [details addSubview:state];
            state.textColor = [UIColor whiteColor];
            state.font = [UIFont systemFontOfSize:26.0];
            state.text = @"00";
            state.textAlignment = UITextAlignmentCenter;
            state.backgroundColor = [UIColor clearColor];
            switch (i) {
                case 0:
                    state.tag = collectionSet;
                    break;
                    
                case 1:
                    state.tag = browseSet;
                    break;
                    
                case 2:
                    state.tag = downLoadSet;
                    break;
                    
                case 3:
                    state.tag = activitySet;
                    break;
                    
                default:
                    break;
            }
        }
        for (int i=1; i<4; i++) {
            UIImageView *cutLine = [[UIImageView alloc]init];
            cutLine.frame = CGRectMake(buttonWidt*i, 10, 1, lineHeight);
            NSString *lineimgPath = [[NSBundle mainBundle]pathForResource:@"res_personalCenter/cutline" ofType:@"png"];
            cutLine.image = [UIImage imageWithContentsOfFile:lineimgPath];
            [details addSubview:cutLine];
        }
        [self updateData:paramsDict];
    }
}

- (void)updateValue:(NSDictionary *)paramDict {
    NSString * imgPath = [paramDict objectForKey:@"imgPath"];
    NSString * realImgPath = [self getPathWithUZSchemeURL:[paramDict objectForKey:@"placeHoldImg"]];
    if (imgPath.length>0 && [imgPath isKindOfClass:[NSString class]]) {
        if (![imgPath hasPrefix:@"http"]) {
            realImgPath = [self getPathWithUZSchemeURL:imgPath];
            imgPath = nil;
            [self updateHeadImg:realImgPath];
        } else {
            //缓存
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *documentPath = [UZAppUtils appDocumentPath];
            NSString *cachPath = [documentPath stringByAppendingString:@"/cacheHeadIMG"];
            NSArray *pathes = [self subFilePath:imgPath];
            NSString *name = [pathes objectAtIndex:1];
            NSString *suffix = [pathes objectAtIndex:2];
            NSString *cachImgPath = [cachPath stringByAppendingFormat:@"/%@.%@",name,suffix];
            if ([fileManager fileExistsAtPath:cachImgPath]) {
                [self updateHeadImg:cachImgPath];
            } else {
                [self updateHeadImg:realImgPath];
                [self getTokenAsynchronous:imgPath andSecret:nil];
            }
        }
    } else if ([realImgPath isKindOfClass:[NSString class]] && realImgPath.length>0) {
        [self updateHeadImg:realImgPath];
    }
    //更新数据
    [self updateData:paramDict];
}

- (void)setSelect:(NSDictionary *)paramDict {
    int index = 0;
    if ([paramDict objectForKey:@"index"]) {
        index = [[paramDict objectForKey:@"index"]intValue];
    }
    UIButton *tempBtn = (UIButton*)[_mainBoard viewWithTag:300+index];
    if (tempBtn) {
        [self buttonClick:tempBtn];
    }
}

#pragma mark-
#pragma mark button CallBack
#pragma mark-

- (void)modpersonClicked:(UIButton *)btn {
    if (_dataSource) {
        [self sendResultEventWithCallbackId:openCbid dataDict:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:[_dataSource count]] forKey:@"click"] errDict:nil doDelete:NO];
    } else {
        [self sendResultEventWithCallbackId:openCbid dataDict:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"click"] errDict:nil doDelete:NO];
    }
}

- (void)leftMod:(UIButton *)btn {
    if (_dataSource) {
        NSInteger index ;
        if (showModButton) {
            index = [_dataSource count]+1;
        } else {
             index = [_dataSource count];
        }
        [self sendResultEventWithCallbackId:openCbid dataDict:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:index] forKey:@"click"] errDict:nil doDelete:NO];
    } else {
        [self sendResultEventWithCallbackId:openCbid dataDict:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:5] forKey:@"click"] errDict:nil doDelete:NO];
    }
}

- (void)rightSet:(UIButton *)btn {
    if (_dataSource) {
        NSInteger index ;
        if (showModButton && showLeft) {
            index = [_dataSource count]+2;
        } else if((showModButton && !showLeft)||(!showModButton && showLeft)){
            index = [_dataSource count]+1;
        } else {
            index = [_dataSource count];
        }
        [self sendResultEventWithCallbackId:openCbid dataDict:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:index] forKey:@"click"] errDict:nil doDelete:NO];
    } else {
        [self sendResultEventWithCallbackId:openCbid dataDict:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:@"click"] errDict:nil doDelete:NO];
    }
}

- (void)detailsClicked:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
            [self sendResultEventWithCallbackId:openCbid dataDict:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"click"] errDict:nil doDelete:NO];
            break;
            
        case 1:
            [self sendResultEventWithCallbackId:openCbid dataDict:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"click"] errDict:nil doDelete:NO];
            break;
            
        case 2:
            [self sendResultEventWithCallbackId:openCbid dataDict:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:3] forKey:@"click"] errDict:nil doDelete:NO];
            break;
            
        case 3:
            [self sendResultEventWithCallbackId:openCbid dataDict:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:4] forKey:@"click"] errDict:nil doDelete:NO];
            break;
            
        default:
            break;
    }
}

- (void)buttonClick:(UIButton *)btn {
    if (!btn.selected) {
        btn.selected = YES;
        //恢复之前点中的按钮
        UIButton *tempBtn = (UIButton*) [_mainBoard viewWithTag:currentButtonIndex];
        [tempBtn setSelected:NO];
        UILabel *teTitleLabel = (UILabel*)[tempBtn viewWithTag:21];
        UILabel *teCountLabel = (UILabel*)[tempBtn viewWithTag:22];
        NSDictionary *btnTempDict = [_dataSource objectAtIndex:(currentButtonIndex-300)];
        NSString *titleColor = [btnTempDict stringValueForKey:@"titleColor" defaultValue:@"#AAAAAA"];
        NSString *countColor = [btnTempDict stringValueForKey:@"countClor" defaultValue:@"#FFFFFF"];
        teTitleLabel.textColor = [UZAppUtils colorFromNSString:titleColor];
        teCountLabel.textColor = [UZAppUtils colorFromNSString:countColor];
        currentButtonIndex = btn.tag;
        //标识当前点击的按钮
        NSDictionary *btnTempDictC = [_dataSource objectAtIndex:(btn.tag-300)];
        NSString *titleLightColor = [btnTempDictC stringValueForKey:@"titleLightColor" defaultValue:@"#A4D3EE"];
        NSString *countLightColor = [btnTempDictC stringValueForKey:@"countLightColor" defaultValue:@"#A4D3EE"];
        UILabel *teTitleLabelC = (UILabel *)[btn viewWithTag:21];
        UILabel *teCountLabelC = (UILabel *)[btn viewWithTag:22];
        teTitleLabelC.textColor = [UZAppUtils colorFromNSString:titleLightColor];
        teCountLabelC.textColor = [UZAppUtils colorFromNSString:countLightColor];
    }
    [self sendResultEventWithCallbackId:openCbid dataDict:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:(btn.tag-300)] forKey:@"click"] errDict:nil doDelete:NO];
}

#pragma mark-
#pragma mark utils Method
#pragma mark-

- (void)addButtonAtView {
    float backImgHeight = (315.0/440.0)* _mainBoard.frame.size.height;
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float btnWidth = screenWidth/(float)[_dataSource count];
    float btnHeight = _mainBoard.frame.size.height-backImgHeight;
    for (int i = 0; i<[_dataSource count]; i++) {
        NSDictionary *btnInfoDict = [_dataSource objectAtIndex:i];
        NSString *bgImg = [btnInfoDict stringValueForKey:@"bgImg" defaultValue:nil];
        if (bgImg) {
            bgImg = [self getPathWithUZSchemeURL:bgImg];
        }
        NSString *selectedImg = [btnInfoDict stringValueForKey:@"selectedImg" defaultValue:nil];
        if (selectedImg) {
            selectedImg = [self getPathWithUZSchemeURL:selectedImg];
        }
        NSString *lightImg = [btnInfoDict stringValueForKey:@"lightImg" defaultValue:nil];
        if (lightImg) {
            lightImg = [self getPathWithUZSchemeURL:lightImg];
        }
        NSString *title = [btnInfoDict stringValueForKey:@"title" defaultValue:nil];
        NSString *count = [btnInfoDict stringValueForKey:@"count" defaultValue:nil];
        NSString *titleColor = [btnInfoDict stringValueForKey:@"titleColor" defaultValue:@"#AAAAAA"];
        NSString *countColor = [btnInfoDict stringValueForKey:@"countClor" defaultValue:@"#FFFFFF"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(btnWidth*i, backImgHeight, btnWidth, btnHeight);
        [button setImage:[UIImage imageWithContentsOfFile:bgImg] forState:UIControlStateNormal];
        [button setImage:[UIImage imageWithContentsOfFile:lightImg] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageWithContentsOfFile:selectedImg] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 300+i;
        [_mainBoard addSubview:button];
        //添加标题
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.frame = CGRectMake(0, button.frame.size.height-35 , button.frame.size.width, 25);
        [button addSubview:titleLabel];
        titleLabel.text = title;
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UZAppUtils colorFromNSString:titleColor];
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.tag = 21;
        //添加计数
        UILabel *countLabel = [[UILabel alloc]init];
        countLabel.frame = CGRectMake(0, 11 , button.frame.size.width, btnHeight-46);
        [button addSubview:countLabel];
        countLabel.textColor = [UZAppUtils colorFromNSString:countColor];
        countLabel.font = [UIFont systemFontOfSize:26.0];
        countLabel.text = count;
        countLabel.textAlignment = UITextAlignmentCenter;
        countLabel.backgroundColor = [UIColor clearColor];
        countLabel.tag = 22;
    }
    //设置第一个按钮为选中状态
    currentButtonIndex = 300;
    UIButton *tempBtn = (UIButton*) [_mainBoard viewWithTag:currentButtonIndex];
    [tempBtn setSelected:YES];
    UILabel *teTitleLabel = (UILabel*)[tempBtn viewWithTag:21];
    UILabel *teCountLabel = (UILabel*)[tempBtn viewWithTag:22];
    NSDictionary *btnTempDict = [_dataSource objectAtIndex:currentButtonIndex-300];
    NSString *titleLightColor = [btnTempDict stringValueForKey:@"titleLightColor" defaultValue:@"#A4D3EE"];
    NSString *countLightColor = [btnTempDict stringValueForKey:@"countLightColor" defaultValue:@"#A4D3EE"];
    teTitleLabel.textColor = [UZAppUtils colorFromNSString:titleLightColor];
    teCountLabel.textColor = [UZAppUtils colorFromNSString:countLightColor];
    //添加分割线
    for (int i=1; i<[_dataSource count]; i++) {
        UIView * line = [[UIView alloc]init];
        line.frame = CGRectMake(btnWidth*i-0.5, backImgHeight+10, 1, btnHeight-20);
        line.backgroundColor = [UIColor whiteColor];
        [_mainBoard addSubview:line];
    }
}

- (void)updateData:(NSDictionary *)paramsDict {
    NSString *usernameData=nil;
    if ([paramsDict objectForKey:@"userName"]) {
        usernameData = [paramsDict stringValueForKey:@"userName" defaultValue:nil];
    } else if ([paramsDict objectForKey:@"username"]) {
        usernameData = [paramsDict stringValueForKey:@"username" defaultValue:nil];
    }
    NSString *collectData = [paramsDict stringValueForKey:@"collect" defaultValue:nil];
    NSString *browseData = [paramsDict stringValueForKey:@"browse" defaultValue:nil];
    NSString *dwonloadData = [paramsDict stringValueForKey:@"dwonload" defaultValue:nil];
    NSString *activityData = [paramsDict stringValueForKey:@"activity" defaultValue:nil];

    //显示用户名积分
    NSString *countLabelShow = [paramsDict stringValueForKey:@"subTitle" defaultValue:nil];
    if (_mainBoard){
        UILabel *tempName = (UILabel *)[_mainBoard viewWithTag:usernameLabel];
        UILabel *tempCount = (UILabel *)[_mainBoard viewWithTag:usercountLabel];
        if (usernameData) {
            tempName.text = usernameData;
        }
        if (countLabelShow) {
            tempCount.text = countLabelShow;
        }
    }
    NSArray *detailsInfo = [paramsDict arrayValueForKey:@"btnArray" defaultValue:nil];
    if (detailsInfo) {
        for (int i=0; i<[detailsInfo count]; i++) {
            UIButton *tempBTN = (UIButton *)[_mainBoard viewWithTag:(300+i)];
            UILabel *tempCount = (UILabel *)[tempBTN viewWithTag:22];
            tempCount.text = [[detailsInfo objectAtIndex:i]objectForKey:@"count"];
        }
    }else{
        if (collectData) {
            //显示收藏
            UILabel *tempCollect = (UILabel *)[_mainBoard viewWithTag:collectionSet];
            tempCollect.text = collectData;
        }
        if (browseData) {
            //浏览
            UILabel *tempBrowse = (UILabel *)[_mainBoard viewWithTag:browseSet];
            tempBrowse.text = browseData;
        }
        if (dwonloadData) {
            //下载
            UILabel *tempDownlowd = (UILabel *)[_mainBoard viewWithTag:downLoadSet];
            tempDownlowd.text = dwonloadData ;
        }
        if (activityData) {
            //活动
            UILabel *tempactivity= (UILabel *)[_mainBoard viewWithTag:activitySet];
            tempactivity.text = activityData;
        }
    }
}

- (void)show:(NSDictionary *)paramsDict {
    _mainBoard.hidden = NO;
}

- (void)hide:(NSDictionary *)paramsDict {
    _mainBoard.hidden = YES;
}

#pragma mark-
#pragma mark utils
#pragma mark-

- (void)updateHeadImg:(NSString *)cachPath {
    PAImageView *avaterImageView = (PAImageView *)[_mainBoard viewWithTag:6787];
    if (avaterImageView) {
        [avaterImageView setImageURL:cachPath];
    }
    UIImageView *backGrounde = (UIImageView *)[_mainBoard viewWithTag:6786];
    if (backGrounde) {
        [backGrounde setImageToBlur:[UIImage imageWithContentsOfFile:cachPath] blurRadius:8.0 completionBlock:nil];
    }
    if (backGround) {
        backGround.originalImage = [UIImage imageWithContentsOfFile:cachPath];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(change) userInfo:nil repeats:NO];
    }
}

- (void)change {
    if (backGround) {
        [backGround setBlurLevel:0.95];
    }
}

- (NSArray *)subFilePath:(NSString *)sorceStr {
    NSString *path = nil;
    NSString *name = nil;
    NSString *suffix = nil;
    NSRange rangeNam = [sorceStr rangeOfString:@"/"];
    NSString *subName = sorceStr;
    while (rangeNam.location != NSNotFound){
        subName = [subName substringFromIndex:rangeNam.location+1];
        rangeNam = [subName rangeOfString:@"/"];
    }
    NSString *remainStr = subName;
    rangeNam = [sorceStr rangeOfString:remainStr];
    path = [sorceStr substringToIndex:rangeNam.location-1];
    NSRange range = [remainStr rangeOfString:@"."];
    if (range.location == NSNotFound) {
        name = remainStr;
        suffix = @"png";
    } else {
        NSString *subStr = remainStr;
        while (range.location != NSNotFound) {
            subStr = [subStr substringFromIndex:range.location+1];
            range = [subStr rangeOfString:@"."];
        }
        suffix = subStr;
        range = [remainStr rangeOfString:suffix];
        name = [remainStr substringToIndex:range.location-1];
    }
    NSArray *resault = [NSArray arrayWithObjects:path,name,suffix, nil];
    return resault;
}

//异步get
- (void)getTokenAsynchronous:(NSString *)appid andSecret:(NSString *)secret {
    NSURL *url=[NSURL URLWithString:appid];
    if (requests) {
        self.requests=nil;
    }
    requests=[[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
    [NSURLConnection connectionWithRequest:requests delegate:self];

}

#pragma mark -
#pragma mark Asynchronous delegate
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    if (recivedData) {
        self.recivedData = nil;
    }
    recivedData = [[NSMutableData alloc]initWithCapacity:1];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [recivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentPath = [UZAppUtils appDocumentPath];
    NSString *cachPath = [documentPath stringByAppendingString:@"/cacheHeadIMG"];
    if (![fileManager fileExistsAtPath:cachPath isDirectory:nil]) {
        [fileManager createDirectoryAtPath:cachPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *imgPath = [[[connection currentRequest] URL]absoluteString];
    NSArray *pathes = [self subFilePath:imgPath];
    NSString *name = [pathes objectAtIndex:1];
    NSString *suffix = [pathes objectAtIndex:2];
    NSString *cachImgPath = [cachPath stringByAppendingFormat:@"/%@.%@",name,suffix];
    if ([fileManager fileExistsAtPath:cachImgPath]) {
        [fileManager removeItemAtPath:cachImgPath error:nil];
    }
    [fileManager createFileAtPath:cachImgPath contents:recivedData attributes:nil];
    [self updateHeadImg:cachImgPath];
}

//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSString *erromsg = @"网络错误";
    NSLog(@"personalCenter_download_head%@",erromsg);
}
    
@end
