//
//  HTSearchQuestionView.h
//  HituSocial
//
//  Created by hitomedia on 13/04/2018.
//  Copyright © 2018 hitumedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XWSearchView.h"
@interface HTSearchQuestionView : UIView

@property (nonatomic, strong) XWSearchView *searchView;
@property (nonatomic, strong) UIButton *cancleBtn;

@property (nonatomic, copy) void(^handleCancleBlock)();

- (void)changeFrame:(CGRect)frame showCancleBtn:(BOOL)showCancleBtn;

@end
