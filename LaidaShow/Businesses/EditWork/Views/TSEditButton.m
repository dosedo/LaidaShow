//
//  TSEditButton.m
//  ThreeShow
//
//  Created by hitomedia on 13/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSEditButton.h"

@implementation TSEditButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    
    return CGRectMake(0, contentRect.size.height/2, contentRect.size.width, contentRect.size.height/2);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat ih = 40/2;
    return CGRectMake(0, (contentRect.size.height/2-ih)/2+2, contentRect.size.width, ih);
}

@end
