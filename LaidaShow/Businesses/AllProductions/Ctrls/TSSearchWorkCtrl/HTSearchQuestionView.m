//
//  HTSearchQuestionView.m
//  HituSocial
//
//  Created by hitomedia on 13/04/2018.
//  Copyright © 2018 hitumedia. All rights reserved.
//

#import "HTSearchQuestionView.h"

#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"

@implementation HTSearchQuestionView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        
        _cancleBtn = [UIButton new];
        CGFloat iw = 45;
        _cancleBtn.frame = CGRectMake(frame.size.width-iw-7, 0, iw, frame.size.height);
        [_cancleBtn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:[UIColor colorWithRgb153] forState:UIControlStateHighlighted];
        _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _cancleBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_cancleBtn addTarget:self action:@selector(handleCancle) forControlEvents:UIControlEventTouchUpInside];
        
        [_cancleBtn setTitle:NSLocalizedString(@"SearchCancleText", nil) forState:UIControlStateNormal];
        [self addSubview:_cancleBtn];
        
        CGFloat ih = 35,iy = (frame.size.height-ih)/2;
        CGFloat ix = 5;
        iw = _cancleBtn.x - ix;
        _searchView = [[XWSearchView alloc] initWithFrame:CGRectMake(ix, iy, iw, ih) backColor:[UIColor colorWithRgb245]];
//        [_searchView cornerRadius:ih/2];
        _searchView.backgroundColor = [UIColor clearColor];
        _searchView.searchBarTextFieldBackColor = [UIColor colorWithRgb245];
        _searchView.searchBar.placeholder = @"搜索";
        if( @available(iOS 13.0,* ) ){
            _searchView.searchBar.searchTextField.font = [UIFont systemFontOfSize:15];
            _searchView.searchBar.searchTextField.textColor = [UIColor colorWithRgb51];
        }
        
//        else{
//            UITextField *textField = [_searchView.searchBar valueForKey:@"_text"];
//            [textfield setValue:[UIColor colorWithRgb153] forKeyPath:@"_placeholderLabel.textColor"];
//            [textfield setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
//        }
        
        [self addSubview:_searchView];
    }
    return self;
}

- (void)handleCancle{
    
    if( _handleCancleBlock ){
        _handleCancleBlock();
    }
}

- (void)changeFrame:(CGRect)frame showCancleBtn:(BOOL)showCancleBtn{
    self.frame = frame;
    
    //    if( self.cancleBtn.isHidden == showCancleBtn){
    self.cancleBtn.hidden = !showCancleBtn;
    //    }
    CGFloat iy =0;
    CGFloat iw = frame.size.width;
    
    if( showCancleBtn ){
        iy = (frame.size.height - self.cancleBtn.height)/2;
        iw = frame.size.width-self.cancleBtn.width;
    }
  
    CGRect fr = self.searchView.frame;
    fr.origin.y = (self.height-fr.size.height)/2;
    fr.size.width = iw-2*fr.origin.x;;
    self.searchView.frame = fr;
    
    fr = self.cancleBtn.frame;
    fr.origin.y = iy;
    self.cancleBtn.frame = fr;
}

@end

