//
//  TSWatermarkImgModel.h
//  ThreeShow
//
//  Created by wkun on 2019/2/1.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWatermarkImgModel : NSObject

@property (nonatomic, strong) NSString *watermarkImgId;
@property (nonatomic, strong) NSString *url;

+ (TSWatermarkImgModel*)waterMarkModelWithDic:(NSDictionary*)dic;

@end

NS_ASSUME_NONNULL_END
//alpha = 20;
//height = 200;
//id = 640;
//isDelete = 0;
//picture = "shenyi/image/member/1164/watermark/a7e888fbe7d643ecb2926071dd9cba13.jpg";
//status = 0;
//text = "";
//uid = 1164;
//width = 153;
//x = "<null>";
//y = "<null>";
