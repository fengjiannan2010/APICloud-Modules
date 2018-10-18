/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoCacheManager.h"

@interface PhotoCacheManager ()

/// 是否选择的长度
@property (nonatomic, assign)unsigned long numberOfAssetIsSelectedSignal;

@end

@implementation PhotoCacheManager

-(instancetype)init
{
    if (self = [super init])
    {
        _numberOfSelectedPhoto = 0;
        _maxNumberOfSelectedPhoto = NSUIntegerMax;
    }
    
    return self;
    
}


+(instancetype)sharedInstace
{
    static PhotoCacheManager * cacheManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        cacheManager = [self new];
        
    });
    
    return cacheManager;
}



-(void)allocInitAssetIsSelectedSignal:(NSUInteger)count
{
    
    self.numberOfAssetIsSelectedSignal = count;
    
    //初始化
    self.assetIsSelectedSignal = new BOOL[count];
    
    memset(self.assetIsSelectedSignal,false,count * sizeof(BOOL));
    
    self.assetSelectedStatusChangeOrderSignal = new int[count];
    memset(self.assetSelectedStatusChangeOrderSignal,false,count * sizeof(int));
}


-(void)allocInitAssetIsPictureSignal:(NSUInteger)count
{

    
    self.assetIsPictureSignal = new BOOL[count];
    
    memset(self.assetIsPictureSignal,false,count * sizeof(BOOL));
}



-(BOOL)changeAssetIsSelectedSignal:(NSUInteger)index
{
    if (index > self.numberOfAssetIsSelectedSignal)
    {
        return false;
    }
    
    self.assetIsSelectedSignal[index] = !self.assetIsSelectedSignal[index];
    
    self.statusChangeOrder ++;
    self.assetSelectedStatusChangeOrderSignal[index] = self.statusChangeOrder;
    
    printf("选中状态:%d\n",self.assetIsSelectedSignal[index]);
    
    return true;
}

-(void)freeAllSignal
{
    

}

-(void)resetMaxSelectedCount
{
    _maxNumberOfSelectedPhoto = NSUIntegerMax;
}


- (void)freeSignalIngnoreMax
{
    if (self.assetIsPictureSignal)
    {
        free(self.assetIsPictureSignal);
    }
    
    if (self.assetIsSelectedSignal)
    {
        free(self.assetIsSelectedSignal);
    }
    
    _numberOfSelectedPhoto = 0;
    _numberOfAssetIsSelectedSignal = 0;
    _isHightQuarity = false;
}


@end
