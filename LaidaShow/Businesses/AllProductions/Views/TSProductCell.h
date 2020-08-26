//
//  TSProductCell.h
//  ThreeShow
//
//  Created by hitomedia on 07/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TSProductCellDelegate;
@class TSProductModel;
/**
 作品
 */
@interface TSProductCell : UICollectionViewCell

@property (nonatomic, strong) TSProductModel *model;
@property (nonatomic, weak) id<TSProductCellDelegate> delegate;
@property (nonatomic, strong) UIButton    *praiseBtn;
@property (nonatomic, strong) UIImageView *userHeadImg;
@property (nonatomic, strong) UIImageView *productImgView;

@end

@protocol TSProductCellDelegate <NSObject>
@optional
- (void)productCell:(TSProductCell*)cell handlePraiseBtn:(UIButton*)praiseBtn;
-(void)productCell:(TSProductCell*)cell handleHeadImgView:(UIImageView*)imageview;
@end

@interface TSProductCell(LocalWork)
- (id)initLocalWorkCell;
@end
