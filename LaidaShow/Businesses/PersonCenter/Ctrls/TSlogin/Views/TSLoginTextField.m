//
//  TSLoginTextField.m
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSLoginTextField.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+Ext.h"

@implementation TSLoginTextField
{
    UIView *_line;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        _line = [UIView new];
        _line.backgroundColor = [UIColor colorWithR:187 G:187 B:187];
        [self addSubview:_line];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat ih = 0.5;
    _line.frame = CGRectMake(0, self.height-ih, self.width, ih);
}

@end



