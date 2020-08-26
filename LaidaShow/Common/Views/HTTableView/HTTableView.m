//
//  HTTableView.m
//  Hitu
//
//  Created by hitomedia on 2017/1/9.
//  Copyright © 2017年 hitomedia. All rights reserved.
//

#import "HTTableView.h"

@implementation HTTableView

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

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    UIView *view = touch.view;
//    if ([view isKindOfClass:[UITableView class]] || [@"UITableViewCellContentView" isEqualToString:[[view class] description]] )
//    {
//        return NO;
//    }
//
//    return YES;
//}

@end
