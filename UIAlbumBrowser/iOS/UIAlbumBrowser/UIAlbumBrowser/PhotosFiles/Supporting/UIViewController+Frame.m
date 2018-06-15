/**
 * APICloud Modules
 * Copyright (c) 2014-2018 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "UIViewController+Frame.h"

@implementation UIViewController (Frame)

-(NSUInteger)width
{
    return self.view.bounds.size.width;
}

-(NSUInteger)height
{
    return self.view.bounds.size.height;
}

-(CGFloat)originX
{
    return self.view.frame.origin.x;
}

-(CGFloat)originY
{
    return self.view.frame.origin.y;
}

-(CGPoint)center
{
    return self.view.center;
}

-(CGFloat)centerX
{
    return self.center.x;
}

-(CGFloat)centerY
{
    return self.center.y;
}

-(CGRect)bounds
{
    return self.view.bounds;
}

@end


@implementation UIScreen (Frame)

-(NSUInteger)width
{
    return self.bounds.size.width;
}

-(NSUInteger)height
{
    return self.bounds.size.height;
}

@end

