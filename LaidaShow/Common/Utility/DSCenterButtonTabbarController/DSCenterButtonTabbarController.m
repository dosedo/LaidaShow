//
//  DSCenterButtonTabbarController.m
//  DSCenterButtonTabbarController
//
//  Created by cgw on 2019/2/20.
//  Copyright © 2019 bill. All rights reserved.
//

#import "DSCenterButtonTabbarController.h"
#import "DSCenterButtonTabbar/DSCenterButtonTabbar.h"

@interface DSCenterButtonTabbarController ()
/**
 是否需要显示中心按钮，默认为NO
 */
@property (nonatomic, assign) BOOL showCenterButton;
@end

@implementation DSCenterButtonTabbarController{
    UIButton *_centerButton;
}

@synthesize centerButton = _centerButon;

- (id)initWithShowCenterButton:(BOOL)showCenterButton{
    self = [super init];
    if( self ){
        _showCenterButton = showCenterButton;
        
        if( _showCenterButton ){
            DSCenterButtonTabbar *tabar = [[DSCenterButtonTabbar alloc] initWithCenterButton:self.centerButton];
            [self setValue:tabar forKey:@"tabBar"];
        }
    }
    return self;
}

#pragma mark - Getter

- (UIButton *)centerButton {
    if( !_centerButton ){
        _centerButton = [UIButton new];
        _centerButton.backgroundColor = [UIColor colorWithWhite:221/255.0 alpha:1];
        _centerButton.frame = CBT_ButtonDefaultFrame;
        _centerButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_centerButton setTitle:@"Center" forState:UIControlStateNormal];
        [_centerButton setTitleColor:[UIColor colorWithWhite:51/255.0 alpha:1] forState:UIControlStateNormal];
        [_centerButton setTitleColor:[UIColor colorWithWhite:102/255.0 alpha:1] forState:UIControlStateHighlighted];
    }
    
    return _centerButton;
}

@end
