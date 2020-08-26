//
//  ImgInfoModel.h
//  PaiPai
//
//  Created by wkun on 12/21/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface ImgInfoModel : NSObject<NSCoding>

#pragma mark - Old Data
@property (nonatomic, assign) NSInteger imgDataIndex;               //图片数据的索引
@property (nonatomic, strong) NSString *imgDataStr;
@property (nonatomic, strong) NSString *imgBgAudio;                 //背景音乐的名字
@property (nonatomic, strong) NSMutableArray  *imgHidInfoArr;
@property (nonatomic, strong) NSString *imgShareUrl;
@property (nonatomic, strong) NSString *imgId;

@property (nonatomic,copy) NSString *imgPath;
@end

@interface HideInfoModel : NSObject<NSCoding>

@property (nonatomic, strong) NSString *hideAudioPath;              //音频文件的本地路径
@property (nonatomic, strong) NSString *hideAudioHttpUrl;           //音频文件的网络url
@property (nonatomic, strong) NSString *hideText;
@property (nonatomic, strong) NSValue  *hideTextOrigin;
@property (nonatomic, strong) NSValue  *hideAudioOrigin;

@end
