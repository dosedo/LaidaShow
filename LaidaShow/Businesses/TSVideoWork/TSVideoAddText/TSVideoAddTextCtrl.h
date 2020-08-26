//
//  TSVideoAddTextCtrl.h
//  ThreeShow
//
//  Created by wkun on 2019/7/21.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSVideoAddTextCtrl : UIViewController
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, copy) void(^completeBlock)(NSURL *newVideoUrl);
@end

NS_ASSUME_NONNULL_END
