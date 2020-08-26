//
//  TSSelectMusicCell.h
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSSelectMusicModel;
@interface TSSelectMusicCell : UITableViewCell

/**
 是否为举报的cell,默认为NO
 */
@property (nonatomic, assign) BOOL isReportCell;

@property (nonatomic, strong) TSSelectMusicModel *model;

//举报cell
- (id)initReportCellWithReuseID:(NSString*)rid;

@end
