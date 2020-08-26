//
//  PPAudioRecord.h
//  PaiPai
//
//  Created by wkun on 12/17/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPAudioRecord : NSObject


+(PPAudioRecord*)sharedAudioRecord;

@property (nonatomic, assign) NSTimeInterval recordTime; //录音时长 （单位秒）

-(void)startRecordWithFileName:(NSString*)fileName;
-(void)endRecord;

-(NSURL*)recordFileURL;
-(NSURL*)recordFileURLWithFileName:(NSString*)fileName;
-(NSString*)recordFilePathWithFileName:(NSString*)fileName;

@end
