//
//  TSAddRecordCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSSelectMusicModel;
@interface TSAddRecordCtrl : UIViewController

@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) void((^selectCompleteBlock)(TSSelectMusicModel* model));

@property (nonatomic, strong) NSURL *videoUrl;

@end
