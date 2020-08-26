//
//  TSHelper.h
//  ThreeShow
//
//  Created by hitomedia on 02/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSVersionModel;
@class TSProductionDetailCtrl;
@class TSEditWorkCtrl;
@class TSTakePhotoCtrl;
@class TSClearWorkBgCtrl;
@class TSMyWorkCtrl;
/**
 项目辅助类，为类提供共用方法，以及某些独立业务的处理。如提供根视图
 */
@interface TSHelper : NSObject

/**
 共享的版本模型
 */
@property (nonatomic, strong) TSVersionModel *versionModel;

//展示引导页时，引导页的实例
@property (nonatomic, strong) UIViewController *guideRootCtrl;

/**
 是否取消去底。默认为NO，当进行退底时使用。当用户点击取消退底，置为YES，开始退底时，置为NO
 */
@property (nonatomic, assign) BOOL isCancleClearBg;

/**
 当前正在处理的本地作品的数据模型。共享,当从本地作品进入编辑，即会持有该作品。
 若进入本地列表页，则该值置为空。若进入拍照页，该值置空。
 */
//@property (nonatomic, strong) TSWorkModel *editingLocalWorkModel;

#pragma mark - 共享实例
+ (TSHelper*)sharedHelper;

#pragma mark - 静态方法

+ (UIViewController*)getRootCtrl;

+ (UIViewController*)rootCtrl;

//作品图片url的前半部分
+ (NSString*)productImgUrlPrefix;

//去底成功后的图片前缀
+ (NSString *)productClearImgUrlPrefix;

//用户头像的前半部分
+ (NSString*)userImgUrlPrefix;

+ (UIImageView*)sharedDetailImgView;

+ (TSProductionDetailCtrl*)sharedProductionDetailCtrl;

+ (TSEditWorkCtrl*)shareEditWorkCtrl;

+ (TSTakePhotoCtrl*)shareTakePhotoCtrl;

+(TSClearWorkBgCtrl *)shareClearWorkCtrl;

+(TSMyWorkCtrl *)shareMyWorkCtrl;

//断开蓝牙
+ (void)disconnectedBlueTooth;

#pragma mark - 作品部分
+ (NSString*)praiseCountWithStr:(NSString*)countStr;
+ (NSString*)collectCountWithStr:(NSString*)countStr;

+ (NSString*)getNewRecordFileName;

+ (NSString*)getNewImgFileName;

+ (NSString *)getlocalNewImgFilePath;

//分享作品
+ (void)shareWorkWithWorkId:(NSString*)workId img:(UIImage*)img workName:(NSString*)workName isVideo:(BOOL)isVideo;
//+ (void)shareWorkWithWorkId:(NSString*)workId isVideo:(BOOL)isVideo;
+ (NSString*)shareWorkUrlWithWorkId:(NSString*)workId isVideo:(BOOL)isVideo;

+ (void)shareWorkQRCodeWithWorkQRImg:(UIImage*)qrImg wrokImg:(UIImage*)workImg completeBlock:(void(^)(BOOL isSaveToAlbum, NSError*err))completeBlock;

//分享本地作品的视频
+ (void)shareWorkVideoWithVideoUrl:(NSURL*)videoUrl videoCover:(UIImage*)workImg workName:(NSString*)workName completeBlock:(void(^)( NSError*err))completeBlock;

/**
 第三方登录，登录成功，直接将服务器需要的参数直接返回

 @param type 0 微信 ， 1 QQ，  2 微博
 @param completeBlock 结果回调：dic，服务器第三方登录需要的参数
 */
+ (void)thirdLoginWithType:(NSInteger)type completeBlock:(void(^)(NSDictionary *dic,NSError *err))completeBlock;

+ (BOOL)isEnglishLanguage;

+ (void)showSelectShootModeAlertWithSelectBlock:(void(^)(NSInteger idx))selectBlock;

#pragma mark - 弹窗缓存
//+ (BOOL)isCanShow


/**
 是否展示过 裁切后，不可去底提示

 @return YES 展示过，NO 未展示
 */
+ (BOOL)isShowedClipAlert;

/**
 是否展示过贴图后，不可去底提示

 @return YES展示过，NO 未展示
 */
+ (BOOL)isShowedPosterAlert;

#pragma mark - 退底部分

/**
 获取原图的遮罩层图片的路径

 @return 遮罩图所在文件夹。非全路径
 */
+ (NSString *)maskClearImgPath;

/**
 退底成功的图片保存路径。

 @return 路径
 */
+ (NSString*)clearedImgWorkPath;

/**
 拍摄的作品图片存储的路径。非全路径，即不包含图片名

 @return 图片所在的文件夹路径。如：usr/abc/files
 */
+ (NSString*)takePhotoImgPath;

/**
 根据作品图片的索引获取图片存储的名字，包含拓展名

 @param idx 图片所在的索引
 @return 如：00.jpg
 */
+ (NSString*)getSaveWorkImgNameAtIndex:(NSUInteger)idx;

- (BOOL)addNewClearId:(NSString*)cid;

- (BOOL)removeCid:(NSString*)cid;

- (NSArray<NSString*>*)getClearIds;

/**
 开始循环查询是否退底成功
 */
- (void)startQueryClearImgsIsSuccess;

#pragma mark - 用户部分

/**
 根据账号，判断该账户是否是邮箱注册的

 @param account 账号，如手机号或邮箱
 @return 邮箱YES，其他NO
 */
- (BOOL)isEmailUserWithAccount:(NSString*)account;

#pragma mark - 检查用户是否掉线
+ (void)checkUserIsOfflineWithCtrl:(UIViewController*)ctrl offlineBlock:(void(^)(void))offlineBlock;

@end
