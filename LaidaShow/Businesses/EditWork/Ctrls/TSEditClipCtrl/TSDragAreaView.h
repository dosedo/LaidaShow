//
//  TSDragAreaView.h
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 拖拽区域视图
 */
@interface TSDragAreaView : UIView

- (id)initWithFrame:(CGRect)frame pointRadius:(CGFloat)radius;

@property (nonatomic, assign) CGFloat pointRadius;

@end
