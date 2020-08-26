//
//  TSEditClipCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 13/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 裁剪图片
 */
@class TSEditWorkCtrl;
@interface TSEditClipCtrl : UIViewController

@property (nonatomic, strong) NSArray *imgs;
@property (nonatomic, strong) TSEditWorkCtrl *editWorkCtrl;

- (void)resetDatas;

@end
