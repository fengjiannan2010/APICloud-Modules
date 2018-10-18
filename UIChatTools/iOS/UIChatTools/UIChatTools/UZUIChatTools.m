/**
  * APICloud Modules
  * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
  * Licensed under the terms of the The MIT License (MIT).
  * Please see the license.html included with this distribution for details.
  */


#import "UZUIChatTools.h"
#import "NSDictionaryUtils.h"
#import "UZUIChatToolsView.h"
#import "UZAppUtils.h"
#import "UZUIChatToolsBoard.h"
#import "UZUIChatToolsAttachment.h"
#import "UIView+UIChatTools.h"
#import "UIChatToolsSingleton.h"
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define customBoardH  217

@interface UZUIChatTools ()<UZUIChatToolsViewDelegate,UIGestureRecognizerDelegate,UZUIChatToolsImagePickerViewDelegate, UZUIChatToolsRecorderViewDelegate,UITextViewDelegate,UITextFieldDelegate>
{
    int faceCbId, appendFaceCbId;
    int albumCbId, editCbId, sendCbId;
    int moveCbId, changeCbId, valueChangedCbId;
    int pressCbId, auditionCbId, auditionCancelCbId, sendCbId_talkback, cancelCbId, shortTimeCbId, startCbId, stopCbId, auditionCbId_record, sendCbId_record,cancelCbId_record;
}



@property (nonatomic, weak) UZUIChatToolsView *chatToolsView;
@property (nonatomic, strong)UIView *maskView;
@property (nonatomic, assign) BOOL isCustomBoardShow;
@property (nonatomic, weak) UIButton *currentButton;
@property (nonatomic, strong) NSMutableArray *emotions;
@property (nonatomic, copy) NSDictionary *appendDict, *faceDict, *imageDict;
@property (nonatomic, copy) NSDictionary *packetDict;
@property (nonatomic, copy) NSDictionary *recorderDict;
@property (nonatomic, copy) NSDictionary *videoDict;
@property (nonatomic, weak) UZUIChatToolsBoard *board;
@property (nonatomic, assign) int toolsListenerCbId, openCbId;
@property(nonatomic, assign)int chatBoxListenerCbId;
@property (nonatomic, assign) NSInteger recorderListenerCbId;

@end

@implementation UZUIChatTools

- (UZUIChatToolsBoard *)board {
    if (!_board) {
        UZUIChatToolsBoard *board = [[UZUIChatToolsBoard alloc] initWithFrame:CGRectMake(0, screenH, screenW, customBoardH)];
        board.backgroundColor = [UIColor whiteColor];
        board.chatTools = self;
        _board = board;
        
        [self addSubview:board fixedOn:nil fixed:YES];
    }
    return _board;
}

- (id)initWithUZWebView:(id)webView {
    if (self = [super initWithUZWebView:webView]) {
         //监听键盘改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        self.recorderListenerCbId = -1;
    }
    return self;
}



- (void)open:(NSDictionary *)params {
    UIChatToolsSingleton.sharedSingleton.paramsDict = params;
    self.openCbId = [params intValueForKey:@"cbId" defaultValue:-1];
    NSArray *arrray = [params arrayValueForKey:@"emotions" defaultValue:@[]];
    self.emotions = [NSMutableArray  arrayWithArray:arrray];
    self.appendDict = [[params dictValueForKey:@"tools" defaultValue:@{}] dictValueForKey:@"append" defaultValue:@{}];
    self.imageDict = [[params dictValueForKey:@"tools" defaultValue:@{}] dictValueForKey:@"image" defaultValue:@{}];
    self.faceDict = [[params dictValueForKey:@"tools" defaultValue:@{}] dictValueForKey:@"face" defaultValue:@{}];
    self.recorderDict = [[params dictValueForKey:@"tools" defaultValue:@{}]dictValueForKey:@"recorder" defaultValue:@{}];
    CGFloat toolH = [[params dictValueForKey:@"tools" defaultValue:@{}] floatValueForKey:@"h" defaultValue:44];

    if (!_chatToolsView                                                                                                                                                                                                                                                                                                                                                                                                                                         ) {
        NSDictionary *stylesDict = [params dictValueForKey:@"styles" defaultValue:@{}];
        NSDictionary *maskDict = [stylesDict dictValueForKey:@"mask" defaultValue:nil];
        
        if (maskDict) {
            NSString *maskBgColor = [maskDict stringValueForKey:@"bgColor" defaultValue:@"rgba(0,0,0,0.5)"];
            
            self.maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenW, screenH)];
            self.maskView.backgroundColor =[UZAppUtils colorFromNSString:maskBgColor];
            self.maskView.userInteractionEnabled = YES;
            UITapGestureRecognizer * maskViewTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapMaskView:)];
            [self.maskView addGestureRecognizer:maskViewTap];
            [self.viewController.view addSubview:self.maskView];
            
            UIChatToolsSingleton.sharedSingleton.maskView = self.maskView;
            
        }
        UZUIChatToolsView *chatToolsView = [[UZUIChatToolsView alloc] initWithParams:params chatTools:self];

        chatToolsView.delegate = self;
        _chatToolsView = chatToolsView;
//        [self addSubview:chatToolsView fixedOn:nil fixed:YES];
        [self.viewController.view addSubview:chatToolsView];
    
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tap.delegate = self;
        UIWebView *superWebView = (UIWebView *)self.uzWebView;
        [superWebView.scrollView addGestureRecognizer:tap];
        
        __weak typeof(self) weakSelf = self;
        //行数改变
        [self.chatToolsView.chatBoxView textHeightDidChanged:^(NSString *text, CGFloat textHeight) {
            //chatToolsView frame
            weakSelf.chatToolsView.y += weakSelf.chatToolsView.chatBoxView.height - textHeight;
            
            weakSelf.chatToolsView.height = textHeight + toolH+6;
            
            //chatBoxView frame
            weakSelf.chatToolsView.chatBoxView.height = textHeight;
            
            //callback
            [weakSelf chatBoxChangeCallback];
        }];
        //文字改变的回调
        [self.chatToolsView.chatBoxView setTextChangeBlock:^{
            if (valueChangedCbId > 0) {
                NSMutableString *strM = [NSMutableString string];
                [weakSelf.chatToolsView.chatBoxView.attributedText enumerateAttributesInRange:NSMakeRange(0, weakSelf.chatToolsView.chatBoxView.attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
                    NSString *str = nil;
                    UZUIChatToolsAttachment *attachment = attrs[@"NSAttachment"];
                    if (attachment) { // 表情
                        str = attachment.emotionStr ;
                        if (str) {
                            [strM appendString:str];

                        }
                    } else { // 文字
                        str = [weakSelf.chatToolsView.chatBoxView.attributedText.string substringWithRange:range];
                        if (str) {
                            [strM appendString:str];
                            
                        }                    }
                }];
                [weakSelf sendResultEventWithCallbackId:valueChangedCbId dataDict:@{@"value" : strM} errDict:nil doDelete:NO];
                
              
            }
        }];
        //send
        [self.chatToolsView setSendMessage:^(NSString *message) {
            [weakSelf sendResultEventWithCallbackId:weakSelf.openCbId dataDict:@{@"eventType" : @"send",@"msg" : message} errDict:nil doDelete:NO];
        }];
        
        [self.board setSendContent:^(NSString *content) {
           
               [weakSelf sendResultEventWithCallbackId:weakSelf.openCbId dataDict:@{@"eventType" : @"send",@"msg" : content} errDict:nil doDelete:NO];
        }];
      
        [self sendResultEventWithCallbackId:self.openCbId dataDict:@{@"eventType" : @"show"} errDict:nil doDelete:NO];
    }

   
}

-(void)clearText:(NSDictionary *)paramsDict_{
    
    self.chatToolsView.chatBoxView.text = nil;
}

- (void)tapMaskView:(UITapGestureRecognizer *)sender{

    if (_isCustomBoardShow) {
        [self hideCustomBoard];
    }
    _isCustomBoardShow = NO;
    self.currentButton.selected = NO;
    [self.chatToolsView.chatBoxView resignFirstResponder];
}

- (void)setAppendButton:(NSDictionary *)params {
    if (self.appendDict.count) {
        int setAppendCbId = [params intValueForKey:@"cbId" defaultValue:-1];
        self.board.appendButtonDict = params;
        __weak typeof(self) weakSelf = self;
        [self.board setAppendBtnClickCallback:^(NSInteger index) {
            [weakSelf sendResultEventWithCallbackId:setAppendCbId dataDict:@{@"index" : @(index)} errDict:nil doDelete:NO];
        }];
    }
}

- (void)faceListener:(NSDictionary *)params {
    if (self.faceDict.count) {
        int faceListenerCbId = [params intValueForKey:@"cbId" defaultValue:-1];
        NSString *faceListenerName = [params stringValueForKey:@"name" defaultValue:@""];
        if ([faceListenerName isEqualToString:@"face"]) {
            if (faceCbId > 0) {
                [self deleteCallback:faceCbId];
            }
            faceCbId = faceListenerCbId;
        }
        if ([faceListenerName isEqualToString:@"appendFace"]) {
            if (appendFaceCbId > 0) {
                [self deleteCallback:appendFaceCbId];
            }
            appendFaceCbId = faceListenerCbId;
        }

        __weak typeof(self)weakSelf = self;
        //send
        [self.board setSendContent:^(NSString *content) {
            [weakSelf sendResultEventWithCallbackId:weakSelf.openCbId dataDict:@{@"eventType" : @"send",@"msg" : content} errDict:nil doDelete:NO];
        }];
        
        //faceListener
        [self.board setFaceListenerCallback:^(NSString *emotionName, NSString *text) {
            if (faceCbId > 0) {
                [weakSelf sendResultEventWithCallbackId:faceCbId dataDict:@{@"emotionName" : emotionName, @"text" : text} errDict:nil doDelete:NO];
            }
        }];
        [self.board setAddFaceCallback:^{
            if (faceListenerCbId > 0 && [faceListenerName isEqualToString:@"appendFace"]) {
                if (appendFaceCbId > 0) {
                    [weakSelf sendResultEventWithCallbackId:appendFaceCbId dataDict:nil errDict:nil doDelete:NO];
                }
            }
        }];
    }
}

- (void)addFace:(NSDictionary *)params {
    if (self.faceDict.count) {
        int addFaceCbId = [params intValueForKey:@"cbId" defaultValue:-1];
        NSString *path = [params stringValueForKey:@"path" defaultValue:@""];
        if (self.board) {
            [self.emotions addObject:path];
            [self.board addFace:path];
            [self sendResultEventWithCallbackId:addFaceCbId dataDict:@{@"status" : @(YES)} errDict:nil doDelete:YES];
        }
    }
}

- (void)imageListener:(NSDictionary *)params {
    if (self.imageDict.count) {
        int imageListenerCbId = [params intValueForKey:@"cbId" defaultValue:-1];
//        NSString *imageListenerName = [params stringValueForKey:@"name" defaultValue:@"send"];
//        if ([imageListenerName isEqualToString:@"album"]) {
            if (albumCbId > 0) {
                [self deleteCallback:albumCbId];
            }
            albumCbId = imageListenerCbId;
//        }
//        if ([imageListenerName isEqualToString:@"edit"]) {
            if (editCbId > 0) {
                [self deleteCallback:editCbId];
            }
            editCbId = imageListenerCbId;
//        }
//        if ([imageListenerName isEqualToString:@"send"]) {
            if (sendCbId > 0) {
                [self deleteCallback:sendCbId];
            }
            sendCbId = imageListenerCbId;
//        }

    }
}

- (void)toolsListener:(NSDictionary *)params {
  
    self.toolsListenerCbId = [params intValueForKey:@"cbId" defaultValue:-1];
}

- (void)recorderListener:(NSDictionary *)params {
    
    if (self.recorderDict.count ) {
        int listenerCbId = [params intValueForKey:@"cbId" defaultValue:-1];
        self.recorderListenerCbId = listenerCbId;
    }
 
    }
   
- (void)startTimer:(NSDictionary *)params {

//    self.board.recorderBoard.isStartTimer = YES;
    [self.board.recorderBoard creatTimer];
    // 模拟点击....
    
}
- (void)close:(NSDictionary *)params {
    [self.chatToolsView removeFromSuperview];
    self.chatToolsView = nil;
    [self.board removeFromSuperview];
    self.board = nil;
}

- (void)show:(NSDictionary *)params {
    self.chatToolsView.hidden = NO;
    self.board.hidden = NO;
}

- (void)hide:(NSDictionary *)params {
    self.chatToolsView.hidden = YES;
    self.board.hidden = YES;
    [self.chatToolsView.chatBoxView resignFirstResponder];

}

- (void)popupKeyboard:(NSDictionary *)params {
    [self.chatToolsView.chatBoxView becomeFirstResponder];
}

- (void)closeKeyboard:(NSDictionary *)params {
    [self.chatToolsView.chatBoxView resignFirstResponder];
}

- (void)popupBoard:(NSDictionary *)params {
    NSString *target = [params stringValueForKey:@"target" defaultValue:@"emotion"];
    if ([target isEqualToString:@"emotion"]) {
        [self.chatToolsView clickAction:self.chatToolsView.faceButton];
    }
    if ([target isEqualToString:@"extras"]) {
        [self.chatToolsView clickAction:self.chatToolsView.appendButton];

    }
}

- (void)closeBoard:(NSDictionary *)params {
    self.currentButton.selected = NO;
    [self hideCustomBoard];
}

- (void)value:(NSDictionary *)params {
    int valueCbId = [params intValueForKey:@"cbId" defaultValue:-1];
    NSString *msg = [params stringValueForKey:@"msg" defaultValue:nil];
    if (msg) {
        self.chatToolsView.chatBoxView.text = msg;
    }else {
        NSMutableString *strM = [NSMutableString string];
        __weak typeof(self) weakSelf = self;
        [self.chatToolsView.chatBoxView.attributedText enumerateAttributesInRange:NSMakeRange(0, self.chatToolsView.chatBoxView.attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            NSString *str = nil;
            
            UZUIChatToolsAttachment *attachment = attrs[@"NSAttachment"];
            
            if (attachment) { // 表情
                str = attachment.emotionStr;
                if (str) {
                    [strM appendString:str];
                    
                }
            } else { // 文字
                str = [weakSelf.chatToolsView.chatBoxView.attributedText.string substringWithRange:range];
                if (str) {
                    [strM appendString:str];
                    
                }
            }
        }];

        [self sendResultEventWithCallbackId:valueCbId dataDict:@{@"status" : @(YES), @"msg" : strM} errDict:nil doDelete:YES];
    }
}

- (void)insertValue:(NSDictionary *)params {

    if (!self.chatToolsView) {
        return;
    }
    int length = (int)self.chatToolsView.chatBoxView.text.length;
    int index = [params intValueForKey:@"index" defaultValue:length];
    index = index < 0 ? 0 : index;
    index = index > length ? length : index;
    NSString *msg = [params stringValueForKey:@"msg" defaultValue:@""];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:self.chatToolsView.chatBoxView.attributedText];
    
    
    NSMutableAttributedString *attributedMsg = [[NSMutableAttributedString alloc] initWithString:msg attributes:@{NSFontAttributeName : self.chatToolsView.chatBoxView.font}];
    [content insertAttributedString:attributedMsg atIndex:index];
    
    self.chatToolsView.chatBoxView.attributedText = content;
    
    if (self.chatBoxListenerCbId) {
       
        [self sendResultEventWithCallbackId:self.chatBoxListenerCbId dataDict:@{@"value" : self.chatToolsView.chatBoxView.attributedText.string } errDict:nil doDelete:NO];
    }
    
    
}

- (void)chatBoxListener:(NSDictionary *)params {
    self.chatBoxListenerCbId = [params intValueForKey:@"cbId" defaultValue:-1];
    NSString *name = [params stringValueForKey:@"name" defaultValue:@""];
    if ([name isEqualToString:@"valueChanged"]) {
        if (valueChangedCbId > 0) {
            
            [self deleteCallback:valueChangedCbId];
        }
        valueChangedCbId = self.chatBoxListenerCbId;
    }
 
    if ([name isEqualToString:@"move"]) {
        
        if (moveCbId >0) {
            
        [self deleteCallback:moveCbId];
  
        }
       moveCbId = self.chatBoxListenerCbId;

    }
    if ([name isEqualToString:@"change"]) {
        
        if (changeCbId >0 ) {
            
            [self deleteCallback:changeCbId];
            
        }
        changeCbId = self.chatBoxListenerCbId;
    }
}


- (void)setPlaceholder:(NSDictionary *)params {
    NSString *placeholder = [params stringValueForKey:@"placeholder" defaultValue:@""];
    self.chatToolsView.chatBoxView.placeholder = placeholder;
}


- (void)tapAction:(UITapGestureRecognizer *)tap {
    if (_isCustomBoardShow) {
        [self hideCustomBoard];
    }
    _isCustomBoardShow = NO;
    self.currentButton.selected = NO;
    [self.chatToolsView.chatBoxView resignFirstResponder];
}

#pragma mark  ------UIKeyboardWillShowNotification&UIKeyboardWillHideNotification
- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘frame
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 获取键盘弹出时长
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //隐藏自定义面板
    if (_isCustomBoardShow) {
        [self hideCustomBoard];
    }
    
    //取消选中按钮
    self.currentButton.selected = NO;
    
    //设置_chatToolsView
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.chatToolsView.frame;
        frame.origin.y = endFrame.origin.y - frame.size.height;
        self.chatToolsView.frame = frame;
        
      
    }];
   [self chatBoxMoveCallback];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // 获取键盘frame
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 获取键盘弹出时长
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (!_isCustomBoardShow) {
        [UIView animateWithDuration:duration animations:^{
            CGRect frame = _chatToolsView.frame;
            if (iPhoneX) {
                frame.origin.y = endFrame.origin.y - frame.size.height-34;

            }else{
                frame.origin.y = endFrame.origin.y - frame.size.height;

            }
            _chatToolsView.frame = frame;
            NSLog(@"------frame%f",frame.size.height);
            
        }];
    }
    [self chatBoxMoveCallback];
}


#pragma mark ----UZUIChatToolsViewDelegate

- (void)chatToolsView:(UZUIChatToolsView *)chatToolsView didClickButton:(UIButton *)button {
  //  NSLog(@"tag:%zd,------selected:%zd-------title:%@",button.tag,button.selected,button.titleLabel.text);
    //toolsListenerCbId
    if (self.toolsListenerCbId > 0) {
        [self sendResultEventWithCallbackId:self.toolsListenerCbId dataDict:@{@"eventType" : button.titleLabel.text} errDict:nil doDelete:NO];
    }
    
    if ([button.titleLabel.text isEqualToString:@"face"]) {
        self.board.emojiPathes = [self.emotions mutableCopy];
        if (button.selected) {
            self.board.emojiBoard.hidden = NO;
            self.board.appendBoard.hidden = YES;
            self.board.imageBoard.hidden = YES;
            self.board.recorderBoard.hidden = YES;
            [self showCustomBoard];
            self.board.textView = _chatToolsView.chatBoxView;
        }else {
            [self hideCustomBoard];
        }
    }
    if ([button.titleLabel.text isEqualToString:@"append"]) {
        if (button.selected) {
            self.board.emojiBoard.hidden = YES;
            self.board.appendBoard.hidden = NO;
            self.board.imageBoard.hidden = YES;
            self.board.recorderBoard.hidden = YES;
            [self showCustomBoard];
        }else {
            [self hideCustomBoard];
        }
    }
    if ([button.titleLabel.text isEqualToString:@"image"]) {
        if (button.selected) {
            self.board.isOpenImageBoard = YES;
            self.board.imageBoard.hidden = NO;
            self.board.imageBoard.delegate = self;
            self.board.appendBoard.hidden = YES;
            self.board.emojiBoard.hidden = YES;
            self.board.recorderBoard.hidden = YES;
            [self showCustomBoard];
        }else {
            [self hideCustomBoard];
        }
    }
    if ([button.titleLabel.text isEqualToString:@"recorder"]) {
        if (button.selected) {
            self.board.recorderBoard.hidden = NO;
            self.board.recorderBoard.delegate = self;
            self.board.imageBoard.hidden = YES;
            self.board.emojiBoard.hidden = YES;
            self.board.appendBoard.hidden = YES;
            [self showCustomBoard];
        }else {
            [self hideCustomBoard];
        }
    }
    self.currentButton = button;
    [_chatToolsView.chatBoxView resignFirstResponder];
}

- (void)hideCustomBoard {
    [UIView animateWithDuration:0.25 animations:^{
        CGRect emtionTemp = self.board.frame;
        emtionTemp.origin.y = screenH;
        self.board.frame = emtionTemp;
        
        CGRect chatToolsTemp =  _chatToolsView.frame;
        if (iPhoneX) {
            chatToolsTemp.origin.y = self.board.frame.origin.y - chatToolsTemp.size.height-34;

        }else{
            chatToolsTemp.origin.y = self.board.frame.origin.y - chatToolsTemp.size.height;

        }
        NSLog(@"---%lf",chatToolsTemp.origin.y);
        _chatToolsView.frame = chatToolsTemp;
        _isCustomBoardShow = NO;
        
    }];
    
    [self chatBoxMoveCallback];
}

- (void)showCustomBoard {
    [UIView animateWithDuration:0.25 animations:^{
        CGRect emtionTemp = self.board.frame;
        if (iPhoneX) {
            emtionTemp.origin.y = screenH - customBoardH-34;

        }else{
            emtionTemp.origin.y = screenH - customBoardH;

        }
        self.board.frame = emtionTemp;
        
        CGRect chatToolsTemp =  _chatToolsView.frame;
        chatToolsTemp.origin.y = self.board.frame.origin.y - chatToolsTemp.size.height;
        _chatToolsView.frame = chatToolsTemp;
        _isCustomBoardShow = YES;
    }];
    
    [self chatBoxMoveCallback];
}

-(void)chatBoxChangeCallback
{
    CGFloat chatBoxHeight = self.chatToolsView.chatBoxView.frame.size.height;
    CGFloat panelHeight = screenH - CGRectGetMaxY(self.chatToolsView.frame);
    NSMutableDictionary *sendDict = [NSMutableDictionary dictionary];
    [sendDict setObject:@(chatBoxHeight) forKey:@"chatBoxHeight"];
    [sendDict setObject:@(panelHeight) forKey:@"panelHeight"];
    
        if ( changeCbId  > 0) {
    
            [self sendResultEventWithCallbackId:changeCbId dataDict:sendDict errDict:nil doDelete:NO];
    
        }
}
- (void)chatBoxMoveCallback {
    
    CGFloat chatBoxHeight = self.chatToolsView.chatBoxView.frame.size.height;
    CGFloat panelHeight = screenH - CGRectGetMaxY(self.chatToolsView.frame);
    NSMutableDictionary *sendDict = [NSMutableDictionary dictionary];
    [sendDict setObject:@(chatBoxHeight) forKey:@"chatBoxHeight"];
    [sendDict setObject:@(panelHeight) forKey:@"panelHeight"];

    if (moveCbId > 0) {
        
        [self sendResultEventWithCallbackId:moveCbId dataDict:sendDict errDict:nil doDelete:NO];

    }

}



#pragma mark ---UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    NSString *class1 = NSStringFromClass([gestureRecognizer class]);
    NSString *class2 = NSStringFromClass([otherGestureRecognizer class]);
    if ([class1 isEqual:class2]) {
        return YES;
    }
    return NO;
}

#pragma mark ------------------UZUIChatToolsImagePickerViewDelegate
- (void)imagePickerView:(UZUIChatToolsImagePickerView *)imagePickerView didClickedButton:(UIButton *)button isOriginalImage:(BOOL)isOriginalImage selectedArray:(NSArray *)selectedArray {
        switch (button.tag) {
            case 0: {
                if (albumCbId > 0) {
                    [self sendResultEventWithCallbackId:albumCbId dataDict:@{@"eventType":@"album"} errDict:nil doDelete:NO];
                }
                break;
            }
            case 1: {
                if (editCbId > 0) {
                    if (isOriginalImage) {
                        UZUIChatToolsImageModel *model = selectedArray.firstObject;
                        if (model.imagePath) {
                            [self sendResultEventWithCallbackId:editCbId dataDict:@{@"eventType":@"edit",@"images" : @[model.imagePath]} errDict:nil doDelete:NO];
                        }
                    }else {
                        UZUIChatToolsImageModel *model = selectedArray.firstObject;
                        UIImage *thumbnail = model.image;
                        NSString *imageName = model.imageName;
                        //创建缩略图的图片路径
                        NSString *imagePath = [self creatImagePath:thumbnail imageName:imageName];
                        if (imagePath) {
                            [self sendResultEventWithCallbackId:editCbId dataDict:@{@"eventType":@"edit",@"images" : @[imagePath]} errDict:nil doDelete:NO];
                        }
                    }
                }
                break;
            }
            case 3: {
                if (sendCbId > 0) {
                    if (isOriginalImage) {
                        NSMutableArray *imagePathes = [NSMutableArray array];
                        for (UZUIChatToolsImageModel *model in selectedArray) {
                            if (model.imagePath) {
                                [imagePathes addObject:model.imagePath];
                            }
                        }
                        [self sendResultEventWithCallbackId:sendCbId dataDict:@{@"eventType":@"send",@"images" : imagePathes} errDict:nil doDelete:NO];
                    }else {
                        NSMutableArray *imagePathes = [NSMutableArray array];
                        for (UZUIChatToolsImageModel *model in selectedArray) {
                            UIImage *thumbnail = model.image;
                            NSString *imageName = model.imageName;
                            //创建缩略图的图片路径
                            NSString *imagePath = [self creatImagePath:thumbnail imageName:imageName];
                            if (imagePath) {
                                [imagePathes addObject:imagePath];
                            }
                        }
                        [self sendResultEventWithCallbackId:sendCbId dataDict:@{@"eventType":@"send",@"images" : imagePathes} errDict:nil doDelete:NO];
                    }
                }
                else{
                   
                    NSMutableArray *imagePathes = [NSMutableArray array];
                    for (UZUIChatToolsImageModel *model in selectedArray) {
                        UIImage *thumbnail = model.image;
                        NSString *imageName = model.imageName;
                        //创建缩略图的图片路径
                        NSString *imagePath = [self creatImagePath:thumbnail imageName:imageName];
                        if (imagePath) {
                            [imagePathes addObject:imagePath];
                        }
                    }
                    [self sendResultEventWithCallbackId:self.openCbId dataDict:@{@"eventType":@"send",@"msg" : imagePathes} errDict:nil doDelete:NO];
                }
                break;
            }
            default:
                break;
        }
}

#pragma mark ----------------------------UZUIChatToolsRecorderViewDelegate
- (void)recorderView:(UZUIChatToolsRecorderView *)recorderView listenType:(ListenType)listenType {
    if (self.recorderListenerCbId == -1) { // 说明用户没有监听此事件.
        return;
    }
    
    NSString * eventType = nil;
    NSString * target = nil;
    
    if (listenType == ListenTypePress) {
        eventType = @"press";
        target = @"talkback";
    }

    if (listenType == ListenTypeAudition) {
        
        eventType = @"audition";
        target = @"talkback";
    }
    
    if (listenType == ListenTypeAuditionCancel) {
        
        eventType = @"audition_cancel";
        target = @"talkback";
    }
    
    if (listenType == ListenTypeaSend) {
        
        eventType = @"send";
        target = @"talkback";
    }
    
    if (listenType == ListenTypeCancel) {
        
        eventType = @"cancel";
        target = @"talkback";
    }
    
    if (listenType == ListenTypeShortTime) {
        
        eventType = @"shortTime";
        target = @"talkback";
    }
    
    if (listenType == ListenTypeStart) {
        
        eventType = @"start";
        target = @"record";
    }
    
    if (listenType == ListenTypeStop) {
        
        eventType = @"stop";
        target = @"record";
    }
    
    if (listenType == ListenTypeAudition_recorder) {
        
        eventType = @"audition";
        target = @"record";
    }
    
    if (listenType == ListenTypeSend_recorder) {
        eventType = @"send";
        target = @"record";
    }
    
    if (listenType == ListenTypeAuditionCancel_recorder) {
        eventType = @"cancel";
        target = @"record";
    }
    if (listenType == ListenTypeAuditionTouchOn) {
        eventType = @"auditionTouchOn";
        target = @"talkback";
    }
    if (target && eventType) {
        [self sendResultEventWithCallbackId:self.recorderListenerCbId
                                   dataDict:@{@"target" : target,
                                              @"eventType": eventType}
                                    errDict:nil doDelete:NO];
    }
}


- (NSString *)creatImagePath:(UIImage *)image imageName:(NSString *)imageName {
    NSData *imageData = nil;
    if (!UIImagePNGRepresentation(image)) {
        imageData = UIImageJPEGRepresentation(image, 1.0);
    }else {
        imageData = UIImagePNGRepresentation(image);
    }
    //将缩略图存到library/Caches/UIChatTools目录下
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UIChatTools"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    filePath = [filePath stringByAppendingPathComponent:imageName];
    [imageData writeToFile:filePath atomically:YES];
    return filePath;
}


@end
