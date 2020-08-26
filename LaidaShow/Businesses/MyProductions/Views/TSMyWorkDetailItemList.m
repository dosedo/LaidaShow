//
//  TSMyWorkDetailItemList.m
//  ThreeShow
//
//  Created by wkun on 2019/3/10.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSMyWorkDetailItemList.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "UILabel+Ext.h"
#import "TSScrollView.h"

static const NSUInteger gBaseTag = 666;

@implementation TSMyWorkDetailItemList{
    HandleItemBlock _handleItemBlock;
    UIView *_shareBtnsBgView;
    TSScrollView *_btnScrollView;
    NSArray *_imgNames;
}

- (id)initWithTitles:(NSArray *)titles imgNames:(NSArray*)imgNames handleItemBlock:(void (^)(NSInteger))handleItemBlock{
    self = [super init];
    if( self ){
        _handleItemBlock = handleItemBlock;
        _shareTitles = titles;
        _imgNames = imgNames;
        
        [self initSubviewsWithImgNames:imgNames];
    }
    return self;
}

- (void)show{
    [self showShareView];
}

#pragma mark - Private

- (void)initSubviewsWithImgNames:(NSArray*)imgNames{
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.userInteractionEnabled = YES;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [_shareBtnsBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if( _shareBtnsBgView == nil ){
        _shareBtnsBgView = [UIView new];
        _shareBtnsBgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_shareBtnsBgView];
        
        //阴影
        _shareBtnsBgView.layer.shadowOffset = CGSizeMake(0, -3);
        _shareBtnsBgView.layer.shadowOpacity = 0.08;
        _shareBtnsBgView.layer.shadowColor = [UIColor blackColor].CGColor;
    }
    
    if( !_btnScrollView ){
        _btnScrollView = [TSScrollView new];
        _btnScrollView.backgroundColor = [UIColor clearColor];
        _btnScrollView.showsHorizontalScrollIndicator = NO;
        [_shareBtnsBgView addSubview:_btnScrollView];
    }
    
    CGFloat shareBtnBottom = 0.0, lastBtnRight = 0;
    for( NSUInteger i=0;i < imgNames.count; i++ ){
        NSString *name = imgNames[i];
        if( [name isKindOfClass:[NSString class]] ){
            NSUInteger btnTag = i+gBaseTag;
            UIButton *shareBtn = [_btnScrollView viewWithTag:btnTag];
            if( shareBtn ==nil ){
                shareBtn = [UIButton new];
                shareBtn.tag = btnTag;
                [_btnScrollView addSubview:shareBtn];
            }
            [shareBtn setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
            [shareBtn addTarget:self action:@selector(handleShareBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            if( _shareTitles.count && i<_shareTitles.count){
                NSString *title = _shareTitles[i];
                [self configShareBtnTitleWithBtn:shareBtn title:title];
            }
            
//            NSUInteger rowIndex = 0;//i/colum;
//            NSUInteger columIndex = i;//i%colum;
//            CGFloat edgeDistance = 10;
            CGFloat iw = //(screenSize.width-2*edgeDistance)/colum;
            [shareBtn.titleLabel labelSizeWithMaxWidth:120].width;
            if( iw < shareBtn.currentImage.size.width ){
                iw = shareBtn.currentImage.size.width;
            }
            CGFloat ix = lastBtnRight+15;
            CGFloat ih = 25+40+25;
            CGFloat iy = (10);
            shareBtn.frame = CGRectMake(ix, iy, iw, ih);
            
            lastBtnRight = shareBtn.right;
            shareBtnBottom = CGRectGetMaxY(shareBtn.frame);
        }
    }
    _btnScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, shareBtnBottom);
    
    [_btnScrollView setContentSize:CGSizeMake(lastBtnRight+15, _btnScrollView.height)];
    
    if( shareBtnBottom > 0 ){
        CGFloat lineTag = 1111;
        UIView *line = [_shareBtnsBgView viewWithTag:lineTag];
        if( !line ){
            line = [UIView new];
            line.backgroundColor = [UIColor colorWithRgb221];
            [_shareBtnsBgView addSubview:line];
            line.tag = lineTag;
        }
        CGFloat lineH = 0.5;
        line.frame = CGRectMake(0, shareBtnBottom+10, screenSize.width, lineH);
        
        //添加取消按钮
        NSUInteger cancleTag = lineTag+1;
        UIButton *cancleBtn = [_shareBtnsBgView viewWithTag:cancleTag];
        if( [cancleBtn isKindOfClass:[UIButton class]] == NO ){
            cancleBtn = [UIButton new];
            [_shareBtnsBgView addSubview:cancleBtn];
            cancleBtn.tag = cancleTag;
        }
        [cancleBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [cancleBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
        [cancleBtn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateHighlighted];
        cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        cancleBtn.frame = CGRectMake(0, CGRectGetMaxY(line.frame), screenSize.width, 45);
        [cancleBtn addTarget:self action:@selector(handleCancleBtn:) forControlEvents:UIControlEventTouchUpInside];
        cancleBtn.backgroundColor = [UIColor clearColor];
        
        CGFloat ih = CGRectGetMaxY(cancleBtn.frame);
        _shareBtnsBgView.frame = CGRectMake(0, screenSize.height, screenSize.width, ih);
    }
}

- (void)configShareBtnTitleWithBtn:(UIButton*)btn title:(NSString*)title{
    
    btn.titleLabel.font  =[UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
    
    [btn setTitle:title forState:UIControlStateNormal];
    CGSize imgSize = btn.currentImage.size;
    CGFloat btnW = CGRectGetWidth(btn.frame);
    CGFloat btnH = CGRectGetHeight(btn.frame);
    CGSize textSize = [btn.titleLabel labelSizeWithMaxWidth:btnW+1000];
    CGFloat ygap = 10;
    CGFloat toTop = (btnH-imgSize.height-ygap-textSize.height)/2;
    CGFloat imgToLeft = (btnW-imgSize.width)/2;
    btn.imageEdgeInsets = UIEdgeInsetsMake(toTop, imgToLeft, btnH-toTop-imgSize.height, imgToLeft-textSize.width);
    toTop = (toTop+imgSize.height+ygap);
    CGFloat toRight = (btnW-textSize.width)/2;
    btn.titleEdgeInsets = UIEdgeInsetsMake(toTop, toRight-imgSize.width, btnH-toTop-textSize.height, toRight);
}

- (void)showShareView{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect fr = _shareBtnsBgView.frame;
        fr.origin.y = ([UIScreen mainScreen].bounds.size.height-fr.size.height);
        _shareBtnsBgView.frame = fr;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideShareView{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect fr = _shareBtnsBgView.frame;
        fr.origin.y = ([UIScreen mainScreen].bounds.size.height);
        _shareBtnsBgView.frame = fr;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - TouchEvents

- (void)handleShareBtn:(UIButton*)btn{
    if( _handleItemBlock ){
        _handleItemBlock(btn.tag-gBaseTag);
    }
    [self hideShareView];
}

- (void)handleCancleBtn:(UIButton*)btn{
    [self hideShareView];
}



@end
