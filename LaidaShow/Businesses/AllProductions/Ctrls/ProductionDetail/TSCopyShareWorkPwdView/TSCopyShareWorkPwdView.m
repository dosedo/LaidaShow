//
//  TSCopyShareWorkPwdView.m
//  LaidaShow
//
//  Created by Met on 2020/8/26.
//  Copyright © 2020 deepai. All rights reserved.
//

#import "TSCopyShareWorkPwdView.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "UILabel+Ext.h"
#import "HTProgressHUD.h"
#import "MBProgressHUD.h"

@implementation TSCopyShareWorkPwdView

+ (TSCopyShareWorkPwdView *)showCopyPwdViewWithPwd:(NSString *)pwd{
    TSCopyShareWorkPwdView *pv = [TSCopyShareWorkPwdView new];
    pv.pwdL.text = pwd;
    [pv doLayout];
    

    //将视图添加到 分享的窗口上
    UIWindow *kv = [UIApplication sharedApplication].keyWindow;
    for( UIWindow *v in [UIApplication sharedApplication].windows ){
        if( v != kv ){
            if( [v isKindOfClass:NSClassFromString(@"UITextEffectsWindow")] ==NO ){
                kv = v;
            }
        }
    }
    
    [kv addSubview:pv];
    
    return pv;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRgb221].CGColor;
        
        _titleL = [UILabel new];
        _titleL.font = [UIFont systemFontOfSize:14];
        _titleL.textColor = [UIColor colorWithRgb51];
        _titleL.text = @"分享密码";
        [self addSubview:_titleL];
        
        _pwdL = [UILabel new];
        _pwdL.backgroundColor = [UIColor whiteColor];
        _pwdL.font = [UIFont systemFontOfSize:14];
        _pwdL.textColor = [UIColor colorWithRgb51];
        _pwdL.layer.masksToBounds = YES;
        _pwdL.layer.cornerRadius = 5;
        _pwdL.layer.borderWidth = 0.5;
        _pwdL.layer.borderColor = [UIColor colorWithRgb221].CGColor;
        _pwdL.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_pwdL];
        
        _copiedBtn = [UIButton new];
        [_copiedBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue"] forState:UIControlStateNormal];
        [_copiedBtn setTitle:@"复制" forState:UIControlStateNormal];
        _copiedBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_copiedBtn addTarget:self action:@selector(handleBtn) forControlEvents:UIControlEventTouchUpInside];
        _copiedBtn.layer.masksToBounds = YES;
        _copiedBtn.layer.cornerRadius = 5;
        [self addSubview:_copiedBtn];
    }
    return self;
}

- (void)handleBtn{
    
    if( self.pwdL.text.length ){
        //系统级别
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.pwdL.text;
        
        [HTProgressHUD showSuccess:@"复制成功" toView:self.superview];
    }
}

- (void)doLayout{
    
    CGFloat maxW = 150;
    CGFloat tw = [UILabel lableSizeWithText:self.titleL.text font:self.titleL.font width:maxW].width+10;
    
    CGFloat pw = [UILabel lableSizeWithText:self.pwdL.text font:self.pwdL.font width:maxW].width+20;
    
    CGFloat bw = 50;
    
    CGFloat gap = 15, ileft = 20;
    CGFloat iw = tw + gap + pw+ gap + bw +gap + ileft*2;
    CGFloat ih = 70;
    self.frame = CGRectMake(0, 0, iw, ih);
    self.center = [UIApplication sharedApplication].keyWindow.center;
    
    self.titleL.frame = CGRectMake(ileft, 0, tw, 20);
    [self setCenterWithView:self.titleL];
    
    self.pwdL.frame = CGRectMake(self.titleL.right+gap, 0, pw, 30);
    [self setCenterWithView:self.pwdL];
    
    
    self.copiedBtn.frame = CGRectMake(self.pwdL.right+gap, 0, bw, 30);
    [self setCenterWithView:self.copiedBtn];
}

- (void)setCenterWithView:(UIView*)v{
    CGFloat ih = self.height;
    v.center = CGPointMake(v.center.x, ih/2);
}

@end
