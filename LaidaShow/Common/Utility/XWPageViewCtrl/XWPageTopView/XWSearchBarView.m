//
//  XWSearchBarView.m
//  HituSocial
//
//  Created by hitomedia on 2018/1/16.
//  Copyright © 2018年 hitumedia. All rights reserved.
//

#import "XWSearchBarView.h"
#import "XWSearchView.h"

@interface XWSearchBarView()
@property (nonatomic, strong) XWSearchView *searchView;
@end

@implementation XWSearchBarView

- (id)initWithFrame:(CGRect)frame showCancleBtn:(BOOL)showCancleBtn{
    self = [super initWithFrame:frame];
    if( self ){
        CGFloat iy = 10;
        _searchView = [[XWSearchView alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, frame.size.height-iy*2) backColor:[UIColor clearColor]];
        [self addSubview:_searchView];
        
    }
    return self;
}

- (void)setSearchBarTextColor:(UIColor *)searchBarTextColor{
    _searchBarTextColor = searchBarTextColor;
    UITextField *tf = [self.searchView.searchBar valueForKey:@"_searchField"];
    tf.textColor = searchBarTextColor;
}

- (void)setSearchBarTextFieldBackColor:(UIColor *)searchBarTextFieldBackColor{
    _searchBarTextFieldBackColor = searchBarTextFieldBackColor;
    self.searchView.backgroundColor = _searchBarTextFieldBackColor;
    self.searchView.searchBarTextFieldBackColor = _searchBarTextFieldBackColor;
}

@end
