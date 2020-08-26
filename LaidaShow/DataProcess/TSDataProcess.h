//
//  TSDataProcess.h
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSProductDataModel;
@class TSVersionModel;
@class TSHttpRequest;
@class TSUserModel;
@class TSHelper;
@interface TSDataProcess : NSObject

@property (nonatomic, strong) TSHttpRequest *httpRequest;

@property (nonatomic, strong) TSVersionModel *versionModel;

@property (nonatomic, strong) TSHelper *helper;

+ (TSDataProcess*)sharedDataProcess;

#pragma mark - Common
//下载图片，若本地存在，则从缓存读取
-(NSURLSessionDownloadTask*)dowloadImg:(NSString*)imgUrl completeBlock:(void (^)(UIImage *img,NSError*err))completeBlock;

/**
 下载图片，若本地缓存了，则从缓存读取

 @param imgUrl 图片url
 @param savePath 保存的路径。
 @param saveImgName 文件名，不含有扩展名
 @param completeBlock 回调
 @return 实例
 */
-(NSURLSessionDownloadTask*)dowloadImg:(NSString*)imgUrl saveImgPath:(NSString*)savePath saveImgName:(NSString*)saveImgName completeBlock:(void (^)(UIImage *,NSString *,NSError*))completeBlock;

- (NSError*)returnErrorWithResult:(NSDictionary*)result;

#pragma mark - UserInfo

- (TSUserModel*)userModel;

- (void)modifyUserImg:(UIImage *)headImg completBlock:(void (^)(NSError *))completeBlock;

- (void)modifyUserName:(NSString*)newName completBlock:(void (^)(NSError *))completeBlock;

- (void)modifyPwd:(NSString*)newPwd oldPwd:(NSString*)oldPwd completBlock:(void (^)(NSError *))completeBlock;

- (void)appLastVersionWithCompleteBlock:(void(^)(BOOL isHaveNewVersion,NSString *newVersionNum,  NSError*err))completeBlock;

/**
 用户的建议

 @param cnt 反馈内容
 @param phone 联系方式 ，可不填
 @param completeBlock 回调
 */
- (void)feedbackWithContent:(NSString*)cnt phone:(NSString*)phone completBlock:(void (^)(NSError *))completeBlock;

- (void)openApplicationInAppStore;

- (void)modifyUserSigature:(NSString*)sign completBlock:(void (^)(NSError *))completeBlock;

/// 用户信息,按条件回调
/// @param completeBlock 回调
- (void)userInfoWithCompleteBlock:(void (^)(NSError *))completeBlock;

/// 用户信息是否需要回调
/// @param needCallback YES则回调，NO按条件自动回调
/// @param completeBlock 回调
- (void)userInfoWithNeedCallback:(BOOL)needCallback completeBlock:(void (^)(NSError *))completeBlock;

#pragma mark - DeviceSelect
- (NSArray<NSString*>*)deviceListDatas;

- (void)updateSelectDeviceAtIndex:(NSInteger)idx;
//退底(env对应值)fc-30:1，fc-80:2,vrmake40:3
- (NSInteger)selectedDeviceIndex;

#pragma mark - Login

/**
 第三方登录
 
 @param para 参数字典
 @param completeBlock 回调
 */
- (void)thirdLoginWithPara:(NSDictionary*)para completBlock:(void (^)(NSError *))completeBlock;

/**
 登录

 @param phone 手机号
 @param pwd md5加密后的密码
 @param completeBlock 回调
 */
- (void)loginWithPhone:(NSString*)phone md5Pwd:(NSString*)pwd isCodeLogin:(BOOL)codeLogin completeBlock:(void (^)(NSError*err))completeBlock;
//登出
- (void)logoutWithCompleteBlock:(void (^)(NSError*err))completeBlock;

//获取手机验证码
- (void)verifyCodeWithPhone:(NSString *)phone type:(NSString*)type deviceType:(NSInteger)deviceType completeBlock:(void (^)(NSDictionary*rusult,NSError*err))completeBlock;

//获取邮箱验证码
- (void)verifyCodeWithEmail:(NSString *)email type:(NSInteger)type deviceType:(NSInteger)deviceType completeBlock:(void (^)(NSError*err))completeBlock;

/**
 验证验证码是否有效

 @param phone 手机号
 @param code 验证码
 @param completeBlock 完成回调
 */
- (void)validateCodeWithPhone:(NSString*)phone code:(NSString*)code completeBlock:(void (^)(NSError*err))completeBlock;

/**
 注册

 @param phone 手机号或邮箱
 @param code 验证码
 @param name 用户名
 @param pwd 密码
 @param type 类型：0手机号，1邮箱
 @param completeBlock 回调
 */
- (void)registerWithPhone:(NSString*)phone code:(NSString*)code name:(NSString*)name pwd:(NSString*)pwd registerType:(NSInteger)type completeBlock:(void (^)(NSError*err))completeBlock;

//检测用户是否存在
- (void)userIsExistWithPhone:(NSString*)phone completeBlock:(void (^)(BOOL isExist,NSError*err))completeBlock;

//重置密码
- (void)resetPwdWithPhone:(NSString*)phone code:(NSString*)code pwd:(NSString*)pwd completeBlock:(void (^)(NSError*err))completeBlock;

/// 三方登录后，绑定手机号
/// @param phone 手机号
/// @param code 验证码
/// @param completeBlock 绑定完成
- (void)bindUserWithPhone:(NSString*)phone code:(NSString*)code completeBlock:(void (^)(NSError*err))completeBlock;

#pragma mark - Work 作品部分

- (void)workDetailWithId:(NSString*)workId completeBlock:(void(^)(TSProductDataModel *dataModel,NSError *er))completeBlock;

/**
 首页所有的产品列表
 
 @param pageIndex 分页，从0开始
 @param category 类别
 @param completeBlock 回调
 */
- (void)allProductListWithPageIndex:(NSInteger)pageIndex category:(NSString*)category tid:(NSString*)tid completeBlock:(void(^)(NSArray* datas,NSError *err))completeBlock;
//此方法是推荐产品页面的展示，根据tid参数判断区分
- (void)allProductListWithPageIndex:(NSInteger)pageIndex tid:(NSString*)tid completeBlock:(void(^)(NSArray* datas,NSError *err))completeBlock;

/**
 搜索线上作品

 @param word 关键字
 @param pageIndex 索引
 @param completeBlock 回调
 */
- (void)searchWorkWithWord:(NSString*)word pageIndex:(NSUInteger)pageIndex completeBlock:(void (^)(NSArray *, NSError *))completeBlock;

- (void)searchWorkWithUserId:(NSString*)userId deviceType:(NSString*)deviceType start:(NSInteger)start count:(NSInteger)count completeBlock:(void (^)(NSArray *, NSError *))completeBlock;

/**
 我的线上作品列表

 @param pageIndex 页号
 @param isPublic 是否是公开的作品
 @param type 0三维作品，1视频作品
 @param completeBlock 回调
 */
- (void)myOnlineWorkListWithPageIndex:(NSUInteger)pageIndex isPublic:(BOOL)isPublic type:(NSInteger)type completeBlock:(void(^)(NSArray* datas,NSError *err))completeBlock;

/**
 收藏的作品

 @param pageIndex 页号
 @param completeBlock 回调
 */
- (void)myCollectWorkListWithPageIndex:(NSUInteger)pageIndex completeBlock:(void(^)(NSArray* datas,NSError *err))completeBlock;

/**
 发布作品

 @param imgs 作品图片
 @param recordData 录音数据
 @param videoUrl 视频本地地址
 @param isVideoWork 是否为视频作品
 @param para 其他参数：如作品名字，价格 等
 @param completeBlock 回调
 */
- (void)releaseWorkWithImgs:(NSArray<UIImage*>*)imgs video:(NSURL*)videoUrl isVideoWork:(BOOL)isVideoWork recordBase64Data:(NSData*)recordData parameters:(NSDictionary*)para completeBlock:(void(^)(NSError *err))completeBlock;

/**
 取消或点赞

 @param isPraise YES 点赞，NO取消点赞
 @param workId 作品ID
 @param completeBlock 回调
 */
- (void)praiseOrCancle:(BOOL)isPraise workId:(NSString*)workId completeBlock:(void(^)(NSError *err))completeBlock;

/**
 取消或点赞
 
 @param isCollect YES 收藏，NO取消收藏
 @param workId 作品ID
 @param completeBlock 回调
 */
- (void)collectOrCancle:(BOOL)isCollect workId:(NSString*)workId completeBlock:(void(^)(NSError *err))completeBlock;

/**
 删除作品

 @param workId 作品id
 @param completeBlock 回调
 */
- (void)deleteWorkWithId:(NSString*)workId completeBlock:(void(^)(NSError *err))completeBlock;

/**
 下载视频文件到本地

 @param videoUrl 作品视频url
 @param completeBlock 完成回调
 */
- (void)downLoadWorkVideoWithUrl:(NSString*)videoUrl completeBlock:(void(^)(NSString *videoFilePath, NSError *err))completeBlock;
    
-(void)loadLocalImgWithUrls:(NSArray*)imgUrls completeBlock:(void (^)(NSArray<UIImage*> *,NSError*))completeBlock;

- (void)waterMarkImgsWithCompleteBlock:(void(^)(NSArray *urls, NSArray *models, NSError *err))completeBlock;

- (void)deleteWatermarkImgWithId:(NSString*)waterMarkId completeBlock:(void(^)(NSError *err))completeBlock;

- (void)addWatermarkWithImg:(UIImage*)img completeBlock:(void(^)(id waterModel, NSError *err))completeBlock;

- (void)otherUserWorkWithUserId:(NSString*)otherUserId pageNum:(NSInteger)pageNum completeBlock:(void (^)(NSArray *, NSError *))completeBlock;

/// 修改我的作品是否公开状态
/// @param isPublic 是否公开
/// @param wid 作品id
/// @param completeBlock 回调
- (void)updateWorkStateWithPublic:(BOOL)isPublic workId:(NSString*)wid completeBlock:(void (^)( NSError *err))completeBlock;

/// 获取分享私有作品时的密码
/// @param wid 作品id
/// @param completeBlock 回调
- (void)getPrivateWorkSharePwdWithWorkId:(NSString*)wid completeBlock:(void (^)(NSString *pwd, NSError *err))completeBlock;

/// 取消分享的私有作品密码
/// @param wid 作品id
/// @param completeBlock 回调
- (void)canclePrivateWorkSharePwdWithWorkId:(NSString*)wid completeBlock:(void (^)(NSError *err))completeBlock;

#pragma mark - 上传至莱搭平台
- (void)uploadWorkToLaidaWithWorkId:(NSString*)wid userName:(NSString*)un pwd:(NSString*)pwd completeBlock:(void (^)(NSArray *, NSError *))completeBlock;

#pragma mark - 退底部分

/**
 上传原图至服务器，开始退底

 @param imgs 原图。拍摄的原图，未经编辑过的
 @param completeBlock 回调
 */
//- (void)startClearBgWithWorkImgs:(NSArray<UIImage*>*)imgs completeBlock:(void(^)(NSError *err,NSString *clearBgId))completeBlock;

/**
 查询退底是否完成

 @param clearId 作品退底id
 @param completeBlock 回调。clearimgurls 退底的成功后，返回图片的urls后半部分，需要拼接
 */
//- (void)queryClearBgIsCompleteWithClearId:(NSString*)clearId completeBlock:(void(^)(NSError *err,NSArray *clearImgUrls,NSString *clearId))completeBlock;

/**
 下载一张遮罩图

 @param url 链接
 @param clearId 退底id
 @param downloadedImgName 下载成功后，图片的名字，与原图路径一致（传参的形式获得）
 @param completeBlock 回调
 */
- (void)downLoadClearImgWithUrl:(NSString*)url clearId:(NSString*)clearId downloadedImgName:(NSString*)downloadedImgName completeBlock:(void (^)(NSError *err,NSString *imgAllPath))completeBlock;

//同步去底图
//api/pic/segment_sync
/**
 上传原图至服务器，开始退底
 @param imgs 原图。拍摄的原图，未经编辑过的
 @param completeBlock 回调,注意--返回的imgPath是遮罩图的本地路径，非退底图，需要进一步将原图和遮罩图进行进行合成
 */
- (NSURLSessionDataTask*)startSyncClearBgWithWorkImgs:(NSArray<UIImage*>*)imgs completeBlock:(void(^)(NSError *err,NSArray *imgPaths))completeBlock;

//- (NSURLSessionDataTask*)newStartSyncClearBgWithWorkImgs:(NSArray<UIImage*>*)imgs completeBlock:(void(^)(NSError *err,NSString *imgPaths))completeBlock;

#pragma mark - Find
- (NSURLSessionDataTask*)findTypeDatasWithCompleteBlock:(void(^)(NSError*err, NSArray *datas))completeBlock;
//http://www.aipp3d.com/ImageWord/findImageNew?tid=30&currentPage=1&pageSize=10&newtype=62&draft=0&search=
- (NSURLSessionDataTask*)findListWithTypeId:(NSString*)typeId pageNum:(NSInteger)pageNum completeBlock:(void(^)(NSError*err, NSArray *datas))completeBlock;

/// 得到新闻详情的id
/// @param newsId 新闻id
/// @param completeBlock 回调
- (id)findDetailIdWithNewsId:(NSString*)newsId completeBlock:(void(^)(NSError*err, NSString *detailId))completeBlock;

#pragma mark - 在线服务以及消息

/**
 * 用户消息的数量
 */
- (void)userMsgCountWithCompleteBlock:(void(^)(NSError*err, NSInteger count))completeBlock;

/**
 修改所有消息为已读
 */
- (void)modifyMsgStatusIsReadedWithCompleteBlock:(void(^)(NSError*err))completeBlock;

/*
 申请在线服务
 */
- (void)startOnlineServiceWithWorkId:(NSString*)wid des:(NSString*)des workImgUrl:(NSString*)workImgUrl completeBlock:(void(^)(NSError*err))completeBlock;
/*
 申请的在线服务的列表
 type:0 未完成作品，1，已完成作品。2 所有作品
 */
- (void)onlineServiceWorkListWithUserNameOrWorkName:(NSString*)name type:(NSInteger)type pageNum:(NSInteger)pageNum completeBlock:(void(^)(NSError*err, NSArray *datas))completeBlock;

@end
