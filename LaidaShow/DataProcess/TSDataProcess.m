//
//  TSDataProcess.m
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSDataProcess.h"
#import "TSDataBase.h"
#import "TSHttpRequest.h"
#import "KError.h"
#import "NSString+Ext.h"
#import "MJExtension.h"
#import "NSDictionary+Ext.h"
#import "TSConstants.h"
#import "TSHelper.h"
#import "TSUserModel.h"
#import "TSVersionModel.h"
#import "PPFileManager.h"
#import "TSWatermarkImgModel.h"
#import "TSFindTypeModel.h"
#import "TSFindModel.h"
#import "TSProductDataModel.h"
#import "UIImage+image.h"

@implementation TSDataProcess{
    NSString *_serverUrl;
}

+ (TSDataProcess *)sharedDataProcess{
    static TSDataProcess *dp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dp = [TSDataProcess new];
        dp->_serverUrl = TSConstantServerUrl;
    });
    return dp;
}

#pragma mark - Common

-(NSURLSessionDownloadTask*)dowloadImg:(NSString*)imgUrl completeBlock:(void (^)(UIImage *,NSError*))completeBlock{
    
    if( !imgUrl || [imgUrl isEqualToString:@""] ){
        if( completeBlock){
            completeBlock(nil,[KError errorWithCode:KErrorCodeDefault msg:@"文件不存在"]);
        }
        return nil;
    }
    
    NSString *savePath = [[self dataBase] getImgCacheDir];//NSTemporaryDirectory();
    NSString *tailStr = @"";
    NSString *prefix = [TSHelper productImgUrlPrefix];
    if( [imgUrl containsString:prefix]){
        tailStr = [imgUrl substringFromIndex:prefix.length];
        NSInteger toidx = -1;
        NSString *lastStr = [tailStr lastPathComponent];
        if( lastStr.length ){
            toidx = [tailStr rangeOfString:lastStr].location;
        }
        if( toidx > 0 )
            tailStr = [tailStr substringToIndex:toidx];
        
        if( tailStr.length ){
            savePath = [savePath stringByAppendingPathComponent:tailStr];
        }
    }
    
//    NSString *fileAllName = [imgUrl lastPathComponent];
//    NSString *filePathMid = [imgUrl stringByDeletingLastPathComponent];
    
    NSString *noCompressImgUrl = imgUrl;
    if( [noCompressImgUrl containsString:@"?"] ){
        noCompressImgUrl = [noCompressImgUrl componentsSeparatedByString:@"?"][0];
    }
    NSString *fileAllName = [noCompressImgUrl lastPathComponent];
    NSString *filePathMid = [noCompressImgUrl stringByDeletingLastPathComponent];
    
    NSString *fileAllPath = [NSString stringWithFormat:@"%@%@",[filePathMid lastPathComponent],fileAllName];
    NSString *imgFilePath = [savePath stringByAppendingPathComponent:fileAllPath];
    
//    /var/mobile/Containers/Data/Application/2F9678A2-0C45-44E6-B185-FF64E762192B/Library/Documentation/AllUserCommon/imgCache/0.jpg

    
//    NSString *imgFilePath = [savePath stringByAppendingPathComponent:[imgUrl lastPathComponent]];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:imgFilePath] ){
        UIImage *img =
        [UIImage imageWithContentsOfFile:imgFilePath];
        
        if( completeBlock && img){
    
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completeBlock(img,nil);
            });
            
            return nil;
        }
    }

    return
    [self.httpRequest downloadFileAsync:imgUrl savePath:savePath downloadingBlock:nil completeBlock:^(NSError *err) {
        UIImage *img = nil;
        if( completeBlock){
            if( err == nil )
                img = [UIImage imageWithContentsOfFile:imgFilePath];
            completeBlock(img,err);
        }
    }];
}

-(NSURLSessionDownloadTask*)dowloadImg:(NSString*)imgUrl saveImgPath:(NSString*)savePath saveImgName:(NSString*)saveImgName completeBlock:(void (^)(UIImage *,NSString *,NSError*))completeBlock{
    
    if( !imgUrl || [imgUrl isEqualToString:@""] ){
        if( completeBlock){
            completeBlock(nil,nil,[KError errorWithCode:KErrorCodeDefault msg:@"文件不存在"]);
        }
        return nil;
    }
    
    if( !savePath || [savePath isEqualToString:@""] ){
        if( completeBlock){
            completeBlock(nil,nil,[KError errorWithCode:KErrorCodeDefault msg:@"文件保存路径错误"]);
        }
        return nil;
    }
    
    if( !saveImgName || [saveImgName isEqualToString:@""] ){
        if( completeBlock){
            completeBlock(nil,nil,[KError errorWithCode:KErrorCodeDefault msg:@"文件名错误"]);
        }
        return nil;
    }
    
    NSString *ext = imgUrl.pathExtension;
    if( ext == nil ) ext = @"jpg";
    NSString *fileAllName = [NSString stringWithFormat:@"%@.%@",saveImgName,ext];
    NSString *imgFilePath = [savePath stringByAppendingPathComponent:fileAllName];//[NSString stringWithFormat:@"%@/%@.%@",savePath,saveImgName,ext];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:imgFilePath] ){
        UIImage *img =
        [UIImage imageWithContentsOfFile:imgFilePath];
        
        if( completeBlock && img){
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completeBlock(img,imgFilePath,nil);
            });
            
            return nil;
        }
    }
    
    return
    [self.httpRequest downloadFileAsync:imgUrl saveAllPath:imgFilePath downloadingBlock:nil completeBlock:^(NSError *err) {
        UIImage *img = nil;
        if( completeBlock){
            if( err == nil )
                img = [UIImage imageWithContentsOfFile:imgFilePath];
            completeBlock(img,imgFilePath,err);
        }
    }];
}

#pragma mark - UserInfo

- (TSUserModel *)userModel{
    return [[TSDataBase sharedDataBase] userModel];
}

- (void)extracted:(void (^)(NSError *))completeBlock dic:(NSDictionary *)dic headImg:(UIImage *)headImg url:(NSString *)url {
    [self.httpRequest uploadImg:headImg url:url parameters:dic completeBlock:^(NSError *err) {
        NSLog(@"modifyHead ");
        NSError* returnErr = err;
        if( err  ){
            NSString* errMsg = @"数据异常，请重试~";
            NSInteger errCode = err.code;
            returnErr = [KError errorWithCode:errCode msg:errMsg];
        }
        
        if( completeBlock ){
            completeBlock(returnErr);
        }
    }];
}

- (void)modifyUserImg:(UIImage *)headImg completBlock:(void (^)(NSError *))completeBlock{
    
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"userId",@"token"] values:self.userModel.userId,self.userModel.token, nil];
    if( dic == nil || headImg == nil){
        NSError *err = nil;
        [self configErrWithDic:nil err:&err];
        if( completeBlock ) {
            completeBlock(err);
        }
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/user/api/user/upload_avatar",TSConstantServerUrl];
    
    [self extracted:completeBlock dic:dic headImg:headImg url:url];
}

- (void)modifyUserName:(NSString *)newName completBlock:(void (^)(NSError *))completeBlock{
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"id",@"token",@"username"] values:self.userModel.userId,self.userModel.token,newName, nil];
    
    [self requestWithJSONParameters:dic urlName:@"/user/Member/updateMemberInfo" result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            if( err ==nil ){
                //更新model
                TSUserModel *um = [self dataBase].userModel;
                um.userName = newName;
                [[self dataBase] updateUserModel:um];
            }
            completeBlock(err);
        }
    }];
}

- (void)modifyPwd:(NSString *)newPwd oldPwd:(NSString*)oldPwd completBlock:(void (^)(NSError *))completeBlock{
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"phone",@"token",@"password",@"oldPassword"] values:self.userModel.phone,self.userModel.token,newPwd, oldPwd,nil];
    [self requestWithJSONParameters:dic urlName:@"/user/Member/updatePass" result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            completeBlock(err);
        }
    }];

}

- (void)appLastVersionWithCompleteBlock:(void (^)(BOOL, NSString *, NSError *))completeBlock{
//    /api/user/update
//    /appClient/last
    
    [self postWithInterfaceName:@"/index/appClient/last" parameters:nil isNeedAnalysisReturnData:YES result:^(NSDictionary *result, NSError *error) {
        if(completeBlock ){
            NSLog(@"appUpdate - %@",result);
            TSVersionModel *vm = [TSVersionModel versionModelWithDic:result];
            
//            [TSVersionModel mj_objectWithKeyValues:result];
            _versionModel = vm;
//            NSLog(@"vmmodel - %@",vm.data[@"releaseCode"]);
//           [[NSUserDefaults standardUserDefaults] setObject:vm.data[@"releaseCode"] forKey:@"rCode"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
    
            BOOL isHaveNew = NO;
            NSString *newVersionNum = NSLocalizedString(@"PersonIsLatestVersion", nil);//@"已是最新版本";
            if( vm ){
                isHaveNew = [vm isNeedUpdate];
                if( isHaveNew ){
                    newVersionNum = NSLocalizedString(@"PersonFindNewVersion", nil);//@"发现新版本";
                    if( vm.vname ){
                        newVersionNum = [NSString stringWithFormat:@"%@(%@)",newVersionNum,vm.vname];
                    }
                }
            }
            completeBlock(isHaveNew,newVersionNum,error);
        }
    }];
}

- (void)feedbackWithContent:(NSString *)cnt phone:(NSString *)phone completBlock:(void (^)(NSError *))completeBlock{
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"content",@"deviceType"] values:cnt,@"3", nil];
    NSLog(@"token - %@",self.userModel.token);

    if( dic ){
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        if( self.userModel.userId ){
            //tempDic[@"username"] = self.userModel.userName;
            tempDic[@"userId"] = self.userModel.userId;
        }

        if( self.userModel.token ){
            tempDic[@"token"] = self.userModel.token;
        }

        if( phone ){
            tempDic[@"contact"] = phone;
        }

        dic = tempDic;
    }
    
    [self requestWithParameters:dic urlName:@"/user/api/user/feedback" result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            completeBlock(err);
        }
    }];
}

- (void)openApplicationInAppStore{
//    NSString *url = @"https://itunes.apple.com/us/app/三围秀/id1132012014?ls=1&mt=8";
    NSString *APPID = @"1525083088";//@"1132012014";
    NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@", APPID];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @YES}  completionHandler:^(BOOL success) {

        }];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (void)modifyUserSigature:(NSString*)sign completBlock:(void (^)(NSError *))completeBlock{
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"id",@"token",@"sign"] values:self.userModel.userId,self.userModel.token,sign, nil];
    
    [self requestWithJSONParameters:dic urlName:@"/user/Member/updateMemberInfo" result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            if( err ==nil ){
                //更新model
                TSUserModel *um = [self dataBase].userModel;
                um.signature = sign;
                [[self dataBase] updateUserModel:um];
            }
            completeBlock(err);
        }
    }];
}

//api/user/profile
- (void)userInfoWithCompleteBlock:(void (^)(NSError *))completeBlock{
    [self userInfoWithNeedCallback:NO completeBlock:completeBlock];
}

- (void)userInfoWithNeedCallback:(BOOL)needCallback completeBlock:(void (^)(NSError *))completeBlock{
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"cellphone",@"token"] values:self.userModel.userId,@"UUID", nil];

    [self requestWithParameters:dic urlName:@"/user/api/user/profile" result:^(NSDictionary *data, NSError *err) {
        
        if( err ){
            NSString *msg =
            [KError errorMsgWithError:err];
            if( [msg containsString:@"重新登录"] ){
                [[TSDataBase sharedDataBase] removeUserModel];
                
                //发送刷新数据的消息
                [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationLoginSuccess object:nil];
                if( needCallback == NO ){
                    if( completeBlock ){
                        completeBlock(err);
                    }
                }
            }
        }
        else{
            
            //缓存头像
            if( [data isKindOfClass:[NSDictionary class]] ){
                NSString *imgurl = [NSString stringWithObj:data[@"headimgurl"]];
                //缓存电话号码
                self.userModel.phone = data[@"phone"];
                if( imgurl ){
                    if( self.userModel.userImgUrl==nil ||  [self.userModel.userImgUrl containsString:imgurl] ==NO ){
                        
                        if( [imgurl containsString:@"http"] ){
                            self.userModel.userImgUrl = imgurl;
                        }else{
                            self.userModel.userImgUrl = [TSConstantProductImgMiddUrl stringByAppendingString:imgurl];
                        }
                        
                        [[TSDataBase sharedDataBase] updateUserModel:self.userModel];
                        
                        if( needCallback == NO ){
                            if( completeBlock ){
                                completeBlock(err);
                            }
                        }
                    }
                }
            }
        }
        
        if( needCallback ){
            if( completeBlock ){
                completeBlock(err);
            }
        }
    }];
}

#pragma mark - DeviceSelect
//退底(env对应值)fc-30:1，fc-80:2,vrmake40:3
- (NSArray<NSString *> *)deviceListDatas{
    return @[@"FC-30M",@"FC-80",@"VRMAKE-40"];
}

- (NSString*)selectDeviceIndexCachekey{
    return @"SelectDeviceIndexCacheKey";
}

- (void)updateSelectDeviceAtIndex:(NSInteger)idx{
    [[NSUserDefaults standardUserDefaults] setValue:@(idx) forKey:[self selectDeviceIndexCachekey]];
}

//退底(env对应值)fc-30:1，fc-80:2,vrmake40:3
- (NSInteger)selectedDeviceIndex{
     NSNumber *num = [[NSUserDefaults standardUserDefaults] valueForKey:[self selectDeviceIndexCachekey]];
    
    if( num == nil ){
        //设置一个默认选择的索引0
        num = @(0);
        [self updateSelectDeviceAtIndex:num.integerValue];
    }
    
    return num.integerValue;
}

#pragma mark - Login

- (void)thirdLoginWithPara:(NSDictionary *)para completBlock:(void (^)(NSError *))completeBlock{
    [self requestWithParameters:para urlName:@"/auth/loginBySocial" result:^(NSDictionary *data, NSError *err) {
        if( err == nil ){
            //更新本地用户缓存
            TSUserModel *um = [TSUserModel userModelWithDic:data];
            [[self dataBase] updateUserModel:um];
        }
        
        if( completeBlock ){
            completeBlock(err);
        }
    }];
}

- (void)loginWithPhone:(NSString *)phone md5Pwd:(NSString *)pwd isCodeLogin:(BOOL)codeLogin completeBlock:(void (^)(NSError *))completeBlock{
    
    NSString *type = @"password";
    NSString *urlName = @"/auth/oauth/token";
    
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"username",@"password",@"grant_type"] values:phone,pwd,type, nil];
    if( codeLogin ) {
        urlName = @"/auth/loginByMobile";
        dic = [NSDictionary dictionaryWithKeys:@[@"phone",@"code"] values:phone,pwd, nil];
    }
    [self requestWithParameters:dic urlName:urlName result:^(NSDictionary *data, NSError *err) {
        if( err == nil ){
            //更新本地用户缓存
            TSUserModel *um = [TSUserModel userModelWithDic:data];
            um.isThirdLogin = NO;
            if( [phone containsString:@"@"] ){
                um.email = phone;
            }else{
                um.phone = phone;
            }
            [[self dataBase] updateUserModel:um];
        }
        
        if( completeBlock ){
            completeBlock(err);
        }
    }];
}



- (void)logoutWithCompleteBlock:(void (^)(NSError *))completeBlock{
    //[[self dataBase] removeUserModel];
    NSLog(@"logouttoken - %@",self.userModel.token);
    // /SiteLogin/loginOut
    
    //直接退出成功,然后再去链接服务器
    if( completeBlock ){
        
        [[self dataBase] removeUserModel];
        completeBlock(nil);
    }
    
    
    NSDictionary *para = [NSDictionary dictionaryWithKeys:@[@"token"] values:self.userModel.token, nil];
    [self getWithInterfaceName:@"/logout" para:para resultBlock:^(NSDictionary *dic, NSError *err) {
        
    }];
}

- (void)verifyCodeWithPhone:(NSString *)phone type:(NSString*)type deviceType:(NSInteger)deviceType completeBlock:(void (^)(NSDictionary*rusult,NSError*err))completeBlock{
        
    NSString *url =[NSString stringWithFormat:@"%@?%@%@&%@%@&%@%ld",@"/user/SiteLogin/getChkCode",@"phone=",phone,@"type=",type,@"deviceType=",deviceType];
    [self getWithInterfaceName:url parameters:@{} isNeedAnalysisReturnData:YES result:^(NSDictionary *result, NSError *error) {
        if( completeBlock ){
            completeBlock(result,error);
        }
    }];
}

-(void)verifyCodeWithEmail:(NSString *)email type:(NSInteger)type deviceType:(NSInteger)deviceType completeBlock:(void (^)(NSError *))completeBlock{
    NSString *url =[NSString stringWithFormat:@"%@?%@&%ld&%ld",@"/SiteLogin/getChkCode",email,type,deviceType];
    
    [self getWithInterfaceName:url para:@{} resultBlock:^(NSDictionary *dic, NSError *err) {
        if( completeBlock ){
            completeBlock(err);
        }
    }];
    
//    [self.httpRequest get:url parameters:nil resultBlock:^(NSDictionary *result, NSError *err) {
//        NSLog(@"getChkCode - %@",url);
//        if( completeBlock ){
//            completeBlock(err);
//        }
//    }];
}

- (void)validateCodeWithPhone:(NSString *)phone code:(NSString *)code completeBlock:(void (^)(NSError *))completeBlock{
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"loginname",@"identify"] values:phone,code,nil];
    [self requestWithParameters:dic urlName:@"/user/api/user/codecheck" result:^(NSDictionary *data, NSError *err) {
        NSLog(@"codecheckdic - %@",dic);
        NSLog(@"codecheck - %@",data);
        if( completeBlock ){
            completeBlock(err);
            NSLog(@"codecheckerr - %@",err);
            
        }
    }];
}

- (void)registerWithPhone:(NSString *)phone code:(NSString *)code name:(NSString *)name pwd:(NSString *)pwd registerType:(NSInteger)type completeBlock:(void (^)(NSError *))completeBlock{
    NSLog(@"register - ");
    //NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"email",@"code",@"username",@"password",@"deviceType"] values:phone,code,name,pwd,3, nil];
    NSDictionary *dic = @{
                          
                          @"code":code,
                          @"username":name,
                          @"password":pwd,
                          @"deviceType":@"3"
                          };
    
    NSString *urlName = @"/user/SiteLogin/regisit_email";
    if( type == 0 ){
        //手机号注册
        urlName = @"/user/SiteLogin/regisit";
        
    }
//    @"email":phone,
    if( dic ){
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        if( type == 0 ){
            tempDic[@"phone"] = phone;
        }else {
            tempDic[@"email"] = phone;
        }
        dic = tempDic;
    }
    [self requestWithJSONParameters:dic urlName:urlName result:^(NSDictionary *data, NSError *err) {
        NSLog(@"register - %@",data);
        if( completeBlock ){
            completeBlock(err);
        }
    }];
}

- (void)userIsExistWithPhone:(NSString *)phone completeBlock:(void (^)(BOOL,NSError *))completeBlock{
    
    NSString *key = @"cellphone";
    if( [phone containsString:@"@"] ){
        key = @"mail";
    }
    
    NSDictionary *para = [NSDictionary dictionaryWithKeys:@[key] values:phone, nil];
    [self requestWithParameters:para urlName:@"/user/api/user/regisited" result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            BOOL exist = NO;
            if( [data isKindOfClass:[NSDictionary class]] ){
                exist = [NSString stringWithObj:data[@"existed"]].boolValue;
            }
            completeBlock(exist,err);
        }
    }];
}

- (void)resetPwdWithPhone:(NSString *)phone code:(NSString *)code pwd:(NSString *)pwd completeBlock:(void (^)(NSError *))completeBlock{
    NSInteger type = [[TSHelper sharedHelper] isEmailUserWithAccount:phone]?1:0;
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"deviceType",@"code",@"newPass",@"type"] values:@"3",code,pwd, @(type).stringValue,nil];
    
    if( phone && dic ){
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        if( type ==1 ){
            //邮箱
            tempDic[@"email"] = phone;
        }else{
            tempDic[@"phone"] = phone;
        }
        dic = tempDic;
    }
    [self requestWithJSONParameters:dic urlName:@"/user/SiteLogin/forgetPass" result:^(NSDictionary *data, NSError *err) {
        NSLog(@"resetPwd - %@",data);
        if( completeBlock ){
            completeBlock(err);
        }
    }];
}

- (void)bindUserWithPhone:(NSString *)phone code:(NSString *)code completeBlock:(void (^)(NSError *))completeBlock{
    NSDictionary *para = [NSDictionary dictionaryWithKeys:@[@"phone",@"code",@"id",@"deviceType"] values:phone,code,self.userModel.userId,@"3", nil];
    [self requestWithJSONParameters:para urlName:@"/user/Member/bind/phone" result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            completeBlock(err);
        }
    }];
}

#pragma mark - AllProductList

- (void)workDetailWithId:(NSString*)workId completeBlock:(void(^)(TSProductDataModel *dataModel,NSError *er))completeBlock{
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"id",@"deviceType"] values:workId,@"3",nil];
    if( self.userModel.userId ){
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        tempDic[@"uid"] = self.userModel.userId;
        dic = tempDic;
    }
    NSString *name = @"/product/services/SyPic360/findSyPic360";
    
    [self getWithInterfaceName:name para:dic resultBlock:^(NSDictionary *dic, NSError *err) {
        if( completeBlock ){
            TSProductDataModel *dm = [TSProductDataModel mj_objectWithKeyValues:dic];
            
            if( dm ){
                NSMutableArray *newPictureUrls = [NSMutableArray new];
                for (int i = 0; i<dm.pictureNum; i++) {
                    NSString *retUrl = nil;
                    NSString *URL = [NSString stringWithFormat:@"%@%d.%@",dm.pictureUrl,i,dm.suffix];
                    //判断两种图片格式
                    if ([dm.pictureUrl containsString:@"sypic"]) {
                        retUrl = [NSString stringWithFormat:@"%@/%@",TSConstantServerUrl,URL];
                        
                    }
                    else if( [[dm.pictureUrl substringToIndex:4] containsString:@"101"] ){
                        NSString *url101Header = @"http://m.res.aipp3d.com/";
                        retUrl = [NSString stringWithFormat:@"%@%@",url101Header,URL];
                    }
                    else{
                        retUrl = //[pm productImgUrlWithTailStr:URL];
                        [[TSHelper productImgUrlPrefix] stringByAppendingString:URL];
                    }
                    
                    [newPictureUrls addObject:retUrl];
                }
                dm.pictureUrls = newPictureUrls;
            }
            completeBlock(dm,err);
        }
    }];
}

- (void)allProductListWithPageIndex:(NSInteger)pageIndex tid:(NSString*)tid completeBlock:(void(^)(NSArray* datas,NSError *err))completeBlock{
    
    NSInteger dataCountOfPage = 15;
    NSInteger startIndex = pageIndex*dataCountOfPage;
    NSInteger endIndex = dataCountOfPage;//dataCountOfPage + startIndex;
    NSLog(@"self.userModel.userId - %@",self.userModel.userId);
    [self productListWithUserId:self.userModel.userId token:self.userModel.token query:nil category:nil collected:nil startIndex:startIndex endIndex:endIndex tid:tid completeBlock:^(NSDictionary *result, NSError *err) {
        if( completeBlock ){
            NSError *retErr = nil;
            NSArray *datas =
            [self returnDatasWithDataDic:result dataKey:@"items" dataModelClass:@"TSProductDataModel" modelClass:@"TSProductModel" dmToModelSelector:@selector(productModelWithDm:) retErr:&retErr];
            
            if( err == nil ) err = retErr;
            completeBlock(datas,err);
//            NSLog(@"***allproudtdata*** %@",datas);
//            NSLog(@"***allproudtdata*** %@",[TSDataProcess sharedDataProcess].userModel.userImgUrl);
        }
    }];
}

- (void)allProductListWithPageIndex:(NSInteger)pageIndex category:(NSString*)category tid:(NSString*)tid completeBlock:(void (^)(NSArray *, NSError *))completeBlock{
    
    NSInteger dataCountOfPage = 20;
    NSInteger startIndex = pageIndex*20;
    NSInteger endIndex = dataCountOfPage + startIndex;
    NSLog(@"self.userModel.userId - %@",self.userModel.userId);
    [self productListWithUserId:self.userModel.userId token:self.userModel.token query:nil category:category collected:nil startIndex:startIndex endIndex:endIndex tid:tid completeBlock:^(NSDictionary *result, NSError *err) {
        if( completeBlock ){
            NSError *retErr = nil;
            NSArray *datas =
            [self returnDatasWithDataDic:result dataKey:@"items" dataModelClass:@"TSProductDataModel" modelClass:@"TSProductModel" dmToModelSelector:@selector(productModelWithDm:) retErr:&retErr];
            
            if( err == nil ) err = retErr;
            completeBlock(datas,err);
//            NSLog(@"***allproudtdata*** %@",datas);
//            NSLog(@"***allproudtdata*** %@",[TSDataProcess sharedDataProcess].userModel.userImgUrl);
        }
    }];
}

- (void)searchWorkWithWord:(NSString*)word pageIndex:(NSUInteger)pageIndex completeBlock:(void (^)(NSArray *, NSError *))completeBlock{
    NSInteger dataCountOfPage = 20;
    NSInteger startIndex = pageIndex*20;
    NSInteger endIndex = dataCountOfPage + startIndex;
    [self productListWithUserId:self.userModel.userId token:self.userModel.token query:word category:nil collected:nil startIndex:startIndex endIndex:endIndex tid:nil completeBlock:^(NSDictionary *result, NSError *err) {
        if( completeBlock ){
            
            NSError *retErr = nil;
            NSArray *datas =
            [self returnDatasWithDataDic:result dataKey:@"items" dataModelClass:@"TSProductDataModel" modelClass:@"TSProductModel" dmToModelSelector:@selector(productModelWithDm:) retErr:&retErr];
            
            if( err == nil ) err = retErr;
            
            completeBlock(datas,err);
        }
    }];
}

-(void)searchWorkWithUserId:(NSString *)userId deviceType:(NSString *)deviceType start:(NSInteger)startIndex count:(NSInteger)count completeBlock:(void (^)(NSArray *, NSError *))completeBlock{
    NSInteger dataCountOfPage = 20;
    //NSInteger startIndex = pageIndex*20;
    NSInteger endIndex = dataCountOfPage + startIndex;
    [self productListWithUserId:self.userModel.userId deviceType:@"3" startIndex:0 count:20 completeBlock:^(NSDictionary *result, NSError *err) {
        
    }];
}


- (void)myOnlineWorkListWithPageIndex:(NSUInteger)pageIndex isPublic:(BOOL)isPublic type:(NSInteger)type completeBlock:(void (^)(NSArray *, NSError *))completeBlock{
    NSInteger dataCountOfPage = 20;
    NSInteger startIndex = pageIndex*20;
    NSInteger endIndex = dataCountOfPage + startIndex;

    if( self.userModel == nil ){
        if( completeBlock ){

            NSError *err = nil;//[KError errorWithCode:KErrorCodeDefault msg:@"您尚未登录，请登录"];
            completeBlock(nil,err);
        }

        return;
    }

    TSUserModel *um = self.userModel;
    NSDictionary *dic = @{@"userId":um.userId,@"token":um.token,
                          @"category":@"",@"type":@(type),
                          @"start":@(startIndex),@"count":@(endIndex),
                          @"deviceType":@"3",@"isPublic":isPublic?@"true":@"false",
                          @"collected":@"0"};
    
    [self postWithInterfaceName:@"/product/SyPic360/findPageMySyPic360s" parameters:dic result:^(NSDictionary *result, NSError *err) {
        if( completeBlock ){
            NSLog(@"mywork -- %@",result);
            NSError *retErr = nil;
            if( err == nil ){
                retErr =
                [self returnErrorWithResult:result];
            }
            NSArray *datas = nil;
            if( retErr == nil ){
                datas =
                [self returnDatasWithDataDic:result dataKey:@"items" dataModelClass:@"TSProductDataModel" modelClass:@"TSProductModel" dmToModelSelector:@selector(productModelWithDm:) retErr:&retErr];
            }
//            if( err == nil ) err = retErr;
            
            completeBlock(datas,retErr);
        }
    }];
}

- (void)myCollectWorkListWithPageIndex:(NSUInteger)pageIndex completeBlock:(void (^)(NSArray *, NSError *))completeBlock{
    NSInteger dataCountOfPage = 20;
    NSInteger startIndex = pageIndex*20;
    NSInteger endIndex = dataCountOfPage + startIndex;
    
    if( self.userModel == nil ){
        if( completeBlock ){
            NSError *err = nil;//[KError errorWithCode:KErrorCodeDefault msg:@"您尚未登录，请登录"];
            completeBlock(nil,err);
        }
        
        return;
    }
    
    [self productListWithUserId:self.userModel.userId token:self.userModel.token query:nil category:nil collected:@(YES).stringValue startIndex:startIndex endIndex:endIndex tid:nil completeBlock:^(NSDictionary *result, NSError *err) {
        if( completeBlock ){
            
            NSError *retErr = nil;
            if( err == nil ){
                retErr =
                [self returnErrorWithResult:result];
            }
            NSArray *datas = nil;
            if( retErr == nil ){
                datas =
                [self returnDatasWithDataDic:result dataKey:@"items" dataModelClass:@"TSProductDataModel" modelClass:@"TSProductModel" dmToModelSelector:@selector(productModelWithDm:) retErr:&retErr];
            }
//            if( err == nil ) reerr = retErr;
            
            completeBlock(datas,retErr);
        }
    }];
}

/**
 作品查询接口

 @param userId 用户id
 @param token 用户令牌
 @param category 表示类别条件，如果为全部类别，则该字段设为空串，或不设置
 @param queryStr 为查询条件，如不指定，则为全部公开记录
 @param collected 如果为true，表示只检索我收藏/关注过的作品，否则为全部作品，默认为false
  start 为记录的开始位置，默认为0，
  count 为从`start`位置开始，最多取的记录数量,默认为20，
 */
- (void)productListWithUserId:(NSString*)userId token:(NSString*)token query:(NSString*)queryStr category:(NSString*)category collected:(NSString*)collected startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex tid:(NSString*)tid completeBlock:(void(^)(NSDictionary*,NSError*))completeBlock{

    if( userId==nil ){
        userId = @"";
    }
    
    if( token == nil ){
        token = @"";
    }
    
    if( category == nil ) category = @"";
    if( queryStr == nil ) queryStr = @"";
    if( collected ==nil ) collected = @(NO).stringValue;
    if (tid == nil) tid = @"";

    NSDictionary *dic = @{@"userId":userId,@"deviceType":@"3",@"start":@(startIndex),@"count":@(endIndex),@"category":category,@"collected":@(collected.boolValue),@"query":queryStr,@"tid":tid};
    
    
    [self postWithInterfaceName:@"/product/ImageWord/findPageSyPic360Excs" parameters:dic result:^(NSDictionary *result, NSError *error) {
        //NSLog(@"***productList*** %@",result);
        if( completeBlock ){
            completeBlock(result,error);
        }
    }];
}

- (void)productListWithUserId:(NSString*)userId deviceType:(NSString*)deviceType startIndex:(NSInteger)start count:(NSInteger)count completeBlock:(void(^)(NSDictionary*,NSError*))completeBlock{
    NSLog(@"----");
}


- (void)releaseWorkWithImgs:(NSArray<UIImage *> *)imgs video:(NSURL*)videoUrl isVideoWork:(BOOL)isVideoWork recordBase64Data:(NSData *)recordData parameters:(NSDictionary *)para completeBlock:(void (^)(NSError *))completeBlock{
    id obj = imgs;
    if( isVideoWork ) obj = videoUrl;
    if( para == nil || obj == nil){
        NSError *err = nil;
        [self configErrWithDic:nil err:&err];
        if( completeBlock ) {
            completeBlock(err);
        }
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/product/services/SyPic360/uploadDoneSyPics",TSConstantServerUrl];

    if( isVideoWork ){
        [self.httpRequest uploadVideo:videoUrl url:url parameters:para completeBlock:^(NSError *err, NSDictionary *dic) {
            NSError* returnErr = err;
            if( completeBlock ){
                completeBlock(returnErr);
            }
        }];
    }else{
        [self.httpRequest uploadImgs:imgs url:url parameters:para completeBlock:^(NSError *err,NSDictionary*dataDic) {
            NSError* returnErr = err;
            if( completeBlock ){
                completeBlock(returnErr);
            }
        }];
    }
}

- (void)praiseOrCancle:(BOOL)isPraise workId:(NSString *)workId completeBlock:(void (^)(NSError *))completeBlock{
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"pid",@"uid",@"token",@"deviceType"] values:workId,self.userModel.userId,self.userModel.token,@"3", nil];
    NSString *name = @"/product/SyPic360/cancelPraise";
    if( isPraise ){
        name = @"/product/SyPic360/praise";
    }
    [self requestWithJSONParameters:dic urlName:name result:^(NSDictionary *data, NSError *err) {
        if( completeBlock){
            completeBlock(err);
        }
    }];
}



- (void)collectOrCancle:(BOOL)isCollect workId:(NSString *)workId completeBlock:(void (^)(NSError *))completeBlock{
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"pid",@"uid",@"token",@"deviceType"] values:workId,self.userModel.userId,self.userModel.token,@"3", nil];
    NSString *name = @"/product/api/user/cancelCollect";
    if( isCollect ){
        name = @"/product/api/user/collect";
    }
    [self requestWithParameters:dic urlName:name result:^(NSDictionary *data, NSError *err) {
        if( completeBlock){
            completeBlock(err);
        }
    }];
}


- (void)deleteWorkWithId:(NSString *)workId completeBlock:(void (^)(NSError *))completeBlock{
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"id",@"uid",@"token",@"deviceType"] values:workId,self.userModel.userId,self.userModel.token,@"3", nil];
//    NSString *name = @"/services/Member/deleteSyPic";
    NSString *name = @"/product/SyPic360/deleteSyPic";
    [self requestWithJSONParameters:dic urlName:name result:^(NSDictionary *data, NSError *err) {
        if( completeBlock){
            completeBlock(err);
        }       
    }];
}

- (void)downLoadWorkVideoWithUrl:(NSString *)videoUrl completeBlock:(void (^)(NSString *, NSError *))completeBlock{
    NSString *path = [self getTmpDocWithSuffix:@"workVideo"];
    if( path ){
        path = [path stringByAppendingPathComponent:@"workVideo.mp4"];
    }
    [self.httpRequest downloadFileAsync:videoUrl saveAllPath:path downloadingBlock:nil completeBlock:^(NSError *err) {
        if( completeBlock ){
            completeBlock(path,err);
        }
    }];
}
    
//根据Url，读取本地缓存的图片
-(void)loadLocalImgWithUrls:(NSArray*)imgUrls completeBlock:(void (^)(NSArray<UIImage*> *,NSError*))completeBlock{
    
    if( !imgUrls || [imgUrls isKindOfClass:[NSArray class]]==NO ){
        if( completeBlock){
            completeBlock(nil,[KError errorWithCode:KErrorCodeDefault msg:@"文件不存在"]);
        }
        return;
    }
    
    NSString *savePath = [[self dataBase] getImgCacheDir];//NSTemporaryDirectory();
    NSString *rootPath = savePath;
    NSString *tailStr = @"";
    NSString *prefix = [TSHelper productImgUrlPrefix];
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:imgUrls.count];
    for( NSString *urlStr in imgUrls ){
        NSString *imgUrl = urlStr;
        if( imgUrl ){
            imgUrl = [[TSHelper productImgUrlPrefix] stringByAppendingString:imgUrl];
        }
        if( [imgUrl containsString:prefix]){
            tailStr = [imgUrl substringFromIndex:prefix.length];
            NSInteger toidx = -1;
            NSString *lastStr = [tailStr lastPathComponent];
            if( lastStr.length ){
                toidx = [tailStr rangeOfString:lastStr].location;
            }
            if( toidx > 0 )
            tailStr = [tailStr substringToIndex:toidx];
            
            if( tailStr.length ){
                savePath = [rootPath stringByAppendingPathComponent:tailStr];
            }
        }
        
        NSString *imgFilePath = [savePath stringByAppendingPathComponent:[imgUrl lastPathComponent]];
        NSFileManager *fm = [NSFileManager defaultManager];
        UIImage *img = nil;
        if( [fm fileExistsAtPath:imgFilePath] ){
            img =
            [UIImage imageWithContentsOfFile:imgFilePath];
        }
        
        if( img ){
            [arr addObject:img];
        }
    }
    if( completeBlock ){
        if( arr.count != imgUrls.count ){
            arr = nil;
        }
        completeBlock(arr,nil);
    }
}

- (void)waterMarkImgsWithCompleteBlock:(void (^)(NSArray *, NSArray*, NSError *))completeBlock{
    NSString *urlName = @"/user/services/Member/findAllWaterMark";

    NSDictionary *dic = @{@"uid":self.userModel.userId,
                          @"deviceType":@"3",
                          @"token":self.userModel.token};
    [self requestWithParameters:dic urlName:urlName result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            NSMutableArray *urls = nil;
            NSMutableArray *models = nil;
            if( [data isKindOfClass:[NSDictionary class]] ){
                NSArray *list = data[@"list"];
                urls = [NSMutableArray new];
                models = [NSMutableArray new];
                for( NSDictionary *imgDic in list ){
                    
                    TSWatermarkImgModel *im = [TSWatermarkImgModel waterMarkModelWithDic:imgDic];
                    if( im ){
                        
                        if( im.url ){
                            [urls addObject:im.url];
                        }
                        
                        [models addObject:im];
                    }
                }
            }
            if( urls.count == 0 ) urls = nil;
            if( models.count ==0 ) models = nil;
            
            completeBlock(urls, models,err);
        }
    }];
}

- (void)deleteWatermarkImgWithId:(NSString *)waterMarkId completeBlock:(void (^)(NSError *))completeBlock{
    NSString *urlName = @"/user/services/Member/deleteWaterMark";
    NSDictionary *dic = @{@"uid":self.userModel.userId,
                          @"deviceType":@"3",@"id":waterMarkId,
                          @"token":self.userModel.token};
    [self requestWithJSONParameters:dic urlName:urlName result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            completeBlock(err);
        }
    }];
}

- (void)addWatermarkWithImg:(UIImage *)img completeBlock:(void (^)(id, NSError *))completeBlock{
    NSDictionary *para = @{
                           @"uid":self.userModel.userId,
                           @"deviceType":@"3",
                           @"token":self.userModel.token,
                           };
    NSString *urlName = @"/user/services/Member/uploadAddWaterMark";
    NSString *url = [NSString stringWithFormat:@"%@%@",_serverUrl,urlName];
//    NSLog(@"水印时token -- %@",self.dataProcess.userModel.token);
    [self.httpRequest uploadWaterMarkImg:img url:url parameters:para completeBlock:^(NSDictionary *dic,NSError *err) {
        NSLog(@"dic");
        if( completeBlock ){
            completeBlock(nil,err);
        }
    }];
//    [self.dataProcess.httpRequest uploadWaterMarkImg:photos[0] url:@"http://www.aipp3d.com/services/Member/uploadAddWaterMark" parameters:para completeBlock:^(NSError *err) {
//        if
}

- (void)otherUserWorkWithUserId:(NSString*)otherUserId pageNum:(NSInteger)pageNum completeBlock:(void (^)(NSArray *, NSError *))completeBlock{
    
    NSDictionary *dic = @{@"userId":otherUserId,@"deviceType":@"3",@"start":@(pageNum),@"count":@(20)};
    if( self.userModel.userId && dic){
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        tempDic[@"currentId"] = self.userModel.userId;
        tempDic[@"token"] = self.userModel.token;
        dic = tempDic;
    }
    
    [self postWithInterfaceName:@"/product/SyPic360/findPageUserSyPic360s" parameters:dic result:^(NSDictionary *result, NSError *err) {
        if( completeBlock ){
            NSError *retErr = nil;
            NSArray *datas =
            [self returnDatasWithDataDic:result dataKey:@"items" dataModelClass:@"TSProductDataModel" modelClass:@"TSProductModel" dmToModelSelector:@selector(productModelWithDm:) retErr:&retErr];
            
            if( err ) retErr = err;
            completeBlock(datas,retErr);
        }
    }];
}

- (void)updateWorkStateWithPublic:(BOOL)isPublic workId:(NSString *)wid completeBlock:(void (^)(NSError *))completeBlock{
    
    NSDictionary *dic = @{@"pid":wid,@"deviceType":@"3",
                          @"level":isPublic?@"1":@"0"};
    [self postWithInterfaceName:@"/product/SyPic360/updateLevel" parameters:dic isNeedAnalysisReturnData:YES result:^(NSDictionary *result, NSError *error) {
        if( completeBlock ){
            completeBlock(error);
        }
    }];
}

- (void)getPrivateWorkSharePwdWithWorkId:(NSString *)wid completeBlock:(void (^)(NSString *, NSError *))completeBlock{
    NSDictionary *dic = @{@"pid":wid};
    [self postWithInterfaceName:@"/product/SyPic360/updatePassword" parameters:dic isNeedAnalysisReturnData:YES result:^(NSDictionary *result, NSError *error) {
        if( error == nil ){
            
            NSString *url = @"/product/SyPic360/code?pid=%@";
            url = [NSString stringWithFormat:url,wid];
            [self getWithInterfaceName:url para:@{} resultBlock:^(NSDictionary *dic, NSError *e) {
                if( e == nil ){
                    NSError *err = e;
                    if( completeBlock ){
                        NSString *pwd = nil;
                        if( [dic isKindOfClass:[NSDictionary class]] ){
                            pwd = [NSString stringWithObj:dic[@"password"]];
                        }
                        
                        completeBlock(pwd,err);
                    }
                }
            }];
            
        }else{
            if( completeBlock ){
                completeBlock(nil,error);
            }
        }
    }];
}

- (void)canclePrivateWorkSharePwdWithWorkId:(NSString *)wid completeBlock:(void (^)(NSError *))completeBlock{
    NSDictionary *dic = @{@"pid":wid};
   [self postWithInterfaceName:@"/product/SyPic360/cancelPassword" parameters:dic isNeedAnalysisReturnData:YES result:^(NSDictionary *result, NSError *error) {
       if( completeBlock ){
           completeBlock(error);
       }
   }];
}

#pragma mark - 上传至莱搭平台
- (void)uploadWorkToLaidaWithWorkId:(NSString*)wid userName:(NSString*)un pwd:(NSString*)pwd completeBlock:(void (^)(NSArray *, NSError *))completeBlock{
    
    NSDictionary *dic = @{@"pid":wid,@"deviceType":@"3",
                          @"username":un,@"password":pwd};
 
    [self postWithInterfaceName:@"/product/SyPic360/laida" parameters:dic isNeedAnalysisReturnData:YES result:^(NSDictionary *result, NSError *err) {
         if( completeBlock ){
             completeBlock(nil,err);
         }
     }];
}

#pragma mark - 退底部分

/**
 上传原图至服务器，开始退底
 
 @param imgs 原图。拍摄的原图，未经编辑过的
 @param completeBlock 回调
 */
//- (void)startClearBgWithWorkImgs:(NSArray<UIImage*>*)imgs completeBlock:(void(^)(NSError *err,NSString *clearBgId))completeBlock{
//    NSDictionary *para = [NSDictionary dictionaryWithKeys:@[@"cellphone",@"token"] values:self.userModel.phone/*userId*/,self.userModel.token, nil];
//    if( para == nil || imgs == nil){
//        NSError *err = nil;
//        [self configErrWithDic:nil err:&err];
//        if( completeBlock ) {
//            completeBlock(err,nil);
//        }
//        return;
//    }
//    
//    NSString *url = [NSString stringWithFormat:@"%@api/pic/segment",TSConstantServerUrl];
//    
//    [self.httpRequest uploadImgs:imgs url:url parameters:para completeBlock:^(NSError *err,NSDictionary*result) {
//        NSError* returnErr = err;
//        
//        if( completeBlock ){
//            NSString *cid = nil;
//            if( [result isKindOfClass:[NSDictionary class]] ){
//                NSString *clearId = [NSString stringWithObj:result[@"id"]];
//                cid = clearId;
//            }
//            if( cid == nil && err == nil ){
//                returnErr = [KError errorWithCode:KErrorCodeDefault msg:@"上传退底图片失败"];
//            }
//
//            completeBlock(returnErr,cid);
//        }
//    }];
//}

//- (void)queryClearBgIsCompleteWithClearId:(NSString *)clearId completeBlock:(void (^)(NSError *, NSArray *,NSString *))completeBlock{
////    http://show.aipp3d.com/api/pic/segment_status/48669226-dd8b-433a-b817-4bd6a70cf091
//    NSString *urlName = @"api/pic/segment_status/";
//    urlName = [NSString stringWithFormat:@"%@%@",urlName,clearId];
//    
//    [self getWithInterfaceName:urlName parametersStr:nil resultBlock:^(NSDictionary *ret, NSError *err) {
//        
//        if( completeBlock ){
//            NSArray *urls = nil;
//            if( [ret isKindOfClass:[NSDictionary class]] ){
//                if( [NSString stringWithObj:ret[@"status"]].integerValue == 1 ){
//                    NSArray *picUrls = ret[@"picUrls"];
//                    if( [picUrls isKindOfClass:[NSArray class]] ){
//                        urls = picUrls;
//                    }
//                }
//            }
//            completeBlock(err,urls,clearId);
//        }
//    }];
//}

- (void)downLoadClearImgWithUrl:(NSString*)url clearId:(NSString*)clearId downloadedImgName:(NSString *)downloadedImgName completeBlock:(void (^)(NSError *,NSString *))completeBlock
{
    
    NSLog(@"____this____");
    if( url == nil ){
        NSError *err = nil;
        [self configErrWithDic:nil err:&err];
        if( completeBlock ) {
            completeBlock(err,nil);
        }
        return;
    }
    
    NSString *savePath = [[self dataBase] getImgCacheDir];//NSTemporaryDirectory();
    NSString *tailStr = @"";
    //TSConstantWorkClearImgMiddUrl
    NSString *prefix = [TSHelper productClearImgUrlPrefix];//productImgUrlPrefix];
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@",prefix,url];
    NSLog(@"下载imgUrl -- %@",imgUrl);
    if( [imgUrl containsString:prefix]){
        tailStr = [imgUrl substringFromIndex:prefix.length];
        NSInteger toidx = -1;
        NSString *lastStr = [tailStr lastPathComponent];
        if( lastStr.length ){
            toidx = [tailStr rangeOfString:lastStr].location;
        }
        if( toidx > 0 )
            tailStr = [tailStr substringToIndex:toidx];
        
        if( tailStr.length ){
            savePath = [savePath stringByAppendingPathComponent:tailStr];
        }
    }
    
//    savePath = [[PPFileManager sharedFileManager] getSanWorkImgPathWithImgAllName:@"abc"];
//    savePath = [savePath substringToIndex:[savePath rangeOfString:@"abc"].location-1];
    
    savePath = [TSHelper maskClearImgPath];//clearedImgWorkPath];
    //下载图名称（遮罩图名称）
    NSString *name = downloadedImgName;//[NSString stringWithFormat:@"%@%lld",clearId,(long long)([NSDate date].timeIntervalSince1970*1000)];
    NSLog(@"savePath -- %@",savePath);
    NSURLSessionDownloadTask *extractedExpr = [self dowloadImg:imgUrl saveImgPath:savePath saveImgName:name completeBlock:^(UIImage *img, NSString *fileAllPath,NSError *err) {
        NSLog(@"imgFilePath -- %@",fileAllPath);
        //NSLog(@"savePath -- %@",savePath);
        if( completeBlock ){
            NSLog(@"complete fileAllPath");
            completeBlock(err,fileAllPath);
        }
    }];
}

//同步去底图
//api/pic/segment_sync
/**
 上传原图至服务器，开始退底
 
 @param imgs 原图。拍摄的原图，未经编辑过的
 @param completeBlock 回调
 */
- (NSURLSessionDataTask*)startSyncClearBgWithWorkImgs:(NSArray<UIImage*>*)imgs completeBlock:(void(^)(NSError *err,NSArray *imgPaths))completeBlock {
    
//    NSString *blename = [[NSUserDefaults standardUserDefaults] objectForKey:@"blename"];
    
    //env传1，不再需要选择设备
    NSString *env = @"1";//@(self.selectedDeviceIndex+1).stringValue;
    //NSDictionary *para = [NSDictionary dictionaryWithKeys:@[@"userId",@"token",@"env"] values:self.userModel.userId,self.userModel.token, env, nil];
    NSDictionary *para = [NSDictionary dictionaryWithKeys:@[@"uid",@"deviceType",@"token",@"env"] values:self.userModel.userId,@"3",self.userModel.token, env, nil];
    if( para == nil || imgs == nil){
        NSError *err = nil;
        [self configErrWithDic:nil err:&err];
        if( completeBlock ) {
            completeBlock(err,nil);
        }
        return nil;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/product/services/SyPic360/segment",TSConstantServerUrl];
    
    return
    [self.httpRequest uploadImgs:imgs url:url parameters:para completeBlock:^(NSError *err,NSDictionary*result) {
        NSError* returnErr = err;
        
        if( completeBlock ){
            
            if( err ){
                completeBlock(err,nil);
                return ;
            }
            
            //NSString *cid = nil;
            if( [result isKindOfClass:[NSDictionary class]] ){
                
                //上传原图后，得到去底ID
                //NSString *clearId = [NSString stringWithObj:result[@"id"]];
               // cid = clearId;
                
                //上传原图后，得到遮罩图的url
                //NSArray *picUrls = result[@"picUrls"];
                NSArray *picUrls = result[@"list"];
                NSLog(@"pictureUrls -- %@",picUrls);
                //如果返回的图片数据不正确，则提示上传原图失败
                if( [picUrls isKindOfClass:[NSArray class]] ==NO/* ||
                   [clearId isKindOfClass:[NSString class]] == NO*/){
                    returnErr = [KError errorWithCode:-1 msg:@"上传去底图片失败"];
                    completeBlock(returnErr,nil);
                }
                
                //得到遮罩图Url，则下载所有遮罩图clearImgPaths
                else
                {
                    NSMutableArray *clearImgPaths = [NSMutableArray new];
                    [self downloadClearImgWithClearId:nil imgUrls:picUrls idx:0 completeBlock:^{
                        
                        completeBlock(returnErr,clearImgPaths);
                        NSLog(@"clearimgPaths -- %@",clearImgPaths);
                        
                    } imgPaths:clearImgPaths];
                }
            }else{
                completeBlock(returnErr,nil);
            }
        }
    }];
}


/**
 递归下载所有照片

 @param clearId 作品的退底id
 @param imgUrls 遮罩图片url
 @param idx 下载的图片索引，从 0开始
 @param completeBlock 回调
 @param imgPaths 存储下载完的遮罩图片的路径
 */
- (void)downloadClearImgWithClearId:(NSString*)clearId imgUrls:(NSArray*)imgUrls idx:(NSUInteger)idx completeBlock:(void(^)(void))completeBlock imgPaths:(NSMutableArray*)imgPaths{
    
    if( idx == 0 ){
        NSLog(@"imgurls===%@",imgUrls[idx]);
        
        //刚开始下载图片。则清除之前的图片
        NSString * savePath = [TSHelper maskClearImgPath];//clearedImgWorkPath];
        //退底的图片
        NSFileManager *fm = [NSFileManager defaultManager];
        if( [fm fileExistsAtPath:savePath] ){
            [fm removeItemAtPath:savePath error:nil];
        }
        
        [fm createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if( idx == imgUrls.count ){
        if( completeBlock ){
            completeBlock();
        }
        
        return;
    }
    
    NSString *url = nil;
    if( imgUrls.count > idx ){
        url = imgUrls[idx];
        NSLog(@"~~imgurls===%@",imgUrls[idx]);
    }
    
    //得到遮罩图名称
    NSString *maskImgName = [TSHelper getSaveWorkImgNameAtIndex:idx];
    NSString *ext = maskImgName.pathExtension;
    if( ext ){
        NSInteger toIdx = [maskImgName rangeOfString:ext].location-1;
        if( toIdx > 0 )
            maskImgName = [maskImgName substringToIndex:toIdx];
    }
    NSLog(@"maskImgName -- %@",maskImgName);
    [self downLoadClearImgWithUrl:url clearId:nil downloadedImgName:maskImgName completeBlock:^(NSError *err, NSString *imgAllPath) {
        
        NSLog(@"igAllPath -- %@",imgAllPath);
        if( [TSHelper sharedHelper].isCancleClearBg ){
            //取消了退底
            return;
        }
        
        if( imgAllPath ){
            [imgPaths addObject:imgAllPath];
            //NSLog(@"~~imgPaths%@===",imgPaths[idx]);
            NSLog(@"~~imgPaths%@===",imgPaths);
        }
        
        [self downloadClearImgWithClearId:clearId imgUrls:imgUrls idx:idx+1 completeBlock:completeBlock imgPaths:imgPaths];
    }];
}

#pragma mark - Find
- (NSURLSessionDataTask *)findTypeDatasWithCompleteBlock:(void (^)(NSError *, NSArray *))completeBlock{
    
    return
    [self requestWithParameters:@{} urlName:@"/index/NewType/select" result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            NSArray *datas = nil;
            if( [data isKindOfClass:[NSDictionary class]] ){
                NSArray *list = data[@"list"];
                if( [list isKindOfClass:[NSArray class]] ){
                    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:list.count];
                    for( NSDictionary *dic in list ){
                        TSFindTypeModel *tm = [TSFindTypeModel findTypeModelWithDic:dic];
                        if( tm ){
                            [arr addObject:tm];
                        }
                    }
                    
                    if( arr.count ){
                        datas = arr;
                    }
                }
            }
            
            completeBlock(err,datas);
        }
    }];
}

- (NSURLSessionDataTask *)findListWithTypeId:(NSString *)typeId pageNum:(NSInteger)pageNum completeBlock:(void (^)(NSError *, NSArray *))completeBlock{
    //http://www.aipp3d.com/ImageWord/findImageNew?tid=30&currentPage=1&pageSize=10&newtype=62&draft=0&search=
//    NSString *urlFormat = @"/ImageWord/findImageNew?tid=30&currentPage=%@&pageSize=10&newtype=%@&draft=0&search=";
//    NSString *urlName = [NSString stringWithFormat:urlFormat,@(pageNum+1).stringValue,typeId];
    NSDictionary *para = [NSDictionary dictionaryWithKeys:@[@"pageNum",@"typeId",@"pageSize"] values:@(pageNum+1).stringValue,typeId,@"10", nil];
    return [self requestWithJSONParameters:para urlName:@"/index/news/getListInfo" result:^(NSDictionary *data, NSError *err) {

        if( completeBlock ){
            NSArray *datas = nil;
            if( [data isKindOfClass:[NSDictionary class]] ){
                NSArray *list = data[@"list"];
                if( [list isKindOfClass:[NSArray class]] ){
                    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:list.count];
                    for( NSDictionary *dic in list ){
                        TSFindModel *tm = [TSFindModel findModelWithDic:dic];
                        if( tm ){
                            [arr addObject:tm];
                        }
                    }

                    if( arr.count ){
                        datas = arr;
                    }
                }
            }

            completeBlock(err,datas);
        }
    }];
}

- (id)findDetailIdWithNewsId:(NSString *)newsId completeBlock:(void (^)(NSError *, NSString *))completeBlock{
    NSDictionary *para = [NSDictionary dictionaryWithKeys:@[@"newsId"] values:newsId, nil];
    return
    [self requestWithParameters:para urlName:@"/index/news/get" result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            NSString *did = nil;
            if( [data isKindOfClass:[NSDictionary class]] ){
                did = [NSString stringWithObj:data[@"id"]];
            }
            NSError *error = err;
            if( did == nil ){
                error = [KError errorWithCode:-1 msg:@"获取文章失败"];
            }
            completeBlock(error,did);
        }
    }];
}

#pragma mark - 在线服务以及消息

/**
 * 用户消息的数量
 */
- (void)userMsgCountWithCompleteBlock:(void(^)(NSError*err, NSInteger count))completeBlock{
    
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"userId",@"token"] values:self.userModel.userId,self.userModel.token,nil];
    
    NSString *name = @"/product/SyPic360Segment/getNoticeNumber";
    
    [self getWithInterfaceName:name para:dic resultBlock:^(NSDictionary *dic, NSError *err) {
        if( completeBlock ){
            NSInteger cnt = 0;
            if( [dic isKindOfClass:[NSDictionary class]] ){
                NSString *num = [NSString stringWithObj:dic[@"noticeNumber"]];
                if( num ){
                    cnt = num.integerValue;
                }
            }
            completeBlock(err,cnt);
        }
    }];
}

/**
 修改所有消息为已读
 */
- (void)modifyMsgStatusIsReadedWithCompleteBlock:(void(^)(NSError*err))completeBlock{
    
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"userId",@"token"] values:self.userModel.userId,self.userModel.token,nil];
    
    NSString *name = @"/product/SyPic360Segment/updateNoticeStatus";
    
    [self getWithInterfaceName:name para:dic resultBlock:^(NSDictionary *dic, NSError *err) {
        if( completeBlock ){
            completeBlock(err);
        }
    }];
}

- (void)startOnlineServiceWithWorkId:(NSString*)wid des:(NSString*)des workImgUrl:(NSString*)workImgUrl completeBlock:(void(^)(NSError*err))completeBlock{
    if( des == nil ) des = @"";
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"pid",@"uid",@"token",@"deviceType",@"picture", @"description"] values:wid,self.userModel.userId,self.userModel.token,@"3", workImgUrl, des,nil];
    
    NSString *name = @"/product/SyPic360Segment/addSyPic360Segment";
    
    [self requestWithJSONParameters:dic urlName:name result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            completeBlock(err);
        }
    }];
}

- (void)onlineServiceWorkListWithUserNameOrWorkName:(NSString*)name type:(NSInteger)type pageNum:(NSInteger)pageNum completeBlock:(void(^)(NSError*err, NSArray *datas))completeBlock{
    NSString *status = nil;
    if( type == 0 ){
        status = @"0";
    }else if( type == 1 ){
        status = @"3";
    }
    NSDictionary *dic = [NSDictionary dictionaryWithKeys:@[@"currentPage",@"pageSize",@"userId",@"token",@"deviceType"] values:@(pageNum).stringValue,@"10",self.userModel.userId,self.userModel.token,@"3",nil];
    if( dic ){
        NSMutableDictionary *tempdic = [NSMutableDictionary dictionaryWithDictionary:dic];
        if( name )
            tempdic[@"search"] = name;
        if( status )
            tempdic[@"status"] = status;
        
        dic = tempdic;
    }
    
    NSString *urlname = @"/product/SyPic360Segment/findPageSyPic360Segments";
    
    [self requestWithParameters:dic urlName:urlname result:^(NSDictionary *data, NSError *err) {
        if( completeBlock ){
            
            NSError *retErr = nil;
            NSArray *datas =
            [self returnDatasWithDataDic:data dataArrKey:@"list" modelClass:@"TSNoticeModel" dicToModelSelector:@selector(noticeModelWithDic:) retErr:&retErr modelBlock:^(id model) {
                
            }];
            
//            [self returnDatasWithDataDic:result dataKey:@"list" dataModelClass:@"TSProductDataModel" modelClass:@"TSProductModel" dmToModelSelector:@selector(productModelWithDm:) retErr:&retErr];
            
            if( err == nil ) err = retErr;
            
            completeBlock(retErr,datas);
        }
    }];
}

#pragma mark - Private

- (NSURLSessionDataTask*)getWithInterfaceName:(NSString*)interfaceName parameters:(NSDictionary*)dic result:(void(^)(NSDictionary*result,NSError *error))resultBlock{
    return [self getWithInterfaceName:interfaceName parameters:dic isNeedAnalysisReturnData:NO result:resultBlock];
}

- (NSURLSessionDataTask*)getWithInterfaceName:(NSString*)interfaceName parameters:(NSDictionary*)dic noNeedDataResult:(void(^)(NSString *))resultBlock{
    return
    [self getWithInterfaceName:interfaceName parameters:dic result:^(NSDictionary *result, NSError *error) {
        if( resultBlock ){
            NSString *msg = nil;
            if( error ){
                msg = [KError errorMsgWithError:error];
            }
            resultBlock(msg);
        }
    }];
}

/**
 get方法

 @param interfaceName 接口名
 @param para 参数值
 @return datatask
 */
- (NSURLSessionDataTask*)getWithInterfaceName:(NSString*)interfaceName para:(NSDictionary*)para resultBlock:(void(^)(NSDictionary *, NSError *))resultBlock{
    
    return [self getWithInterfaceName:interfaceName parameters:para isNeedAnalysisReturnData:YES result:resultBlock];
}

- (NSURLSessionDataTask*)getWithInterfaceName:(NSString*)interfaceName parameters:(NSDictionary*)dic isNeedAnalysisReturnData:(BOOL)needAnalysis result:(void(^)(NSDictionary*result,NSError *error))resultBlock{
    
    NSString *url =[NSString stringWithFormat:@"%@%@",_serverUrl,interfaceName];

    return
    [self.httpRequest get:url parameters:dic resultBlock:^(NSDictionary *result, NSError *err) {
        
//        NSLog(@"\n\n请求完成\n\nRequestUrl:\n%@\n\nRequestPara:\n%@\n\nRequestData:\n%@\n\nRequestError:\n%@\n\n",url,dic,result,err);
        NSDictionary *data = result;
        NSError *returnErr = err;
        if( needAnalysis ){
            NSString *errMsg = nil;

            NSInteger errCode = 0;
            data = nil;
            returnErr = nil;
            if( err || ![result isKindOfClass:[NSDictionary class]] ){
                errMsg = @"数据异常，请重试~";
                errCode = err.code;
                returnErr = [KError errorWithCode:errCode msg:errMsg];
            }
            else{
                returnErr = [self returnErrorWithResult:result];
                if( !returnErr ){
                    data = [self returnDataWithResult:result];
                }
            }
        }
        if( resultBlock ){
            resultBlock(data,returnErr);
        }
    }];
}

- (NSURLSessionDataTask*)postWithInterfaceName:(NSString*)interfaceName parameters:(NSDictionary*)dic result:(void(^)(NSDictionary*result,NSError *error))resultBlock{
    return [self postWithInterfaceName:interfaceName parameters:dic isNeedAnalysisReturnData:NO result:resultBlock];
}

/**
 根据是否需要解析返回数据，请求服务器
 
 @param interfaceName 接口名字
 @param dic 参数
 @param needAnalysis 是否需要解析返回的数据
 @param resultBlock a
 @return a
 */
- (NSURLSessionDataTask*)postWithInterfaceName:(NSString*)interfaceName parameters:(NSDictionary*)dic isNeedAnalysisReturnData:(BOOL)needAnalysis result:(void(^)(NSDictionary*result,NSError *error))resultBlock{
    
    NSString *url =[NSString stringWithFormat:@"%@%@",_serverUrl,interfaceName];

    return
    [self.httpRequest post:url parameters:dic resultBlock:^(NSDictionary *result, NSError *err) {
        
//        NSLog(@"\n\n请求完成:\n\nRequestUrl:\n%@\n\nRequestPara:\n%@\n\nRequestData:\n%@\n\nRequestError:\n%@\n\n",url,dic,result,err);
        NSDictionary *data = result;
        NSError *returnErr = err;
        if( needAnalysis ){
            NSString *errMsg = nil;

            NSInteger errCode = 0;
            data = nil;
            returnErr = nil;
            if( err || ![result isKindOfClass:[NSDictionary class]] ){
                errMsg = @"数据异常，请重试~";
                errCode = err.code;
                returnErr = [KError errorWithCode:errCode msg:errMsg];
            }
            else{
                returnErr = [self returnErrorWithResult:result];
                if( !returnErr ){
                    data = [self returnDataWithResult:result];
                }
            }
        }
        if( resultBlock ){
            resultBlock(data,returnErr);
        }
    }];
}

- (NSURLSessionDataTask*)postWithJSONInterfaceName:(NSString*)interfaceName parameters:(NSDictionary*)dic isNeedAnalysisReturnData:(BOOL)needAnalysis result:(void(^)(NSDictionary*result,NSError *error))resultBlock{
    
    NSString *url =[NSString stringWithFormat:@"%@%@",_serverUrl,interfaceName];
    
    return
    [self.httpRequest postJSON:url parameters:dic resultBlock:^(NSDictionary *result, NSError *err) {
        NSDictionary *data = result;
        NSError *returnErr = err;
        
        NSLog(@"\n\n请求完成\n\nRequestUrl:\n%@\n\nRequestPara:\n%@\n\nRequestData:\n%@\n\nRequestError:\n%@\n\n",url,dic,result,err);
        
        if( needAnalysis ){
            NSString *errMsg = nil;
            
            NSInteger errCode = 0;
            data = nil;
            returnErr = nil;
            if( err || ![result isKindOfClass:[NSDictionary class]] ){
                errMsg = @"数据异常，请重试~";
                errCode = err.code;
                returnErr = [KError errorWithCode:errCode msg:errMsg];
            }
            else{
                returnErr = [self returnErrorWithResult:result];
                if( !returnErr ){
                    data = [self returnDataWithResult:result];
                }
            }
        }
        if( resultBlock ){
            resultBlock(data,returnErr);
        }
    }];
}

/**
 不需要返回数据的请求！ 只需知道是否成功即可
 
 @param interfaceName 接口名
 @param dic 参数，可为空
 @param resultBlock 是否成功的回调
 @return NSURLSessionDataTask 实例
 */
- (NSURLSessionDataTask*)postWithInterfaceName:(NSString*)interfaceName parameters:(NSDictionary*)dic noNeedDataResult:(void(^)(NSString *))resultBlock{
    return
    [self postWithInterfaceName:interfaceName parameters:dic result:^(NSDictionary *result, NSError *error) {
        if( resultBlock ){
            NSString *msg = nil;
            if( error ){
                msg = [KError errorMsgWithError:error];
            }
            resultBlock(msg);
        }
    }];
}

#pragma mark - Request请求使用如下方法
- (NSURLSessionDataTask*)requestWithParameters:(NSDictionary*)para urlName:(NSString *)urlName result:(void(^)(NSDictionary*data,NSError *err))resultBlock{
    
    return
    [self requestWithParameters:para urlName:urlName isNeedAnalysisReturnData:YES result:resultBlock];
}

- (NSURLSessionDataTask*)requestWithJSONParameters:(NSDictionary*)para urlName:(NSString *)urlName result:(void(^)(NSDictionary*data,NSError *err))resultBlock{
    
    return
    [self requestWithJSONParameters:para urlName:urlName isNeedAnalysisReturnData:YES result:resultBlock];
}

/**
 请求数据，根据接口名和是否需要解析结果数据,会验证参数是否为空
 
 @param para a
 @param urlName a
 @param needAnalyiss a
 @param resultBlock a
 @return a
 */
- (NSURLSessionDataTask*)requestWithParameters:(NSDictionary*)para urlName:(NSString *)urlName isNeedAnalysisReturnData:(BOOL)needAnalyiss result:(void(^)(NSDictionary*data,NSError *err))resultBlock{
    
    if( [para isKindOfClass:[NSDictionary class]] == NO ){
        if( resultBlock ){
            NSError *err = nil;
            [self  configErrWithDic:nil err:&err];
            resultBlock(nil, err);
        }
        
        return nil;
    }
    
    return [self postWithInterfaceName:urlName parameters:para isNeedAnalysisReturnData:needAnalyiss result:resultBlock];
}

- (NSURLSessionDataTask*)requestWithJSONParameters:(NSDictionary*)para urlName:(NSString *)urlName isNeedAnalysisReturnData:(BOOL)needAnalyiss result:(void(^)(NSDictionary*data,NSError *err))resultBlock{
    
    if( [para isKindOfClass:[NSDictionary class]] == NO ){
        if( resultBlock ){
            NSError *err = nil;
            [self  configErrWithDic:nil err:&err];
            resultBlock(nil, err);
        }
        
        return nil;
    }
    
    return [self postWithJSONInterfaceName:urlName parameters:para isNeedAnalysisReturnData:needAnalyiss result:resultBlock];
}


#pragma mark __返回结果处理

- (NSError*)returnErrorWithResult:(NSDictionary*)result{
    NSError *err = nil;
    NSString *successKey = @"code";
    NSString *successValue = @"success";
    NSString *errMsgKey = @"returnDesc";
    
    NSString *successCodeStr = [NSString stringWithObj:result[successKey]];
    
    if( [successCodeStr isEqualToString:successValue] ){
        return nil;
    }
    else{
        
        if( [NSString stringWithObj:result[@"rtnCode"]].integerValue == 1 ){
            return nil;
        }
        
        NSString *code = result[successKey];
        NSString *msg = result[errMsgKey];
        if( msg==nil ){
            msg = result[@"msg"];
        }
        
        if( msg == nil ){
            msg = result[@"errorMessage"];
        }
        err = [KError errorWithCode:code.integerValue msg:msg];
    }
    
    return err;
}

- (NSDictionary*)returnDataWithResult:(NSDictionary*)result{
    NSString *dataKey = @"data";
    NSDictionary *ret = result[dataKey];
    if( ![ret isKindOfClass:[NSDictionary class]] ){
        return result[@"rtnResult"];
    }
    
    return ret;
}

/**
 *  服务器返回的不常见错误设置
 *
 *  @param dic 服务器返回的结果数据
 */
-(void)configErrWithDic:(NSDictionary*)dic err:(NSError**)err{
    
    NSInteger code =0;
    NSString *des = @"操作失败,请重试";
    if( dic && (dic[@"msg"] || dic[@"messages"] || dic[@"returnDesc"] || dic[@"message"] )){
        des = dic[@"msg"];
        
        if( des == nil ){
            des = dic[@"messages"];
        }
        
        if( des == nil ){
            des = dic[@"returnDesc"];
        }
        
        if( des == nil ){
            des = dic[@"message"];
        }
    }
    
    if( [dic isKindOfClass:[NSDictionary class]] ){
    
        NSNumber *ret = dic[@"code"];
        if( ret && [ret isKindOfClass:[NSNumber class]] ){
            code = ret.integerValue;
            
            if( ret.intValue == 203 ){
                //数据为空
                des = @"暂无数据";
            }
        }

        NSString *retCode = [NSString stringWithObj:dic[@"returnCode"]];
        if( retCode ){
            code = retCode.integerValue;
        }
    }
    if( err ){
        *err = [KError errorWithDomain:KErrorDomainNetwork code:code msg:des];
    }
}


/**
 验证返回的数据是否存在错误
 
 @param result 服务端返回的字典
 @param err 服务端返回的错误
 @return 得到的错误
 */
- (NSError*)getReturnDataErrWithDic:(NSDictionary*)result err:(NSError*)err{
    NSDictionary *data = result;
    NSError *returnErr = err;
    
    NSString *errMsg = nil;
    
    NSInteger errCode = 0;
    data = nil;
    returnErr = nil;
    if( err || ![result isKindOfClass:[NSDictionary class]] ){
        errMsg = @"数据异常，请重试~";
        errCode = err.code;
        returnErr = [KError errorWithCode:errCode msg:errMsg];
    }
    else{
       
        returnErr = [self returnErrorWithResult:result];
    }
    
    return returnErr;
}

- (TSHttpRequest*)httpRequest{
    return [TSHttpRequest sharedHttpRequest];
}

- (TSDataBase*)dataBase{
    return [TSDataBase sharedDataBase];
}

/**
 根据字典获取模型数组，需datamodel类等  其中字典的值为数组
 必须符合改格式的数据 才可调用此方法。另外此方法的
 
 @param data 返回的数据字典
 @param dataKey 数据的key值
 @param dmClass datamodel 的类名
 @param mClass model的类名
 @param dTOmSel dataModel 转Model的方法,该方法由model实现调用
 @param error 错误返回
 @return model的集合
 */
- (NSArray*)returnDatasWithDataDic:(NSDictionary*)data
                           dataKey:(NSString*)dataKey
                    dataModelClass:(NSString*)dmClass
                        modelClass:(NSString*)mClass
                 dmToModelSelector:(SEL)dTOmSel
                            retErr:(NSError**)error{
    
    if( dataKey == nil ) return nil;
    
    NSArray *arr= nil;
    if( *error ==nil ){
//        [self configErrWithDic:nil err:error];

        if( [data isKindOfClass:[NSDictionary class]] ){
            NSDictionary *dataDic = data[@"data"];
            if( ![dataDic isKindOfClass:[NSDictionary class]] ){
                return nil;
            }
            NSArray *datas = data[@"data"][dataKey];
            NSLog(@"datas - %@",datas);
            if( [datas isKindOfClass:[NSArray class]] ){
                arr = [self returnDatasWithDicArr:datas dataModelClass:dmClass modelClass:mClass dmToModelSelector:dTOmSel retErr:error];
            }
        }
    }
    return arr;
}

- (NSArray*)returnDatasWithDicArr:(NSArray*)dicArr
                   dataModelClass:(NSString*)dmClass
                       modelClass:(NSString*)mClass
                dmToModelSelector:(SEL)dTOmSel
                           retErr:(NSError**)error{
    
    NSArray *datas = dicArr;
    if( [datas isKindOfClass:[NSArray class]] ){
        *error = nil;
        NSMutableArray *arr = [NSMutableArray array];
        for( NSDictionary *dic in datas ){
            
            id dm = [NSClassFromString(dmClass) mj_objectWithKeyValues:dic];
            id sm = nil;
            if( [NSClassFromString(mClass) respondsToSelector:dTOmSel] ){
                sm = [NSClassFromString(mClass) performSelector:dTOmSel withObject:dm];
            }
            if( sm ){
                [arr addObject:sm];
            }
        }
        return arr;
    }
    
    return nil;
}

- (NSArray*)returnDatasWithDataDic:(NSDictionary*)data
                        dataArrKey:(NSString*)dataArrKey
                        modelClass:(NSString*)mClass
                dicToModelSelector:(SEL)dTOmSel
                            retErr:(NSError**)error{
    return [self returnDatasWithDataDic:data
                             dataArrKey:dataArrKey
                             modelClass:mClass
                     dicToModelSelector:dTOmSel
                                 retErr:error
                             modelBlock:nil];
}
/**
 根据字典获取模型数组，需model类等
 
 @param data 返回的数据集合的字典
 @param dataArrKey data的key值
 @param mClass model的类名
 @param dTOmSel  dic转Model的方法,该方法由model实现调用
 @param error 错误返回
 @param modelBlock 每个model的block回调
 @return model的集合
 */
- (NSArray*)returnDatasWithDataDic:(NSDictionary*)data
                        dataArrKey:(NSString*)dataArrKey
                        modelClass:(NSString*)mClass
                dicToModelSelector:(SEL)dTOmSel
                            retErr:(NSError**)error
                        modelBlock:(void(^)(id model))modelBlock{
    NSMutableArray *arr= nil;
    if( *error ==nil ){
//        [self configErrWithDic:nil err:error];
        arr = [NSMutableArray array];
        if( [data isKindOfClass:[NSDictionary class]] ){
            NSArray *datas = data[dataArrKey];
            if( [datas isKindOfClass:[NSArray class]] ){
                *error = nil;
                for( NSDictionary *dic in datas ){
                    
                    id sm = nil;
                    if( [NSClassFromString(mClass) respondsToSelector:dTOmSel] ){
                        sm = [NSClassFromString(mClass) performSelector:dTOmSel withObject:dic];
                    }
                    if( sm ){
                        if( modelBlock ){
                            modelBlock(sm);
                        }
                        [arr addObject:sm];
                    }
                }
            }
        }
    }
    return arr;
}

#pragma mark __临时目录
-(NSString*)getTmpDocWithSuffix:(NSString*)pathSuffix{
    if( pathSuffix == nil )
        return pathSuffix;
    
    NSString *docDir = NSTemporaryDirectory();
    NSString *tmpDocDir = [docDir stringByAppendingPathComponent:pathSuffix];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:tmpDocDir] ){
        NSError *err;
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpDocDir withIntermediateDirectories:YES attributes:nil error:&err];
        if( err) {
            return  nil;
        }
    }
    return tmpDocDir;
}

@end
