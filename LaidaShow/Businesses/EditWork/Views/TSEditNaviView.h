//
//  TSEditNaviView.h
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSEditNaviView : UIView

- (id)initWithTitle:(NSString*)title target:(id)target cancleSel:(SEL)cancleSel sureSel:(SEL)sureSel ;
    
@property (nonatomic, strong) UIButton *sureBtn;

@end

//带有标题按钮，即标题可以点击，标题可多个，最多3个
@interface TSFilterVideoNaviView : TSEditNaviView

/**
 创建视频滤镜底部导航视图

 @param target 事件响应类
 @param cancleSel 取消事件
 @param sureSel 确认事件
 @param titles 标题
 @param handleTitleSel 标题事件，参数(UIButton *btn)标题按钮
 @return 本实例
 */
- (id)initWithTarget:(id)target cancleSel:(SEL)cancleSel sureSel:(SEL)sureSel titles:(NSArray*)titles handleTitleSel:(SEL)handleTitleSel;

- (UIButton*)buttonWithIndex:(NSInteger)index;

@end
