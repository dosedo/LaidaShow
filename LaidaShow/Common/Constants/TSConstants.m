//
//  TSConstants.m
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSConstants.h"

@implementation TSConstants
//http://show.aipp3d.com/
NSString* const TSConstantServerUrl = @"https://show.schengroup.com";//@"http://www.aipp3d.com";
NSString* const TSConstantProductImgMiddUrl = @"https://oss.show.schengroup.com/";
//@"http://aipp-micro.oss-cn-shenzhen.aliyuncs.com/";

//@"http://n.res.aipp3d.com/";//pic/work/";***重定向的地址http://n.res.aipp3d.com/  把返回的数据重定向,有些需要用这个地址前缀而不是http://www.aipp3d.com***
NSString* const TSConstantUserHeadImgMiddUrl =@"/api/user/avatar/id/";// @"/api/avatar/id/";
NSString* const TSConstantWorkClearImgMiddUrl = @"pic/seg/";     //去底成功的图片的 前缀

NSUInteger const TSConstantViewTagBase = 9022;
NSUInteger const TSConstantPhoneNumLen = 11;

NSUInteger const TSConstantVerificationCodeLen = 6;
NSUInteger const TSConstantAccountPwdMaxLen = 18;//账号密码最大长度
NSUInteger const TSConstantAccountPwdMinLen = 6;//账号密码最小长度
NSUInteger const TSConstantUserNameMinLen = 1;
NSUInteger const TSConstantUserNameMaxLen = 30;

NSString* const TSConstantDefaultHeadImgName = @"default_headimg";

NSString* const TSConstantNotificationLoginSuccess = @"login_success_notifacion";
NSString* const TSConstantNotificationModifyUserImgSuccess = @"modify_userimg_notifaciotn";
NSString* const TSConstantNotificationModifyUserNameSuccess = @"modfiy_username_notificaiton";
NSString* const TSConstantNotificationDeleteWorkOnLine = @"delete_online_work_notificaiton";
NSString* const TSConstantNotificationDeleteWorkLocal = @"delete_local_work_notificaiton";
NSString* const TSConstantNotificationUserCancleCollect = @"user_cancle_collect_work_notificaiton";
NSString* const TSConstantNotificationReloadWorkList = @"delete_online_work_notificaiton";
//NSString* const TSConstantNotificationStartWorkClearBg = @"start_work_clear_bg_notification"; //开始作品开始去底
@end
