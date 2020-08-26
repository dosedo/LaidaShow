//
//  TSVideoWorkDetailBottomView.m
//  ThreeShow
//
//  Created by cgw on 2019/7/15.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSVideoWorkDetailBottomView.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+Ext.h"
#import "UILabel+Ext.h"
#import "TSProductionDetailModel.h"
#import "UIImageView+WebCache.h"
#import "NSString+Ext.h"
#import "TSProductDataModel.h"
#import "TSWorkShowInfoView.h"
//#import "DSButton.h"

@interface TSVideoWorkDetailBottomView()

@property (nonatomic, strong) TSWorkShowInfoView *showInfoView;

@end

@implementation TSVideoWorkDetailBottomView

- (void)setModel:(TSProductionDetailModel *)model{
    _model = model;
    
    self.showInfoView.model = model;
    self.praiseBtn.selected = model.isPraised;
//    self.collectBtn.selected = model.isCollected;
//    
//    //    model.collectCount = @"1W+";
//    if( model.collectCount.integerValue <= 0 ){
//        model.collectCount = @"0";
//    }
//    [self.collectBtn setTitle:model.collectCount forState:UIControlStateNormal];
    
    //    model.praiseCount = @"2.3K";
    if( model.praiseCount.integerValue <= 0 ){
        model.praiseCount = @"0";
    }
    [self.praiseBtn setTitle:model.praiseCount forState:UIControlStateNormal];
    
    self.buyBtn.hidden = YES;
    if( model.buyUrl.length > 3){
        self.buyBtn.hidden = NO;
    }

    [self doLayoutWithSize:self.size];
}

//点赞成功更新按钮状态
- (void)praiseSuccess:(BOOL)isCancle{
    NSInteger praiseCount = [NSString stringWithObj:_model.dm.praise].integerValue;
    if( isCancle ){
        praiseCount --;
        if( praiseCount < 0 ) praiseCount = 0;
    }
    else{
        praiseCount ++;
    }
    
    [self.praiseBtn setTitle:@(praiseCount).stringValue forState:UIControlStateNormal];
    self.praiseBtn.selected = !isCancle;
}

//收藏成功更新按钮状态
- (void)collectSuccess:(BOOL)isCancle{
    NSInteger count = [NSString stringWithObj:_model.dm.collectCount].integerValue;
    if( isCancle ){
        count --;
        if( count < 0 ) count = 0;
    }
    else{
        count ++;
    }
    
    [self.collectBtn setTitle:@(count).stringValue forState:UIControlStateNormal];
    self.collectBtn.selected = !isCancle;
}

#pragma mark - Private

#pragma mark - Layout
- (void)doLayoutWithSize:(CGSize)viewSize{
    CGSize size = viewSize;
    
    CGFloat ih = 50;
    CGFloat praiseW = [self calculateWidthWithBtn:self.praiseBtn];
//    CGFloat btnW = praiseW+50;
//    NSInteger count = 3;
//    CGFloat ix = (size.width-count*btnW)/(count+1);
//    self.praiseBtn.frame = CGRectMake(size.width-btnW-ix, 0, btnW, ih);
//
//    self.shareBtn.frame = CGRectMake(viewSize.width/2-btnW/2, 0, btnW, ih);
//
//    self.showBtn.frame = CGRectMake(ix, 0, btnW, ih);
    
    
    
    
//    CGFloat collectW = [self calculateWidthWithBtn:self.collectBtn];
    CGFloat imgW = 20;

    NSInteger equalWidthBtnCount = 4;
    NSInteger gapCount = 10;
    if( self.buyBtn.isHidden ){
        equalWidthBtnCount--;
        gapCount = 8;
    }
    //按钮距离左右视觉上看起来的距离。
    CGFloat gap = (size.width-praiseW-imgW*equalWidthBtnCount)/gapCount;

    CGFloat btnW = praiseW+gap*2;
    self.praiseBtn.frame = CGRectMake(size.width-btnW, 0, btnW, ih);
//    btnW = collectW+gap*2;
//    self.collectBtn.frame = CGRectMake(_praiseBtn.x-btnW, 0, btnW, ih);
    btnW = imgW+gap*2;
    
    self.shareBtn.frame = CGRectMake(_praiseBtn.x-btnW, 0, btnW, ih);
    self.qrCodeBtn.frame = CGRectMake(_shareBtn.x-btnW, 0, btnW, ih);
    self.buyBtn.frame = CGRectMake(_qrCodeBtn.x-btnW, 0, btnW, ih);
    self.showBtn.frame = CGRectMake(0, 0, btnW, ih);
}

- (CGFloat)calculateWidthWithBtn:(UIButton*)btn{
    CGFloat imgW = 18;
    CGFloat maxW = 50;
    if( btn.titleLabel.text.length ){
        CGFloat titleW = [btn.titleLabel labelSizeWithMaxWidth:maxW].width;
        return titleW+imgW+3;
    }
    
    return imgW;
}

#pragma mark - TouchEvents

- (void)handleshowBtn:(UIButton*)btn{
    
    btn.selected = !btn.isSelected;
    [self.showInfoView show];
}

- (void)handleBuyBtn:(UIButton*)btn{
    [self handleBtnAtIndex:0 isSelected:NO];
}

- (void)handleShareQRBtn:(UIButton*)btn{
    [self handleBtnAtIndex:1 isSelected:NO];
}

- (void)handlePraiseBtn:(UIButton*)btn{
    [self handleBtnAtIndex:2 isSelected:btn.isSelected];
}

- (void)handleCollectBtn:(UIButton*)btn{
    [self handleBtnAtIndex:3 isSelected:btn.isSelected];
}

- (void)handleShareBtn:(UIButton*)btn{
    [self handleBtnAtIndex:4 isSelected:NO];
}

- (void)handleBtnAtIndex:(NSUInteger)idx isSelected:(BOOL)isSelected{
    if( _delegate && [_delegate respondsToSelector:@selector(videoWorkDetailBottomView:handleBtnAtIndex: isCancle:)]){
        [_delegate videoWorkDetailBottomView:self handleBtnAtIndex:idx isCancle:isSelected];
    }
}

#pragma mark - Propertys


- (UIButton *)buyBtn {
    if( !_buyBtn ){
        _buyBtn = [[UIButton alloc] init];
        [_buyBtn setImage:[UIImage imageNamed:@"work_buy"] forState:UIControlStateNormal];
        _buyBtn.imageView.contentMode = UIViewContentModeCenter;
        [_buyBtn addTarget:self action:@selector(handleBuyBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_buyBtn];
    }
    return _buyBtn;
}

- (UIButton*)getBtnWithImgName:(NSString*)imgName hiImgName:(NSString*)hiImgName sImgName:(NSString*)sImgName sel:(SEL)sel{
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
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
    
    btn.imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:btn];
    
    return btn;
}

- (UIButton *)showBtn {
    if( !_showBtn ){
        
        _showBtn = [self getBtnWithImgName:@"work_open" hiImgName:nil sImgName:@"work_close" sel:@selector(handleshowBtn:)];
    }
    return _showBtn;
}

- (UIButton *)praiseBtn {
    if( !_praiseBtn ){
        _praiseBtn = [self getBtnWithImgName:@"work_praise_n" hiImgName:nil sImgName:@"work_praise_s" sel:@selector(handlePraiseBtn:)];
    }
    return _praiseBtn;
}

- (UIButton *)collectBtn {
    if( !_collectBtn ){
        _collectBtn = [self getBtnWithImgName:@"work_collection" hiImgName:nil sImgName:@"work_collection_s" sel:@selector(handleCollectBtn:)];
        _collectBtn.imageEdgeInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
    }
    return _collectBtn;
}

- (UIButton *)shareBtn {
    if( !_shareBtn ){
        _shareBtn = [self getBtnWithImgName:@"work_share" hiImgName:nil sImgName:nil sel:@selector(handleShareBtn:)];
    }
    return _shareBtn;
}

- (UIButton *)qrCodeBtn{
    if( !_qrCodeBtn ){
        _qrCodeBtn = [self getBtnWithImgName:@"work_ma" hiImgName:nil sImgName:nil sel:@selector(handleShareQRBtn:)];
    }
    return _qrCodeBtn;
}

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
