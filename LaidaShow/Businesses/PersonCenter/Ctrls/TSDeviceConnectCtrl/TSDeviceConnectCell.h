//
//  TSDeviceConnectCell.h
//  ThreeShow
//
//  Created by hitomedia on 12/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBLoadingView;
@class CBPeripheral;
@interface TSDeviceConnectCell : UITableViewCell

@property (nonatomic, strong) UILabel *leftL;
@property (nonatomic, strong) UIImageView *rightImgView;
@property (nonatomic, strong) WBLoadingView *animateView;
@property (nonatomic ,strong) UIView      *line;

@property (nonatomic, strong) CBPeripheral *model;

@end


