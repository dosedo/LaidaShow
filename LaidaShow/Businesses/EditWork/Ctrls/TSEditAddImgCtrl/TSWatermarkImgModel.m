//
//  TSWatermarkImgModel.m
//  ThreeShow
//
//  Created by wkun on 2019/2/1.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSWatermarkImgModel.h"
#import "TSConstants.h"
#import "NSString+Ext.h"

@implementation TSWatermarkImgModel

+ (TSWatermarkImgModel *)waterMarkModelWithDic:(NSDictionary *)dic{
    if( [dic isKindOfClass:[NSDictionary class]] ==NO ) return nil;
    
    TSWatermarkImgModel *im = [TSWatermarkImgModel new];
    
    NSString *urlTail = dic[@"picture"];
    
    if( [urlTail isKindOfClass:[NSString class]] ){
//    NSString *URL = [NSString stringWithFormat:@"%@%d.%@",dm.pictureUrl,i,dm.suffix];
    //判断两种图片格式
        if ([urlTail containsString:@"sypic"]) {
            im.url = [NSString stringWithFormat:@"%@/%@",TSConstantServerUrl,urlTail];
//            NSLog(@"sypic产品详细图地址 —— %@",im.url);
        }
        else if( [[urlTail substringToIndex:4] containsString:@"101"] ){
            NSString *url101Header = @"http://m.res.aipp3d.com/";
            im.url = [NSString stringWithFormat:@"%@%@",url101Header,urlTail];
        }
        else{
            NSString *url = [NSString stringWithFormat:@"%@/%@",TSConstantProductImgMiddUrl,urlTail];
            im.url = url;
        }
    }
    
    im.watermarkImgId = [NSString stringWithObj:dic[@"id"]];
    return im;
}

@end
