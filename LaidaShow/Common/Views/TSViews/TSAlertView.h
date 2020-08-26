//
//  TSAlertView.h
//  ThreeShow
//
//  Created by hitomedia on 18/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 在中间弹出的视图。顶部是标题，中间是内容描述，接着是一个取消一个确定按钮
 */
@interface TSAlertView : UIView

+ (void)showAlertWithTitle:(NSString*)title des:(NSString*)des cancleTitle:(NSString*)cti sureTitle:(NSString*)sti needCancleBlock:(BOOL)needCancleBlock handleBlock:(void(^)(NSInteger index))handleBlock;

/**
 显示视图

 @param title 标题
 @param des 展示内容描述
 @param handleBlock 点击按钮回调，索引从上往下，从0开始
 */
+ (void)showAlertWithTitle:(NSString*)title des:(NSString*)des handleBlock:(void(^)(NSInteger index))handleBlock;

+ (void)showAlertWithTitle:(NSString*)title handleBlock:(void(^)(NSInteger index))handleBlock;

/**
 展示alert弹出，只展示内容和确定按钮

 @param title 展示的内容
 */
+ (void)showAlertWithTitle:(NSString*)title;


@end
