//
//  TSCopyShareWorkPwdView.h
//  LaidaShow
//
//  Created by Met on 2020/8/26.
//  Copyright © 2020 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSCopyShareWorkPwdView : UIView

@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UILabel *pwdL;
//复制
@property (nonatomic, strong) UIButton *copiedBtn;

+ (TSCopyShareWorkPwdView*)showCopyPwdViewWithPwd:(NSString*)pwd;

@end

NS_ASSUME_NONNULL_END
