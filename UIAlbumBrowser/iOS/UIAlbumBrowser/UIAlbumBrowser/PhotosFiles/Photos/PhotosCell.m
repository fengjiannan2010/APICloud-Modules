/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotosCell.h"
#import "RITLPhotoConfig.h"
#import "Masonry.h"
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"
#import "UZModule.h"
@interface PhotosCell ()
@property(assign,nonatomic)CGFloat  chooseImgSize;
@property(strong,nonatomic)NSString *chooseImgPosition;
@property(strong,nonatomic)NSString *chooseImgIconPath;
@end

@implementation PhotosCell


- (void)prepareForReuse{
    //重置所有数据
    self.imageView.image = nil;
    self.chooseImageView.hidden = false;
    self.messageView.hidden = true;
    self.messageImageView.image = nil;
    self.messageLabel.text = @"";
    NSString *imgPath = [[NSBundle mainBundle]pathForResource:@"res_UIAlbumBrowser/Selected@2x"ofType:@"png"];
    self.chooseImageView.image = [UIImage imageWithContentsOfFile:imgPath]; 
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame])
    {
  
        [self photosCellWillLoad];
    }
    
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self photosCellWillLoad];
    
}


- (void)photosCellWillLoad
{
    self.backgroundColor = [UIColor whiteColor];
    [self addSubImageView];
    [self addSubMessageView];
    [self addSubMessageImageView];
    [self addSubMessageLabel];
    
}

#pragma mark - CreateSubviews

- (void)addSubImageView
{
    //添加imageView
    _imageView = [[UIImageView alloc]init];
    _imageView.clipsToBounds = true;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.backgroundColor = [UIColor whiteColor];

    [self.contentView addSubview:_imageView];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.contentView);
        
    }];
    

}


- (void)addSubMessageView
{
    _messageView = [[UIView alloc]init];
    
    [self.contentView addSubview:_messageView];
    
    [_messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.and.bottom.equalTo(self.contentView);
        make.height.equalTo(@(20));
        
    }];

    _messageView.backgroundColor = [UIColor clearColor];
    _messageView.hidden = true;
}


- (void)addSubMessageImageView
{
    _messageImageView = [[UIImageView alloc]init];
    
    [_messageView addSubview:_messageImageView];
    
    [_messageImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(5));
        make.bottom.equalTo(self.messageView);
        make.size.mas_equalTo(CGSizeMake(30, 20));
    }];
    
}


- (void)addSubMessageLabel
{
    _messageLabel = [[UILabel alloc]init];
    
    [_messageView addSubview:_messageLabel];
    
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.messageImageView.mas_right);
        make.right.equalTo(self.messageView).offset(-3);
        make.bottom.equalTo(self.messageView);
        make.height.mas_equalTo(20);
        
    }];
    
    
    _messageLabel.font = [UIFont systemFontOfSize:11];
    _messageLabel.textAlignment = NSTextAlignmentRight;
    _messageLabel.textColor = [UIColor whiteColor];
    _messageLabel.text = @"00:25";
}


- (void)addChooseControl
{
    _chooseControl = [UIControl new];
    
    
    [self.contentView addSubview:_chooseControl];
    
    if ([self.chooseImgPosition isEqualToString:@"bottom_left"]) {
        [_chooseControl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(65, 65));
            make.left.mas_equalTo(3);
            make.bottom.mas_equalTo(-3);
            
        }];
    } if ([self.chooseImgPosition isEqualToString:@"top_left"]) {
        [_chooseControl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(65, 65));
            make.left.and.top.mas_equalTo(3);
            
        }];
    }if ([self.chooseImgPosition isEqualToString:@"top_right"]) {
        [_chooseControl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(65, 65));
            make.top.mas_equalTo(3);
            make.right.mas_equalTo(-3);
            
        }];
    }if ([self.chooseImgPosition isEqualToString:@"bottom_right"]) {
        [_chooseControl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(65, 65));
            make.right.and.bottom.mas_equalTo(-3);
            
        }];
    }
    
    _chooseControl.backgroundColor = [UIColor clearColor];
    [_chooseControl addTarget:self action:@selector(chooseButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
}

/** 选择按钮被点击 */
- (IBAction)chooseButtonDidTap:(id)sender
{
    if (self.chooseImageDidSelectBlock)
    {
        self.chooseImageDidSelectBlock(self);
    }
}

- (void)addChooseImageView
{
    _chooseImageView = [UIImageView new];
    
    [_chooseControl addSubview:_chooseImageView];
    
    if ([self.chooseImgPosition isEqualToString:@"bottom_left"]) {
        [_chooseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(self.chooseImgSize, self.chooseImgSize));
            make.left.and.bottom.mas_equalTo(0);
            
        }];
    } if ([self.chooseImgPosition isEqualToString:@"top_left"]) {
        [_chooseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(self.chooseImgSize, self.chooseImgSize));
            make.left.and.top.mas_equalTo(0);
            
        }];
    }if ([self.chooseImgPosition isEqualToString:@"top_right"]) {
        [_chooseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(self.chooseImgSize, self.chooseImgSize));
            make.right.and.top.mas_equalTo(0);
            
        }];
    }if ([self.chooseImgPosition isEqualToString:@"bottom_right"]) {
        [_chooseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(self.chooseImgSize, self.chooseImgSize));
            make.right.and.bottom.mas_equalTo(0);
            
        }];
    }
    _chooseImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

 
    NSString *icon = self.chooseImgIconPath;
    if (self.chooseImgIconPath.length >0) {

        
        NSString *realPath =  [UZAppUtils getPathWithUZSchemeURL:icon];
        _chooseImageView.image = [UIImage imageWithContentsOfFile:realPath];
        
    }else
    {
        NSString *imgPath = [[NSBundle mainBundle]pathForResource:@"res_UIAlbumBrowser/Selected@2x"ofType:@"png"];
        _chooseImageView.image = [UIImage imageWithContentsOfFile:imgPath];
    }
  
    _chooseImageView.layer.cornerRadius = self.chooseImgSize / 2.0;
    _chooseImageView.clipsToBounds = true;
}

@end


@implementation PhotosCell (RITLPhotosViewModel)

-(void)cellSelectedAction:(BOOL)isSelected
{

    
    NSString *deselectedImgPath = [[NSBundle mainBundle]pathForResource:@"res_UIAlbumBrowser/unSelected@2x"ofType:@"png"];
    NSString *selectedImgPath = [[NSBundle mainBundle]pathForResource:@"res_UIAlbumBrowser/Selected@2x"ofType:@"png"];
    
    
    if (self.chooseImgIconPath.length > 0) {
        
        NSString *realPath =  [UZAppUtils getPathWithUZSchemeURL:self.chooseImgIconPath];
        
        self.chooseImageView.image = !isSelected ? [UIImage imageWithContentsOfFile:deselectedImgPath]:[UIImage imageWithContentsOfFile:realPath];
    }else
    {
    
    self.chooseImageView.image = !isSelected ? [UIImage imageWithContentsOfFile:deselectedImgPath]:  [UIImage imageWithContentsOfFile:selectedImgPath];
        
    }
    
    if (isSelected)
    {
        [self startSelectedAnimation];
    }
    
}


- (void)startSelectedAnimation
{
    //anmiation
    [UIView animateWithDuration:0.2 animations:^{
        //放大
        self.chooseImageView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    } completion:^(BOOL finished) {//变回
        [UIView animateWithDuration:0.2 animations:^{
            self.chooseImageView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            
        }];
        
    }];
}

-(void)setMarkDict:(NSDictionary *)markDict
{
    
    if (_markDict) {
        return;
    }
    _markDict = markDict;
    self.chooseImgSize = [self.markDict floatValueForKey:@"size" defaultValue:20];
    self.chooseImgIconPath = [self.markDict stringValueForKey:@"icon" defaultValue:nil];
    self.chooseImgPosition = [self.markDict stringValueForKey:@"position" defaultValue:@"bottom_left"];
    [self addChooseControl];
    [self addChooseImageView];
  
  
}

@end
