//
//  TSUserModel.h
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSUserModel : NSObject<NSCoding>

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userType;
@property (nonatomic, strong) NSString *userImgUrl;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, assign) NSString *tokenType;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) BOOL isThirdLogin; //是否为第三方登录
@property (nonatomic, strong) NSString *signature; //个性签名
@property (nonatomic, strong) NSString *email;

+ (TSUserModel*)userModelWithDic:(NSDictionary*)dic;

@end
