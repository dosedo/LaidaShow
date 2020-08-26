//
//  TSVideoFilterTypeView.m
//  ThreeShow
//
//  Created by cgw on 2019/7/17.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSVideoFilterTypeView.h"
#import "UIColor+Ext.h"
#import "FilterHelper.h"

@interface TSVideoFilterTypeViewButton : UIButton
- (id)initWithImgToText:(CGFloat)imgToText imgH:(CGFloat)imgH;
@end

@implementation TSVideoFilterTypeView{
    UIScrollView *_scrollView;
    BOOL _isCanSelected;
    UIButton *_lastSelectedBtn;
}

- (id)initWithFrame:(CGRect)fr filters:(NSArray<MHFilterInfo*>*)filters typeImgHeight:(CGFloat)typeImgHeight{
    self = [super initWithFrame:fr];
    if( self ){
        if( filters.count > TSVIDEOFILTERTYPE_MAX_TYPE_COUNT ){
            NSLog(@"初始化--TSVideoFilterTypeView--失败，因titles数量超过最大%d个限制",TSVIDEOFILTERTYPE_MAX_TYPE_COUNT);
            return nil;
        }
        
        _filters = filters;
        
        _isCanSelected = YES;
        
        _scrollView = [UIScrollView new];
        _scrollView.frame = CGRectMake(0, 0, fr.size.width, fr.size.height);
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
        for( NSInteger i=0; i<filters.count; i++ ){
            MHFilterInfo *fi = filters[i];
            NSString *ti = NSLocalizedString(fi.filterName, nil);//titles[i];
          
            UIButton *btn = [[TSVideoFilterTypeViewButton alloc] initWithImgToText:5 imgH:typeImgHeight];
            [btn setImage:[UIImage imageNamed:fi.imgName] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 100 +i;
            [btn setTitle:ti forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateNormal];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.numberOfLines = 0;
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            CGFloat iw = fr.size.width/filters.count;
            if( iw < 70 ){
                iw = 70;
            }
            btn.frame = CGRectMake(iw*i, 0, iw, fr.size.height);
            [_scrollView addSubview:btn];
            
            if( _isCanSelected ){
                [btn setImage:[UIImage imageNamed:fi.sImgName] forState:UIControlStateSelected];
                [btn setTitleColor:[UIColor colorWithRgb_0_151_216] forState:UIControlStateSelected];
                
                if( i==0){
                    btn.selected = YES;
                    _lastSelectedBtn = btn;
                }
                else if( i==filters.count-1){
                    [_scrollView setContentSize:CGSizeMake(CGRectGetMaxX(btn.frame), _scrollView.frame.size.height)];
                }
            }
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)fr titles:(NSArray<NSString *> *)titles imgNames:(NSArray<NSString *> *)imgNames sImgNames:(NSArray<NSString *> *)sImgNames isCanSelected:(BOOL)isCanSelected typeImgHeight:(CGFloat)typeImgHeight{
    self = [super initWithFrame:fr];
    if( self ){
        if( titles.count > TSVIDEOFILTERTYPE_MAX_TYPE_COUNT ){
            NSLog(@"初始化--TSVideoFilterTypeView--失败，因titles数量超过最大%d个限制",TSVIDEOFILTERTYPE_MAX_TYPE_COUNT);
            return nil;
        }
        
        _isCanSelected = isCanSelected;
        
        _scrollView = [UIScrollView new];
        _scrollView.frame = CGRectMake(0, 0, fr.size.width, fr.size.height);
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
        for( NSInteger i=0; i<titles.count; i++ ){
            NSString *ti = titles[i];
            NSString *imgName = nil;
            if( imgNames.count > i ) {
                imgName = imgNames[i];
            }
            NSString *sImgName = nil;
            if( sImgNames.count > i ){
                sImgName = sImgNames[i];
            }
            
            UIButton *btn = [[TSVideoFilterTypeViewButton alloc] initWithImgToText:5 imgH:typeImgHeight];
            [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 100 +i;
            [btn setTitle:ti forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateNormal];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            CGFloat iw = fr.size.width/titles.count;
            if( iw < 70 ){
                iw = 70;
            }
            btn.frame = CGRectMake(iw*i, 0, iw, fr.size.height);
            [_scrollView addSubview:btn];
            
            if( isCanSelected ){
                [btn setImage:[UIImage imageNamed:sImgName] forState:UIControlStateSelected];
                [btn setTitleColor:[UIColor colorWithRgb_0_151_216] forState:UIControlStateSelected];
                
                if( i==0){
                    btn.selected = YES;
                    _lastSelectedBtn = btn;
                }
            }
        }
    }
    return self;
}

- (void)handleBtn:(UIButton*)btn{
    if( _isCanSelected ){
        if( btn.isSelected ) return;
    }
    
    if( _selectBlock ){
        _selectBlock(btn.tag-100);
    }
    
    if( _isCanSelected ){
        _lastSelectedBtn.selected = NO;
        btn.selected = YES;
        _lastSelectedBtn = btn;
    }
}

@end

@implementation TSVideoFilterTypeViewButton{
    CGFloat _gap;
    CGFloat _imgH;
}

- (id)initWithImgToText:(CGFloat)imgToText imgH:(CGFloat)imgH{
    self = [super init];
    if( self ){
        _gap = imgToText;
        _imgH = imgH;//54;
    }
    return self;
}

- (CGFloat)toTopWithHeight:(CGFloat)height{
    CGFloat wh = _imgH, textH = 15;
    CGFloat toTop = (height-wh-textH-_gap)/2;
    return toTop;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat wh = _imgH;
    return CGRectMake(contentRect.size.width/2-wh/2, [self toTopWithHeight:contentRect.size.height], wh, wh);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat wh = _imgH, textH = 15;
    CGFloat toTop = (contentRect.size.height-wh-textH-_gap)/2;
    
    return CGRectMake(0, contentRect.size.height-textH-toTop, contentRect.size.width, textH);
}

@end
