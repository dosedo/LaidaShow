//
//  PPAudioRecord.m
//  PaiPai
//
//  Created by wkun on 12/17/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

//录音
#import "PPAudioRecord.h"
#import <AVFoundation/AVFoundation.h>
#import "KCommon.h"
#import "amrFileCodec.h"
#import "PPFileManager.h"

#define PAR_AUDIO_FILE_EXTISION_CAF   @"caf"  //默认保存的录音文件的扩展名
#define PAR_AUDIO_FILE_EXTISION_AMR  @"amr"  //服务器需要的文件的扩展名
#define PAR_AUDIO_CHANNELS 2

enum
{
    ENC_AAC = 1,
    ENC_ALAC = 2,
    ENC_IMA4 = 3,
    ENC_ILBC = 4,
    ENC_ULAW = 5,
    ENC_PCM = 6,
} encodingTypes;

@implementation PPAudioRecord{
    
    NSURL *_recordeFile;
    AVAudioRecorder *_recoder;
    int _recordEncoding;
    NSString *_fileName;                    //保存的录音文件的名字
}

#pragma mark - Public

+(PPAudioRecord*)sharedAudioRecord{
    static PPAudioRecord *ar = nil;
    if( ar == nil ){
        ar = [[PPAudioRecord alloc] init];
        [ar initData];
    }
    return ar;
}

-(id)init{
    self = [super init];
    if( self ){
        [self initData];
    }
    return self;
}


-(void)startRecordWithFileName:(NSString *)fileName{
    
    _recordTime = 0;
    if( fileName == nil ){
        _fileName = @"ppaudiotest";
    }
    else{
        _fileName = fileName;
    }
    NSLog(@"startRecording");
    
    [_recoder stop];
    _recoder = nil;
    
//    NSString *fan = 
    NSString *urlString = [[PPFileManager sharedFileManager] getAudioFileTmpPathWithFileAllName:fileName];//[self getRecordUrlWithName:fileName];
    if( urlString == nil ) {
        NSLog(@"Error: Url 路径出错");
        return;
    }
    
    NSString *fileAllUrl = [urlString stringByAppendingPathExtension:PAR_AUDIO_FILE_EXTISION_CAF];

    if( fileAllUrl == nil ) {
        NSLog(@"Error: fileAllUrl 路径出错");
        return;
    }
    NSURL *url = [NSURL URLWithString:fileAllUrl];
    _fileName = fileName;
    NSDictionary *recordSettings = [self getRecordSettings];
    
    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryRecord error:&err];
    _recoder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    
    if ([_recoder prepareToRecord] == YES){
        [_recoder record];
    }else {
        int errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
    }
}

-(void)endRecord{
    _recordTime =
    [_recoder currentTime];
    
    [_recoder stop];
    NSURL *url = _recoder.url;
    _recoder = nil;
    if( url == nil || url.absoluteString == nil) {
        NSLog(@"Error: 保存录音失败, fileAllUrl 路径出错");
        return;
    }
    
    NSURL *wavUrl = [NSURL fileURLWithPath:url.absoluteString];
    NSData *wavData = [NSData dataWithContentsOfURL:wavUrl];
    NSData *armData = EncodeWAVEToAMR(wavData, PAR_AUDIO_CHANNELS, 16);
    [self dataToFileWithUrl:url armData:armData];
}

-(NSURL*)recordFileURL{
    return [self getRecordUrlWithName:_fileName];
}

-(NSURL*)recordFileURLWithFileName:(NSString *)fileName{
//    return [self getRecordUrlWithName:fileName];
    NSString *path = [[PPFileManager sharedFileManager] getAudioFileTmpPathWithFileAllName:[fileName stringByAppendingPathExtension:PAR_AUDIO_FILE_EXTISION_AMR]];
    if( path == nil ) {
        NSLog(@"Error: 获取录音路径出错");
        return nil;
    }
    
    return [NSURL fileURLWithPath:path];
}

-(NSString*)recordFilePathWithFileName:(NSString *)fileName{
    if( fileName == nil){
        return nil;
    }
    
    NSString *fileAllName = [NSString stringWithFormat:@"%@.%@",fileName,PAR_AUDIO_FILE_EXTISION_CAF];
    
    NSString *fileDir = [NSString stringWithFormat:@"%@/recordFiles", /*[[NSBundle mainBundle] resourcePath]*/[KCommon getSandBoxDocPath]];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isExsit = [fm fileExistsAtPath:fileDir];
    if( !isExsit ){
        [fm createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/%@",fileDir,fileAllName];

}

#pragma mark - Private
-(void)initData{
    _recordEncoding = ENC_AAC;
}

-(NSDictionary*)getRecordSettings{
    
//    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
//                                   [NSNumber numberWithFloat:8000], AVSampleRateKey,
////                                   [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
//                                   [NSNumber numberWithInt:PAR_AUDIO_CHANNELS], AVNumberOfChannelsKey,
//                                   //  [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
//                                   [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
//                                   [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
//                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
//                                   [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
//                                   nil];
//    
//    return recordSetting;
    
    NSNumber *sampleRate, *formatId, *numberOfChannels, *audioQuality,  *linearPCMBitDepth;
    
//    // recording file path
//    filePath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents/recording.caf"];
    
    // set up record settings
    
    sampleRate = [NSNumber numberWithFloat: 8000];
    formatId = [NSNumber numberWithInt: kAudioFormatLinearPCM];
    numberOfChannels = [NSNumber numberWithInt: PAR_AUDIO_CHANNELS];
    audioQuality = [NSNumber numberWithInt: AVAudioQualityMax];
    linearPCMBitDepth = [NSNumber numberWithInt:16];
    // save settings in NSDictionary
    NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    sampleRate,         AVSampleRateKey,
                                    formatId,           AVFormatIDKey,
                                    numberOfChannels,   AVNumberOfChannelsKey,
                                    audioQuality,       AVEncoderAudioQualityKey,
                                    linearPCMBitDepth,  AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,

                                    nil];
    
    return recordSettings;
    
    
//    // Init audio with record capability
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
//    
//    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
//    if(_recordEncoding == ENC_PCM)
//    {
//        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
//        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
//        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
//        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
//        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
//    }
//    else
//    {
//        NSNumber *formatObject;
//        
//        switch (_recordEncoding) {
//            case (ENC_AAC):
//                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
//                break;
//            case (ENC_ALAC):
//                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
//                break;
//            case (ENC_IMA4):
//                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
//                break;
//            case (ENC_ILBC):
//                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
//                break;
//            case (ENC_ULAW):
//                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
//                break;
//            default:
//                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
//        }
//        
//        [recordSettings setObject:formatObject forKey: AVFormatIDKey];//ID
//        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];//采样率
//        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];//通道的数目,1单声道,2立体声
//        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];//解码率
//        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];//采样位
//        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
//    }
//    
//    return recordSettings;
}

-(void)dataToFileWithUrl:(NSURL*)url armData:(NSData*)armData{
//    NSData *armData = [NSData dataWithContentsOfURL:url];
//    NSArray *paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentPath       = [paths objectAtIndex:0];
//    NSString *wavFile        = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"test.amr"]];
    if( armData == nil || url == nil )
    {
        NSLog( @"armData为空或caf url为空");
        return;
    }
    NSString *urlPath = url.absoluteString;
    NSString *amrFile = [[urlPath stringByDeletingPathExtension] stringByAppendingPathExtension:PAR_AUDIO_FILE_EXTISION_AMR];  //[[PPFileManager sharedFileManager] get]
    [armData writeToFile:amrFile atomically:YES];
}

-(NSURL*)getRecordUrlWithName:(NSString*)fileName{

    if( fileName == nil){
        return nil;
    }
    
    NSString *fileAllName = [NSString stringWithFormat:@"%@.%@",fileName,PAR_AUDIO_FILE_EXTISION_CAF];
    
    NSString *fileDir = [NSString stringWithFormat:@"%@/recordFiles", /*[[NSBundle mainBundle] resourcePath]*/[KCommon getSandBoxDocPath]];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isExsit = [fm fileExistsAtPath:fileDir];
    if( !isExsit ){
        [fm createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",fileDir,fileAllName]];
    return url;
}

@end
