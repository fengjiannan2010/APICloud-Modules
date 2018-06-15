/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
#import <UIKit/UIKit.h>

/* 思路实现，详见： https://stackoverflow.com/a/3977305 */
typedef void (^ActionBlock)();

@interface UIBlockButtonForAlbumBrowser : UIButton {
    ActionBlock _actionBlock;
}

-(void) handleControlEvent:(UIControlEvents)event
                 withBlock:(ActionBlock) action;
@end
