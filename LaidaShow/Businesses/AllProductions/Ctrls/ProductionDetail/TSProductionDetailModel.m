//
//  TSProductionDetailModel.m
//  ThreeShow
//
//  Created by hitomedia on 09/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSProductionDetailModel.h"
#import "TSProductDataModel.h"
#import "TSHelper.h"
#import "NSString+Ext.h"
#import "TSWorkModel.h"
#import "TSDataProcess.h"
#import "TSUserModel.h"
#import "TSCategoryModel.h"
#import "NSArray+CDIExtention.h"
#import "TSConstants.h"
#import "NSDate+Ext.h"

@implementation TSProductionDetailModel

+ (TSProductionDetailModel *)productionDetailModelWithDm:(TSProductDataModel *)dm{
    
    if( [dm isKindOfClass:[TSProductDataModel class]] ==NO ) return nil;
    
    TSProductionDetailModel *pm = [TSProductionDetailModel new];
    NSString *headImgPrefix = [TSHelper userImgUrlPrefix];
//    if( [dm.headimgurl isKindOfClass:[NSString class]] ){
//        pm.headImgUrl = [headImgPrefix stringByAppendingString:dm.headimgurl];//dm.uid];
//    }
    
    if( [dm.headimgurl isKindOfClass:[NSString class]] ){
        if( [dm.headimgurl containsString:@"http"] ){
            pm.headImgUrl = dm.headimgurl;
        }else{
            pm.headImgUrl = [headImgPrefix stringByAppendingString:dm.headimgurl];
        }
    }
    
    pm.userName = dm.userName;
    pm.productName = dm.title;
    pm.isPraised = [NSString stringWithObj:dm.liked].boolValue;
    pm.isCollected = [NSString stringWithObj:dm.collected].boolValue;
    pm.praiseCount = [TSHelper praiseCountWithStr:[NSString stringWithObj:dm.praise]];
    pm.productDes = dm.describe;
    if(pm.productDes == nil || [pm.productDes isEqualToString:@""] ){
        pm.productDes = @"--";
    }
    pm.collectCount = [TSHelper collectCountWithStr:[NSString stringWithObj:dm.collectCount]];
    pm.musicUrl = dm.audio;
    pm.musicName = [pm musicNameWithMusicUrl:pm.musicUrl recordBase64:dm.recordBase64];
    pm.imgUrls = dm.pictureUrls;
    [pm priceAndSaleCountWithPrice:dm.price saleCount:dm.saleCount];
    pm.videoUrl = [pm productVideoUrlWithTailStr:dm.video];
    pm.productCategory = [pm categoryWithStr:[NSString stringWithObj:dm.category]];
    pm.buyUrl = [NSString stringWithObj:dm.link];
    pm.createTime = [pm createTimeWithTime:dm.createtime];
    pm.gifUrl = [pm gifUrlWithStr:dm.gif];
    pm.isCanOnline = YES;
    NSString *status = ([NSString stringWithObj:dm.segmentStatus]);
    if( status && status.integerValue == 1 ){
        pm.isCanOnline = NO;
    }
    pm.dm = dm;
    
    return pm;
}

#pragma mark - Private

- (NSString*)gifUrlWithStr:(NSString*)tailStr{
//    gif = "g/2018/12/21/1139/9f85a33f7891450190e234e7dd217d83.gif";
    NSString * ts = [NSString stringWithObj:tailStr];
    if(  ts && ts.length > 2 ){
        return [[TSHelper productImgUrlPrefix] stringByAppendingString:tailStr];
    }
    return nil;
}

- (NSString*)categoryWithStr:(NSString*)str{
    NSArray *categoryCodes = [TSCategoryModel categoryCodes];
    NSString *name = str;
    if( str && [categoryCodes containsObject:str] ){
        name = [[TSCategoryModel categoryNames] objectAtIndex:[categoryCodes indexOfObject:str]];
    }
    if( name == nil ) return @"--";
    return name;
}

- (NSString*)priceAndSaleCountWithPrice:(NSString*)priceStr saleCount:(NSString*)saleCountStr{
    NSString *str = nil;
    NSString *price = priceStr;//[NSString stringWithObj:priceStr];
    if( [priceStr isKindOfClass:[NSString class]] ==NO ){
        price = @"0";
    }
    NSString *saleCount = [NSString stringWithObj:saleCountStr];
    if( price.floatValue <= 0 ){
        price = @"0";
    }
    
    NSString *danweiStrMark= NSLocalizedString(@"WorkDetailPriceDanwei", nil);
//    NSDecimalNumber *currNum = [NSDecimalNumber decimalNumberWithString:price];
    str = [NSString stringWithFormat:@"%.1f%@",price.floatValue,danweiStrMark];
    self.price = str;
    
    if( saleCount == nil ){
        saleCount = @"0";
    }
    
    NSString *unitMark = NSLocalizedString(@"WorkDetailMonthSaleCountUnit", nil);
    self.saleCount = [NSString stringWithFormat:@"%@%@",saleCount,unitMark];

    return nil;
}

- (NSString*)productVideoUrlWithTailStr:(NSString*)tailStr{
    NSString * ts = [NSString stringWithObj:tailStr];
    if(  ts && ts.length > 2 ){
        return [[TSHelper productImgUrlPrefix] stringByAppendingString:tailStr];
    }
    return nil;
}

- (NSString*)musicNameWithMusicUrl:(NSString*)url recordBase64:(NSString*)rb{
  //  http://n.res.aipp3d.com/
    if( [url isKindOfClass:[NSString class] ] ){
        if( [url containsString:@"http"] ||[url containsString:@"m/"] ){
            return [url lastPathComponent];
        }
    }
    
    if( [rb isKindOfClass:[NSString class]] && rb.length > 5 ){
        return NSLocalizedString(@"WorkEditBottomRecordFile", nil);//@"录音文件";
    }
    
    return nil;
}

- (NSString*)createTimeWithTime:(NSString*)time{
    if([NSString stringWithObj:time]==nil ) return nil;
    
    NSString *newTime = [NSString stringWithDate:[NSDate dateWithString:time format:@"yyyy-MM-dd HH:mm:ss.0"] format:@"yyyy-MM-dd HH:mm:ss"];
    return newTime;
}

#pragma mark - 本地作品部分

+ (TSProductionDetailModel *)productionDetailModelWithWorkModel:(TSWorkModel *)wm{
    if([wm isKindOfClass:[TSWorkModel class]] == NO ) return nil;
    
    TSProductionDetailModel *dm = [TSProductionDetailModel new];
    dm.productName = wm.workName;
//    dm.priceAndSaleCount = [dm localWorkPriceAndSaleCountWithPrice:wm.workPrice saleCount:wm.workSaleCount];
    dm.productDes = wm.workDes;
//    dm.price = wm.workPrice;
    [dm priceAndSaleCountWithPrice:wm.workPrice saleCount:wm.workSaleCount];
    dm.buyUrl = wm.workBuyUrl;
    dm.headImgUrl = [TSDataProcess sharedDataProcess].userModel.userImgUrl;//@"textimg";
    dm.userName = [TSDataProcess sharedDataProcess].userModel.userName;
    dm.musicUrl = wm.musicUrl;
    dm.musicName = [dm musicNameWithMusicUrl:wm.musicUrl recordBase64:wm.recordPath];
//    dm.productCategory = wm.workCategory;//
    dm.productCategory = [dm localWorkCategoryWithStr:wm.workCategoryCode];
    
    //根据Code未取到类别名称，则直接取保存时的类别名
    if( [dm.productCategory isEqualToString:@""] ){
        dm.productCategory = wm.workCategory;
    }
    return dm;
}

- (NSString*)localWorkCategoryWithStr:(NSString*)str{
//    NSString *mark = NSLocalizedString(@"WorkDetailCategory", nil);
    NSArray *categoryCodes = [TSCategoryModel categoryCodes];
    NSString *name = str;
    if( str && [categoryCodes containsObject:str] ){
        name = [[TSCategoryModel categoryNames] objectAtIndex:[categoryCodes indexOfObject:str]];
    }
    if( name == nil ) return @"";
    return name;
}
//
//- (NSString*)localWorkPriceAndSaleCountWithPrice:(NSString*)priceStr saleCount:(NSString*)saleCountStr{
//    NSString *str = nil;
//    NSString *price = [NSString stringWithObj:priceStr];
//    NSString *saleCount = [NSString stringWithObj:saleCountStr];
//    if( price.integerValue > 0 ){
//        NSString *pstrMark = NSLocalizedString(@"WorkDetailPriceText", nil);
//        NSString *danweiStrMark= NSLocalizedString(@"WorkDetailPriceDanwei", nil);
//        str = [NSString stringWithFormat:@"%@：%@%@",pstrMark,price,danweiStrMark];
//
//        if( saleCount ){
//            NSString *saleCountMark = NSLocalizedString(@"WorkDetailMonthSaleCount", nil);
//            NSString *unitMark = NSLocalizedString(@"WorkDetailMonthSaleCountUnit", nil);
//            str = [NSString stringWithFormat:@"%@   %@：%@%@",str,saleCountMark,saleCount,unitMark];
//        }
//    }
//
//    return str;
//}

@end
