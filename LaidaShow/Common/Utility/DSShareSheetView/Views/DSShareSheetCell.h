//
//  DSShareSheetCell.h
//  ThreeShow
//
//  Created by wkun on 2020/1/10.
//  Copyright © 2020 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSShareSheetModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imgName;

@end

@interface DSShareSheetCell : UICollectionViewCell

@property (nonatomic, strong) DSShareSheetModel *model;

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleL;

@end

NS_ASSUME_NONNULL_END
