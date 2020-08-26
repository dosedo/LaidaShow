//
//  TSUserInfoView.h
//  ThreeShow
//
//  Created by wkun on 2019/2/23.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSUserModel;
@interface TSUserInfoView : UIView

@property (nonatomic, strong) UIImageView *headImgView;
@property (nonatomic, strong) UILabel     *nameL;
@property (nonatomic, strong) UILabel     *signatureL;   //个性签名

@property (nonatomic, strong) TSUserModel *model;

- (id)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
