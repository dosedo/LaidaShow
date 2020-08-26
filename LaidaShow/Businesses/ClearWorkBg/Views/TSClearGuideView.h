//
//  TSClearGuideView.h
//  ThreeShow
//
//  Created by cgw on 2019/2/26.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HideBlock)(void);

/**
 去底引导视图，即提示用户点击去底，可轻松去掉产品的背景图，快来试试吧
 */
@interface TSClearGuideView : UIView

/**
 展示去底视图

 @param fr 高亮去底的按钮的针对整个屏幕的frame
 @param hideBlock 点击的回调
 */
+ (void)showClearGuideViewWithBtnFrame:(CGRect)fr HideBlock:(HideBlock)hideBlock;

@end

NS_ASSUME_NONNULL_END
