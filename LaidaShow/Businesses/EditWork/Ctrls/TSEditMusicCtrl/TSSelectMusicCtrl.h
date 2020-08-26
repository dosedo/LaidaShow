//
//  TSSelectMusicCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSSelectMusicModel;
@interface TSSelectMusicCtrl : UIViewController

@property (nonatomic, strong) void((^selectCompleteBlock)(TSSelectMusicModel* model));

@end
