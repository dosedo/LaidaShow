//
//  XWSearchView.m
//  XWPageViewControllerDemo
//
//  Created by hitomedia on 16/7/29.
//  Copyright © 2016年 hitu. All rights reserved.
//

#import "XWSearchView.h"
#import "UIColor+XW.h"

@interface XWSearchView()
@end

@implementation XWSearchView{
    UIView *_searchBarBgView;
}

@synthesize searchBar = _searchBar;

- (instancetype)init{
    self = [super init ];
    if( self ){
        [self initSelf];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame backColor:(UIColor *)backColor{
    self = [super initWithFrame:frame];
    if( self ){
        CGRect barFr = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self initViewsWithFrame:frame searchBarFr:barFr backColor:backColor];
    }
    return self;
}

#pragma mark - Private

- (void)initSelf{
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    //阴影
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0];
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowOpacity = 0.02;
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;

    CGFloat ih = 27+10;

    CGFloat selfH = 46;
    [self initViewsWithFrame:CGRectMake(0, 0, size.width, selfH) searchBarFr:CGRectMake(0, (selfH-ih)/2, size.width, ih) backColor:[UIColor colorWithR:240 G:239 B:244]];
}

- (void)initViewsWithFrame:(CGRect)fr searchBarFr:(CGRect)barFr backColor:(UIColor*)backColor{
    self.frame = fr;//CGRectMake(0, 0, size.width, 46);
    self.searchBar.frame = barFr;
    self.searchBar.backgroundColor = [UIColor clearColor];//[UIColor colorWithWhite:245/255.0 alpha:1]
    [self addSubview:self.searchBar];
}

//- (void)setSearchBarTextFieldBackColor:(UIColor *)searchBarTextFieldBackColor{
//    _searchBarTextFieldBackColor = searchBarTextFieldBackColor;
//    [self setSearchTextFieldBackgroundColor:searchBarTextFieldBackColor];
//}

- (void)dismissKeyBoard{
    [self.searchBar resignFirstResponder];
}

- (void)layoutSubviews{
    CGFloat ih = self.frame.size.height;// 27+10;
    CGFloat iy = (self.frame.size.height-ih)/2;
    self.searchBar.frame = CGRectMake(0, iy, self.frame.size.width, ih);
}

//- (void)inputAccessView{
//    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
//    [topView setBarStyle:UIBarStyleBlackTranslucent];
//    
//    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(2, 5, 50, 25);
//    [btn addTarget:self action:@selector(dismissKeyBoard) forControlEvents:UIControlEventTouchUpInside];
//    [btn setImage:[UIImage imageNamed:@"shouqi"] forState:UIControlStateNormal];
//    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
//    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneBtn,nil];
//    [topView setItems:buttonsArray];
//}

- (void)setSearchTextFieldBackgroundColor:(UIColor *)backgroundColor
{
    
//    return;
//    UIView *searchTextField = nil;
//
//    BOOL IsiOS7OrLater = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0);
//    if (IsiOS7OrLater) {
//        // 经测试, 需要设置barTintColor后, 才能拿到UISearchBarTextField对象
//        self.searchBar.barTintColor = [UIColor whiteColor];
//        searchTextField = [[[self.searchBar.subviews firstObject] subviews] lastObject];
//        for (UIView *subView in self.searchBar.subviews) {
//            if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
//                searchTextField = subView;
//            }
//        }
//    }
//    searchTextField.backgroundColor = backgroundColor;
}

- (UISearchBar *)searchBar{
    if( !_searchBar)
    {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"请输入搜索内容";
        _searchBar.keyboardType = UIKeyboardTypeDefault;
        _searchBar.searchBarStyle = UIBarStyleBlackTranslucent;
        
        if( @available(iOS 13.0, *) ){
            UITextField *tf = _searchBar.searchTextField;
            tf.font = [UIFont systemFontOfSize:14.0];
        }
    }
    return _searchBar;
}


@end






