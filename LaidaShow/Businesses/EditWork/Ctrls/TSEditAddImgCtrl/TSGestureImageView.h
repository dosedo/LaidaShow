//
//  TSGestureImageView.h
//  ThreeShow
//
//  Created by hitomedia on 15/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 具有手势操作是的imageview ，可旋转， 缩放，拖拽
 */
@interface TSGestureImageView : UIImageView

@property (nonatomic, strong) UIImageView *imgView;

//重新初始化值
- (void)resetViews;

@end
