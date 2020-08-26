//
//  XWPageViewAppearance.h
//  Hitu
//
//  Created by hitomedia on 16/8/17.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef XWPAGEVIEWAPPEARANCE
#define XWPAGEVIEWAPPEARANCE

typedef NS_ENUM(NSUInteger, XWPageTopViewItemStyle) {
    XWPageTopViewItemStyleMonospaced =0, //等宽的Item
    XWPageTopViewItemStyleUniformlySpaced  //等间距的Item
};

#endif

@interface XWPageViewAppearance : NSObject

/**
 item 最小的宽度
 */
@property (nonatomic, assign) CGFloat itemMinWidth;

/**
 item 水平方向的间距
 */
@property (nonatomic, assign) CGFloat itemXGap;

/**
 距离左右边框的距离。
 */
@property (nonatomic, assign) CGFloat itemEdgeDistance;

/**
 item 中心点之间的x距离
 */
@property (nonatomic, assign) CGFloat itemCenterXDistance;

/**
 item 标题字号
 */
@property (nonatomic, assign) CGFloat itemTitleFontSize;

/**
 item 标题颜色
 */
@property (nonatomic, strong) UIColor *itemTitleColor;

/**
 item 选中之后的颜色
 */
@property (nonatomic, strong) UIColor *itemSelectedTitleColor;

/**
 滑动线条宽度，0为自动计算。
 */
@property (nonatomic, assign) CGFloat lineViewWidth;
/**
 滑动线条的颜色
 */
@property (nonatomic, strong) UIColor *lineColor;

/**
 line的滚动视图的背景色
 */
@property (nonatomic, strong) UIColor *lineScrollViewBackColor;

/**
 line的背景视图的颜色,默认为nil
 */
@property (nonatomic, strong) UIColor *lineBackViewColor;

/**
 topView的Y坐标，默认为0
 */
@property (nonatomic, assign) CGFloat topViewOriginY;

/**
 topView的高度，默认为30;
 */
@property (nonatomic, assign) CGFloat topViewHeight;


/**
 topView的背景色
 */
@property (nonatomic, strong) UIColor *topViewBackColor;

/**
 topView中item的背景色
 */
@property (nonatomic, strong) UIColor *topViewItemColor;

/**
 item 最大数量。0 为不限制
 */
@property (nonatomic, assign) NSUInteger itemMaxCount;

/**
 当前选择的item的索引
 */
@property (nonatomic, assign) NSUInteger currItemIndex;

/**
 topView的类别的展示方式，有两种，item等宽和item等间距。
 XWPageTopViewItemStyleMonospaced，等宽，即所有的item的宽度都相同，间距也相同；
 XWPageTopViewItemStyleUniformlySpaced，等间距的Item， item的宽度根据文字的长度计算。
 默认为等宽
 */
@property (nonatomic, assign) XWPageTopViewItemStyle topViewItemStyle;

@end
