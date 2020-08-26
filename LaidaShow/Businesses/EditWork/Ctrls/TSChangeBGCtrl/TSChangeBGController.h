//
//  ViewController.h
//  ThreeShow
//
//  Created by DeepAI on 2019/1/26.
//  Copyright © 2019年 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TSEditWorkCtrl;
@class TSWorkModel;
@interface TSChangeBGController : UIViewController
//@property (nonatomic, strong) NSArray *imgs;
@property (nonatomic, strong) TSEditWorkCtrl *editWorkCtrl;
//@property (nonatomic, strong) NSArray<NSString *> *oriImgs;
//@property (nonatomic, strong) NSArray<NSString *> *maskClearImgs;
//@property (nonatomic, strong) NSArray<NSString *> *resultImgs;

@property (nonatomic, strong) TSWorkModel *model;

- (void)resetDatas;
@end

NS_ASSUME_NONNULL_END
