//
//  TSSelectDeviceView.h
//  ThreeShow
//
//  Created by cgw on 2019/2/26.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef TSSELECTDEVICEVIEW
#define TSSELECTEDVICEVIEW

typedef void(^SureBlock)(void);

#endif

@interface TSSelectDeviceView : UIView

+ (void)showSelectDeviceViewWithSureBlock:(SureBlock)sureBlock;

@end

NS_ASSUME_NONNULL_END
