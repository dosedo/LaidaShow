//
//  XWPageViewAppearance.m
//  Hitu
//
//  Created by hitomedia on 16/8/17.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import "XWPageViewAppearance.h"
#import "UIColor+XW.h"

@implementation XWPageViewAppearance

- (instancetype)init{
    self = [super init];
    if( self ){
        _itemMinWidth = 30;
        _itemXGap = 0;
        _itemEdgeDistance = 0;
        _itemCenterXDistance = 0;
        _itemTitleFontSize = 14;
        _itemTitleColor = [UIColor colorWithR:51 G:51 B:51];
        _itemSelectedTitleColor = _itemTitleColor;
        _itemMaxCount = 0;
        _currItemIndex = 0;
        _lineViewWidth = 0;
        _lineColor = [UIColor colorWithR:24 G:148 B:209];
        _lineScrollViewBackColor = [UIColor clearColor];
        _topViewOriginY = 0;
        _topViewHeight = 80;
        _topViewBackColor = [UIColor colorWithR:240 G:240 B:240];
        _topViewItemColor = [UIColor clearColor];
        _topViewItemStyle = XWPageTopViewItemStyleMonospaced;
        _lineBackViewColor = [UIColor clearColor];
    }
    return self;
}

@end
