//
//  TSSelectMusicModel.h
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSSelectMusicModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) BOOL isRecord; //默认为NO

@end
