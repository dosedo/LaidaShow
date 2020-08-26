//
//  TSPathManager.m
//  ThreeShow
//
//  Created by cgw on 2019/1/30.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSPathManager.h"

//每个作品目录名字前缀
static NSString * const gWorkDirNamePrefix = @"workimgrpath";
static NSString * const gNotDeleteDirName = @"sanweishowWork";

@implementation TSPathManager

+ (TSPathManager *)sharePathManager{
    static TSPathManager *pm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pm = [TSPathManager new];
    });
    return pm;
}

#pragma mark - Public

/**
 得到Document的路径
 
 @return document的全路径
 */
- (NSString *)getDocPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    return docDir;
}

/**
 得到document和pathSuffix拼接后的路径,若路径不存在，则创建；存在，则直接放回
 
 @param pathSuffix 路径后缀
 @return document拼接pathSuffix后的全路径
 */
- (NSString*)getDocPathWithSuffix:(NSString*)pathSuffix{
    if( pathSuffix == nil )
        return pathSuffix;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    //拼接一层不清除缓存的文件目录
    NSString *notDeleteDir = gNotDeleteDirName;//@"sanweishowWork";
    docDir =
    [docDir stringByAppendingPathComponent:notDeleteDir];
    
    NSString *docPath = [NSString stringWithFormat:@"%@/%@",docDir,pathSuffix];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( ![fm fileExistsAtPath:docPath] ){
        NSError *err;
        [fm createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:&err];
        if( err) {
            return  nil;
        }
    }
    return docPath;
}

#pragma mark - 拍照和下载中间图的路径
- (NSString*)takePhotoWorkImgDirName{
    return @"takePhotoWork2";//[self getDocPathWithSuffix:@"takePhotoWork"];
}

#pragma mark - 本地作品路径

- (NSString *)getNewWorkDirName{
    NSDate *nowDate = [NSDate date];
    NSString *workDirName = [NSString stringWithFormat:@"%@%lld",gWorkDirNamePrefix,(long long)(nowDate.timeIntervalSince1970*1000)];
    
    return workDirName;
}

/**
 作品原图的路径
 
 @param workDirName 作品的目录名
 @param fileAllName 图片文件的全名，包含扩展名
 @return 原图文件所在的全路径
 */
- (NSString*)getWorkOriginImgPathWithWorkDirName:(NSString*)workDirName fileAllName:(NSString*)fileAllName{
//    return [self getWorkImgPathWithWorkDirName:workDirName suffixDoc:@"originImgs" fileAllName:fileAllName];
    return [[self getWorkOriginImgPathWithWorkDirName:workDirName] stringByAppendingString:fileAllName];
}

/**
 作品去底的遮罩图(也叫去底中间图)的路径
 
 @param workDirName 作品的目录名
 @param fileAllName 图片文件的全名，包含扩展名
 @return 这招图文件所在的全路径
 */
- (NSString*)getWorkMaskImgPathWithWorkDirName:(NSString *)workDirName fileAllName:(NSString *)fileAllName{
//    return [self getWorkImgPathWithWorkDirName:workDirName suffixDoc:@"maskImgs" fileAllName:fileAllName];
    return [[self getWorkMaskImgPathWithWorkDirName:workDirName] stringByAppendingString:fileAllName];
}

/**
 作品去底图的路径
 
 @param workDirName 作品的目录名
 @param fileAllName 图片文件的全名，包含扩展名
 @return 去底图文件所在的全路径
 */
- (NSString*)getWorkClearImgPathWithWorkDirName:(NSString *)workDirName fileAllName:(NSString *)fileAllName{
//    return [self getWorkImgPathWithWorkDirName:workDirName suffixDoc:@"clearImgs" fileAllName:fileAllName];
    
    return [[self getWorkClearImgPathWithWorkDirName:workDirName] stringByAppendingString:fileAllName];
}

/**
 作品原图的父路径，即图片所在的目录
 
 @param workDirName 作品的目录名
 @return 原图文件所在的全路径
 */
- (NSString*)getWorkOriginImgPathWithWorkDirName:(NSString*)workDirName{
    NSString *midDoc = [NSString stringWithFormat:@"%@/%@/",workDirName,@"originImgs"];
    NSString *path = [self getDocPathWithSuffix:midDoc];
   
    return path;
}

/**
 作品去底的遮罩图(也叫去底中间图)的父路径，即图片所在的目录
 
 @param workDirName 作品的目录名
 @return 这招图文件所在的全路径
 */
- (NSString*)getWorkMaskImgPathWithWorkDirName:(NSString *)workDirName{
    
    NSString *midDoc = [NSString stringWithFormat:@"%@/%@/",workDirName,@"maskImgs"];
    NSString *path = [self getDocPathWithSuffix:midDoc];
    
    return path;
}

/**
 作品去底图的父路径，即去底图所在的目录
 
 @param workDirName 作品的目录名
 @return 去底图文件所在的全路径
 */
- (NSString*)getWorkClearImgPathWithWorkDirName:(NSString *)workDirName{
    NSString *midDoc = [NSString stringWithFormat:@"%@/%@/",workDirName,@"clearImgs"];
    NSString *path = [self getDocPathWithSuffix:midDoc];
    
    return path;
}

- (NSString *)getNewPathByReplaceOldDocPathWithPath:(NSString *)path{

    if( path == nil ) return nil;
    
    //判断路径是否是作品的本地路径
    NSString *workDirPrefix = gNotDeleteDirName;//gWorkDirNamePrefix;
    if( [path containsString:workDirPrefix] ){
        NSArray *arr = [path componentsSeparatedByString:workDirPrefix];
        if( arr.count == 2 ){
            NSString *docPathOld = arr[0];
            
            //替换沙盒的document路径
            //1.获取当前沙河路径
            NSString *docPathNow = [self getDocPath];
            //2.获取沙盒doc后面的作品路径
            NSString *suffix = [path substringFromIndex:docPathOld.length];
            //3.用当前的沙盒doc目录和作品后面路径 合成新的路径
            NSString *newPath = [NSString stringWithFormat:@"%@/%@",docPathNow,suffix];
            return newPath;
        }
    }

    return path;
}

- (NSString *)getLocalWorkDocNameFromWorkPath:(NSString *)workPath{
    NSString *prefix = gWorkDirNamePrefix;
    NSArray *paths = [workPath pathComponents];
    for( NSString *com in paths ){
        if( [com containsString:prefix]){
            return com;
        }
    }
    return nil;
}

#pragma mark - Private

- (NSString*)getWorkImgPathWithWorkDirName:(NSString *)workDirName suffixDoc:(NSString*)suffixDoc fileAllName:(NSString *)fileAllName{
    
    NSString *midDoc = [NSString stringWithFormat:@"%@/%@",workDirName,suffixDoc];
    NSString *path = [self getDocPathWithSuffix:midDoc];
    path = [path stringByAppendingPathComponent:fileAllName];
    
    return path;
}


//-(NSString*)getFilePathWithFileName:(NSString*)fileName{
//
//    if( fileName == nil )
//        return nil;
//
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docDir = [paths objectAtIndex:0];
//
//    NSString *filePath = [docDir stringByAppendingPathComponent:fileName];
//    return filePath;
//
//}

-(NSString*)getFilePathWithFileName:(NSString*)fileName docDir:(NSString*)docDir{
    
    if( fileName == nil || docDir == nil )
        return nil;
    
    NSString *fp = [docDir stringByAppendingPathComponent:fileName];
    return fp;
}

@end
