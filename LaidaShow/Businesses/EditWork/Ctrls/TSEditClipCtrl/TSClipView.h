//
//  TSClipView.h
//  ThreeShow
//
//  Created by hitomedia on 13/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 裁剪框视图
 */
@protocol TSClipViewDelegate;
@interface TSClipView : UIView

@property (nonatomic, strong) UIColor *pointColor;     //点的颜色，默认为黄色
@property (nonatomic, assign) BOOL isCanMove; //是有效移动
@property (nonatomic, weak) id<TSClipViewDelegate> delegate;
@property (nonatomic, strong) NSArray *pointArr;

- (void)setViewSize:(CGSize)size;

@end


@protocol TSClipViewDelegate<NSObject>
//拖拽选取框 结束
- (void)dragSelectAreaEnd:(TSClipView*)view;
@end
