//
//  TSVersionModel.m
//  ThreeShow
//
//  Created by hitomedia on 11/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSVersionModel.h"
#import "MJExtension.h"
#import "NSString+Ext.h"

@implementation TSVersionModel

+ (TSVersionModel *)versionModelWithDic:(NSDictionary *)dic{
    if( [dic isKindOfClass:[NSDictionary class]] ==NO ) return nil;
    
    TSVersionModel *vm = [TSVersionModel new];
    
    vm.vname = [NSString stringWithObj:dic[@"iosReleaseName"]];
    vm.vcode = [NSString stringWithObj:dic[@"iosReleaseCode"]];
    
    return vm;
}

//+ (NSDictionary *)mj_replacedKeyFromPropertyName{
//    return @{@"ID":@"id",@"DESCRIPTION":@"description"};
//}
//
- (instancetype)init {
    self = [super init];
    if( self ){
        _showUpdateItem = NO;
    }
    return self;
}

- (BOOL)isNeedUpdate{
    // app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if( [app_Version containsString:@"."] ){
//        self.releaseCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"rCode"];
        NSString *serverVersion = self.vcode;
        NSString *nowVersion = [app_Version stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSLog(@"serverversion - %@",serverVersion);
        NSLog(@"nowversion - %@",nowVersion);
        if( nowVersion.intValue < serverVersion.intValue ){
            //当前的app版本号小于服务端版本号，说明存在新版
            self.showUpdateItem = YES;
            return YES;
        }else{  //if(nowVersion.integerValue >= serverVersion.integerValue ){
            //当前的app版本号大于或等于服务端版本号 则不展示检查更新按钮
            self.showUpdateItem = NO;
        }
    }
    return NO;
}

@end
