//
//  PPAudioPlay.h
//  PaiPai
//
//  Created by 李新学 on 15/12/8.
//  Copyright © 2015年 SparkFour. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    
    AudioPlayStateEnd = 0,
    AudioPlayStatePause,
    AudioPlayStatePlaying,
    
}AudioPlayState;

@class PPAudioPlay;
@protocol PPAudioPlayDelegate <NSObject>

@optional
/**
 *  音频播放结束
 *
 *  @param auidoPlay PPAudioPlay对象实例
 */
-(void)audioPlayEndPlay:(PPAudioPlay*)auidoPlay;

-(void)audioPlayStartPlay:(PPAudioPlay*)audioPlay;

@end

@interface PPAudioPlay : NSObject


//以下两个属性是为了 解决当点击播放后，还未真正开始播放时，此时想结束播放的话。将该属性设为YES
@property (nonatomic, assign) BOOL needEndWhenStartPlaying;
//@property (nonatomic, copy) void(^startPlayBlock)(void);

@property (nonatomic, weak) id<PPAudioPlayDelegate> delegate;
@property (nonatomic, assign) AudioPlayState playState;

+(PPAudioPlay*)shareAudioPlay;

/**
 开始播放音频

 @param data 音频数据
 */
- (void)startPlayWithData:(NSData*)data;

/**
 开始播放Amr音频，需要转码数据
 
 @param data 音频数据 
 */
- (void)startPlayAmrWithData:(NSData*)data;

/**
 *  开始播放音频
 *
 *  @param fileUrl 音频文件的url. (NSString 或 NSURL)
 */
-(void)startPlayWithUrl:(id)fileUrl;

/**
 *  开始播放音频
 *
 *  @param fileAllName 音频文件的全名,包含扩展名
 */
-(void)startPlayWithFileAllName:(NSString*)fileAllName;


//-(void)startPlayWithFileAllName:(NSString *)fileAllName finishedBlock:(AudioPlayFinishedBlock)finishedBlock;

-(void)endPlay;

-(void)pausePlay;

/**
 *  暂停后,重新播放
 */
-(void)restartPlay;

@end
