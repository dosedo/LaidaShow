//
//  TSCancleLoadingView.h
//  ThreeShow
//
//  Created by cgw on 2019/3/15.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^TSCancleLoadingViewCancleBlock)(void);

/**
 加载视图，带有取消按钮
 */
@interface TSCancleLoadingView : UIView

+ (void)showWithCancleBlock:(TSCancleLoadingViewCancleBlock)cancleBlock;

+ (void)hide;

@end

NS_ASSUME_NONNULL_END
