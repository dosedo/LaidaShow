//
//  TSVersionModel.h
//  ThreeShow
//
//  Created by hitomedia on 11/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 版本信息Model
 */
/*
{
    "code": "success",
    "data": {
        "id" : "1",
        "releaseName" : "1.0.0",
        "description" : "版本更新，修改bug。",
        "userName" : "admin",
        "appName" : "三维秀",
        "userId" : "1061",
        "iosLink":"itmsapps://itunes.apple.com/cn/app/id1252918819?mt=8",
        "androidLink" : "http://www.moispano.com/public/download/Moispano_1.0.0.apk",
        "createTime" : 2018-10-24 12:45:43,
        "releaseCode" : "100"
    },
*/
@interface TSVersionModel : NSObject

//@property (nonatomic, strong) NSString *ID;//
//@property (nonatomic, strong) NSString *releaseName ;// App的版本号;
//@property (nonatomic, strong) NSString *DESCRIPTION;// 新版本的内容
//@property (nonatomic, strong) NSString *iosLink;//App下载链接
//@property (nonatomic, strong) NSString *userName;// 用户名
//@property (nonatomic, strong) NSString *appName;//App的名称
//@property (nonatomic, strong) NSString *userId;//
//@property (nonatomic, strong) NSString *releaseCode;//
//@property (nonatomic, strong) NSString *createTime;//创建时间
//@property (nonatomic, strong) NSDictionary *data;//创建时间



@property (nonatomic, strong) NSString *info;// 新版本的内容
@property (nonatomic, strong) NSString *name ;// App的名字;
@property (nonatomic, strong) NSString *url;//App下载链接
@property (nonatomic, strong) NSString *vcode;// 版本号 204;
@property (nonatomic, strong) NSString *vname;// 版本号名字"2.0.4";

@property (nonatomic, assign) BOOL showUpdateItem; //是否展示更新按钮。默认为NO

//是否需要更新
- (BOOL)isNeedUpdate;

+ (TSVersionModel*)versionModelWithDic:(NSDictionary*)dic;

@end

