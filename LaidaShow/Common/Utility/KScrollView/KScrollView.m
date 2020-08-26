//
//  KScrollView.m
//  ThreeShow
//
//  Created by hitomedia on 05/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "KScrollView.h"

@implementation KScrollView

- (id)init{
    self = [super init];
    if( self )
    {
        [self initSelf];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initSelf];
    }
    return self;
}

- (void)initSelf{
    //为了防止，uibutton 加在tableview上后，没有效果的问题
    self.canCancelContentTouches = YES;
    self.delaysContentTouches = NO;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
    return YES;
}

@end
