//
//  TSClearGuideView.m
//  ThreeShow
//
//  Created by cgw on 2019/2/26.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSClearGuideView.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+Ext.h"
#import "UILabel+Ext.h"

@implementation TSClearGuideView{
    UIView *_bgBtn;
}

+ (TSClearGuideView*)shareClearGuideView{
    static TSClearGuideView *gv = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gv = [TSClearGuideView new];
    });
    return gv;
}

+ (void)showClearGuideViewWithBtnFrame:(CGRect)fr HideBlock:(HideBlock)hideBlock{
    TSClearGuideView *gv = [self shareClearGuideView];
    [gv setupViewsWithBtnFr:fr];
    
    [[UIApplication sharedApplication].keyWindow addSubview:gv];
}

- (void)handleBg{
    [self removeFromSuperview];
}

- (void)setupViewsWithBtnFr:(CGRect)fr{
    NSInteger baseTag = 100;
    UIButton *bgBtn = [self viewWithTag:baseTag];
    if( bgBtn == nil ){
        
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        bgBtn = [UIButton new];
        bgBtn.tag = baseTag;
        bgBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        bgBtn.frame = self.bounds;
        [bgBtn addTarget:self action:@selector(handleBg) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgBtn];
    }
    
    UIButton *clearBtn = [self viewWithTag:baseTag+1];
    if( [clearBtn isKindOfClass:[UIButton class]] ==NO ){

        UIButton *btn = [UIButton new];
        [btn setTitle:NSLocalizedString(@"ClearBgStartClearTitle", nil) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"preview_remove_normal"] forState:UIControlStateNormal];
        
        CGFloat btnH = 77,btnW = btn.currentImage.size.width;
        btn.frame = CGRectMake((bgBtn.width-btnW)/2, fr.origin.y, btnW, btnH);
        
        CGFloat titleH = 20;
        CGSize imgSize = btn.currentImage.size;
        CGFloat titleLen = [btn.titleLabel labelSizeWithMaxWidth:btnW].width;
        CGFloat toLeft = (btnW-titleLen)/2;
        btn.titleEdgeInsets = UIEdgeInsetsMake(btnH-titleH, toLeft-imgSize.width, 0, toLeft);
        toLeft = (btnW-imgSize.width)/2;
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, toLeft, btnH-imgSize.height, toLeft-titleLen);
        btn.userInteractionEnabled = NO;
        btn.tag = baseTag+1;
        [bgBtn addSubview:btn];
        
        clearBtn = btn;
    }
    
    UIImageView *arrowV = [bgBtn viewWithTag:baseTag+2];
    if( arrowV==nil ){
        arrowV = [UIImageView new];
        arrowV.image = [UIImage imageNamed:@"clear_arrow_down_white"];
        CGSize size = arrowV.image.size;
        CGFloat iy = SCREEN_HEIGHT-size.height-(120+BOTTOM_NOT_SAVE_HEIGHT);
        arrowV.frame = CGRectMake(clearBtn.center.x-size.width/2, iy, size.width, size.height);
        arrowV.tag = baseTag+2;
        [bgBtn addSubview:arrowV];
    }
    
    UILabel *desL = [bgBtn viewWithTag:baseTag+3];
    if( desL == nil ){
        desL = [UILabel new];
        [bgBtn addSubview:desL];
        
        CGFloat ih = 40;
        desL.frame = CGRectMake(0, arrowV.y-ih-15, bgBtn.width, ih);
        NSString *text = NSLocalizedString(@"ClearBgGuideText", nil);
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:text];
        [as addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, text.length)];
        [as addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, text.length)];
        
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        ps.alignment = NSTextAlignmentCenter;
        ps.lineSpacing = 3;
        
        [as addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, text.length)];
        desL.attributedText = as;
        desL.tag = baseTag+3;
        desL.numberOfLines = 0;
    }
    
    UILabel *sureL = [bgBtn viewWithTag:baseTag+4];
    if( sureL == nil ){
        sureL = [UILabel new];
        sureL.tag = baseTag+4;
        CGFloat iw = 70,ih = 25;
        sureL.frame = CGRectMake((bgBtn.width-iw)/2, desL.y-ih-15, iw, ih);
        [sureL cornerRadius:ih/2];
        sureL.layer.borderColor = [UIColor whiteColor].CGColor;
        sureL.layer.borderWidth = 0.5;
        [bgBtn addSubview:sureL];
        
        sureL.text = NSLocalizedString(@"ClearBgGuideOk", nil);
        sureL.font = [UIFont systemFontOfSize:15];
        sureL.textAlignment = NSTextAlignmentCenter;
        sureL.textColor = [UIColor whiteColor];
    }
}

@end
