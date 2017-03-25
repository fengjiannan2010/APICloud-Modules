/**
  * APICloud Modules
  * Copyright (c) 2014-2017 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */

#import "NVTabBarView.h"
#import "NVTabBar.h"
#import "UZAppUtils.h"
#import "NSDictionaryUtils.h"
#import "NVTBBadgeView.h"
#import "UZModule.h"
#pragma mark - UIView Category -
@interface UIView (badge)
//设置徽章
- (void) setBadgeWithTitle: (NSString *) title
                    config: (NSDictionary *)config;
//移除徽章
- (void) removeBadge;

@end

@implementation UIView (badge)

- (void) setBadgeWithTitle: (NSString *)title
                    config: (NSDictionary *)config {
    NVTBBadgeView *badgeView = [[NVTBBadgeView alloc]initWithTitle:title config:config];
    [self addSubview: badgeView];
}


- (void) removeBadge {
    [self.subviews enumerateObjectsUsingBlock:^(UIView *tempView, NSUInteger idx, BOOL *stop) {
        if ([tempView isKindOfClass:[NVTBBadgeView class]]) {
            [tempView removeFromSuperview];
        }
    }];
}

@end

#pragma mark - NVTabBarView -

@interface NVTabBarView () {
    NSDictionary *_stylesInfo;
    CGFloat lineWidth;
}

@property (nonatomic, strong) NSMutableArray *iconBtnArray;
@property (nonatomic, strong) NSMutableArray *titlesArray;

@end

@implementation NVTabBarView

- (NSMutableArray *)iconBtnArray {
    if (!_iconBtnArray) {
        _iconBtnArray = [NSMutableArray array];
    }
    return _iconBtnArray;
}

- (NSMutableArray *)titlesArray {
    if (!_titlesArray) {
        _titlesArray = [NSMutableArray array];
    }
    return _titlesArray;
}

- (instancetype)initWithFrame:(CGRect)frame withDelegate:(id<NVTabBarViewDelegate>)delegate withStyle:(NSDictionary *)stylesInfo {
    self = [super initWithFrame:frame];
    if (self) {
        _nvTBDelegate = delegate;
        _stylesInfo = stylesInfo;
        NSString *bgPath = [stylesInfo stringValueForKey:@"bg" defaultValue:@"#ffffff"];
        if (bgPath.length <= 0) {
            bgPath = @"#ffffff";
        }
        if ([UZAppUtils isValidColor:bgPath]) {
            self.backgroundColor = [UZAppUtils colorFromNSString:bgPath];
        } else {
            self.backgroundColor = [UIColor clearColor];
            CGRect bgrect = self.bounds;
            UIImageView *bgImgView = [[UIImageView alloc]initWithFrame:bgrect];
            bgImgView.backgroundColor = [UIColor clearColor];
            bgPath = [delegate getRealPath:bgPath];
            bgImgView.image = [UIImage imageWithContentsOfFile:bgPath];
            bgImgView.contentMode = UIViewContentModeScaleToFill;
            [self addSubview:bgImgView];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //分割线
    NSDictionary *divLineInfo = [_stylesInfo dictValueForKey:@"dividingLine" defaultValue:@{}];
    lineWidth = [divLineInfo floatValueForKey:@"width" defaultValue:0.5];
    NSString *lineColor = [divLineInfo stringValueForKey:@"color" defaultValue:@"#000"];
    if (lineColor.length <= 0) {
        lineColor = @"#000";
    }
    CGContextRef lineContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(lineContext, lineWidth);
    CGContextSetStrokeColorWithColor(lineContext, [UZAppUtils colorFromNSString:lineColor].CGColor);
    CGContextMoveToPoint(lineContext, 0, lineWidth/2.0);
    CGContextAddLineToPoint(lineContext, self.frame.size.width, lineWidth/2.0);
    CGContextStrokePath(lineContext);
}

- (void)didMoveToSuperview {
    if (self.itemsArray.count <= 0) {
        return;
    }
    __block CGFloat itemBgViewX = 0;
    [self.itemsArray enumerateObjectsUsingBlock:^(NSDictionary *itemInfo, NSUInteger idx, BOOL *stop) {
        CGFloat defaultItemW = self.frame.size.width / self.itemsArray.count;
        //w
        CGFloat itemWidth = [itemInfo floatValueForKey:@"w" defaultValue:defaultItemW];
        //bg
        NSDictionary *bgInfo = [itemInfo dictValueForKey:@"bg" defaultValue:@{}];
        CGFloat marginB = [bgInfo floatValueForKey:@"marginB" defaultValue:0.0];
        NSString *bgImg = [bgInfo stringValueForKey:@"image" defaultValue:@"rgba(0,0,0,0)"];
        //iconRect
        NSDictionary *iconRectInfo = [itemInfo dictValueForKey:@"iconRect" defaultValue:@{}];
        CGFloat iconWidth = [iconRectInfo floatValueForKey:@"w" defaultValue:25.0];
        CGFloat iconHeigh = [iconRectInfo floatValueForKey:@"h" defaultValue:25.0];
        //icon
        NSDictionary *iconInfo = [itemInfo dictValueForKey:@"icon" defaultValue:@{}];
        NSString *iconNormal = [iconInfo stringValueForKey:@"normal" defaultValue:nil];
        NSString *iconSelect = [iconInfo stringValueForKey:@"selected" defaultValue:nil];
        //title
        NSDictionary *titleInfo = [itemInfo dictValueForKey:@"title" defaultValue:@{}];
        NSString *titleText = [titleInfo stringValueForKey:@"text" defaultValue:@""];
        NSString *titleNormal = [titleInfo stringValueForKey:@"normal" defaultValue:@"#696969"];
        NSString *titleSelect = [titleInfo stringValueForKey:@"selected" defaultValue:@"#ff0"];
        CGFloat titleSize = [titleInfo floatValueForKey:@"size" defaultValue:12.0];
        CGFloat titleMarB = [titleInfo floatValueForKey:@"marginB" defaultValue:6.0];
        if (titleNormal.length <= 0) {
            titleNormal = @"#696969";
        }
        if (titleSelect.length <= 0) {
            titleSelect = @"#ff0";
        }
        UIFont *titleFont = [UIFont systemFontOfSize:titleSize];
        if (nil != [titleInfo objectForKey: @"ttf"]) {
            NSString *name = [titleInfo stringValueForKey:@"ttf" defaultValue:@"Alkatip Basma Tom"];
            titleFont = [UIFont fontWithName:name size:titleSize];
        }
        CGFloat titleHeight = [titleText sizeWithFont:titleFont
                                             forWidth:itemWidth
                                        lineBreakMode:NSLineBreakByCharWrapping].height;
        CGFloat itemHeight = self.frame.size.height;
        UIButton *itemBgBtn = [[UIButton alloc]initWithFrame:CGRectMake(itemBgViewX, lineWidth-marginB, itemWidth, itemHeight)];
        //CGFloat itemHeight = iconHeigh+4+titleHeight+titleMarB;
        //UIButton *itemBgBtn = [[UIButton alloc]initWithFrame:CGRectMake(itemBgViewX, self.frame.size.height-lineWidth-(itemHeight+marginB), itemWidth, itemHeight)];
        itemBgBtn.tag = idx;
        [self addSubview:itemBgBtn];
        if ([UZAppUtils isValidColor:bgImg]) {
            itemBgBtn.backgroundColor = [UZAppUtils colorFromNSString:bgImg];
        } else {
            bgImg = [self.nvTBDelegate getRealPath:bgImg];
            [itemBgBtn setBackgroundImage:[UIImage imageWithContentsOfFile:bgImg] forState:UIControlStateNormal];
            [itemBgBtn setBackgroundImage:[UIImage imageWithContentsOfFile:bgImg] forState:UIControlStateSelected];
        }
        [itemBgBtn addTarget:self action:@selector(iconTouchDown:) forControlEvents:UIControlEventTouchDown];
        [itemBgBtn addTarget:self action:@selector(iconTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        float iconY = (itemBgBtn.bounds.size.height+marginB - (titleHeight+titleMarB) - iconHeigh)/2.0;
        UIImageView *iconView = [[UIImageView alloc]init];
        [iconView setFrame:CGRectMake((itemWidth-iconWidth)/2.0, iconY, iconWidth, iconHeigh)];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        //image
        if (iconNormal && (iconNormal.length > 0)) {
            iconNormal = [self.nvTBDelegate getRealPath:iconNormal];
            [iconView setImage:[UIImage imageWithContentsOfFile:iconNormal]];
        }
        [itemBgBtn addSubview:iconView];
        [self.iconBtnArray addObject:iconView];
        
        //title
        float titleY = itemBgBtn.bounds.size.height+marginB - titleMarB - titleHeight;
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, titleY, itemWidth, titleHeight)];
        //UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, itemHeight-titleHeight-titleMarB, itemWidth, titleHeight)];
        titleLabel.text = titleText;
        titleLabel.font = titleFont;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UZAppUtils colorFromNSString:titleNormal];
        titleLabel.backgroundColor = [UIColor clearColor];
        [itemBgBtn addSubview:titleLabel];
        [self.titlesArray addObject:titleLabel];
        
        if (self.selectedIndex == idx) {
            if (iconSelect && (iconSelect.length > 0) ) {
                itemBgBtn.selected = YES;
                iconSelect = [self.nvTBDelegate getRealPath:iconSelect];
                [iconView setImage:[UIImage imageWithContentsOfFile:iconSelect]];
            }
            titleLabel.textColor = [UZAppUtils colorFromNSString:titleSelect];
        }
        itemBgViewX += itemWidth;
    }];
}

//高亮
- (void)iconTouchDown:(UIButton *)thisBtn {
    NSDictionary *itemInfo = [self.itemsArray objectAtIndex:thisBtn.tag];
    NSDictionary *iconInfo = [itemInfo dictValueForKey:@"icon" defaultValue:@{}];
    NSString *iconHighLi = [iconInfo stringValueForKey:@"highlight" defaultValue:nil];

    UIImageView *thisIconView = [self.iconBtnArray objectAtIndex:thisBtn.tag];
    if (iconHighLi && (iconHighLi.length > 0)) {
        iconHighLi = [self.nvTBDelegate getRealPath:iconHighLi];
        [thisIconView setImage:[UIImage imageWithContentsOfFile:iconHighLi]];
    }
}

//click
- (void)iconTouchUpInside:(UIButton *)thisBtn {
    NSDictionary *itemInfo = [self.itemsArray objectAtIndex:thisBtn.tag];
    NSDictionary *iconInfo = [itemInfo dictValueForKey:@"icon" defaultValue:@{}];
    NSString *iconSelect = [iconInfo stringValueForKey:@"selected" defaultValue:nil];
    //title
    NSDictionary *titleInfo = [itemInfo dictValueForKey:@"title" defaultValue:@{}];
    NSString *titleNormal = [titleInfo stringValueForKey:@"normal" defaultValue:@"#696969"];
    NSString *titleSelect = [titleInfo stringValueForKey:@"selected" defaultValue:@"#ff0"];
    if (titleNormal.length <= 0) {
        titleNormal = @"#696969";
    }
    if (titleSelect.length <= 0) {
        titleSelect = @"#ff0";
    }
    UIImageView *thisIconView = [self.iconBtnArray objectAtIndex:thisBtn.tag];
    UILabel *thisTitle = [self.titlesArray objectAtIndex:thisBtn.tag];
    if (!thisBtn.selected) {
        thisBtn.selected = !thisBtn.selected;
        thisTitle.textColor = [UZAppUtils colorFromNSString:titleSelect];
        //其他不选中
        [self menuItemDisSelected:thisBtn.tag];
    } else {

    }
    if (iconSelect && (iconSelect.length > 0)) {
        iconSelect = [self.nvTBDelegate getRealPath:iconSelect];
        [thisIconView setImage:[UIImage imageWithContentsOfFile:iconSelect]];
    }
    [self.nvTBDelegate callBack:@{@"eventType":@"click",@"index":@(thisBtn.tag)}];
}

- (void)menuItemDisSelected:(NSInteger)indexDefault {
    [self.itemsArray enumerateObjectsUsingBlock:^(NSDictionary *itemDic, NSUInteger idx, BOOL *stop) {
        if (idx != indexDefault) {
            NSDictionary *iconInfo = [itemDic dictValueForKey:@"icon" defaultValue:@{}];
            NSString *iconNormal = [iconInfo stringValueForKey:@"normal" defaultValue:nil];
            //title
            NSDictionary *titleInfo = [itemDic dictValueForKey:@"title" defaultValue:@{}];
            NSString *titleNormal = [titleInfo stringValueForKey:@"normal" defaultValue:@"#696969"];
            NSString *titleSelect = [titleInfo stringValueForKey:@"selected" defaultValue:@"#ff0"];
            if (titleNormal.length <= 0) {
                titleNormal = @"#696969";
            }
            if (titleSelect.length <= 0) {
                titleSelect = @"#ff0";
            }
            UIImageView *iconView = [self.iconBtnArray objectAtIndex:idx];
            UIButton *inactiveBtn = (UIButton *)[iconView superview];
            [inactiveBtn setSelected:NO];
            
            iconNormal = [self.nvTBDelegate getRealPath:iconNormal];
            if ([[NSFileManager defaultManager] fileExistsAtPath:iconNormal]) {
                UIImage *activeImg = [UIImage imageWithContentsOfFile:iconNormal];
                [iconView setImage:activeImg];
            } else {
                [iconView setImage:nil];
            }
            UILabel *thisTitle = [self.titlesArray objectAtIndex:idx];
            if (thisTitle) {
                thisTitle.textColor = [UZAppUtils colorFromNSString:titleNormal];
            }
            [iconView setAnimationImages:nil];
        }
    }];
}

#pragma mark - 设置徽章 -

- (void)setBadgeAtIndex:(NSUInteger)thisIndex title:(NSString *)title {
    UIButton *thisBtn = [self.iconBtnArray objectAtIndex:thisIndex];
    if (thisBtn == nil) {
        return;
    }
    if (title == nil) {
        [thisBtn removeBadge];
    } else {
        [thisBtn removeBadge];
        NSDictionary *badgeInfo = [_stylesInfo dictValueForKey:@"badge" defaultValue:@{}];
        [thisBtn setBadgeWithTitle:title config:badgeInfo];
    }
}

#pragma mark - 设置选中icon - 

- (void)setSelectedIconOfIndex:(NSInteger)index
                   selectState:(BOOL)state selectGifIcons:(NSMutableArray *)iconsArray selectInterval:(CGFloat)interval{
  
 
    if (index >= self.iconBtnArray.count || index < 0) {
        return;
    }
    UIImageView *thisIcon = [self.iconBtnArray objectAtIndex:index];
    if (thisIcon == nil) {
        return;
    }

    UIButton *thisBtn = (UIButton *)[thisIcon superview];
//    if (thisBtn.selected && state) {
//        return;
//    }
    NSDictionary *itemInfo = [self.itemsArray objectAtIndex:index];
    NSDictionary *iconInfo = [itemInfo dictValueForKey:@"icon" defaultValue:@{}];
    NSString *iconSelect = [iconInfo stringValueForKey:@"selected" defaultValue:nil];
    NSString *iconNormal = [iconInfo stringValueForKey:@"normal" defaultValue:nil];
    NSDictionary *titleInfo = [itemInfo dictValueForKey:@"title" defaultValue:@{}];
    NSString *titleNormal = [titleInfo stringValueForKey:@"normal" defaultValue:@"#696969"];
    NSString *titleSelect = [titleInfo stringValueForKey:@"selected" defaultValue:@"#ff0"];
    if (titleNormal.length <= 0) {
        titleNormal = @"#696969";
    }
    if (titleSelect.length <= 0) {
        titleSelect = @"#ff0";
    }
   
    
  
    
    UILabel *thisTitle = [self.titlesArray objectAtIndex:index];
    thisBtn.selected = state;
    if (state ) {
        thisTitle.textColor = [UZAppUtils colorFromNSString:titleSelect];
        //index 选中
        if (iconSelect && (iconSelect.length > 0)||iconsArray.count == 0) {
            iconSelect = [self.nvTBDelegate getRealPath:iconSelect];
            [thisIcon setImage:[UIImage imageWithContentsOfFile:iconSelect]];
        
        }
        //其他不选中
        [self menuItemDisSelected:thisBtn.tag];
    } else {
        thisTitle.textColor = [UZAppUtils colorFromNSString:titleNormal];
        if (iconNormal && (iconNormal.length > 0)||iconsArray.count == 0) {
            iconNormal = [self.nvTBDelegate getRealPath:iconNormal];
            [thisIcon setImage:[UIImage imageWithContentsOfFile:iconNormal]];
        }
    }
    
    NSMutableArray  *arrayM=[NSMutableArray array];
    
    for (int i = 0; i < iconsArray.count; i ++) {
        
        NSString *icon =  [self.nvTBDelegate getRealPath:iconsArray[i]];
        UIImage * imgItem = [UIImage imageNamed:[NSString stringWithFormat:icon]];
        if (imgItem) {
            [arrayM addObject:imgItem];
        }
    }
    //设置动画数组
    [thisIcon setAnimationImages:arrayM];
    //设置动画重复次数，默认为0，无限循环
    [thisIcon setAnimationRepeatCount:0];
    //设置动画时长,
    
    CGFloat intervalTime = interval/1000.0;
    [thisIcon setAnimationDuration:intervalTime*iconsArray.count];
    //开始动画
    [thisIcon startAnimating];
}

@end
