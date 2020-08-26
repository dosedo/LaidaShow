//
//  HTNaviBgView.m
//  HituSocial
//
//  Created by hitomedia on 12/04/2018.
//  Copyright © 2018 hitumedia. All rights reserved.
//

#import "HTNaviBgView.h"

@implementation HTNaviBgView

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat ih = 0.5;
    self.bottomLine.frame = CGRectMake(0, self.frame.size.height-ih, self.frame.size.width, ih);
}

- (UIView*)bottomLine{
    if( !_bottomLine ){
        _bottomLine = [UIView new];
        _bottomLine.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
        [self addSubview:_bottomLine];
    }
    return _bottomLine;
}

@end
