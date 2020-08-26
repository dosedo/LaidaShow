//
//  TSConstants.h
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSConstants : NSObject

//服务器接口url
extern NSString* const TSConstantServerUrl;
extern NSString* const TSConstantProductImgMiddUrl; //作品图片的中间的串
extern NSString* const TSConstantUserHeadImgMiddUrl; //用户头像的中间串
extern NSString* const TSConstantWorkClearImgMiddUrl; //去底图的中间串

//常量数值
extern NSUInteger const TSConstantViewTagBase;
extern NSUInteger const TSConstantPhoneNumLen;
extern NSUInteger const TSConstantVerificationCodeLen; //验证码长度
extern NSUInteger const TSConstantAccountPwdMaxLen;//账号密码最大长度
extern NSUInteger const TSConstantAccountPwdMinLen;//账号密码最小长度
extern NSUInteger const TSConstantUserNameMinLen; //用户名最小值
extern NSUInteger const TSConstantUserNameMaxLen; //用户名最大值
//常量字符串
extern NSString* const TSConstantDefaultHeadImgName;  //默认的头像

//通知key
extern NSString* const TSConstantNotificationLoginSuccess;
extern NSString* const TSConstantNotificationModifyUserImgSuccess;
extern NSString* const TSConstantNotificationModifyUserNameSuccess;
extern NSString* const TSConstantNotificationDeleteWorkOnLine; //删除线上作品的通知
extern NSString* const TSConstantNotificationDeleteWorkLocal;  //删除本地作品的通知
extern NSString* const TSConstantNotificationUserCancleCollect;//用户取消收藏

#warning 与 TSConstantNotificationDeleteWorkOnLine 的值一样，其作用相同，后期可将TSConstantNotificationDeleteWorkOnLine 其全部替换为TSConstantNotificationReloadWorkList。
extern NSString* const TSConstantNotificationReloadWorkList;   //重新加载作品列表数据（如首页和我的作品）

//extern NSString* const TSConstantNotificationStartWorkClearBg; //作品开始去底
@end
