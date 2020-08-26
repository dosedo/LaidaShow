//
//  TSLanguageSetView.h
//  ThreeShow
//
//  Created by wkun on 2020/1/1.
//  Copyright © 2020 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 语言设置视图
@interface TSLanguageSetView : UIView

+ (void)showWithComplete:(void(^)(void))complete;

@end

@class TSLanguageModel;
@interface TSLanguageSetViewCell : UITableViewCell

@property (nonatomic, strong) TSLanguageModel *model;

@end

NS_ASSUME_NONNULL_END
