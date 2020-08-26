//
//  XWPickerView.h
//  Hitu
//
//  Created by hitomedia on 2017/3/21.
//  Copyright © 2017年 hitomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef XWPickerViewCompleteBlock
#define XWPickerViewCompleteBlock

typedef void(^CompleteBlock)(NSUInteger index1, NSUInteger index2, NSUInteger index3) ;

#endif

/**
 三级选择，每级之间并不会相关连
 */
@interface XWPickerView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *data1;
@property (nonatomic, strong) NSArray *data2;
@property (nonatomic, strong) NSArray *data3;

- (void)showWithCompleteBlock:(CompleteBlock)completeBlock;
- (void)showWithCompleteBlock:(CompleteBlock)completeBlock dismisBlock:(void(^)(void))dismisBlock;

@end
