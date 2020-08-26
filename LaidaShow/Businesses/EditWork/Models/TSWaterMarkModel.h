//
//  TSWaterMarkModel.h
//  ThreeShow
//
//  Created by DeepAI on 2019/1/24.
//  Copyright © 2019年 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
{
    code = "<null>";
    data = "<null>";
    errorMessage = "<null>";
    msg = "";
    page = 0;
    rtnCode = 1;
    rtnResult =     {
        alpha = 20;
        height = 200;
        id = 537;
        isDelete = 0;
        picture = "shenyi/image/member/1157/watermark/568b0ab9e6b640e2a3698150b8db4cd9.jpg";
        status = 0;
        text = "";
        uid = 1157;
        width = 111;
        x = "<null>";
        y = "<null>";
    };
}------
*/
@interface TSWaterMarkModel : NSObject

/**水印图片*/
@property (nonatomic,strong) NSString *picture;

@end

NS_ASSUME_NONNULL_END
