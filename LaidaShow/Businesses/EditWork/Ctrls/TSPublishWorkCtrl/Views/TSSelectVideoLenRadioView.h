//
//  TSSelectVideoLenRadioView.h
//  ThreeShow
//
//  Created by cgw on 2019/3/20.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef TSSELECTVIDEOLENRADIOVIEW
#define TSSELECTVIDEOLENRAEIOVIEW

typedef void(^SelectRadioBlock)(NSInteger index);

#endif

/**
 选择视频时长
 */
@interface TSSelectVideoLenRadioView : UIView

- (id)initWithSelectedIndex:(NSInteger)selectIndex titles:(NSArray*)titles;
@property (nonatomic, assign, readonly) NSInteger selectedIndex;
@property (nonatomic, copy) SelectRadioBlock selectBlock;

@end

NS_ASSUME_NONNULL_END
