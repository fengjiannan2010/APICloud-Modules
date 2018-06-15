//
//  myPhotoCell.m
//  photoDemo
//
//  Created by wangxinxu on 2017/6/1.
//  Copyright © 2017年 wangxinxu. All rights reserved.
//

#import "myPhotoCell.h"
#import "NSDictionaryUtils.h"
#import "UZAlbumSingleton.h"
#import "UZAppUtils.h"
@implementation myPhotoCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        NSDictionary *stylesInfo = UZAlbumSingleton.sharedSingleton.stylesInfo;
        NSDictionary *markInfo = [stylesInfo dictValueForKey:@"mark" defaultValue:@{}];
        NSString *position = [markInfo stringValueForKey:@"position" defaultValue:@"bottom_left"];
        CGFloat size = [markInfo floatValueForKey:@"size" defaultValue:20];
        _photoView = [[UIImageView alloc] initWithFrame:self.bounds];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.layer.masksToBounds = YES;
        [self addSubview:_photoView];
        
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(self.bounds.size.width/4, self.bounds.size.height/4*3, self.bounds.size.width/2, self.bounds.size.height/4)];
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        _progressView.progressTintColor = [UIColor clearColor];
        _progressView.trackTintColor = [UIColor clearColor];
        [_photoView addSubview:_progressView];
        
        _signImage = [[UIImageView alloc]init];
        _signImage.layer.cornerRadius = size/2;
        _signImage.image = [UIImage imageNamed:@"res_UIAlbumBrowser/wphoto_select_no@2x.png"];
        _signImage.layer.masksToBounds = YES;
        if ([position isEqualToString:@"top_right"]) {
            _signImage.frame = CGRectMake(self.frame.size.width-size-3,3, size, size);
        }else if ([position isEqualToString:@"top_left"]){
            _signImage.frame = CGRectMake(3, 3, size, size);
            
        }else if ([position isEqualToString:@"bottom_left"]){
            
            _signImage.frame = CGRectMake(3, self.frame.size.width-size-3, size, size);

        }else if ([position isEqualToString:@"bottom_right"]){
            _signImage.frame = CGRectMake(self.frame.size.width-size-3, self.frame.size.width-size-3, size, size);

        }
        [_photoView addSubview:_signImage];
        
    }
    
    return self;
}

-(void)setProgressFloat:(CGFloat)progressFloat {
    _progressFloat = progressFloat;
    [_progressView setProgress:progressFloat animated:YES];
}

@end
