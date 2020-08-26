//
//  TSEditAddImgCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TSEditWorkCtrl;

@interface TSEditAddImgCtrl : UIViewController
@property (nonatomic, strong) NSArray *imgs;

@property (nonatomic, copy) void(^completeBlock)(NSArray *newImgArr);
//@property (nonatomic, strong) TSEditWorkCtrl *editWorkCtrl;

- (void)resetDatas;

@property (nonatomic, strong) NSURL *videoUrl;

@end
