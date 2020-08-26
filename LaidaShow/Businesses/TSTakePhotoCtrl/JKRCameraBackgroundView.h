//
//  JKRCameraBackgroundView.h
//  JKRCameraDemo
//
//  Created by tronsis_ios on 16/8/30.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JKRCameraBackgroundView;
@protocol JKRCameraBackgroundViewDelegate <NSObject>

- (void)cameraBackgroundDidChangeISO:(CGFloat)iso isPlusOrMinusBtn:(BOOL)isPlusOrMinusBtn;
- (void)cameraBackgroundDidTap:(CGPoint)point;

- (void)cameraBackgroundView:(JKRCameraBackgroundView*)cv touchDownSlider:(UISlider*)slider;
- (void)cameraBackgroundView:(JKRCameraBackgroundView*)cv touchUpSlider:(UISlider*)slider;
@end

@protocol JKRCameraBackgroundViewDatasource <NSObject>


@end

@interface JKRCameraBackgroundView : UIView

@property (nonatomic, strong) UISlider *isoSilder;
@property (nonatomic, strong) CALayer *focusLayer;
@property (nonatomic, strong) UIButton *butplus;
@property (nonatomic, strong) UIButton *minusBtn;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, weak) id<JKRCameraBackgroundViewDelegate> delegate;
@property (nonatomic, weak) id<JKRCameraBackgroundViewDatasource> datasource;
- (void)reset;

@end
