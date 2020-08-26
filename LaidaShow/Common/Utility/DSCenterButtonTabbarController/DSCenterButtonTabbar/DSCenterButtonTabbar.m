//
//  DSCenterButtonTabbar.m
//  DSCenterButtonTabbarController
//
//  Created by cgw on 2019/2/20.
//  Copyright © 2019 bill. All rights reserved.
//

#import "DSCenterButtonTabbar.h"

@implementation DSCenterButtonTabbar{
    UIButton *_centerButton;
}

- (DSCenterButtonTabbar *)initWithCenterButton:(UIButton *)centerButton{
    self = [super init];
    if( self ){
        //若centerButton为nil,则不添加
        if( centerButton ){
            _centerButton = centerButton;
            [self addSubview:_centerButton];
        }
    }
    return self;
}

- (void)setItems:(NSArray<UITabBarItem *> *)items{
    [super setItems:items];
    
    [self doLayoutWithSize:self.bounds.size];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    //若tabbar未隐藏，且点击的是中心按钮，则响应按钮事件
    if( !self.hidden && _centerButton ){
        CGPoint newPoint = [self convertPoint:point toView:_centerButton];
        if ( [_centerButton pointInside:newPoint withEvent:event]) {
            return _centerButton;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark - Layout
- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self doLayoutWithSize:self.bounds.size];
}

- (void)doLayoutWithSize:(CGSize)size{
    
    //不展示中心按钮，不必更新frame
    if( ![self isShowCenterButton] ) return ;
    
    //若tabbar的size还未设置，或者tabbar的items没有数据，不必更新button的frame
    if( (size.width<=0 || size.height <=0) || self.items.count==0 ){
        return;
    }
    
    //若为默认的Frame则设置按钮居中
    BOOL isDefalutFrame = CGRectEqualToRect(CBT_ButtonDefaultFrame,_centerButton.frame);
    if( isDefalutFrame ){
        _centerButton.center = CGPointMake(size.width/2, size.height/2);
    }
    
    //item和按钮，宽度均分
    CGFloat iw = (size.width)/(self.items.count+1);
 
    //中心按钮右侧第一个Item的索引,若有4个Item，则该索引为2，若有3个item，该索引为1
    NSInteger rightItemStartIndex = self.items.count/2;
    
    NSInteger i=0;
    for( UIView *view in self.subviews ){
        if( [view isKindOfClass:NSClassFromString(@"UITabBarButton")] ){
            BOOL isLeftItem = (i<rightItemStartIndex);
            CGFloat ix = isLeftItem ? (iw*i) : (iw*i+iw);
            
            CGRect fr = view.frame;
            fr.origin.x = ix;
            fr.size.width = iw;
            view.frame = fr;
    
            i++;
        }
    }
}

#pragma mark - Private
- (BOOL)isShowCenterButton{
    return _centerButton;
}

@end
