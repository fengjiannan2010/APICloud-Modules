/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "PhotoHandleManager.h"
@implementation PhotoHandleManager

+(NSArray<PHAsset *> *)assetForAssets:(NSArray<PHAsset *> *)assets status:(BOOL *)status orders:(int *)orders
{
    // 存储排序前的数据.
    NSMutableArray * assetsHandleUnorder = [NSMutableArray arrayWithCapacity:assets.count];
    
    for (NSUInteger i = 0; i < assets.count; i++)
    {
        //获得当前的状态
        BOOL currentStatus = status[i];
        int order = orders[i];
        
        if (currentStatus)
        {
            [assetsHandleUnorder addObject:@{
                                             @"order": @(order),
                                             @"value": assets[i],
                                             }];
        }
    }
    
    // TODO: 拿到数据之后,要排序.
    [assetsHandleUnorder sortUsingComparator:^NSComparisonResult(NSDictionary *  _Nonnull obj1, NSDictionary *   _Nonnull obj2) {
        NSInteger order1 = [[obj1 objectForKey:@"order"] integerValue];
        NSInteger order2 = [[obj2 objectForKey:@"order"] integerValue];
        
        return order1>=order2;
    }];
    
    NSMutableArray <PHAsset *> * assetsHandle = [NSMutableArray arrayWithCapacity:assets.count];
    for (int i = 0; i < assetsHandleUnorder.count; i++) {
        PHAsset * value = [assetsHandleUnorder[i] objectForKey:@"value"];
        [assetsHandle addObject:value];
    }
    
    return [assetsHandle copy];
}

@end

@implementation PhotoHandleManager (DurationTime)

+ (NSString *)timeStringWithTimeDuration:(NSTimeInterval)timeInterval
{
    NSUInteger time = (NSUInteger)timeInterval;
    
    //大于1小时
    if (time >= 60 * 60)
    {
        NSUInteger hour = time / 60 / 60;
        NSUInteger minute = time % 3600 / 60;
        NSUInteger second = time % (3600 * 60);
        
        return [NSString stringWithFormat:@"%.2lu:%.2lu:%.2lu",(unsigned long)hour,(unsigned long)minute,(unsigned long)second];
    }
    
    
    if (time >= 60)
    {
        NSUInteger mintue = time / 60;
        NSUInteger second = time % 60;
        
        return [NSString stringWithFormat:@"%.2lu:%.2lu",(unsigned long)mintue,(unsigned long)second];
    }
    
    return [NSString stringWithFormat:@"00:%.2lu",(unsigned long)time];
}

@end
