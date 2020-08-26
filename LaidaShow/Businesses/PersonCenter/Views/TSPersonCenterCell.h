//
//  TSPersonCenterCell.h
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSPersonCenterCellModel;
@interface TSPersonCenterCell : UITableViewCell

@property (nonatomic, strong) UIImageView *leftImgV;
@property (nonatomic, strong) UIImageView *arrowImgV;
@property (nonatomic ,strong) UILabel     *leftL;
@property (nonatomic, strong) UILabel     *rightL;
@property (nonatomic ,strong) UIView      *line;

/**
 是否展示右侧箭头，默认为YES
 */
@property (nonatomic, assign) BOOL showArrow;

/**
 是否展示左侧图标，默认为NO
 */
@property (nonatomic, assign) BOOL showLeftImg;


/**
 默认为-1，-1为自动计算！
 */
@property (nonatomic, assign) CGFloat leftLabelWidth;

@property (nonatomic ,strong) TSPersonCenterCellModel *model;

- (CGFloat)getEdgeDistance;

@end


