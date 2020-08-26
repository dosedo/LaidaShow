//
//  XWPageViewCtrl.h
//  XWPageViewControllerDemo
//
//  Created by hitomedia on 16/7/29.
//  Copyright © 2016年 hitu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XWPageViewCtrlDelegate;
@class XWPageTopView;
@class XWPageViewAppearance;
@interface XWPageViewCtrl : UIViewController

@property (nonatomic, strong) UIScrollView  *scrollView;    //只读
@property (nonatomic, strong) XWPageTopView *topView;       //只读

@property (nonatomic, weak) id<XWPageViewCtrlDelegate> delegate;

@property (nonatomic, strong) XWPageViewAppearance *apearance;

- (void)resetViewCtrls:(NSArray<UIViewController*>*)ctrls titles:(NSArray<NSString*>*)titles;

@end


@protocol XWPageViewCtrlDelegate <NSObject>

@optional
- (void)pageViewCtrl:(XWPageViewCtrl*)pvCtrl searchTextDidChange:(NSString*)searchText;
- (void)pageViewCtrlSearchBtnClicked:(XWPageViewCtrl*)pvCtrl;
- (void)pageViewCtrl:(XWPageViewCtrl*)pvCtrl scrollToPage:(NSUInteger)pageIndex;
/**
 滚动之前的选中的item的索引
 
 @param pvCtrl 当前实例
 @param pageIndex 页面Index
 */
- (void)pageViewCtrl:(XWPageViewCtrl*)pvCtrl scrollFromPage:(NSUInteger)pageIndex;

@end
