/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import "UZUIChatToolsImagePickerView.h"
#import "UZUIChatToolsImageCell.h"
#import "UZUIChatToolsImageUtils.h"
#import "UIChatToolsSingleton.h"
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"
static NSString * const ID = @"image";

#define lightBlueColor [UIColor colorWithRed:46 / 255.0 green:178 / 255.0 blue:243 / 255.0 alpha:1.0]

@interface UZUIChatToolsImagePickerView ()<UICollectionViewDelegate, UICollectionViewDataSource, UZUIChatToolsImageCellDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIButton *originalImageButton;
@property (nonatomic, strong) NSMutableArray *seletedArray;
@property (nonatomic,strong)NSDictionary *paramsDict;

@end

@implementation UZUIChatToolsImagePickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.paramsDict =  UIChatToolsSingleton.sharedSingleton.paramsDict;
        [self loadData];
        [self setupChildViews];
       
    }
    return self;
}

- (void)loadData{
    [UZUIChatToolsImageUtils loadLimitImagesFromCamerarollSucess:^(NSArray *images) {
   
         self.dataArr = images;
        NSOperationQueue *waitQueue = [[NSOperationQueue alloc] init];
        [waitQueue addOperationWithBlock:^{
            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0]];
            [UZUIChatToolsImageUtils loadImagesFromCamerarollSucess:^(NSArray *images) {
                NSMutableArray * targetArray = [NSMutableArray arrayWithArray: images];

                [self.dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [targetArray replaceObjectAtIndex:idx withObject:obj];
                }];
                dispatch_async(dispatch_get_main_queue(), ^{

                self.dataArr = targetArray;
                    });
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
     
        }];
       
     
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)setDataArr:(NSArray *)dataArr {
    _dataArr = dataArr;
    [self.collectionView reloadData];
}

- (void)setupChildViews {
    //collectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(150, 150);
    layout.minimumInteritemSpacing = 4;
    layout.minimumLineSpacing = 4;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 180) collectionViewLayout:layout];
    
    [collectionView registerClass:[UZUIChatToolsImageCell class] forCellWithReuseIdentifier:ID];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"haha"];
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    //bottomView
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(collectionView.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(collectionView.frame))];
    [self addSubview:bottomView];
    _bottomView = bottomView;
    CGFloat btnW = 70;
    NSArray *titleArr = @[@"相册",@"编辑",@"原图"];
    for (int i = 0; i < titleArr.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i * btnW, 0, btnW, CGRectGetHeight(bottomView.frame))];
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:lightBlueColor forState:UIControlStateNormal];
        if (i == 1 && !self.seletedArray.count) {
            btn.enabled = NO;
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
          
        }
        if (i == 2) {
         
            [btn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"res_UIChatTools/original.png" ofType:nil]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"res_UIChatTools/original_selected.png" ofType:nil]] forState:UIControlStateSelected];
        }
        btn.tag = i;
        [btn addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:btn];
    }
    
    CGFloat sendBtnW = 60;
    CGFloat sendBtnY = 4;
    CGFloat magin = 8;
    
    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(bottomView.frame) - magin - sendBtnW, sendBtnY, sendBtnW, CGRectGetHeight(bottomView.frame) - sendBtnY * 2)];
    sendBtn.tag = titleArr.count;
    sendBtn.layer.borderWidth = 0.5;
    NSDictionary *chatBoxInfo = [self.paramsDict dictValueForKey:@"chatBox" defaultValue:@{}];
    NSDictionary *sendBtnInfo = [chatBoxInfo dictValueForKey:@"sendBtn" defaultValue:@{}];
    NSString *sendTitle = [sendBtnInfo stringValueForKey:@"title" defaultValue:@"发送"];
    NSDictionary *styleDict = [self.paramsDict dictValueForKey:@"styles" defaultValue:@{}];
    NSString *bg = [[styleDict dictValueForKey:@"sendBtn" defaultValue:@{}] stringValueForKey:@"bg" defaultValue:@"rgba(46,178,243,1)" ];
    NSString *titleColor = [[styleDict dictValueForKey:@"sendBtn" defaultValue:@{}] stringValueForKey:@"titleColor" defaultValue:@"#fff" ];
    CGFloat titleSize = [[styleDict dictValueForKey:@"sendBtn" defaultValue:@{}] floatValueForKey:@"titleSize"  defaultValue:14];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UZAppUtils colorFromNSString:@"#fff"] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[self getImageWithColor:[UZAppUtils colorFromNSString:@"rgba(46,178,243,1)"] size:sendBtn.frame.size] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[self getImageWithColor:[UIColor lightGrayColor] size:sendBtn.frame.size] forState:UIControlStateDisabled];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
//    [sendBtn setTitle:sendTitle forState:UIControlStateNormal];
//    [sendBtn setTitleColor:[UZAppUtils colorFromNSString:titleColor] forState:UIControlStateNormal];
//    [sendBtn setBackgroundImage:[self getImageWithColor:[UZAppUtils colorFromNSString:bg] size:sendBtn.frame.size] forState:UIControlStateNormal];
//    [sendBtn setBackgroundImage:[self getImageWithColor:[UZAppUtils colorFromNSString:bg] size:sendBtn.frame.size] forState:UIControlStateDisabled];
//    sendBtn.titleLabel.font = [UIFont systemFontOfSize:titleSize];
    
    sendBtn.enabled = self.seletedArray.count ? YES : NO;
    sendBtn.alpha = sendBtn.enabled ? 1.0 : 0.4;
    [sendBtn addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:sendBtn];
}

- (void)bottomButtonClick:(UIButton *)btn {
    if (btn.tag == 2) {
        btn.selected = !btn.selected;
        self.originalImageButton = btn;
    }
    if ([self.delegate respondsToSelector:@selector(imagePickerView:didClickedButton:isOriginalImage:selectedArray:)]) {
        [self.delegate imagePickerView:self didClickedButton:btn isOriginalImage:self.originalImageButton.selected selectedArray:self.seletedArray];
    }
}

#pragma mark ---UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UZUIChatToolsImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    UZUIChatToolsImageModel *model = self.dataArr[indexPath.item];
    model.offset = collectionView.contentOffset;
    cell.model = model;
    cell.delegate = self;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray *cells =  [self.collectionView visibleCells];
    for (UZUIChatToolsImageCell *cell in cells) {
        UZUIChatToolsImageModel *model = self.dataArr[[[self.collectionView indexPathForCell:cell] item]];
        model.offset = scrollView.contentOffset;
        cell.model = model;
    };
}

#pragma mark ---UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UZUIChatToolsImageModel *model = self.dataArr[indexPath.item];
    return model.image.size;
}

#pragma mark ----DXImageCollectionCellDelegate

- (void)imageCell:(UZUIChatToolsImageCell *)imageCell didClickedButton:(UIButton *)button {
    UZUIChatToolsImageModel *selectedModel = imageCell.model;
    for (UZUIChatToolsImageModel *model in self.dataArr) {
        if ([model isEqual:selectedModel]) {
            if ([self.seletedArray containsObject:model]) {
                model.count = 0;
                [self.seletedArray removeObject:model];
                NSMutableArray *temp = [NSMutableArray arrayWithCapacity:10];
                
                for (UZUIChatToolsImageModel *seltedModel in self.seletedArray) {
                    [temp addObject:seltedModel];
                }
                [self.seletedArray removeAllObjects];
                [self.seletedArray addObjectsFromArray:temp];
                
            }else{
                [self.seletedArray addObject:model];
            }
        }
    }
    for (UZUIChatToolsImageModel *model in self.dataArr) {
        NSUInteger index = [self.seletedArray indexOfObject:model];
        if (index != NSNotFound && index +1) {
            model.count = index +1;
        }else{
            model.count = 0;
        }
    }
    [self.collectionView reloadData];
    
    
    //control bottomView
    UIButton *editBtn = [_bottomView viewWithTag:1];
    editBtn.enabled = self.seletedArray.count == 1 ? YES : NO;
    
    UIButton *sendBtn = (UIButton *)_bottomView.subviews.lastObject;
    sendBtn.enabled = self.seletedArray.count ? YES : NO;
    sendBtn.alpha = sendBtn.enabled ? 1.0 : 0.4;
}

#pragma mark ---lazy
- (NSMutableArray *)seletedArray{
    if (!_seletedArray) {
        _seletedArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _seletedArray;
}

- (UIImage *)getImageWithColor:(UIColor *)color size:(CGSize)size {
    //开启图形上下文
    UIGraphicsBeginImageContext(size);
    //设置图形上下文的填充颜色
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    //设置填充区域
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    //得到图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return image;
}


@end
