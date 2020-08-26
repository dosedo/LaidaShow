//
//  TSEditModifyCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TSEditWorkCtrl;

/**
 调整图片，修改透明度灰度啥的
 */
@interface TSEditModifyCtrl : UIViewController

@property (nonatomic, strong) NSArray *imgs;
@property (nonatomic, strong) TSEditWorkCtrl *editWorkCtrl;

- (void)resetDatas;

@end
