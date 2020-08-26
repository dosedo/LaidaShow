//
//  HTNoDataView.h
//  Hitu
//
//  Created by hitomedia on 2016/12/8.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTNoDataView : UIView

- (id)initWithFrame:(CGRect)fr text:(NSString*)text action:(SEL)loadDataSel target:(UIViewController*)target;

@property (nonatomic, assign) BOOL hideReloadBtn;   //默认为NO
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *imgName;

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *loadBtn;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, assign) BOOL isAutoLayout; //默认为NO 
@property (nonatomic, assign) NSUInteger content;

@property (nonatomic, assign) UIControlContentVerticalAlignment contentVerticalAlignment;  //竖直方向内容的布局。默认为UIControlContentVerticalAlignmentTop
@end
