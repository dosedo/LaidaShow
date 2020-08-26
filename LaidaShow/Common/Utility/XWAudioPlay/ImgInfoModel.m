//
//  ImgInfoModel.m
//  PaiPai
//
//  Created by wkun on 12/21/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import "ImgInfoModel.h"

@implementation ImgInfoModel

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if( self ){
        self.imgBgAudio = [aDecoder decodeObjectForKey:@"imgBgAudioKey"];
        self.imgDataStr = [aDecoder decodeObjectForKey:@"imgDataStrKey"];
        self.imgHidInfoArr =[aDecoder decodeObjectForKey:@"imgHidInfoArrKey"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.imgBgAudio forKey:@"imgBgAudioKey"];
    [aCoder encodeObject:self.imgDataStr forKey:@"imgDataStrKey"];
    [aCoder encodeObject:self.imgHidInfoArr forKey:@"imgHidInfoArrKey"];
}

@end

@implementation HideInfoModel

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if( self ){
        self.hideAudioOrigin = [aDecoder decodeObjectForKey:@"hideAudioOriginKey"];
        self.hideAudioPath = [aDecoder decodeObjectForKey:@"hideAudioPathKey"];
        self.hideText = [aDecoder decodeObjectForKey:@"hideTextKey"];
        self.hideTextOrigin = [aDecoder decodeObjectForKey:@"hideTextOriginKey"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.hideAudioOrigin forKey:@"hideAudioOriginKey"];
    [aCoder encodeObject:self.hideAudioPath forKey:@"hideAudioPathKey"];
    [aCoder encodeObject:self.hideText forKey:@"hideTextKey"];
    [aCoder encodeObject:self.hideTextOrigin forKey:@"hideTextOriginKey"];
}

-(void)setHideAudioHttpUrl:(NSString *)hideAudioHttpUrl{
    _hideAudioHttpUrl = hideAudioHttpUrl;
    if( ![[hideAudioHttpUrl pathExtension] isEqualToString:@"amr"] ){
    }
}

-(void)setHideAudioPath:(NSString *)hideAudioPath{
    _hideAudioPath = hideAudioPath;
    if( ![[hideAudioPath pathExtension] isEqualToString:@"amr"] ){
        NSLog(@"ac");
    }
}

@end


