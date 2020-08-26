//
//  PPLocalFileManager.m
//  PaiPai
//
//  Created by wkun on 12/22/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import "PPLocalFileManager.h"
#import "KCommon.h"
//#import "ImgInfoModel.h"
#import "TSWorkModel.h"

#define LFM_FILE_COUNT_KEY @"LocalFileCountKey"

@implementation PPLocalFileManager


#pragma mark - public
+(PPLocalFileManager*)shareLocalFileManager{
    static PPLocalFileManager *shareLFM = nil;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        shareLFM = [[PPLocalFileManager alloc] init];
    });
    return shareLFM;
}

-(NSArray*)getLocalFilesInfo{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    NSString *filePath = [self getPlistPath];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    if( data )
    {
        for( NSUInteger i=0; i<= [self getFileCount]; i++ ){
            NSString *key = [self getFileInfoKeyWithIndex:i];
            if( key && data[key] ){
                
                TSWorkModel *wm = [NSKeyedUnarchiver unarchiveObjectWithData:data[key]];
                
                wm.imgDataIndex = i;
                if( [wm isKindOfClass:[TSWorkModel class]] ){
                    [dataArr addObject:wm];
                }
            }
        }
    }
    return dataArr;
}

-(void)saveFileToLocal:(id)fileInfoModel{
    
//    if( ![fileInfoModel isKindOfClass:[ImgInfoModel class]]  || fileInfoModel == nil )
    if( ![fileInfoModel isKindOfClass:[TSWorkModel class]]  || fileInfoModel == nil )
        return;
    
    TSWorkModel *wm = (TSWorkModel*)fileInfoModel;
    wm.imgArr = nil;
    wm.clearBgImgArr = nil;
    wm.editingImgs = nil;
    wm.imgMaskArr = nil;
    
    fileInfoModel = [NSKeyedArchiver archivedDataWithRootObject:fileInfoModel];

    NSString *filePath = [self getPlistPath];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    //若data为nil，说明不存在本地作品
    if( !data ){
        data = [NSMutableDictionary dictionary];
        [self updateFileCount:0];
    }

    NSString *key = [self getFileInfoKey];
    if( fileInfoModel && key ){
        [data setObject:fileInfoModel forKey:key];
        //写入plist文件
        if ([data writeToFile:filePath atomically:YES]) {
            NSLog(@"写入成功");
            
            //数量+1
            NSUInteger cnt = [self getFileCount];
            [self updateFileCount:cnt+1];
        };
    }
}

-(BOOL)removeFileWithIndex:(NSUInteger)index{

    NSString *filePath = [self getPlistPath];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    if( !data ){
        data = [NSMutableDictionary dictionary];
        [self updateFileCount:0];
    }
    
    NSString *key = [self getFileInfoKeyWithIndex:index];
    if( [data isKindOfClass:[NSDictionary class]]  && key && data[key] ){
        
        [data removeObjectForKey:key];

        //写入plist文件
        if ([data writeToFile:filePath atomically:YES]) {
            return YES;
        };
    }
    
    return NO;
}

- (BOOL)updateModel:(id)model atIndex:(NSUInteger)index{
    
    NSString *filePath = [self getPlistPath];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    if( data )
    {
        NSString *key = [self getFileInfoKeyWithIndex:index];
        if( key && data[key] && model){
            id arciveObj = [NSKeyedArchiver archivedDataWithRootObject:model];
            if( arciveObj ){
            
                [data setObject:arciveObj forKey:key];
            
                //写入plist文件
                if ([data writeToFile:filePath atomically:YES]) {
                    return YES;
                };
            }
        }
    }
    
    return NO;
}

#pragma mark - private

-(NSString*)getPlistPath{

    NSString *fileDir = [NSString stringWithFormat:@"%@/picList", /*[[NSBundle mainBundle] resourcePath]*/[KCommon getSandBoxDocPath]];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isExsit = [fm fileExistsAtPath:fileDir];
    if( !isExsit ){
        [fm createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *path_sandox = fileDir;
    //创建一个存储plist文件的路径
    NSString *newPath = [path_sandox stringByAppendingPathComponent:@"/pic.plist"];
    return newPath;
}

-(void)updateFileCount:(NSUInteger)count{
    //    NSString *fileNameKeyPrefix = @"ImgNameKey";
    //    NSString *localFileCountKey = @"LocalFileCountKey";
    //    NSString *localFileCount = [[NSUserDefaults standardUserDefaults] objectForKey:localFileCountKey];
    
    //    NSUInteger fileCount = 0;
    //    if( localFileCount ){
    //        fileCount = localFileCount.integerValue;
    //    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",count] forKey:LFM_FILE_COUNT_KEY];
}

-(NSUInteger)getFileCount{
    NSUInteger count = 0;
    NSString *lfCount = [[NSUserDefaults standardUserDefaults] objectForKey:LFM_FILE_COUNT_KEY];
    if( lfCount ){
        count = lfCount.integerValue;
    }
    return count;
}

-(NSString*)getFileInfoKey{
    NSString *keyPrefix = @"FileInfoKey";
    NSString *key = [NSString stringWithFormat:@"%@%lu",keyPrefix,(unsigned long)[self getFileCount]];
    return key;
}

-(NSString*)getFileInfoKeyWithIndex:(NSUInteger)index{
    NSString *keyPrefix = @"FileInfoKey";
    NSString *key = [NSString stringWithFormat:@"%@%lu",keyPrefix,index];
    return key;
}

@end
