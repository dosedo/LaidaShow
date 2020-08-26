//
//  KTimer.m
//  RRTY
//
//  Created by 端倪 on 15/5/21.
//  Copyright (c) 2015年 RRTY. All rights reserved.
//

#import "KTimer.h"

@implementation KTimer
{
    NSString *_btnTitle;
    NSUInteger _times;                  //次数
    NSTimer *_timer;
    NSString *_timerString;             //倒计时字符串提示
    UIButton *_btn;
}

-(id)initWithButton:(UIButton *)btn
{
    self = [super init];
    if( self )
    {
        _isTiming = NO;
        _btn = btn;
    }
    return self;
}

-(void)startTimer
{
    _times = 59 ;
    _timerString = NSLocalizedString(@"秒后再次获取", nil);//; 
    _btnTitle = _btn.titleLabel.text;
    _btn.enabled = NO;
    _isTiming = YES;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(OnTimer:) userInfo:nil repeats:YES];
    [_timer fire];
}

-(void)OnTimer:(id)sender
{
    NSString *title = _btnTitle;
    if( _times > 0 )
    {
        NSString *timeStr = @(_times).stringValue;
        
        title = [NSString stringWithFormat:@"%@%@",timeStr,_timerString];

        UIColor *titleColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:_btn.titleLabel.font,NSForegroundColorAttributeName:titleColor}];
        UIColor *timeColor = [UIColor colorWithRed:249/255.0 green:76/255.0 blue:67/255.0 alpha:1.0];
        [as addAttribute:NSForegroundColorAttributeName value:timeColor range:NSMakeRange(0, timeStr.length)];
        
        [_btn setAttributedTitle:as forState:UIControlStateDisabled];
    }
    else
    {
        [_timer invalidate];
        _btn.enabled = YES;
        _isTiming = NO;
    }
//    _btn.titleLabel.text = title;
//    [_btn setTitle:title forState:UIControlStateNormal];

    _times--;
}

-(void)endTimer{
    [_timer invalidate];
    _btn.enabled = YES;
    _btn.titleLabel.text = _btnTitle;
    _isTiming = NO;
    [_btn setTitle:_btnTitle forState:UIControlStateNormal];

}

@end
