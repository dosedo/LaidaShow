//
//  TSWorkTypeSelectView.h
//  ThreeShow
//
//  Created by cgw on 2019/7/15.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 视频作品、三维作品选择视图
 */
@interface TSWorkTypeSelectView : UIButton

- (id)initWithFrame:(CGRect)fr inView:(UIView*)inView;

//当前选择的类型 0三维、1视频
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) void(^selectBlock)(NSInteger selectIndex);

@end

NS_ASSUME_NONNULL_END
