/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import "UZUIChatToolsBoard.h"
#import "UZUIChatToolsBasicCell.h"
#import "UZUIChatToolsAppendCell.h"
#import "UZUIChatToolsAttachment.h"
#import "NSDictionaryUtils.h"
#import "UZUIChatToolsAppendButton.h"
#import "UZAppUtils.h"
#import "UIView+UIChatTools.h"
#import "UIChatToolsSingleton.h"

static NSString *const basicEmotion = @"basicEmotion";
static NSString *const basicHeader = @"basicHeader";
static NSString *const appendEmotion = @"appendEmotion";


@interface UZUIChatToolsBoard ()<UIScrollViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *emojiDatas;
@property (nonatomic, weak) UIButton *currentIndexBtn;
@property (nonatomic, weak) UIScrollView *emojiContainer;
@property (nonatomic, weak) UIScrollView *bottomView;
@property (nonatomic, strong) UIView *backBtn;
@property (nonatomic, weak) UIButton *sendBtn;
@property (nonatomic, assign) BOOL isSend;
@property (nonatomic, strong) NSDictionary *paramsDict;
@end

@implementation UZUIChatToolsBoard

- (NSMutableArray *)emojiDatas {
    if (!_emojiDatas) {
        _emojiDatas = [NSMutableArray array];
    }
    return _emojiDatas;
}

#pragma mark --override set method

- (UIView *)recorderBoard {
    if (!_recorderBoard) {
        UZUIChatToolsRecorderView *recorderBoard = [[UZUIChatToolsRecorderView alloc] initWithFrame:self.bounds];
        recorderBoard.backgroundColor = [UIColor whiteColor];
        [self addSubview:recorderBoard];
        _recorderBoard = recorderBoard;
    }
    return _recorderBoard;
}

- (void)setIsOpenImageBoard:(BOOL)isOpenImageBoard {
    _isOpenImageBoard = isOpenImageBoard;
    if (isOpenImageBoard) {
        [self setupImageBoard];
    }
}

- (void)setAppendButtonDict:(NSDictionary *)appendButtonDict {
    _appendButtonDict = appendButtonDict;
    if (_appendButtonDict.count) {
        [self setupAppendBoard];
    }
}

- (void)setEmojiPathes:(NSMutableArray *)emojiPathes {
    _emojiPathes = emojiPathes;
    [self setupEmojiBoard];
}

- (void)setupImageBoard {
    if (!_imageBoard) {
        UZUIChatToolsImagePickerView *pickerView = [[UZUIChatToolsImagePickerView alloc] initWithFrame:self.bounds];
        
        pickerView.backgroundColor = [UIColor whiteColor];
        [self addSubview: pickerView];
        _imageBoard = pickerView;
    }
}

- (void)setupAppendBoard {
    if (!_appendBoard) {
        NSDictionary *styles = [_appendButtonDict dictValueForKey:@"styles" defaultValue:@{}];
        NSArray *buttons = [_appendButtonDict arrayValueForKey:@"buttons" defaultValue:@[]];
        NSInteger row = [styles integerValueForKey:@"row" defaultValue:2];
        NSInteger column = [styles integerValueForKey:@"column" defaultValue:4];
        NSInteger iconSize = [styles integerValueForKey:@"iconSize" defaultValue:30];
        NSInteger titleSize = [styles integerValueForKey:@"titleSize" defaultValue:13];
        NSString *titleColor = [styles stringValueForKey:@"titleColor" defaultValue:@"#000"];
        
        NSInteger page = ceil((float)buttons.count / (row * column)) ;
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        scroll.hidden = YES;
        scroll.showsHorizontalScrollIndicator = NO;
        [self addSubview:scroll];
        self.appendBoard = scroll;
        CGFloat scrollW = scroll.frame.size.width;
        CGFloat scrollH = scroll.frame.size.height;
        scroll.contentSize = CGSizeMake(scrollW * page, 0);
        scroll.pagingEnabled = YES;
        CGFloat btnW = scrollW / column;
        CGFloat btnH = scrollH / row;
        for (int i = 0 ; i < page; i++) {
            for (int j = 0; j < row; j++) {
                for (int k = 0; k < column; k++) {
                    NSInteger currentNum = i * row * column + j * column + k;
                    if (currentNum >= buttons.count)   return;
                    NSDictionary *buttonDict = buttons[currentNum];
                    NSString *normal = [buttonDict stringValueForKey:@"normal" defaultValue:@""];
                    normal = [_chatTools getPathWithUZSchemeURL:normal];
                    NSString *highlight = [buttonDict stringValueForKey:@"highlight" defaultValue:@""];
                    highlight = [_chatTools getPathWithUZSchemeURL:highlight];
                    NSString *title = [buttonDict stringValueForKey:@"title" defaultValue:@""];
                    
                    UZUIChatToolsAppendButton *btn = [[UZUIChatToolsAppendButton alloc] initWithFrame:CGRectMake(i * scrollW + k * btnW, j * btnH, btnW, btnH)];
                    [btn setTitle:title forState:UIControlStateNormal];
                    [btn setTitleColor:[UZAppUtils colorFromNSString:titleColor] forState:UIControlStateNormal];
                    btn.titleLabel.font = [UIFont systemFontOfSize:titleSize];
                    [btn setImage:[self getImageWithImage:[UIImage imageWithContentsOfFile:normal] size:CGSizeMake(iconSize, iconSize)] forState:UIControlStateNormal];
                    [btn setImage:[self getImageWithImage:[UIImage imageWithContentsOfFile:highlight] size:CGSizeMake(iconSize, iconSize)] forState:UIControlStateHighlighted];
                    btn.tag = currentNum;
                    [btn addTarget:self action:@selector(appendClick:) forControlEvents:UIControlEventTouchUpInside];
                    [scroll addSubview:btn];
                }
            }
        }
    }
}

- (void)appendClick:(UIButton *)btn {
    
    !self.appendBtnClickCallback ? : self.appendBtnClickCallback(btn.tag);
}

- (void)setupEmojiBoard {
    if (!_emojiBoard) {
        UIView *emojiBoard = [[UIView alloc] initWithFrame:self.bounds];
        emojiBoard.hidden = YES;
        _emojiBoard = emojiBoard;
        [self addSubview:emojiBoard];
        
        //contentView
        UIScrollView *emojiContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, emojiBoard.width, 180)];
        emojiContainer.delegate = self;
        [emojiBoard addSubview:emojiContainer];
        emojiContainer.pagingEnabled = YES;
        emojiContainer.contentSize = CGSizeMake(_emojiPathes.count * emojiBoard.width, 0);
        emojiContainer.showsHorizontalScrollIndicator = NO;
        self.emojiContainer = emojiContainer;
        
        for (int i = 0 ; i < _emojiPathes.count; i++) {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            
            if (i == 0) {
                layout.minimumLineSpacing = 10;
                layout.minimumInteritemSpacing = 10;
                layout.itemSize = CGSizeMake(30, 30);
                layout.headerReferenceSize = CGSizeMake(self.bounds.size.width, 30);
            }else {
                layout.minimumLineSpacing = 15;
                layout.minimumInteritemSpacing = 15;
                layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
                layout.itemSize = CGSizeMake(40, 45);
            }
           
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(i * emojiBoard.width, 0, emojiBoard.width, 180) collectionViewLayout:layout];
            collectionView.tag = i;
            [collectionView registerClass:[UZUIChatToolsBasicCell class] forCellWithReuseIdentifier:basicEmotion];
            [collectionView registerClass:[UZUIChatToolsAppendCell class] forCellWithReuseIdentifier:appendEmotion];
            [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:basicHeader];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.backgroundColor = [UIColor whiteColor];
            [emojiContainer addSubview:collectionView];
        }
        //bottomView
        CGFloat sendBtnW = 80;
        UIScrollView *bottomView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(emojiContainer.frame), CGRectGetWidth(emojiContainer.frame) , emojiBoard.bounds.size.height - CGRectGetMaxY(emojiContainer.frame))];
        bottomView.backgroundColor = [UIColor whiteColor];
        bottomView.showsHorizontalScrollIndicator = NO;
        [emojiBoard addSubview:bottomView];
        self.bottomView = bottomView;
        CGFloat btnW = 45;
        for (int i = 0 ; i < _emojiPathes.count; i++) {

            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i * btnW, 0, btnW, bottomView.frame.size.height)];
            
            //取出索引图标
            NSArray *array = [_emojiPathes[i] componentsSeparatedByString:@"/"];
            NSString *lastStr = [array lastObject];
            NSString *supStr = [_chatTools getPathWithUZSchemeURL:_emojiPathes[i]];
            NSString *indexPath = [NSString stringWithFormat:@"%@/%@.png",supStr,lastStr];
            UIImage *indexImage = [UIImage imageWithContentsOfFile:indexPath];
//            indexImage = [self getImageWithImage:indexImage size:CGSizeMake(30, 30)];
            btn.imageEdgeInsets = UIEdgeInsetsMake(33,35, 33, 35);
            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [btn setImage:indexImage forState:UIControlStateNormal];
            btn.tag = i + 10;
            if (i == 0) {
                [self indexBtnClick:btn];
            }
            [btn addTarget:self action:@selector(indexBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [bottomView addSubview:btn];
            
            //解析数据
            NSString *realPath = [NSString stringWithFormat:@"%@/%@.json",supStr,lastStr];
            
            NSData *originalData = [[NSData alloc] initWithContentsOfFile:realPath];
            if (!originalData) return;
            NSArray *emojiDatas = [NSJSONSerialization JSONObjectWithData:originalData options:NSJSONReadingAllowFragments error:nil];
            [self.emojiDatas addObject:emojiDatas];
        }
        bottomView.contentSize = CGSizeMake(btnW * _emojiPathes.count, 0);
        //sendBtn
        UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(emojiContainer.width - sendBtnW, CGRectGetMinY(bottomView.frame), sendBtnW, bottomView.height)];

        self.paramsDict =  UIChatToolsSingleton.sharedSingleton.paramsDict;
        NSDictionary *chatBoxInfo = [self.paramsDict dictValueForKey:@"chatBox" defaultValue:@{}];
        NSDictionary *sendBtnInfo = [chatBoxInfo dictValueForKey:@"sendBtn" defaultValue:@{}];
//        NSString *sendTitle = [sendBtnInfo stringValueForKey:@"title" defaultValue:@"发送"];
//        NSDictionary *styleDict = [self.paramsDict dictValueForKey:@"styles" defaultValue:@{}];
//        NSString *bg = [[styleDict dictValueForKey:@"sendBtn" defaultValue:@{}] stringValueForKey:@"bg" defaultValue:@"rgba(46,178,243,1)" ];
//        NSString *titleColor = [[styleDict dictValueForKey:@"sendBtn" defaultValue:@{}] stringValueForKey:@"titleColor" defaultValue:@"#fff" ];
//        CGFloat titleSize = [[styleDict dictValueForKey:@"sendBtn" defaultValue:@{}] floatValueForKey:@"titleSize"  defaultValue:14];
        sendBtn.backgroundColor = [UIColor colorWithRed:46 / 255.0 green:178 / 255.0 blue:243 / 255.0 alpha:1.0];
//        sendBtn.backgroundColor = [UZAppUtils colorFromNSString:bg];
        
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [sendBtn setTitleColor:[UZAppUtils colorFromNSString:@"#fff"] forState:UIControlStateNormal];
        [sendBtn addTarget:self action:@selector(sendText:) forControlEvents:UIControlEventTouchUpInside];
        [emojiBoard addSubview:sendBtn];
        self.sendBtn = sendBtn;
    }
}

- (void)addFace:(NSString *)path {
    //加入到_emojiPathes数组中
    [_emojiPathes addObject:path];
    
    //添加collectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 15;
    layout.minimumInteritemSpacing = 15;
    layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    layout.itemSize = CGSizeMake(70, 70);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake((_emojiPathes.count - 1) * self.emojiBoard.width, 0, self.emojiBoard.width, 180) collectionViewLayout:layout];
    collectionView.tag = _emojiPathes.count - 1;
    [collectionView registerClass:[UZUIChatToolsAppendCell class] forCellWithReuseIdentifier:appendEmotion];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.emojiContainer addSubview:collectionView];
    
    //添加索引button
    CGFloat btnW = 45;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((_emojiPathes.count - 1) * btnW, 0, btnW, self.bottomView.height)];
    NSArray *array = [path componentsSeparatedByString:@"/"];
    NSString *lastStr = [array lastObject];
    NSString *supStr = [_chatTools getPathWithUZSchemeURL:path];
    NSString *indexPath = [NSString stringWithFormat:@"%@/%@.png",supStr,lastStr];
    UIImage *indexImage = [UIImage imageWithContentsOfFile:indexPath];
    indexImage = [self getImageWithImage:indexImage size:CGSizeMake(30, 30)];
    [btn setImage:indexImage forState:UIControlStateNormal];
    btn.tag = _emojiPathes.count - 1 + 10;
    [btn addTarget:self action:@selector(indexBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:btn];
    
    //解析数据
    NSString *realPath = [NSString stringWithFormat:@"%@/%@.json",supStr,lastStr];
    NSData *originalData = [[NSData alloc] initWithContentsOfFile:realPath];
    if (!originalData) return;
    NSArray *emojiDatas = [NSJSONSerialization JSONObjectWithData:originalData options:NSJSONReadingAllowFragments error:nil];
    [self.emojiDatas addObject:emojiDatas];
    self.emojiContainer.contentSize = CGSizeMake(self.emojiContainer.width * _emojiPathes.count, 0);
    self.bottomView.contentSize = CGSizeMake(btnW * _emojiPathes.count, 0);
}

- (void)indexBtnClick:(UIButton *)btn {
    self.currentIndexBtn.enabled = YES;
    self.currentIndexBtn.backgroundColor = [UIColor clearColor];
    btn.enabled = NO;
    btn.backgroundColor = [UIColor lightGrayColor];
    self.currentIndexBtn = btn;
    
    [self.emojiContainer setContentOffset:CGPointMake(self.emojiContainer.width * (btn.tag-10), 0) animated:YES];
    //切换sendBtn
    if (btn.tag - 10 == 0) {
        _isSend = YES;
        self.sendBtn.width = 80;
        self.sendBtn.x = self.emojiContainer.width - 80;
        [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateNormal];
    }
    else {
        
        BOOL isShowAddImg = [self.paramsDict boolValueForKey:@"isShowAddImg" defaultValue:true];
        if (isShowAddImg) {
            self.sendBtn.width = 60;

        }else{
            self.sendBtn.width = 0;

        }
            _isSend = NO;
            self.sendBtn.x = self.emojiContainer.width - 60;
            [self.sendBtn setTitle:@"" forState:UIControlStateNormal];
            [self.sendBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"res_UIChatTools/add.png" ofType:nil]] forState:UIControlStateNormal];
        
    }
}

- (void)sendText:(UIButton *)btn {
    NSMutableString *strM = [NSMutableString string];
    [_textView.attributedText enumerateAttributesInRange:NSMakeRange(0, _textView.attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSString *str = nil;
        UZUIChatToolsAttachment *attachment = attrs[@"NSAttachment"];
        if (attachment) { // 表情
            str = attachment.emotionStr;
            if (str) {
                [strM appendString:str];
            }
        } else { // 文字
            
            str = [_textView.attributedText.string substringWithRange:range];
            if (str) {
                [strM appendString:str];
            }
        }
    }];
    if (_isSend) {
        !self.sendContent ? : self.sendContent(strM);
    }else {
        !self.addFaceCallback ? : self.addFaceCallback();
    }
}


#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
// 返回多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView.tag == 0) {
        NSArray *array = self.emojiDatas[collectionView.tag];
        return array.count;
    }else {
        return 1;
    }
}

// 返回每组多少行
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *arr = nil;
    
    if (collectionView.tag < self.emojiDatas.count) {
        arr = self.emojiDatas[collectionView.tag];
    }
    
    if (collectionView.tag == 0) {
        return [arr[section][@"emotions"] count];
    }else {
        return arr.count;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *collectionViewCell = nil;
    if (collectionView.tag == 0) {
        UZUIChatToolsBasicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:basicEmotion forIndexPath:indexPath];
        NSArray *arr = self.emojiDatas[collectionView.tag];
        NSString *name = arr[indexPath.section][@"emotions"][indexPath.row][@"name"];
        NSString *text = arr[indexPath.section][@"emotions"][indexPath.row][@"text"];
        NSString *supStr = [_chatTools getPathWithUZSchemeURL:_emojiPathes[collectionView.tag]];
        NSString *realPath = [NSString stringWithFormat:@"%@/%@",supStr,name];
        
        NSArray *array = [_emojiPathes[collectionView.tag] componentsSeparatedByString:@"/"];
        NSString *lastStr = [array lastObject];

        cell.imageView.image = [UIImage imageNamed:realPath];
        cell.emotionName = lastStr;
        cell.text = text;
        collectionViewCell = cell;
    }else {
        UZUIChatToolsAppendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:appendEmotion forIndexPath:indexPath];
//        cell.backgroundColor = [UIColor redColor];
        NSArray *arr = self.emojiDatas[collectionView.tag];
        NSString *name = arr[indexPath.row][@"name"];
        NSString *text = arr[indexPath.row][@"text"];
        NSString *supStr = [_chatTools getPathWithUZSchemeURL:_emojiPathes[collectionView.tag]];
        NSString *realPath = [NSString stringWithFormat:@"%@/%@",supStr,name];
        NSArray *array = [_emojiPathes[collectionView.tag] componentsSeparatedByString:@"/"];
        NSString *lastStr = [array lastObject];
        cell.icon.image = [UIImage imageWithContentsOfFile:realPath];
        NSString *title = [text substringFromIndex:1];
        title = [title substringToIndex:title.length - 1];
        cell.title.text = title;
        cell.emotionName = lastStr;
        cell.text = text;
        collectionViewCell = cell;
    }
    return collectionViewCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:basicHeader forIndexPath:indexPath];
    if (collectionView.tag == 0) {
        NSArray *arr = self.emojiDatas[collectionView.tag];
        UILabel *title = [[UILabel alloc] initWithFrame:reusableView.bounds];
        title.text = [NSString stringWithFormat:@"%@",arr[indexPath.section][@"label"]];
        title.font = [UIFont systemFontOfSize:10];
        [reusableView addSubview:title];
    }
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    UZUIChatToolsAttachment *attachment = [[UZUIChatToolsAttachment alloc] init];
    NSArray *arr = self.emojiDatas[collectionView.tag];
    if (collectionView.tag == 0) {
        UZUIChatToolsBasicCell *cell = (UZUIChatToolsBasicCell *)[collectionView cellForItemAtIndexPath:indexPath];
        attachment.image = cell.imageView.image;
        attachment.emotionStr = arr[indexPath.section][@"emotions"][indexPath.row][@"text"];
        
        attachment.bounds = CGRectMake(0, -3, 18, 18);
        NSRange range = _textView.selectedRange;
        // 设置textView的文字
        NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
        
        NSAttributedString *imageAttr = [NSMutableAttributedString attributedStringWithAttachment:attachment];
        
        [textAttr replaceCharactersInRange:_textView.selectedRange withAttributedString:imageAttr];
        [textAttr addAttributes:@{NSFontAttributeName : _textView.font} range:NSMakeRange(_textView.selectedRange.location, 1)];
        
        _textView.attributedText = textAttr;
        
        // 会在textView后面插入空的,触发textView文字改变
        [_textView insertText:@""];
        
        // 设置光标位置
        _textView.selectedRange = NSMakeRange(range.location + 1, 0);
        
        //callback
        !self.faceListenerCallback ? : self.faceListenerCallback(cell.emotionName,cell.text);
    }else {
        UZUIChatToolsAppendCell *cell = (UZUIChatToolsAppendCell *)[collectionView cellForItemAtIndexPath:indexPath];
        attachment.image = cell.icon.image;
        attachment.emotionStr = arr[indexPath.section][@"emotions"][indexPath.row][@"text"];
        
        attachment.bounds = CGRectMake(0, -3, 18, 18);
        NSRange range = _textView.selectedRange;
        // 设置textView的文字
        NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
        
        NSAttributedString *imageAttr = [NSMutableAttributedString attributedStringWithAttachment:attachment];
        
        [textAttr replaceCharactersInRange:_textView.selectedRange withAttributedString:imageAttr];
        [textAttr addAttributes:@{NSFontAttributeName : _textView.font} range:NSMakeRange(_textView.selectedRange.location, 1)];
        
        _textView.attributedText = textAttr;
        
        // 会在textView后面插入空的,触发textView文字改变
        [_textView insertText:@""];
        
        // 设置光标位置
        _textView.selectedRange = NSMakeRange(range.location + 1, 0);
        //callback
        !self.faceListenerCallback ? : self.faceListenerCallback(cell.emotionName,cell.text);
    }
}

#pragma mark -----------------UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.emojiContainer]) {
        NSUInteger index = scrollView.contentOffset.x / scrollView.width;
        UIButton *btn = (UIButton *)[self.bottomView viewWithTag:(index + 10)];
        [self indexBtnClick:btn];
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
