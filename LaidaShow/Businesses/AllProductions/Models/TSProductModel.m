//
//  TSProductModel.m
//  ThreeShow
//
//  Created by hitomedia on 07/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSProductModel.h"
#import "TSProductDataModel.h"
#import "NSString+Ext.h"
#import "TSConstants.h"
#import "TSHelper.h"
#import "NSArray+CDIExtention.h"

@implementation TSProductModel

+ (TSProductModel *)productModelWithDm:(TSProductDataModel *)dm{
    if( dm == nil ) return nil;
    
    NSString *headImgPrefix = [TSHelper userImgUrlPrefix];

    TSProductModel *pm = [TSProductModel new];
    if( [dm.headimgurl isKindOfClass:[NSString class]] ){
        if( [dm.headimgurl containsString:@"http"] ){
            pm.userImgUrl = dm.headimgurl;
        }else{
            pm.userImgUrl = [headImgPrefix stringByAppendingString:dm.headimgurl];
        }
    }
    pm.userName = dm.userName;
    pm.productName = dm.title;
    pm.isPraised = [NSString stringWithObj:dm.liked].boolValue;
    pm.praiseCount = [TSHelper praiseCountWithStr:[NSString stringWithObj:dm.praise]];
    pm.isVideoWork = [NSString stringWithObj:dm.type].integerValue == 1 ;
    
 //   pm.productImgUrl = [pm productImgUrlWithTailStr:dm.picture];
    NSMutableArray *newPictureUrls = [NSMutableArray array];
    
    // pictureUrl = "shenyi/image/member/98/sypic/e5760a857e9b42baa455a984f66d8509_w/"
    // pictureUrl = "932/3c07882e95a345dc8f1d43bfb2fec3c0/"
    //两种图片格式需区分否则不显示，重定向导致两种路径url
    
    for (int i = 0; i<dm.pictureNum; i++) {
        
        NSString *URL = [NSString stringWithFormat:@"%@%d.%@",dm.pictureUrl,i,dm.suffix];
        
        NSString *imgUrl = nil;
        
        //判断两种图片格式。 申义开头
        if ([dm.pictureUrl containsString:@"sypic"]) {
//            pm.productImgUrl
            imgUrl = [NSString stringWithFormat:@"%@/%@",TSConstantServerUrl,URL];
        }
        else if( [[dm.pictureUrl substringToIndex:4] containsString:@"101"] ){
            NSString *url101Header = @"http://m.res.aipp3d.com/";
//            pm.productImgUrl =
            imgUrl = [NSString stringWithFormat:@"%@%@",url101Header,URL];
        }
        else {
//            pm.productImgUrl
            imgUrl = [pm productImgUrlWithTailStr:URL];
        }
        
//        String imgUrl = goodsBean.getPicUrls().get(0);
//        if (null != imgUrl) {
//            if (imgUrl.startsWith("shenyi")) {
//                imgUrl = “http://www.aipp3d.com” + imgUrl;
//            } else if (imgUrl.startsWith("101")) {
//                imgUrl = “http://m.res.aipp3d.com”+ imgUrl;
//            } else {
//                imgUrl = “http://n.res.aipp3d.com” + imgUrl;
//            }
//        }
//        [newPictureUrls addObject:pm.productImgUrl];
        if( i ==0 ){
            pm.productImgUrl = imgUrl;
        }
        
        //压缩一下
        imgUrl = [imgUrl stringByAppendingString:@"?x-oss-process=image/resize,w_720"];        
        [newPictureUrls addObject:imgUrl];
    }
    dm.pictureUrls = newPictureUrls;
    //NSLog(@"产品详细图数组 —— %@",newPictureUrls);
    if( [dm.pictureUrls isKindOfClass:[NSArray class]] && dm.pictureUrls.count ){
     
        pm.productImgUrl = dm.pictureUrls[0];
        
        //若是SOS的图片，则压缩一下
        if ([dm.pictureUrl containsString:@"sypic"]  ||
            [[dm.pictureUrl substringToIndex:4] containsString:@"101"] ) {
            pm.productImgUrl = [pm.productImgUrl stringByAppendingString:@"?x-oss-process=image/resize,w_300"];
        }
    }
    
    
    pm.isCanOnlineService = ( [NSString stringWithObj:dm.segmentStatus].integerValue == 1 );
    
    if( pm.isVideoWork ){
        pm.productImgUrl = [pm productImgUrlWithTailStr:dm.picture];
    }
    
    pm.dm = dm;
//    NSLog(@"tid - %@",dm.tid);
    return pm;
}

#pragma mark - Private
- (NSString*)praiseCountWithStr:(NSString*)countStr{
    if( countStr ){
        return countStr;
    }
    
    return @"";
}

- (NSString*)productImgUrlWithTailStr:(NSString*)tailStr{
    if( [NSString stringWithObj:tailStr] ){
        return [[TSHelper productImgUrlPrefix] stringByAppendingString:tailStr];
    }
    return nil;
}

- (NSString*)productVideoUrlWithTailStr:(NSString*)taiStr{
    return [self productImgUrlWithTailStr:taiStr];
}

@end
