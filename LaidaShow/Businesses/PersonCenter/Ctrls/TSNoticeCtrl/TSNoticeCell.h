//
//  TSNoticeCell.h
//  ThreeShow
//
//  Created by wkun on 2019/3/10.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSNoticeModel;
@interface TSNoticeCell : UITableViewCell

@property (nonatomic, strong) TSNoticeModel *model;

@end

NS_ASSUME_NONNULL_END
