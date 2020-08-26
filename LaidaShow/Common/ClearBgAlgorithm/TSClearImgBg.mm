//
//  NSObject.m
//  ThreeShow
//
//  Created by wkun on 2018/8/16.
//  Copyright © 2018年 deepai. All rights reserved.
//

#import "TSClearImgBg.h"
//#import "ClearImgBgAlgorithm.hpp"
#import "TSHelper.h"
#import "UIViewController+Ext.h"
#import "post_process.h"

@implementation TSClearImgBg

+ (TSClearImgBg*)shareClearImgBg{
    static dispatch_once_t onceToken;
    static TSClearImgBg *clearImg = nil;
    dispatch_once(&onceToken, ^{
        clearImg = [TSClearImgBg new];
    });
    
    return clearImg;
}

+ (void)startClearImgWithOriginImgPaths:(NSArray<NSString *> *)originImgPaths midImgPaths:(NSArray<NSString *> *)midImgPaths resultImgPaths:(NSArray<NSString *> *)resultImgPaths  completBlock:(void (^)(NSError *))completeBlock{
    [[TSClearImgBg shareClearImgBg] startClearImgWithOriginImgPaths:originImgPaths midImgPaths:midImgPaths resultImgPaths:resultImgPaths completBlock:completeBlock];
}

+ (void)startClearImgWithOriginImgPath:(NSString *)originImgPath maskImgPath:(NSString *)maskImgPath resultImgPath:(NSString *)resultImgPath changeBgImg:(NSString *)changeImgAllPath count:(NSUInteger)count completBlock:(void (^)(NSError *))completeBlock{
    [[TSClearImgBg shareClearImgBg] startClearImgWithOriginImgPath:originImgPath maskImgPath:maskImgPath resultImgPath:resultImgPath changeBgImg:changeImgAllPath count:count completBlock:completeBlock];
}

+ (void)cancleClearImg{
    [[TSClearImgBg shareClearImgBg] cancleClearImg];
}

#pragma mark - Private

- (void)startClearImgWithOriginImgPath:(NSString *)originImgPath maskImgPath:(NSString *)maskImgPath resultImgPath:(NSString *)resultImgPath changeBgImg:(NSString *)changeImgAllPath count:(NSUInteger)count completBlock:(void (^)(NSError *))completeBlock{
    if(originImgPath==nil || maskImgPath==nil || resultImgPath == nil  || count==0 ){
        if( completeBlock ){
            NSError *err = [[NSError alloc] initWithDomain:@"" code:-1 userInfo:@{@"KErrorDesKey":@"去底作品路径不正确"}];
            completeBlock(err);
        }
        return;
    }
    
    dispatch_queue_t globalQ = dispatch_queue_create("clearSuanFaQ", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(globalQ, ^{
        
        if( [TSHelper sharedHelper].isCancleClearBg ) return ;
        NSLog(@"getmaxCC");
        getMaxCC((char*)[originImgPath UTF8String], (char*)[maskImgPath UTF8String], (char*)[resultImgPath UTF8String], (char*)[changeImgAllPath UTF8String],(int)count);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if( completeBlock ){
                completeBlock(nil);
            }
        });
    });
}

- (void)startClearImgWithOriginImgPaths:(NSArray<NSString *> *)originImgPaths midImgPaths:(NSArray<NSString *> *)midImgPaths resultImgPaths:(NSArray<NSString *> *)resultImgPaths completBlock:(void (^)(NSError *))completeBlock{
    if(originImgPaths==nil || midImgPaths==nil || resultImgPaths == nil  || originImgPaths.count != midImgPaths.count || midImgPaths.count != resultImgPaths.count ){
        if( completeBlock ){
            NSError *err = [[NSError alloc] initWithDomain:@"" code:-1 userInfo:@{@"KErrorDesKey":@"去底作品路径不正确"}];
            completeBlock(err);
        }
        return;
    }
    dispatch_group_t group = dispatch_group_create();
    NSInteger count = originImgPaths.count;
    NSLog(@"originImgPaths -- %@",originImgPaths[0]);

    NSLog(@"count - %ld",(long)count);
    NSLog(@"originImgPaths[0].length -- %ld",originImgPaths[0].length);
    
    NSString *oPathStr = [originImgPaths[0] substringToIndex:originImgPaths[0].length-6];
    NSLog(@"newstr -- %@",resultImgPaths[0]);
    NSString *mPathStr = [midImgPaths[0] substringToIndex:midImgPaths[0].length-6];
    NSString *rPathStr = [resultImgPaths[0] substringToIndex:resultImgPaths[0].length-6];
    //[rPathStr stringByAppendingString:@"//"];
    NSLog(@"newRstr -- %@",rPathStr);
    dispatch_queue_t globalQ = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    
    dispatch_group_async(group, globalQ, ^{
        
        if( [TSHelper sharedHelper].isCancleClearBg ) return ;
        NSLog(@"getmaxCC");
        getMaxCC((char*)[oPathStr UTF8String], (char*)[mPathStr UTF8String], (char*)[rPathStr UTF8String],NULL,(int)count);
        
    });
    
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSError *err = nil;
        if([TSHelper sharedHelper].isCancleClearBg ) {
            err = [[NSError alloc] initWithDomain:@"" code:-1 userInfo:@{@"KErrorDesKey":@"已取消退底"}];
        }
        //所有图片合成完毕
        if( completeBlock ){
            
            completeBlock(err);
        }
    });
}

//- (void)showAllFileWithPath:(NSString *) path {
//    NSFileManager * fileManger = [NSFileManager defaultManager];
//    BOOL isDir = NO;
//    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
//    if (isExist) {
//        if (isDir) {
//            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
//            NSString * subPath = nil;
//            for (NSString * str in dirArray) {
//                subPath  = [path stringByAppendingPathComponent:str];
//                BOOL issubDir = NO;
//                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
//                [self showAllFileWithPath:subPath];
//            }
//        }else{
//            NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
//            if ([fileName hasSuffix:@".jpg"]) {
//                //do anything you want
//                NSLog(@"filename==%@",fileName);
//            }
//        }
//    }else{
//        NSLog(@"this path is not exist!");
//    }
//}


- (void)cancleClearImg{
    
}

@end
