//
//  PPFileManager.m
//  PaiPai
//
//  Created by wkun on 12/27/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import "PPFileManager.h"
#import "TSPathManager.h"

#define FM_RESULT_IMG_PATH_SUFFIX @"finalResult"
#define FM_RESULT_IMG_NAME @"result.jpg"

#define FM_MAKE_RESULT_IMG_PATH_SUFFIX @"makeResult/result"
#define FM_MAKE_RESULT_IMG_NAME_PREFIX @"makeResultImg"

#define FM_KOUTU_TEMPLETE_IMG_PATH_SUFFIX @"kouTuTemplete"

#define FM_KOUTU_RESULT_PATH_SUFFIX @"kouTu/kouTuResult"
#define FM_KOUTU_RESULT_IMG_NAME @"kouTuResult.png"

#define FM_KOUTU_BG_PATH_SUFFIX @"kouTu/kouTuBg"

#define FM_AUDIO_FILE_PATH_SUFFIX_CAN_CLEAR @"canClear/audio"           //可以被清空的音频路径
#define FM_AUDIO_FILE_PATH_SUFFIX_NOT_CLEAR @"notClear/audio"           //不可以清空的音频路径

#define FM_SANWEISHOW_WORK_LOCAL_IMG_PATH_SUFFIX @"sanweishowWork"      //不可清空

@implementation PPFileManager

#pragma mark - public
+(PPFileManager*)sharedFileManager{
    static PPFileManager *fm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fm = [[PPFileManager alloc] init];
    });

    return fm;
}

//得到图片路径 根据名字
- (NSString *)getSanWorkImgPathWithImgAllName:(NSString *)imgAllName {
    if( imgAllName == nil )
        return nil;
    NSString *rD = [self getDocDirWithSuffix:FM_SANWEISHOW_WORK_LOCAL_IMG_PATH_SUFFIX];
    ///NSString *mD = [self getDocDirWithSuffix:@"LocalWork"];
    return [self getFilePathWithFileName:imgAllName docDir:rD];
}

- (NSString *)getSanWorkLocalImgPathWithImgAllName:(NSString *)imgAllName localPath:(NSString*)localPath {
    if( imgAllName == nil )
        return nil;
    NSString *mD = [self getDocDirWithSuffix:@"LocalWork"];
    mD = [self getDocDirWithSuffix:localPath];
    return [self getFilePathWithFileName:imgAllName docDir:mD];
}

- (NSString *)getDocumentsDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];

    return docDir;
//    NSString *docPath = [docDir stringByAppendingPathComponent:pathSuffix];
//    if( ![[NSFileManager defaultManager] fileExistsAtPath:docPath] ){
//        NSError *err;
//        [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:&err];
//        if( err) {
//            return  nil;
//        }
//    }
//    return docPath;
}

- (NSString*)getSanweishowWorkImgWithImgAllName:(NSString *)imgAllName{
    
    NSString *path =
    [self getDocDirWithSuffix:@"workimg1548817291041/originImgs"];
    path = [path stringByAppendingPathComponent:imgAllName];
    return path;
    return nil;
    
    NSString  *path1 = [self getSanWorkImgPathWithImgAllName:imgAllName];
    if( path ){
        NSFileManager *fm = [NSFileManager defaultManager];
        if( [fm fileExistsAtPath:path isDirectory:nil] ){
            //文件存在则返回
            return path;
        }else{
            return nil;
        }
    }
    
    return nil;
}

-(NSString*)getMakeResultImgPathWithIndex:(NSUInteger)index{
    NSString *docDir = [self getDocDirWithSuffix:[NSString stringWithFormat:@"%@",FM_MAKE_RESULT_IMG_PATH_SUFFIX]];
    return [self getFilePathWithFileName:[NSString stringWithFormat:@"%@%ld",FM_MAKE_RESULT_IMG_NAME_PREFIX,index] docDir:docDir];
}

-(NSString*)getResultImgPath{
    NSString *rD = [self getDocDirWithSuffix:FM_RESULT_IMG_PATH_SUFFIX];
    return [self getFilePathWithFileName:FM_RESULT_IMG_NAME docDir:rD];
}

-(NSString*)getTemplateImgPathWithImgName:(NSString *)templateName{
    NSString *rD = [self getDocDirWithSuffix:FM_KOUTU_TEMPLETE_IMG_PATH_SUFFIX];
    return [self getFilePathWithFileName:templateName docDir:rD];
}

-(NSString*)getKouTuResultImgPath{
    NSString *rD = [self getDocDirWithSuffix:FM_KOUTU_RESULT_PATH_SUFFIX];
    return [self getFilePathWithFileName:FM_KOUTU_RESULT_IMG_NAME docDir:rD];
}

-(NSString*)getKouTuBgImgPathWithName:(NSString *)imgName{
    if( imgName == nil )
        return nil;
    NSString *rD = [self getDocDirWithSuffix:FM_KOUTU_BG_PATH_SUFFIX];
    return [self getFilePathWithFileName:imgName docDir:rD];
}

#pragma mark 音频
-(NSString*)getAudioFilePathWithFileAllName:(NSString *)fileName isCanClear:(BOOL)isCanClear{
    NSString *suffix = FM_AUDIO_FILE_PATH_SUFFIX_CAN_CLEAR;
    if( isCanClear == NO )
        suffix = FM_AUDIO_FILE_PATH_SUFFIX_NOT_CLEAR;
    
    NSString *dir = [self getDocDirWithSuffix:suffix];
    if( fileName == nil ){
        return dir;
    }
    NSString *fp = [self getFilePathWithFileName:fileName docDir:dir];
    return fp;
}

-(BOOL)moveAuidoFileToNotClearPathWithFileName:(NSString *)fileAllName{

    NSString *filePath = [self getAudioFileTmpPathWithFileAllName:fileAllName];
    NSString *toPath = [self getAudioFilePathWithFileAllName:fileAllName isCanClear:NO];
    
    if( fileAllName == nil || filePath == nil || toPath == nil)
        return NO;
    
    NSError *err;
  
    BOOL ret = [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:toPath error:&err];
    if( err ){
        NSLog(@"移动文件失败------/nfromPath:%@/ntoPath:%@/nerr=%@/n",filePath,toPath,err);
    }
    return ret;
}

-(NSString*)getAudioFileTmpPathWithFileAllName:(NSString *)fileName{
    NSString *filePath = [self getTmpDocWithSuffix:@"audios"];
    NSString *fp = [self getFilePathWithFileName:fileName docDir:filePath];
    return fp;
}

#pragma mark - 保存和清除

/**
 保存三维秀 的一个产品的所有图片到不可删除的图片缓存路径
 
 @param img 图片
 @param imgAllName 图片名字 带有扩展名
 @return 成功yes 否则NO
 */
- (BOOL)saveSanweishowImgToNotClearPath:(UIImage*)img imgAllName:(NSString*)imgAllName{
    
    
    NSString *imgPath = [self getSanWorkImgPathWithImgAllName:imgAllName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:imgPath isDirectory:nil] ){
        //文件存在则不保存
        return YES;
    }
    //文件不存在，则创建
    return [UIImageJPEGRepresentation(img, 1) writeToFile:imgPath atomically:YES];
}

- (BOOL)saveSanweishowLocalImgToNotClearPath:(UIImage*)img type:(NSInteger)type paths:(NSString *)paths imgAllName:(NSString*)imgAllName{
    
    TSPathManager *pm = [TSPathManager sharePathManager];
    NSString *imgPath = nil;//[self getSanWorkLocalImgPathWithImgAllName:imgAllName localPath:paths];
    
    if( type == 0 ){
        imgPath = [pm getWorkOriginImgPathWithWorkDirName:paths fileAllName:imgAllName];
    }else if( type == 1 ){
        imgPath = [pm getWorkMaskImgPathWithWorkDirName:paths fileAllName:imgAllName];
    }else if( type == 2 ){
        imgPath = [pm getWorkClearImgPathWithWorkDirName:paths fileAllName:imgAllName];
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:imgPath isDirectory:nil] ){
        //文件存在则不保存
        return YES;
    }
    //文件不存在，则创建
    return [UIImageJPEGRepresentation(img, 1) writeToFile:imgPath atomically:YES];
}

/**
 根据图片全路径删除图片
 
 @param imgAllPath 图片的全路径，包括拓展名
 @return 成功YES 否则NO
 */
- (BOOL)removeSanwieshowImgWithImgAllPath:(NSString*)imgAllPath{

    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:imgAllPath isDirectory:nil] ){
        //文件存在则不移除
        NSError *err = nil;
        [fm removeItemAtPath:imgAllPath error:&err];
        if( err ){
            return NO;
        }
        return YES;
    }
    return NO;
}

-(BOOL)saveTemplateImgWithImgName:(NSString *)templateName image:(UIImage *)tmpImg {
    NSString *imgPath = [self getTemplateImgPathWithImgName:templateName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:imgPath isDirectory:nil] ){
        //文件存在则不保存
        return YES;
    }
    
    //文件不存在，则创建
    return [UIImagePNGRepresentation(tmpImg) writeToFile:imgPath atomically:YES];
}

-(BOOL)saveResultImg:(UIImage *)img{
    NSString *imgPath = [self getResultImgPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:imgPath isDirectory:nil] ){
        NSError *err;
        [fm removeItemAtPath:imgPath error:&err];
        if( err ){
            return NO;
        }
    }
    
    return [UIImageJPEGRepresentation(img, 1.0) writeToFile:imgPath atomically:YES];
}

-(BOOL)saveKouTuBgImg:(UIImage *)bgImg imgName:(NSString *)imgName{
    NSString *imgPath = [self getKouTuBgImgPathWithName:imgName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:imgPath isDirectory:nil] ){
        NSError *err;
        [fm removeItemAtPath:imgPath error:&err];
        if( err ){
            return NO;
        }
    }
    
    return [UIImagePNGRepresentation(bgImg) writeToFile:imgPath atomically:YES];
}

-(BOOL)removeKouTuImg{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self getDocDirWithSuffix:@"kouTu"];
    NSError *err;
    [fm removeItemAtPath:filePath error:&err];
    if( err )
        return NO;
    return YES;
}

-(BOOL)removeMakeResultImg{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self getDocDirWithSuffix:FM_MAKE_RESULT_IMG_PATH_SUFFIX];
    NSError *err;
    [fm removeItemAtPath:filePath error:&err];
    if( err )
        return NO;
    return YES;
}

-(BOOL)removeTemplateImg{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self getDocDirWithSuffix:FM_KOUTU_TEMPLETE_IMG_PATH_SUFFIX];
    NSError *err;
    [fm removeItemAtPath:filePath error:&err];
    if( err )
        return NO;
    return YES;
}

- (BOOL)removeFileAtAllPath:(NSString *)fileAllPath{
    return 
    [self removeSanwieshowImgWithImgAllPath:fileAllPath];
}

//清除从服务器下载的音频文件
-(void)clearCache{
    NSString *doc = [self getDocDirWithSuffix:FM_AUDIO_FILE_PATH_SUFFIX_CAN_CLEAR];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:doc error:nil];
}

#pragma mark - private

-(NSString*)getTmpDocWithSuffix:(NSString*)pathSuffix{
    if( pathSuffix == nil )
        return pathSuffix;

    NSString *docDir = NSTemporaryDirectory();
    NSString *tmpDocDir = [docDir stringByAppendingPathComponent:pathSuffix];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:tmpDocDir] ){
        NSError *err;
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpDocDir withIntermediateDirectories:YES attributes:nil error:&err];
        if( err) {
            return  nil;
        }
    }
    return tmpDocDir;
}

-(NSString*)getDocDirWithSuffix:(NSString*)pathSuffix{
    if( pathSuffix == nil )
        return pathSuffix;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSString *docPath = [docDir stringByAppendingPathComponent:pathSuffix];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:docPath] ){
        NSError *err;
        [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:&err];
        if( err) {
            return  nil;
        }
    }
    return docPath;
}

-(NSString*)getFilePathWithFileName:(NSString*)fileName{
    
    if( fileName == nil )
        return nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSString *filePath = [docDir stringByAppendingPathComponent:fileName];
    return filePath;

}

-(NSString*)getFilePathWithFileName:(NSString*)fileName docDir:(NSString*)docDir{
    
    if( fileName == nil || docDir == nil )
        return nil;
    
    NSString *fp = [docDir stringByAppendingPathComponent:fileName];
    return fp;
}

@end
