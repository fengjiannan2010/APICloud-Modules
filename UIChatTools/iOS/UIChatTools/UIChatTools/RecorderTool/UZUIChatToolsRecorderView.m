/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import "UZUIChatToolsRecorderView.h"
#import "UIView+UIChatTools.h"

#define lightBlueColor [UIColor colorWithRed:46 / 255.0 green:178 / 255.0 blue:243 / 255.0 alpha:1.0]

@interface UZUIChatToolsRecorderView ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) UIButton *microphoneBtn;
@property (nonatomic, weak) UIButton *recorderBtn;
@property (nonatomic, weak) UIImageView *microphoneImageView;
@property (nonatomic, weak) UIImageView *recorderImageView;
@property (nonatomic, weak) UIActivityIndicatorView *microphoneIndicator;
@property (nonatomic, weak) UIActivityIndicatorView *recorderIndicator;
@property (nonatomic, weak) UIButton *playView;
@property (nonatomic, weak) UIButton *rubbishView;
@property (nonatomic, weak) UIButton *sendBtn;
@property (nonatomic, weak) UIButton *cancelBtn;
@property (nonatomic, weak) UIScrollView *containerView;
@property (nonatomic, weak) UIButton *bottomRecorderBtn;
@property (nonatomic, weak) UIButton *bottomTalkbackBtn;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIView *maskView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger second;

@end

@implementation UZUIChatToolsRecorderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
    }
    return self;
}

- (void)creatTimer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
    }
}

- (void)startTimer {
    self.second++;
    if (!self.playView.selected && !self.rubbishView.selected) {
        if (self.containerView.contentOffset.x == 0) {
            
            [self.microphoneBtn setTitle:[self setTimeTitle:self.second] forState:UIControlStateNormal];
        }else {
            
            [self.recorderBtn setTitle:[self setTimeTitle:self.second] forState:UIControlStateNormal];
        }
    }
}

- (NSString *)setTimeTitle:(NSInteger)second {
    NSInteger min = second / 60;
    NSInteger sec = second % 60;
    NSString *title = [NSString stringWithFormat:@"%ld:%02ld",(long)min,(long)sec];
    return title;
}

- (void)setupChildViews {
    //containerView
    UIScrollView *containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 160)];
    containerView.delegate = self;
    containerView.bounces = NO;
    containerView.showsHorizontalScrollIndicator = NO;
    containerView.pagingEnabled = YES;
    containerView.contentSize = CGSizeMake(self.bounds.size.width * 2, 0);
    
    [self addSubview:containerView];
    self.containerView = containerView;
    
    CGFloat scrollW = containerView.bounds.size.width;
    CGFloat indicatorViewWH = 20;
    CGFloat pressViewWH = 100;
    CGFloat maginLR = 10;
    CGFloat circleWH = 50;
    NSArray *titleArr = @[@"按住说话",@"点击录音"];
    NSArray *sendCancelTitles = @[@"取消",@"发送"];
    
    NSArray *imagePaths = @[@"res_UIChatTools/play_noFull.png", @"res_UIChatTools/rubbish.png"];
    for (int i = 0; i < 2; i++) {
        //titleBtn
        UIButton *titleBtn = [[UIButton alloc] init];
        [titleBtn setTitle:titleArr[i] forState:UIControlStateNormal];
        [titleBtn sizeToFit];
        titleBtn.center = CGPointMake(scrollW * (0.5 + i), 30);
        [titleBtn setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.7] forState:UIControlStateNormal];
        [containerView addSubview:titleBtn];
        
        //pressView
        UIImageView *pressView = [[UIImageView alloc] initWithFrame:CGRectMake((scrollW - pressViewWH) / 2 + i * scrollW, CGRectGetMaxY(titleBtn.frame), pressViewWH, pressViewWH)];
        pressView.contentMode = UIViewContentModeCenter;
        pressView.layer.cornerRadius = pressViewWH / 2;
        pressView.layer.masksToBounds = YES;
        [containerView addSubview:pressView];
        pressView.userInteractionEnabled = YES;
        
        //indicatorView
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetMinX(titleBtn.frame) - indicatorViewWH, titleBtn.frame.origin.y + 0.5 * (titleBtn.frame.size.height - indicatorViewWH), indicatorViewWH, indicatorViewWH)];
        [containerView addSubview:indicatorView];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        //播放&取消按钮
        UIButton *squreView = [[UIButton alloc] initWithFrame:CGRectMake(maginLR + i * (scrollW - 2 * maginLR - circleWH), CGRectGetMinY(pressView.frame), circleWH, circleWH)];
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imagePaths[i] ofType:nil]];
        UIButton *circleView = [self setupCircleViewWithSquareView:squreView image:image];
        circleView.hidden = YES;
        [containerView addSubview:circleView];
        
        
        //试听界面的取消&发送
        CGFloat sendOrCancelBtnH = 40;
        UIButton *sendOrCancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0 + i * 0.5 * containerView.width, self.height - sendOrCancelBtnH, containerView.width * 0.5, sendOrCancelBtnH)];
        [sendOrCancelBtn setTitle:sendCancelTitles[i] forState:UIControlStateNormal];
        [sendOrCancelBtn setTitleColor:lightBlueColor forState:UIControlStateNormal];
        sendOrCancelBtn.layer.borderWidth = 0.5;
        sendOrCancelBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        sendOrCancelBtn.tag = i;
        [sendOrCancelBtn addTarget:self action:@selector(sendOrCancelClick:) forControlEvents:UIControlEventTouchUpInside];
        sendOrCancelBtn.hidden = YES;
        [self addSubview:sendOrCancelBtn];
        
        if (i == 0) {
            pressView.backgroundColor = lightBlueColor;
            pressView.image = [self getImageWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"res_UIChatTools/microphone.png" ofType:nil]] size:CGSizeMake(40, 40)];
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]; 
            [pressView addGestureRecognizer:longPress];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            tap.delegate = self;
            [pressView addGestureRecognizer:tap];
            
            self.microphoneBtn = titleBtn;
            self.microphoneIndicator = indicatorView;
            self.playView = circleView;
            self.microphoneImageView = pressView;
            self.cancelBtn = sendOrCancelBtn;
        }
        if (i == 1) {
            pressView.image = [self getImageWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"res_UIChatTools/redCircle.png" ofType:nil]] size:CGSizeMake(85, 85)];
            pressView.layer.borderWidth = 0.5;
            pressView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            self.recorderBtn = titleBtn;
            self.recorderIndicator = indicatorView;
            self.rubbishView = circleView;
            self.sendBtn = sendOrCancelBtn;
            self.recorderImageView = pressView;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [pressView addGestureRecognizer:tap];
        }
    }
    
    //bottomView
    UIView *bottomView = [[UIView alloc] init];
    [self addSubview:bottomView];
    bottomView.y = CGRectGetMaxY(containerView.frame) + 10;
    bottomView.width = self.containerView.width;
    self.bottomView = bottomView;
    
    UIView *pointView = [[UIView alloc] init];
    pointView.size = CGSizeMake(4, 4);
    pointView.centerX = bottomView.width * 0.5;
    pointView.layer.cornerRadius = pointView.width * 0.5;
    pointView.layer.masksToBounds = YES;
    pointView.backgroundColor = lightBlueColor;
    [bottomView addSubview:pointView];
    
    
    NSArray *bottomBtnTitles = @[@"对讲",@"录音"];
    CGFloat bottomBtnW = 40;
    CGFloat bottomBtnH = 20;
    for (int i = 0; i < 2; i++) {
        UIButton *bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomBtn setTitle:bottomBtnTitles[i] forState:UIControlStateNormal];
        [bottomBtn setTitleColor:lightBlueColor forState:UIControlStateSelected];
        [bottomBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        bottomBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        bottomBtn.size = CGSizeMake(bottomBtnW, bottomBtnH);
        bottomBtn.centerX = bottomView.width * 0.5 + bottomBtnW * i;
        bottomBtn.y = CGRectGetMaxY(pointView.frame);
        bottomBtn.tag = i;
        [bottomBtn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            [self bottomBtnClick:bottomBtn];
        }
        [bottomView addSubview:bottomBtn];
        if (i == 0) {
            self.bottomTalkbackBtn = bottomBtn;
        }
        if (i == 1) {
            self.bottomRecorderBtn = bottomBtn;
            bottomView.height = CGRectGetMaxY(bottomBtn.frame);
        }
    }
    //mask
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, [UIScreen mainScreen].bounds.size.height - self.height)];
    maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    maskView.hidden = YES;
    self.maskView = maskView;
    [[UIApplication sharedApplication].windows.lastObject addSubview:maskView];
    self.recorderState = RecorderStateNormal;
    self.talkbackState = TalkbackStateNormal;
}

- (void)bottomBtnClick:(UIButton *)btn {
    [UIView animateWithDuration:0.25 animations:^{
        btn.centerX = self.containerView.width * 0.5;
        btn.selected = YES;
        if (btn.tag == 0) {
            self.bottomRecorderBtn.centerX = btn.centerX + btn.width;
            self.bottomRecorderBtn.selected = NO;
        }
        if (btn.tag == 1) {
            self.bottomTalkbackBtn.centerX = btn.centerX - btn.width;
            self.bottomTalkbackBtn.selected = NO;
        }
    }];
    [self.containerView setContentOffset:CGPointMake(btn.tag * self.containerView.width, 0) animated:YES];
}

- (void)tap:(UITapGestureRecognizer *)sender {
    if ([sender.view isEqual:self.microphoneImageView]) {
        if (!self.cancelBtn.hidden) {
            
            switch (self.talkbackState) {
                case TalkbackStateNormal:
                    self.talkbackState = TalkbackStatePlay;
                    //callback
                    if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                        [self.delegate recorderView:self listenType:ListenTypeAudition];
                    }
                    self.microphoneImageView.image = [self getImageWithColor:lightBlueColor size:CGSizeMake(40, 40)];
                    break;
                case TalkbackStatePlay:
                    self.talkbackState = TalkbackStatePause;
                    self.microphoneImageView.image = [self getImageWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"res_UIChatTools/play.png" ofType:nil]] size:CGSizeMake(40, 40)];
                    self.microphoneImageView.contentMode = UIViewContentModeCenter;
                    
                    break;
                case TalkbackStatePause:
                    self.talkbackState = TalkbackStatePlay;
                    if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                        [self.delegate recorderView:self listenType:ListenTypeAudition];
                    }
                    self.microphoneImageView.image = [self getImageWithColor:lightBlueColor size:CGSizeMake(40, 40)];
                    break;
                    
                default:
                    break;
            }
        }
    }else {
        if (self.recorderState == RecorderStateNormal) {
            [self.recorderBtn setTitle:@"准备中" forState:UIControlStateNormal];
            //            [self.recorderIndicator startAnimating];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //动画
            [self.recorderIndicator stopAnimating];
            switch (self.recorderState) {
                case RecorderStateNormal:
                    self.containerView.scrollEnabled = NO;
                    self.maskView.hidden = NO;
                    self.recorderState = RecorderStateIng;
                    //microphoneBtn 计时器开始计时
                    if (self.isStartTimer) {
                        [self creatTimer];
                    }
                    if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                        [self.delegate recorderView:self listenType:ListenTypeStart];
                    }
                    [self.recorderBtn setTitle:[self setTimeTitle:self.second] forState:UIControlStateNormal];
                    self.recorderImageView.backgroundColor = [UIColor clearColor];
                    self.recorderImageView.image = [self getImageWithColor:lightBlueColor size:CGSizeMake(40, 40)];
                    break;
                case RecorderStateIng:
                    self.recorderState = RecorderStatePause;
                    [self.timer invalidate];
                    self.timer = nil;
                    [self showListenView];
                    if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                        [self.delegate recorderView:self listenType:ListenTypeStop];
                    }
                    break;
                case RecorderStatePause:
                    self.recorderState = RecorderStatePlay;
                    self.recorderImageView.image = [self getImageWithColor:lightBlueColor size:CGSizeMake(40, 40)];
                    self.recorderImageView.contentMode = UIViewContentModeCenter;
                    if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                        [self.delegate recorderView:self listenType:ListenTypeAudition_recorder];
                    }
                    break;
                case RecorderStatePlay:
                    self.recorderState = RecorderStatePause;
                    self.recorderImageView.image = [self getImageWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"res_UIChatTools/play.png" ofType:nil]] size:CGSizeMake(40, 40)];
                    break;
                default:
                    break;
            }
        });
    }
}

- (UIButton *)setupCircleViewWithSquareView:(UIButton *)squareView image:(UIImage *)image{
    squareView.backgroundColor = [UIColor whiteColor];
    squareView.layer.cornerRadius = squareView.frame.size.width * 0.5;
    squareView.layer.masksToBounds = YES;
    [squareView setBackgroundImage:[self getImageWithColor:[UIColor whiteColor] size:squareView.frame.size] forState:UIControlStateNormal];
    [squareView setBackgroundImage:[self getImageWithColor:[UIColor grayColor] size:squareView.frame.size] forState:UIControlStateSelected];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = CGPointMake(squareView.frame.size.width / 2, squareView.frame.size.height / 2);
    imageView.image = image;
    [squareView addSubview:imageView];
    return squareView;
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.microphoneBtn setTitle:@"准备中" forState:UIControlStateNormal];
        [self.microphoneIndicator startAnimating];
        self.bottomView.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //hidden
            self.playView.hidden = NO;
            self.rubbishView.hidden = NO;
            
            //动画
            [self.microphoneIndicator stopAnimating];
            
            //callback
            if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                [self.delegate recorderView:self listenType:ListenTypePress];
            }
            //microphoneBtn 计时器开始计时
            if (self.isStartTimer) {
                [self creatTimer];
            }
            [self.microphoneBtn setTitle:[self setTimeTitle:self.second] forState:UIControlStateNormal];
        });
    }
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [sender locationInView:self.containerView];
        //playView
        if (point.x - self.containerView.width / 2 < 0) {
            self.playView.selected = CGRectContainsPoint(self.playView.frame, point);
            if (self.playView.selected) {
                [self.microphoneBtn setTitle:@"松手试听" forState:UIControlStateNormal];
            }else {
                [self.microphoneBtn setTitle:[self setTimeTitle:self.second] forState:UIControlStateNormal];
            }
        }else {
            //rubbishView
            self.rubbishView.selected = CGRectContainsPoint(self.rubbishView.frame, point);
            if (self.rubbishView.selected) {
                //停止计时
                [self.microphoneBtn setTitle:@"松手取消发送" forState:UIControlStateNormal];
                [self.microphoneBtn sizeToFit];
                self.microphoneBtn.centerX = self.containerView.width * 0.5;
            }else {
                //如果没有停止，不做处理，如果停止，则继续
                [self.microphoneBtn setTitle:[self setTimeTitle:self.second] forState:UIControlStateNormal];
            }
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.playView.hidden = YES;
        self.rubbishView.hidden = YES;
        if (self.second <= 1) {
            //callback
            if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                [self.delegate recorderView:self listenType:ListenTypeShortTime];
            }
            [self.microphoneBtn setTitle:@"按住说话" forState:UIControlStateNormal];
            [self.microphoneBtn sizeToFit];
            self.microphoneBtn.centerX = self.containerView.width * 0.5;
            self.bottomView.hidden = NO;
        }else {
            //playView
            if (self.playView.selected) {
                [self showListenView];
            }else {
                [self.microphoneBtn setTitle:@"按住说话" forState:UIControlStateNormal];
                [self.microphoneBtn sizeToFit];
                self.microphoneBtn.centerX = self.containerView.width * 0.5;
                self.bottomView.hidden = NO;
            }
            //rubbishView
            if (self.rubbishView.selected) {
                [self cancelSend];
            }
            //callback-send
            if (!self.playView.selected && !self.rubbishView.selected) {
                if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                    [self.delegate recorderView:self listenType:ListenTypeaSend];
                }
            }
        }
        self.second = 0;
        [self.timer invalidate];
        self.timer = nil;
        self.playView.selected = NO;
        self.rubbishView.selected = NO;
    }
}

- (void)showListenView {
    NSLog(@"哈哈哈哈哈哈哈");
    if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
        [self.delegate recorderView:self listenType:ListenTypeAuditionTouchOn];
    }
    self.cancelBtn.hidden = self.sendBtn.hidden = NO;
    [self.containerView setScrollEnabled:NO];
    self.bottomView.hidden = YES;
    if (self.containerView.contentOffset.x == 0) {
        [self.microphoneBtn setTitle:[self setTimeTitle:self.second] forState:UIControlStateNormal];
        self.microphoneImageView.image = [self getImageWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"res_UIChatTools/play.png" ofType:nil]] size:CGSizeMake(40, 40)];
        self.microphoneImageView.contentMode = UIViewContentModeCenter;
        self.microphoneImageView.layer.borderWidth = 2;
        self.microphoneImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.microphoneImageView.backgroundColor = [UIColor clearColor];
    }else {
        [self.recorderBtn setTitle:[self setTimeTitle:self.second] forState:UIControlStateNormal];
        self.recorderImageView.image = [self getImageWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"res_UIChatTools/play.png" ofType:nil]] size:CGSizeMake(40, 40)];
        self.recorderImageView.contentMode = UIViewContentModeCenter;
    }
}

- (void)cancelSend {
    //callback
    if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
        [self.delegate recorderView:self listenType:ListenTypeCancel];
    }
}

- (void)sendOrCancelClick:(UIButton *)btn {
    if (self.containerView.contentOffset.x == 0) {
        
        
        if (btn.tag == 0) {
            //callback
            if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                [self.delegate recorderView:self listenType:ListenTypeAuditionCancel];
            }
        }else {
            //callback
            if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                [self.delegate recorderView:self listenType:ListenTypeaSend];
            }
        }
    }else {
        
        if (btn.tag == 0) {
            //callback
            if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                [self.delegate recorderView:self listenType:ListenTypeAuditionCancel_recorder];
            }
        }else {
            //callback
            if ([self.delegate respondsToSelector:@selector(recorderView:listenType:)]) {
                [self.delegate recorderView:self listenType:ListenTypeSend_recorder];
            }
        }
    }
    
    self.containerView.scrollEnabled = YES;
    self.recorderState = RecorderStateNormal;
    self.talkbackState = TalkbackStateNormal;
    self.sendBtn.hidden = self.cancelBtn.hidden = YES;
    self.bottomView.hidden = NO;
    self.microphoneImageView.image = [self getImageWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"res_UIChatTools/microphone.png" ofType:nil]] size:CGSizeMake(40, 40)];
    self.microphoneImageView.backgroundColor = lightBlueColor;
    self.microphoneImageView.layer.borderWidth = 0;
    [self.microphoneBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.recorderBtn setTitle:@"点击录音" forState:UIControlStateNormal];
    self.recorderImageView.image = [self getImageWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"res_UIChatTools/redCircle.png" ofType:nil]] size:CGSizeMake(85, 85)];
    self.second = 0;
    self.maskView.hidden = YES;
}

- (UIImage *)getImageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//改变图片尺寸
- (UIImage *)getImageWithImage:(UIImage *)image size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, 0.0, 1.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma  mark ------------------------UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGFloat translationX = offset.x * self.bottomRecorderBtn.width / scrollView.width;
    self.bottomTalkbackBtn.centerX = self.containerView.width * 0.5 - translationX;
    self.bottomRecorderBtn.x = CGRectGetMaxX(self.bottomTalkbackBtn.frame);
    if (self.bottomTalkbackBtn.centerX == self.containerView.centerX) {
        self.bottomTalkbackBtn.selected = YES;
        self.bottomRecorderBtn.selected = NO;
    }
    if (self.bottomRecorderBtn.centerX == self.containerView.centerX) {
        self.bottomRecorderBtn.selected = YES;
        self.bottomTalkbackBtn.selected = NO;
    }
}

@end
