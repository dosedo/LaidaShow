//
//  XWPageTopView.h
//  XWPageViewControllerDemo
//
//  Created by hitomedia on 16/7/29.
//  Copyright © 2016年 hitu. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef XWPAGETOPVIEW
#define XWPAGETOPVIEW

typedef NS_ENUM(NSUInteger, XWScrollDirection){
    XWScrollDirectionLeft = 0,
    XWScrollDirectionRight,
    XWScrollDirectionTop,
    XWScrollDirectionDown
};

#endif

@class XWPageViewAppearance;
@protocol XWPageTopViewDelegate;
@interface XWPageTopView : UIView

@property (nonatomic, assign) BOOL showSearchView;      //是否展示搜索视图，默认为NO
@property (nonatomic, strong) NSArray* itemTitles;      //各页顶部的标题

@property (nonatomic, weak) id<XWPageTopViewDelegate> delegate;

@property (nonatomic, strong) XWPageViewAppearance *apearance;

- (void)scrollLineViewWithPercent:(CGFloat)percent;

- (void)scrollLineViewWithPercent:(CGFloat)percent currIndex:(NSUInteger)currIndex desIndex:(NSUInteger)desIndex;

@end

@interface XWPageTopView(AddTourSegmentView)
- (void)scrollItemToIndex:(NSUInteger)idx animate:(BOOL)animate;
@end

@protocol XWPageTopViewDelegate <NSObject>

@optional
/**
 *  点击item事件
 *
 *  @param item 被触发事件的item
 */
- (void)pageTopViewHandleItem:(UIButton*)item itemIndex:(NSUInteger)index;

- (void)pageTopView:(XWPageTopView*)ptView searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;

- (void)pageTopView:(XWPageTopView*)ptView searchBarSearchButtonClicked:(UISearchBar *)searchBar;

@end


