//
//  TSSelectDeviceCtrl.h
//  ThreeShow
//
//  Created by wkun on 2019/2/24.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSelectDeviceCtrl : UIViewController
@property (nonatomic, copy) void(^handleSelectBlock)(NSInteger idx);

@end

NS_ASSUME_NONNULL_END
