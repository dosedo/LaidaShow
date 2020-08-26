//
//  TSLocalWorkInfoView.m
//  ThreeShow
//
//  Created by cgw on 2019/3/15.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSLocalWorkInfoView.h"
#import "UIView+LayoutMethods.h"
#import "TSConstants.h"
#import "DSContentButton.h"
#import "UIColor+Ext.h"
#import "TSProductionDetailModel.h"
#import "TSWorkShowInfoView.h"

@interface TSLocalWorkInfoView()
@property (nonatomic, assign) BOOL isLocalVideoWork;
@property (nonatomic, strong) TSWorkShowInfoView *showInfoView;

@end

@implementation TSLocalWorkInfoView{
    UIButton *_buyBtn;
}

- (void)dealloc{
    [self removeObserver:self.switchBtn forKeyPath:@"isHidden"];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        self.userInteractionEnabled = YES;
        [self createBtns];
        
        [self addObserver:self.switchBtn forKeyPath:@"isHidden" options:(NSKeyValueObservingOptionNew) context:nil];
    }
    return self;
}

- (void)setModel:(TSProductionDetailModel *)model{
    _model = model;
    
    self.showInfoView.model = model;
    _buyBtn.hidden = !(model.buyUrl.length > 3);
    
    [self setNeedsLayout];
}

#pragma mark - Observer notications
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    [self setNeedsLayout];
}

#pragma mark - TouchEvents
- (void)handleBtn:(UIButton*)btn{
    
    if( [btn isEqual:_showBtn] ){
        btn.selected = !btn.isSelected;
        [self.showInfoView show];
        return;
    }
    
    NSLog(@"---handle Local Detail view bottom btn");
    if( _delegate && [_delegate respondsToSelector:@selector(localWorkInfoView:handleBtnAtIndex:)] ){
        [_delegate localWorkInfoView:self handleBtnAtIndex:btn.tag-TSConstantViewTagBase];
    }
}

#pragma mark - Layout
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize swiSize = [self switchBtnSize];
    _switchBtn.frame = CGRectMake(15, 0, swiSize.width, swiSize.height);
    
    CGFloat //iw = 55,
    ih = swiSize.height;
    CGFloat iy = _switchBtn.y;
    NSInteger btnCount = 5;
    if( _isLocalVideoWork ) btnCount = 6;
    
    CGFloat baseX = _switchBtn.right;
    //(self.width-btnCount*iw);
    
    if( _buyBtn.hidden ){
        btnCount = btnCount-1;
    }
    
    NSInteger gapCount = ((btnCount*2)+1);
    if( _switchBtn.isHidden ){
        baseX = 0;
        gapCount = (btnCount*2);
    }
    
    CGFloat btnGap = (self.width-baseX-20*btnCount)/gapCount;
    
//    baseX = baseX + btnGap;
    if( _switchBtn.isHidden == NO ){
        baseX = baseX + btnGap;
    }
    CGFloat iw = (self.width-baseX)/btnCount;
    for( NSUInteger i=0; i<btnCount; i++ ){
        
        NSUInteger tag = TSConstantViewTagBase+i+1;
        if( _buyBtn.isHidden ){
            if( i > 0 ){
                tag++;
            }
        }
        UIView *btn = [self viewWithTag:tag];
        if( [btn isKindOfClass:[UIButton class]] ){
            btn.frame = CGRectMake(baseX+i*iw, iy, iw, ih);
        }
    }
    
//    [self setupShowBtnLayoutWithIsShowBuy:!_buyBtn.isHidden];
}

- (void)setupShowBtnLayoutWithIsShowBuy:(BOOL)showBuyBtn{
    CGPoint center = _showBtn.center;
    if( !showBuyBtn ){
        center.x = _buyBtn.center.x;
    }
    else{
        center.x = _buyBtn.x - _showBtn.width/2;
    }
    
    _showBtn.center = center;
}

#pragma mark - Private

- (void)createBtns{
    NSArray *imgs = @[@"work_open",@"work_buy",@"work_save",@"work_delete",@"work_release"];
    for( NSInteger i=0; i<imgs.count; i++ ){
        UIButton *btn = [self getBtnWithImgName:imgs[i] hiImgName:nil sImgName:nil sel:@selector(handleBtn:) tag:i+TSConstantViewTagBase+1];
        if( i==0 ){
            _showBtn = btn;
            [btn setImage:[UIImage imageNamed:@"work_close"] forState:UIControlStateSelected];
        }
        
        else if( i==1 ){
            _buyBtn = btn;
        }
    }
    
    DSContentButton *swiBtn = [[DSContentButton alloc] initWithCornerRadius:3 borderWidth:0 borderColor:[UIColor clearColor]];
    swiBtn.tag = TSConstantViewTagBase;
    CGSize swiSize = [self switchBtnSize];
    swiBtn.contentRect = CGRectMake(0, (swiSize.height-20)/2, swiSize.width, 20);
    swiBtn.contentView.backgroundColor = [UIColor colorWithRgb221];
    [swiBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
    [swiBtn setTitle:NSLocalizedString(@"ClearBgSwitchOriginImgTitle", nil) forState:UIControlStateNormal];
    [swiBtn setTitle:NSLocalizedString(@"ClearBgSwitchCleardImgTitle", nil) forState:UIControlStateSelected];
    swiBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [swiBtn.titleLabel sizeToFit];
    [swiBtn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:swiBtn];
    
    _switchBtn = swiBtn;
}

- (CGSize)switchBtnSize{
    return CGSizeMake(70, 50);
}

- (UIButton*)getBtnWithImgName:(NSString*)imgName hiImgName:(NSString*)hiImgName sImgName:(NSString*)sImgName sel:(SEL)sel tag:(NSInteger)tag{
    UIButton *btn = [[UIButton alloc] init];
    btn.tag = tag;
    if( imgName ){
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    }
    
    if( hiImgName ){
        [btn setImage:[UIImage imageNamed:hiImgName] forState:UIControlStateHighlighted];
    }
    
    if( sImgName ){
        [btn setImage:[UIImage imageNamed:sImgName] forState:UIControlStateSelected];
    }
    
    if( [self respondsToSelector:sel] ){
        [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    }
    
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:btn];
    
    return btn;
}

#pragma mark - getters

- (TSWorkShowInfoView *)showInfoView{
    if( !_showInfoView ){
        _showInfoView = [[TSWorkShowInfoView alloc] initWorkShowInfoView];
        __weak typeof(self) wk = self;
        _showInfoView.handleHideBlock = ^{
            wk.showBtn.selected = NO;
        };
    }
    return _showInfoView;
}

@end


@implementation TSLocalWorkInfoView(LocalVideoWork)

- (void)createVideoWorkBtns{
    NSArray *imgs = @[@"work_open",@"work_buy",@"work_save",@"work_delete",@"work_share",@"work_release"];
    for( NSInteger i=0; i<imgs.count; i++ ){
        UIButton *btn = [self getBtnWithImgName:imgs[i] hiImgName:nil sImgName:nil sel:@selector(handleBtn:) tag:i+TSConstantViewTagBase+1];
        if( i==0 ){
            _showBtn = btn;
            [btn setImage:[UIImage imageNamed:@"work_close"] forState:UIControlStateSelected];
        }
        
        else if( i==1 ){
            _buyBtn = btn;
        }
    }
    
    DSContentButton *swiBtn = [[DSContentButton alloc] initWithCornerRadius:3 borderWidth:0 borderColor:[UIColor clearColor]];
    swiBtn.tag = TSConstantViewTagBase;
    [self addSubview:swiBtn];
    
    _switchBtn = swiBtn;
}

- (id)initLocalVideoWorkInfoView{
    self = [super initWithFrame:CGRectZero];
    if( self ){
        _isLocalVideoWork = YES;
        self.userInteractionEnabled = YES;
        [self createVideoWorkBtns];
        
        [self addObserver:self.switchBtn forKeyPath:@"isHidden" options:(NSKeyValueObservingOptionNew) context:nil];
    }
    return self;
}
@end
