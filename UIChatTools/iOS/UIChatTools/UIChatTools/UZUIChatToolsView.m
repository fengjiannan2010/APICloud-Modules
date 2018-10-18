/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import "UZUIChatToolsView.h"
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"
#import "UZUIChatToolsAttachment.h"
#import "UIChatToolsSingleton.h"
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
@interface UZUIChatToolsView ()<UITextViewDelegate>

@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSMutableArray *items;
//标识作用
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) UIButton *currentBtn;

@property (nonatomic, strong)UIView *maskView;

@end

@implementation UZUIChatToolsView

- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (NSMutableArray *)titles {
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

- (instancetype)initWithParams:(NSDictionary *)params chatTools:(UZUIChatTools *)chatTools {
    self = [super init];
    if (self) {
        _params = params;
        _chatTools = chatTools;
        [self setupViews];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    CGRect maskViewFrame = UIChatToolsSingleton.sharedSingleton.maskView.frame;
    maskViewFrame.size.height = frame.origin.y;
    UIChatToolsSingleton.sharedSingleton.maskView.frame = maskViewFrame;
}

- (void)setupViews {
    //chatBox
    NSDictionary *chatBoxDict = [_params dictValueForKey:@"chatBox" defaultValue:@{}];
    NSString *placeholder = [chatBoxDict stringValueForKey:@"placeholder" defaultValue:@""];
    BOOL autoFocuse = [chatBoxDict boolValueForKey:@"autoFocuse" defaultValue:NO];
    NSInteger maxRows = [chatBoxDict integerValueForKey:@"maxRows" defaultValue:6];

    //styles
    NSDictionary *stylesDict = [_params dictValueForKey:@"styles" defaultValue:@{}];
    CGFloat margin = [stylesDict floatValueForKey:@"margin" defaultValue:10];
    NSString *bgColor = [stylesDict stringValueForKey:@"bgColor" defaultValue:@"#D1D1D1"];
    
    //tools
    NSDictionary *toolsDict = [_params dictValueForKey:@"tools" defaultValue:@{}];
    CGFloat toolsH = [toolsDict floatValueForKey:@"h" defaultValue:44];
    CGFloat iconSize = [toolsDict floatValueForKey:@"iconSize" defaultValue:30];
    NSDictionary *recorderDict = [toolsDict dictValueForKey:@"recorder" defaultValue:nil];
    NSDictionary *imageDict = [toolsDict dictValueForKey:@"image" defaultValue:nil];
    NSDictionary *videoDict = [toolsDict dictValueForKey:@"video" defaultValue:nil];
    NSDictionary *packetDict = [toolsDict dictValueForKey:@"packet" defaultValue:nil];
    NSDictionary *faceDict = [toolsDict dictValueForKey:@"face" defaultValue:nil];
    NSDictionary *appendDict = [toolsDict dictValueForKey:@"append" defaultValue:nil];

    self.backgroundColor = [UZAppUtils colorFromNSString:bgColor];
    
    //chatBoxView
    CGFloat chatBoxViewH = 38;
    UZUIChatToolsInputView *chatBoxView = [[UZUIChatToolsInputView alloc] initWithFrame:CGRectMake(margin, 5, screenW - 2 * margin, chatBoxViewH)];
    chatBoxView.font = [UIFont systemFontOfSize:16];
    chatBoxView.placeholder = placeholder;
    chatBoxView.maxNumberOfLines = maxRows;
    chatBoxView.layer.borderWidth = 0.5;
    chatBoxView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    chatBoxView.layer.masksToBounds = YES;
    chatBoxView.layer.cornerRadius = 4;
    chatBoxView.keyboardType = UIKeyboardTypeDefault;
    chatBoxView.returnKeyType = UIReturnKeySend;
    chatBoxView.delegate = self;
    if (autoFocuse) {
        [chatBoxView becomeFirstResponder];
    }
    [self addSubview:chatBoxView];
    self.chatBoxView = chatBoxView;
    
    //toolView
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(chatBoxView.frame), screenW, toolsH)];
    toolView.backgroundColor = self.backgroundColor;
    [self addSubview:toolView];
    self.toolView = toolView;
    if (recorderDict) {
       [self.items addObject:recorderDict];
       [self.titles addObject:@"recorder"];
    }
    if (imageDict) {
        [self.items addObject:imageDict];
        [self.titles addObject:@"image"];

    }
    if (videoDict) {
        [self.items addObject:videoDict];
        [self.titles addObject:@"video"];

    }
    if (packetDict) {
        [self.items addObject:packetDict];
        [self.titles addObject:@"packet"];

    }
    if (faceDict) {
        [self.items addObject:faceDict];
        [self.titles addObject:@"face"];

    }
    if (appendDict) {
        [self.items addObject:appendDict];
        [self.titles addObject:@"append"];

    }
    //计算chatToolsViewframe
    CGFloat chatToolsViewH = CGRectGetMaxY(toolView.frame);
    if (iPhoneX) {
        self.frame = CGRectMake(0, screenH - chatToolsViewH-34, screenW, chatToolsViewH);

    }else{
        self.frame = CGRectMake(0, screenH - chatToolsViewH, screenW, chatToolsViewH);

    }
    
    if (!_items.count) return;
    
    CGFloat btnW = toolView.bounds.size.width / _items.count;
    CGFloat btnH = toolView.bounds.size.height;
    
    for (NSUInteger i = 0 ; i < _items.count; i++) {
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(btnW * i, 0, btnW, btnH)];
        [toolView addSubview:backView];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnW/2-iconSize/2, btnH/2-iconSize/2, iconSize, iconSize)];
        NSDictionary *itemDict = _items[i];
        NSString *normal = [itemDict stringValueForKey:@"normal" defaultValue:@""];
        NSString *selected = [itemDict stringValueForKey:@"selected" defaultValue:@""];
        normal = [_chatTools getPathWithUZSchemeURL:normal];
        selected = [_chatTools getPathWithUZSchemeURL:selected];
//        [btn setBackgroundImage:[self getImageWithImage:[UIImage imageWithContentsOfFile:normal] size:CGSizeMake(iconSize, iconSize)] forState:UIControlStateNormal];
//        [btn setBackgroundImage:[self getImageWithImage:[UIImage imageWithContentsOfFile:selected] size:CGSizeMake(iconSize, iconSize)] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageWithContentsOfFile:normal] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageWithContentsOfFile:selected] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.text = _titles[i];
        
        if ([_titles[i] isEqualToString:@"face"]) {
            self.faceButton = btn;
        }
        if ([_titles[i] isEqualToString:@"append"]) {
            self.appendButton = btn;
        }
        [backView addSubview:btn];
    }
}

- (void)clickAction:(UIButton *)btn {
    if (![self.currentBtn isEqual:btn]) {
        self.currentBtn.selected = NO;
        btn.selected = YES;
        self.currentBtn = btn;
    }else {
        btn.selected = !btn.selected;
    }
    
    //UZUIChatToolsViewDelegate
    if ([self.delegate respondsToSelector:@selector(chatToolsView:didClickButton:)]) {
        [self.delegate chatToolsView:self didClickButton:btn];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSDictionary *toolsDict = [_params dictValueForKey:@"tools" defaultValue:@{}];
    CGFloat toolsH = [toolsDict floatValueForKey:@"h" defaultValue:44];
    self.toolView.frame = CGRectMake(0, CGRectGetMaxY(_chatBoxView.frame), screenW, toolsH);
}

#pragma mark ---------------UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        NSMutableString *strM = [NSMutableString string];
        [textView.attributedText enumerateAttributesInRange:NSMakeRange(0, textView.attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            NSString *str = nil;
            UZUIChatToolsAttachment *attachment = attrs[@"NSAttachment"];
            if (attachment) { //表情
                str = attachment.emotionStr;
                if (str) {
                    [strM appendString:str];
                    
                }
            } else { //文字
                str = [textView.attributedText.string substringWithRange:range];
                if (str) {
                    [strM appendString:str];
                    
                }
            }
        }];
        !self.sendMessage ? : self.sendMessage(strM);
        return NO;
    }else {
        return YES;
    }
}

//改变图片尺寸
- (UIImage *)getImageWithImage:(UIImage *)image size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
