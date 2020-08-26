//
//  TSSelectDeviceView.m
//  ThreeShow
//
//  Created by cgw on 2019/2/26.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSSelectDeviceView.h"
#import "UIView+LayoutMethods.h"
#import "UILabel+Ext.h"
#import "UIColor+Ext.h"
#import "TSDataProcess.h"
#import "DSContentButton.h"

@interface TSSelectDeviceView()

@property (nonatomic, strong) UIButton *bgBtn;
@property (nonatomic, strong) NSArray *btns;

@end

@implementation TSSelectDeviceView{
    SureBlock _sureBlock;
}

+ (TSSelectDeviceView*)shareSelectDeviceView{
    static TSSelectDeviceView *dv = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dv = [TSSelectDeviceView new];
        [dv setupViews];
    });
    return dv;
}

+ (void)showSelectDeviceViewWithSureBlock:(SureBlock)sureBlock{
    TSSelectDeviceView *dv = [TSSelectDeviceView shareSelectDeviceView];
    dv->_sureBlock = sureBlock;
    [dv setSelectIndex:[TSDataProcess sharedDataProcess].selectedDeviceIndex];
    [[UIApplication sharedApplication].keyWindow addSubview:dv.bgBtn];
}

- (void)setupViews{
    CGFloat iw = 206,ih = 221;
    self.frame = CGRectMake((self.bgBtn.width-iw)/2, (_bgBtn.height-ih)/2, iw, ih);
    self.backgroundColor = [UIColor whiteColor];
    [self cornerRadius:5];
    [self.bgBtn addSubview:self];
    
    UILabel *titleL =
    [UILabel getLabelWithTextColor:[UIColor colorWithRgb51]
                              font:[UIFont systemFontOfSize:15]
                     textAlignment:NSTextAlignmentLeft
                             frame:CGRectMake(15, 15, iw-30, 25)
                         superView:self];
//    "ClearBgSelectDeviceTitle"="Please select a device";
//    "ClearBgSelectDeviceDes"
    titleL.text = NSLocalizedString(@"ClearBgSelectDeviceTitle", nil);
    
    UILabel *desL =
    [UILabel getLabelWithTextColor:[UIColor colorWithRgb153]
                              font:[UIFont systemFontOfSize:12]
                     textAlignment:NSTextAlignmentLeft
                             frame:CGRectMake(titleL.x, titleL.bottom, titleL.width, 40)
                         superView:self];
    desL.text = NSLocalizedString(@"ClearBgSelectDeviceDes", nil);
    desL.numberOfLines = 0;
    ih = [desL labelSizeWithMaxWidth:desL.width].height;
    CGRect fr = desL.frame; fr.size.height = ih; desL.frame = fr;
    
    NSArray *titles = [[TSDataProcess sharedDataProcess] deviceListDatas];
    NSMutableArray *arr = [NSMutableArray new];
    for( NSInteger i=0; i<titles.count; i++ ){
        DSContentButton *btn = [DSContentButton new];
        [btn setImage:[UIImage imageNamed:@"radiobutton"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"radiobutton_s"] forState:UIControlStateSelected];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat ih = 25;
        btn.frame = CGRectMake(0, ih*i+desL.bottom+3, self.width, ih);
        
        CGSize imgSize = CGSizeMake(15, 15);//btn.currentImage.size;
        btn.imageRect = CGRectMake(desL.x, (btn.height-imgSize.height)/2, imgSize.width, imgSize.height);
        CGFloat ix = CGRectGetMaxX(btn.imageRect)+desL.x;
        btn.titleRect = CGRectMake(ix, 0, btn.width-ix-5, btn.height);
        btn.tag = i;
        [btn setNeedsLayout];
        [self addSubview:btn];
        
        [arr addObject:btn];
    }
    _btns = arr;
    
    //取消和确定按钮
//    ClearBgSelectDeviceBtnTitleSure
    titles = @[NSLocalizedString(@"SearchCancleText", nil),
               NSLocalizedString(@"ClearBgSelectDeviceBtnTitleSure",nil)];
    NSArray *bgImgs = @[@"btn_bg_disable220",@"btn_bg_blue"];
    iw = 50;ih= 25;
    CGFloat iLeft = (self.width-iw*2)/3;
    NSInteger i=0;
    for( NSString *title in titles ){
        DSContentButton *btn = [DSContentButton new];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setBackgroundImage:[UIImage imageNamed:bgImgs[i]] forState:UIControlStateNormal];
        CGFloat ix = iLeft + (iw+iLeft)*i;
        CGFloat edge = 2;
        btn.frame = CGRectMake(ix-edge, self.height-ih-15-edge, iw+2*edge, ih+2*edge);
        [btn cornerRadius:5];
        [self addSubview:btn];
        
        [btn addTarget:self action:@selector(handleBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        i++;
    }
}

- (void)setSelectIndex:(NSInteger)selectIndex{
    
    for( UIButton *btn in self.btns ){
        btn.selected = (btn.tag==selectIndex);
    }
}

#pragma mark - TouchEvents
- (void)hanldeBgBtn{
    [self.bgBtn removeFromSuperview];
}

- (void)handleBtn:(UIButton*)btn{
    [self setSelectIndex:btn.tag];
}

- (void)handleBottomBtn:(UIButton*)btn{
    [self hanldeBgBtn];
    if( btn.tag == 1 ){
        //确认
        for( UIButton *deviceBtn in _btns ){
            if( deviceBtn.isSelected ){
                [[TSDataProcess sharedDataProcess] updateSelectDeviceAtIndex:deviceBtn.tag];
                break;
            }
        }
        
        if( _sureBlock ){
            _sureBlock();
        }
    }
}

#pragma mark - Propertys
- (UIButton *)bgBtn {
    if( !_bgBtn ){
        _bgBtn = [UIButton new];
        _bgBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _bgBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_bgBtn addTarget:self action:@selector(hanldeBgBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _bgBtn;
}

@end
