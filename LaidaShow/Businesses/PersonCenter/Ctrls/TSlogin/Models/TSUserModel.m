//
//  TSUserModel.m
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSUserModel.h"
#import "NSString+Ext.h"
#import "TSHelper.h"
#import "MJExtension.h"

@implementation TSUserModel

MJCodingImplementation

//avatar = "avatar-default.png";
//birthDate = "1990-01-01 00:00:00";
//cellphone = 17731248081;
//city = "\U6f4d\U574a\U5e02";
//createTime = "2018-05-10 11:07:31";
//district = "\U4e34\U6710\U53bf";
//id = "c5c1f03b-c7ba-46c4-8118-89fd64b76fe7";
//lastLoginTime = "2018-05-10 11:07:31";
//name = SanVShow16807;
//passwordMd5 = E10ADC3949BA59ABBE56E057F20F883E;
//platform = 0;
//province = "\U5c71\U4e1c\U7701";
//sex = "\U7537";
//thirdId = "";
//token = "8d9feb07-5ddc-4a3b-874d-861be6fed4cf";

+ (TSUserModel*)userModelWithDic:(NSDictionary *)tdic{
    if( [tdic isKindOfClass:[NSDictionary class]] == NO ) return nil;
    NSDictionary *dic = nil;
    NSDictionary *infoDic = tdic[@"additionalInformation"];
    if( [infoDic isKindOfClass:[NSDictionary class]] ){
        dic = infoDic[@"member"];
    }
    if( ![dic isKindOfClass:[NSDictionary class]] ) return nil;
    
    TSUserModel *um = [TSUserModel new];
    um.userId = [NSString stringWithObj:dic[@"id"]];
    um.userName = [NSString stringWithObj:dic[@"username"]];
    if( um.userName.length ==0 ){
        um.userName = [NSString stringWithObj:dic[@"nickname"]];
    }
    um.phone = [NSString stringWithObj:dic[@"phone"]];
    um.sex = [NSString stringWithObj:dic[@"sex"]];
    
    um.tokenType = [NSString stringWithObj:tdic[@"tokenType"]];
    um.token = [NSString stringWithObj:tdic[@"value"]];
    
    um.signature = [NSString stringWithObj:dic[@"sign"]];
    um.email = [NSString stringWithObj:dic[@"email"]];
    um.isThirdLogin = NO;
    if( um.userId )
       // http://www.aipp3d.com/shenyi/image/member/1062/AVATAR/2019/01/18/1062/750b83fdd4da4742afa1470bf3ae694c.jpg
      //  http://www.aipp3d.com/shenyi/api/avatar/id/AVATAR/2019/01/18/1062/750b83fdd4da4742afa1470bf3ae694c.jpg
       // um.userImgUrl = [[TSHelper userImgUrlPrefix] stringByAppendingString:[NSString stringWithFormat:@"%@/%@",um.userId,[NSString stringWithObj:dic[@"headimgurl"]]] ];
        //um.userImgUrl = [[TSHelper userImgUrlPrefix] stringByAppendingString:[NSString stringWithObj:dic[@"headimgurl"]]];
        um.userImgUrl = [[TSHelper userImgUrlPrefix] stringByAppendingString:um.userId];
    
    if( um.email == nil && um.phone == nil ){
        //说明是第三方登录
        um.isThirdLogin = YES;
    }
    return um;
}

@end
