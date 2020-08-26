//
//  TSLocalWorkDetailCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 16/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSWorkModel;
/**
 本地作品的详情
 */
@interface TSLocalWorkDetailCtrl : UIViewController

//本地作品model，localModel
@property (nonatomic, strong) TSWorkModel *model;

@end
