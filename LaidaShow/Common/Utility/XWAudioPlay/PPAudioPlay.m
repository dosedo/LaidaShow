//
//  PPAudioPlay.m
//  PaiPai
//
//  Created by 李新学 on 15/12/8.
//  Copyright © 2015年 SparkFour. All rights reserved.
//

#import "PPAudioPlay.h"
#import <AudioToolbox/AudioToolbox.h>
//#import <AVFoundation/AVAudioPlayer.h>
//#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVFoundation.h>
#import "PPFileManager.h"

//ogg播放解码
//#import "IDZAQAudioPlayer.h"
//#import "IDZTrace.h"
//#import "IDZOggVorbisFileDecoder.h"

//arm 转 wav
#import "amrFileCodec.h"

@interface PPAudioPlay()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *currentPlayer;
//@property (nonatomic, strong) id<IDZAudioPlayer> oggPlayer;
@property (nonatomic, assign) BOOL isOgg;    //是否为ogg
@property (nonatomic, strong) dispatch_queue_t playQuene;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@end

@interface PPAudioPlay(DownloadData)

/**
 同步下载url的数据

 @param url 数据的url
 @param dataTask 网络任务的实例，用来取消任务
 @return 下载的数据
 */
- (NSData*)downloadDataWithUrl:(NSURL*)url;
@end

@implementation PPAudioPlay{
//    AudioPlayFinishedBlock _finishBlock;
}

#pragma mark - Public

+(PPAudioPlay*)shareAudioPlay{
    static PPAudioPlay *play = nil;
    if( play == nil ){
        play = [[PPAudioPlay alloc] init];
        play.needEndWhenStartPlaying = NO;
        play.playQuene = dispatch_queue_create("PPPlayAudioQ", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    return play;
}

- (void)startPlayWithData:(NSData *)data{
    if( data == nil ){
        return;
    }
    
    NSError *err = nil;
    self.currentPlayer = [[AVAudioPlayer alloc] initWithData:data error:&err];
    if( err ){
        NSLog(@"播放失败%@",err.description);
        return;
    }
    self.currentPlayer.delegate = self;
    self.currentPlayer.volume = 1.0;
    
    if( [self.currentPlayer prepareToPlay]){
        [self.currentPlayer play];
        _playState = AudioPlayStatePlaying;
    }
}

- (void)startPlayAmrWithData:(NSData *)data{

    NSData *newData = DecodeAMRToWAVE(data);
    
    [self startPlayWithData:newData];
}

-(void)startPlayWithFileAllName:(NSString *)fileAllName{
    NSURL *url = [self getUrlWithFileAllName:fileAllName];
    [self startPlayWithUrl:url.absoluteString];
}


//-(void) startPlayWithFileAllName:(NSString *)fileAllName finishedBlock:(AudioPlayFinishedBlock)finishedBlock{
//    _finishBlock = finishedBlock;
//    [self startPlayWithFileAllName:fileAllName];
//}

-(void)startPlayWithUrl:(NSString *)fileUrl{
    self.needEndWhenStartPlaying = NO;
    if( [fileUrl isKindOfClass:[NSString class]] && [[fileUrl pathExtension] isEqualToString:@"amr"] ){
        NSFileManager *fm = [NSFileManager defaultManager];
        if( ![fm fileExistsAtPath:fileUrl ]){
            fileUrl = [[PPFileManager sharedFileManager ] getAudioFilePathWithFileAllName:fileUrl.lastPathComponent isCanClear:NO];
        }
    }
    if( !fileUrl ){
        NSLog(@"文件地址错误");
        return;
    }
    
    NSURL *url = nil;
    if( [fileUrl isKindOfClass:[NSURL class]] ){
        url = (NSURL*)fileUrl;
    }
    else{
    
//        fileUrl = [fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        fileUrl = [fileUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        url = [NSURL URLWithString:fileUrl];
    }
    
    BOOL isOgg = [[url.absoluteString pathExtension] isEqualToString:@"ogg"];
    self.isOgg = isOgg;
    
    dispatch_async(self.playQuene, ^{

        if( isOgg ){
            [self startPlayOggUrl:url];
        }
        else{
            [self startPlayOtherUrl:url];
        }
    });
}

-(void)endPlay{
    
    [self.dataTask cancel];
    
    if( _playState == AudioPlayStatePlaying ){
        if( self.isOgg ){
//            [self.oggPlayer stop];
        }
        else
            [self.currentPlayer stop];
        _playState = AudioPlayStateEnd;
    }
    self.currentPlayer = nil;
}
 
-(void)pausePlay{
    if( _playState == AudioPlayStatePlaying ){
        if(self.isOgg ){
//            [self.oggPlayer pause];
        }
        else
            [self.currentPlayer pause];
        _playState = AudioPlayStatePause;
    }
}

-(void)restartPlay{
    
    if( _playState == AudioPlayStatePause ){
        if( self.isOgg ){
//            [self.oggPlayer play];
        }
        else{
            if( self.currentPlayer.url && self.currentPlayer.isPlaying == NO ){
                [self.currentPlayer play];
            }
        }
        
        _playState = AudioPlayStatePlaying;
    }
}

- (void)setPlayState:(AudioPlayState)playState{
    _playState = playState;
    
}

#pragma mark - Private

-(id)init{
    self = [super init];
    if( self ){
        _isOgg = NO;
    }
    return self;
}

-(NSURL*)getUrlWithFileAllName:(NSString*)fileAllName{
    
    if( fileAllName == nil || fileAllName.length == 0 ){
        return nil;
    }
    
    NSString *extions = [fileAllName pathExtension];
    NSString *fileName = [fileAllName substringToIndex:(fileAllName.length - extions.length - 1 )];
    if( extions == nil || fileName == nil )
        return nil;
    
    NSURL *smallAppleURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:extions];
    return smallAppleURL;
}

/**
 *  播放ogg
 *
 *  @param url ogg-fileurl
 */
-(void)startPlayOggUrl:(NSURL*)url{
    
//    self.currentPlayer = nil;
//    NSURL* oggUrl = [[NSBundle mainBundle] URLForResource:@"music1" withExtension:@".ogg"];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
     
//    [self.oggPlayer stop];
//    self.oggPlayer = nil;
//
//    NSError *error;
//    IDZOggVorbisFileDecoder* decoder = [[IDZOggVorbisFileDecoder alloc] initWithContentsOfURL:url error:&error];
//    NSLog(@"Ogg Vorbis file duration is %g", decoder.duration);
//    self.oggPlayer = [[IDZAQAudioPlayer alloc] initWithDecoder:decoder error:nil];
//    self.oggPlayer.delegate = self;

//    if( [self.oggPlayer prepareToPlay] ){
//        [self.oggPlayer play];
//        _playState = AudioPlayStatePlaying;
//    }
}

/**
 *  播放除Ogg外的其他文件
 *
 *  @param url 音频文件url
 */
-(void)startPlayOtherUrl:(NSURL*)url{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    
    
    NSString *path = [url path];
    
    NSData *data = nil;
    if( url.absoluteString && [url.absoluteString containsString:@"http"]){
        
        //在线播放音频，应换做AVPlayer进行播放。待优化
        //从网络加载音频数据，这里需要优化，虽然现在将播放音乐放在子线程中，但依旧存在其他问题。
//        data = [NSData dataWithContentsOfURL:url];
        data = [self downloadDataWithUrl:url];
    }else{
        data = [NSData dataWithContentsOfFile:path];
    }
    if( [[url pathExtension] isEqualToString:@"amr"] ){
        
        data = DecodeAMRToWAVE(data);
    }
    
    if( _needEndWhenStartPlaying ){
        _needEndWhenStartPlaying = NO;
        return;
    }
    
    self.currentPlayer = [[AVAudioPlayer alloc] initWithData:data error:&err];
    if( err ){
        NSLog(@"播放失败%@",err.description);
        return;
    }
    self.currentPlayer.delegate = self;
    self.currentPlayer.volume = 1.0;
    
    if( [self.currentPlayer prepareToPlay]){
        [self.currentPlayer play];
        _playState = AudioPlayStatePlaying;
    }
}

-(NSData*)dataToUTF8DataWithFilePath:(NSString*)path{
    if( path==nil || path.length == 0)
        return nil;
    
    NSData *srcData = [NSData dataWithContentsOfFile:path];
    if( srcData && strlen([srcData bytes]) == 0){
        NSData *desData = nil;
        FILE *pFile = fopen(path.UTF8String, "r");
        char *pBuf;//文件指针÷÷
        fseek(pFile,0,SEEK_END); //把指针移动到文件的结尾 ，获取文件长度
        int len=ftell(pFile); //获取文件长度
//        char pBuf[len+1];//定义数组长度
        pBuf = malloc(len+1);
        rewind(pFile); //把指针移动到文件开头 因为我们一开始把指针移动到结尾，如果不移动回来 会出错
        fread(pBuf,1,len,pFile); //读文件
        pBuf[len]=0; //把读到的文件最后一位 写为0 要不然系统会一直寻找到0后才结束
//        MessageBox(pBuf);  //显示读到的数据
        fclose(pFile); // 关闭文件
        
        desData = [NSData dataWithBytes:pBuf length:len];
        free(pBuf);
        
        return desData;
        
    }
    return srcData;
}

#pragma mark - avauidoplayer Delegate And oggAudioPlayerDelegate

/**
 *  播放结束调用此代理
 *
 *  @param player 播放器
 *  @param flag   播放标识
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{

    if( self.delegate && [self.delegate respondsToSelector:@selector(audioPlayEndPlay:)]){
        [self.delegate audioPlayEndPlay:self];
        player = nil;
        _playState = AudioPlayStateEnd;
    }
}

//#pragma mark oggAudioPlayerDelegate
/**
 * @brief Called when playback ends.
 */
//- (void)audioPlayerDidFinishPlaying:(id<IDZAudioPlayer>)player
//                       successfully:(BOOL)flag{
//    
//}
/**
 * @brief Called when a decode error occurs.
 */
//- (void)audioPlayerDecodeErrorDidOccur:(id<IDZAudioPlayer>)player
//                                 error:(NSError *)error{
//    
//}

@end

@implementation PPAudioPlay(DownloadData)

- (NSData *)downloadDataWithUrl:(NSURL *)url{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    __block NSData *retData = nil;
    
    dispatch_semaphore_t disp = dispatch_semaphore_create(0);
    NSURLSessionDataTask *task =
    [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        retData = data;
        NSLog(@"data=%@",response);
        
        dispatch_semaphore_signal(disp);
    }];
    self.dataTask = task;
    [task resume];
    
    dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
    
    return retData;;
}

@end
