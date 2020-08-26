//
//  TSNoticeModel.m
//  ThreeShow
//
//  Created by wkun on 2019/3/10.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSNoticeModel.h"
#import "NSString+Ext.h"
#import "NSDate+Ext.h"
#import "TSConstants.h"
#import "TSHelper.h"

@implementation TSNoticeModel


+ (TSNoticeModel *)noticeModelWithDic:(NSDictionary *)dic{
    if( ![dic isKindOfClass:[NSDictionary class]] ) return nil;
    
    TSNoticeModel *model = [TSNoticeModel new];
    model.title = [model titleWithDic:dic];
    model.des = [NSString stringWithObj:dic[@"name"]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[NSString stringWithObj:dic[@"updateTime"]].doubleValue/1000];
    model.time = [date formatDateStr];
    model.imgUrl = [model workImgUrlWithUrlStr:[NSString stringWithObj:dic[@"picture"]]];
    
    model.originDic = dic;
    return model;
}

- (NSString*)workImgUrlWithUrlStr:(NSString*)tailStr{
    
    if( [NSString stringWithObj:tailStr] ){
        
        NSString *url = [[TSHelper productImgUrlPrefix] stringByAppendingString:tailStr];
        
        if ([tailStr containsString:@"sypic"]) {
            url = [NSString stringWithFormat:@"%@/%@",TSConstantServerUrl,tailStr];
//            NSLog(@"sypic产品详细图地址 —— %@",url);
        }
        else if( [[tailStr substringToIndex:4] containsString:@"101"] ){
            NSString *url101Header = @"http://m.res.aipp3d.com/";
            url = [NSString stringWithFormat:@"%@%@",url101Header,tailStr];
        }

        return url;
    }
    return nil;
    
//    return [NSString stringWithFormat:@"%@/%@",TSConstantServerUrl,url];
}
//申请成功，处理完成会通知您的哦=Application is successful, you will be notified when the processing is completed.
- (NSString*)titleWithDic:(NSDictionary*)dic{
    NSString *status = [NSString stringWithObj:dic[@"status"]];
    if( status ){
        //未完成
        if( status.integerValue == 0 ){
            return [NSString stringWithObj:dic[@"description"]];
        }
        
        //处理中作品
        else if( status.integerValue == 1 ){
            return NSLocalizedString(@"WorkOnlineServiceSuccess", nil);
        }
        //已完成的作品
        else if( status.integerValue == 3 ){
            return NSLocalizedString(@"WorkOnlineServiceComplete", nil);
        }
    }
    return nil;
}

@end
