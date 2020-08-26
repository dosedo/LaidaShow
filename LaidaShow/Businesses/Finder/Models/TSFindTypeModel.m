//
//  TSFindTypeModel.m
//  ThreeShow
//
//  Created by wkun on 2019/2/23.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSFindTypeModel.h"


@implementation TSFindTypeModel

+ (TSFindTypeModel *)findTypeModelWithDic:(NSDictionary *)dic{
    if( [dic isKindOfClass:[NSDictionary class]]==NO ) return nil;
    
    TSFindTypeModel *tm = [TSFindTypeModel new];
    tm.des = [self stringWithObj:dic[@"desccript"]];
    tm.ID = [self stringWithObj:dic[@"id"]];
    tm.typeName = [self stringWithObj:dic[@"name"]];
    tm.title = [self stringWithObj:dic[@"title"]];
    tm.ywTypeName = [self stringWithObj:dic[@"ywkeyWord"]];
    tm.ywdesccript = [self stringWithObj:dic[@"ywdesccript"]];
    tm.ywtitle = [self stringWithObj:dic[@"ywtitle"]];
    
    return tm;
}

+ (NSString*)stringWithObj:(id)obj{
    if( [obj isKindOfClass:[NSString class]] ){
        return obj;
    }
    
    if( [obj isKindOfClass:[NSNumber class]] ){
        return ((NSNumber*)(obj)).stringValue;
    }
    
    return @"";
}

@end
