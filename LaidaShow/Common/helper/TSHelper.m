//
//  TSHelper.m
//  ThreeShow
//
//  Created by hitomedia on 02/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSHelper.h"
#import "UIViewController+Ext.h"
#import "UINavigationController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSPersonCenterCtrl.h"
#import "TSConstants.h"
#import "TSProductionDetailCtrl.h"
#import "MyBleClass.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "UIImage+Extras.h"
#import "NSDictionary+Ext.h"
#import "KError.h"
#import "TSGuideCtrl.h"
#import "TSUserModel.h"
#import "TSDataProcess.h"
#import "TSEditWorkCtrl.h"
#import "TSTakePhotoCtrl.h"
#import "TSNaviCtrl.h"
#import "TSDataProcess.h"
#import "PPFileManager.h"
#import "PPLocalFileManager.h"
#import "TSWorkModel.h"
#import "TSClearBgStateView.h"
#import "TSHttpRequest.h"
#import "TSClearWorkBgCtrl.h"
#import "TSMyWorkCtrl.h"
#import "UITabBarController+Ext.h"
#import "DSCenterButtonTabbarController.h"
#import "TSTakePhotoCtrl.h"
#import "TSDeviceConnectCtrl.h"
#import "HTProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "XWShareView.h"
#import "UIImage+Extras.h"
#import "TSShootVideoCtrl.h"
#import "TSAlertView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MJRefreshComponent.h"
#import <ShareSDKUI/SSUIShareSheetConfiguration.h>
#import "TSLanguageModel.h"

@interface TSHelper()
@property (nonatomic, strong) UIImageView *detailImgView;
@property (nonatomic, strong) TSProductionDetailCtrl *detailCtrl;
@property (nonatomic, strong) TSEditWorkCtrl *editCtrl;
@property (nonatomic, strong) TSTakePhotoCtrl *takePhotoCtrl;
@property (nonatomic,strong) TSClearWorkBgCtrl *clearWorkCtrl;
@property (nonatomic,strong) TSMyWorkCtrl *myWorkCtrl;

@property (nonatomic, strong) NSArray *clearBgImgIds; //退底图片的退底id集合
@property (nonatomic, assign) NSInteger downLoadingClearImgIndex; //默认为0
@property (nonatomic, strong) NSMutableArray *clearBgImgPaths;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TSHelper

+ (TSHelper*)sharedHelper{
//    static TSHelper *helper = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        helper = [TSHelper new];
//    });
    
    TSDataProcess *dp = [TSDataProcess sharedDataProcess];
    
    if( dp.helper == nil ){
        dp.helper = [TSHelper new];
    }
    
    return dp.helper;
}

+ (UIViewController *)getRootCtrl{
    
    //每次切换根视图，清空bundle的缓存，重新加载Mj下拉刷新的组件的资源
    [self mj_clearCache];

    TSHelper *ts = [TSHelper sharedHelper];
    
    ts.guideRootCtrl = [[self class] naviCtrlWithRootCtrlName:@"TSGuideCtrl"];
    if( [ts.guideRootCtrl isLogined] ){
        return [self rootCtrl];
    }
    return ts.guideRootCtrl;
}

+ (UIViewController*)rootCtrl{

    DSCenterButtonTabbarController *tabbar =
    [[DSCenterButtonTabbarController alloc] initWithShowCenterButton:YES];
    NSArray *ctrls = @[[[self class] naviCtrlWithRootCtrlName:@"TSHomeProductionCtrl"],
                       [[self class] naviCtrlWithRootCtrlName:@"TSFindHomeCtrl"],
                       [[self class] naviCtrlWithRootCtrlName:@"TSMyWorkCtrl"],
                       [[self class] naviCtrlWithRootCtrlName:@"TSPersonCenterCtrl"]];
    NSArray *titles = @[NSLocalizedString(@"TabbarHomeTitle", nil),
                        NSLocalizedString(@"TabbarFinder", nil),
                        NSLocalizedString(@"TabbarWork", nil),
                        NSLocalizedString(@"TabbarMe", nil)];
    NSArray *niNames = @[@"home_square_n",@"home_found_n",@"home_work_n",@"home_mine_n"];
    NSArray *siNames = @[@"home_square_s",@"home_found_s",@"home_work_s",@"home_mine_s"];
    [tabbar configTabbarWithCtrls:ctrls titles:titles
                 selectedImgNames:siNames
                   normalImgNames:niNames
                        textColor:[UIColor colorWithRgb170]
                 selctedTextColor:[UIColor colorWithRgb_0_151_216]];
    
    tabbar.tabBar.barTintColor = [UIColor whiteColor];
    
    UIButton *center = tabbar.centerButton;
    [center setImage:[UIImage imageNamed:@"home_camera"] forState:UIControlStateNormal];
    [center setTitle:nil forState:UIControlStateNormal];
    center.backgroundColor = [UIColor clearColor];
    [center addTarget:self action:@selector(handleCenterBtn) forControlEvents:UIControlEventTouchUpInside];
    CGFloat wh = 50;
    center.frame = CGRectMake((SCREEN_WIDTH-wh)/2, -10, wh, wh);
    tabbar.delegate = (id)[TSHelper sharedHelper];
    return tabbar;
}

+ (NSString *)productImgUrlPrefix{
    //return [TSConstantServerUrl stringByAppendingString:TSConstantProductImgMiddUrl];
    return TSConstantProductImgMiddUrl;
}

+ (NSString *)productClearImgUrlPrefix{
    //return [TSConstantServerUrl stringByAppendingString:TSConstantWorkClearImgMiddUrl];
    return TSConstantProductImgMiddUrl;
}

+ (NSString *)userImgUrlPrefix{
//    http://aipp-micro.oss-cn-shenzhen.aliyuncs.com/a/2020/08/03/25/251838d1-7b81-44d6-8fe2-9e80816514fe.png
    return TSConstantProductImgMiddUrl;
    
  //  http://www.aipp3d.com/shenyi/image/member/
  //  http://www.aipp3d.com/api/user/avatar/id/
    return [TSConstantServerUrl stringByAppendingString:TSConstantUserHeadImgMiddUrl];
}

+ (UIImageView *)sharedDetailImgView{
    TSHelper *hp = [TSHelper sharedHelper];
    if( !hp.detailImgView ){
        hp.detailImgView = [UIImageView new];
        hp.detailImgView.contentMode = UIViewContentModeScaleAspectFill;
        hp.detailImgView.backgroundColor = [UIColor whiteColor];
    }
    
    return hp.detailImgView;
}

+ (TSProductionDetailCtrl *)sharedProductionDetailCtrl{
    
    return [TSProductionDetailCtrl new];
    
    TSHelper *hp = [TSHelper sharedHelper];
    
    TSProductionDetailCtrl *dc = hp.detailCtrl;
    if( !dc ){
        dc = [TSProductionDetailCtrl new];
        hp.detailCtrl = dc;
    }
    return dc;
}

+ (TSEditWorkCtrl *)shareEditWorkCtrl{
    
//    return [TSEditWorkCtrl new];
    
    
    TSHelper *hp = [TSHelper sharedHelper];
    
    TSEditWorkCtrl *dc = hp.editCtrl;
    if( !dc ){
        dc = [TSEditWorkCtrl new];
        hp.editCtrl = dc;
    }
    return dc;
}

+(TSClearWorkBgCtrl *)shareClearWorkCtrl{
    
//    return [TSClearWorkBgCtrl new];
    
    TSHelper *hp = [TSHelper sharedHelper];
    TSClearWorkBgCtrl *dc = hp.clearWorkCtrl;
    if (!dc) {
        dc = [TSClearWorkBgCtrl new];
        hp.clearWorkCtrl = dc;
    }
    return dc;
}

+(TSMyWorkCtrl *)shareMyWorkCtrl{
    
//    return [TSMyWorkCtrl new];
    
    TSHelper *hp = [TSHelper sharedHelper];
    TSMyWorkCtrl *dc = hp.myWorkCtrl;
    if (!dc) {
        dc = [TSMyWorkCtrl new];
        hp.myWorkCtrl = dc;
    }
    return dc;
}

+ (TSTakePhotoCtrl *)shareTakePhotoCtrl{
    
//    return [TSTakePhotoCtrl new];
    
    TSHelper *hp = [TSHelper sharedHelper];
    
    TSTakePhotoCtrl *dc = hp.takePhotoCtrl;
    if( !dc ){
        dc = [TSTakePhotoCtrl new];
        hp.takePhotoCtrl = dc;
    }
    return dc;
}

+ (void)disconnectedBlueTooth{
    [[MyPublic shareMyBleClass] MybleDisConnectBleAll];
}

#pragma mark - TabbarDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    tabBarController.view.tag = [tabBarController.viewControllers indexOfObject:viewController];
    
    return YES;
}

#pragma mark - TouchEvents
+ (void)handleCenterBtn{
    UINavigationController *navi = nil;
//    TSTakePhotoCtrl *pc = [[self class] shareTakePhotoCtrl];
//    pc.hidesBottomBarWhenPushed = YES;
    UITabBarController *rootCtrl = (UITabBarController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    if( [rootCtrl isKindOfClass:[UITabBarController class]] ){
        navi = rootCtrl.selectedViewController;
        if( ![navi isKindOfClass:[UINavigationController class]] ){
            return;
        }
    }
    
    if( navi == nil ) return;
    
//    //直接去拍照
//    TSTakePhotoCtrl *pc = [TSHelper shareTakePhotoCtrl];//[TSTakePhotoCtrl new];
//    pc.hidesBottomBarWhenPushed = YES;
//    [pc resetDatas];
//    [navi pushViewController:pc animated:YES];
//    return;
//    TSShootVideoCtrl *vc = [TSShootVideoCtrl new];
//    vc.hidesBottomBarWhenPushed = YES;
//    [navi pushViewController:vc animated:YES];
//    return;
    
    
    //若未登录，先去登录
    if( ![navi.topViewController isLoginedWithGotoLoginCtrl] ) return;
    
    if([MyPublic shareMyBleClass].connectedShield.state == CBPeripheralStateConnected ){
    
        [self showSelectShootModeAlertWithSelectBlock:^(NSInteger idx) {
            if( idx == 1 ){
                //连接中 直接去拍照
                TSTakePhotoCtrl *pc = [TSHelper shareTakePhotoCtrl];//[TSTakePhotoCtrl new];
                pc.hidesBottomBarWhenPushed = YES;
                [pc resetDatas];
                [navi pushViewController:pc animated:YES];
            }else if( idx == 0 ){
                TSShootVideoCtrl *vc = [TSShootVideoCtrl new];
                vc.hidesBottomBarWhenPushed = YES;
                [navi pushViewController:vc animated:YES];
            }
        }];
        

        
    }else{
        //未连接，先去链接页面
        [HTProgressHUD showError:NSLocalizedString(@"ConnectEquipment", nil)];//@"请先连接设备"
        TSDeviceConnectCtrl *cc = [TSDeviceConnectCtrl new];
        cc.hidesBottomBarWhenPushed = YES;
        [navi pushViewController:cc animated:YES];
    }
}

#pragma mark - 作品部分
+ (NSString*)praiseCountWithStr:(NSString*)countStr{
    if( countStr ){
        return countStr;
    }
    
    return @"";
}

+ (NSString*)collectCountWithStr:(NSString*)countStr{
    if( countStr ){
        return countStr;
    }
    
    return @"";
}

+ (NSString*)getNewRecordFileName{
    NSDate *nowDate = [NSDate date];
    NSString *name = [NSString stringWithFormat:@"record%lld",(long long)(nowDate.timeIntervalSince1970*1000)];
    
    return name;
}

+ (NSString *)getNewImgFileName{
    NSDate *nowDate = [NSDate date];
    NSString *name = [NSString stringWithFormat:@"workimg%lld.jpg",(long long)(nowDate.timeIntervalSince1970*1000)];
    
    return name;
}

+ (NSString *)getlocalNewImgFilePath{
    NSDate *nowDate = [NSDate date];
    NSString *name = [NSString stringWithFormat:@"workimg%lld",(long long)(nowDate.timeIntervalSince1970*1000)];
    
    return name;
}


//http://www.aipp3d.com:9000/pic/work/+video字段值

//+ (void)shareWorkWithWorkId:(NSString *)workId isVideo:(BOOL)isVideo{
//    TSDataProcess *dp =[TSDataProcess sharedDataProcess];
//    if (isVideo) {
//        NSString *url =[NSString stringWithFormat:@"%@?%@",@"http://www.aipp3d.com/api/video/share",workId];
//        [dp.httpRequest get:url parameters:nil resultBlock:^(NSDictionary *result, NSError *err) {
//            NSLog(@"share");
//
//        }];
//    }else if (!isVideo){
//        NSString *url =[NSString stringWithFormat:@"%@?%@",@"http://www.aipp3d.com/api/work/share",workId];
//        [dp.httpRequest get:url parameters:nil resultBlock:^(NSDictionary *result, NSError *err) {
//            NSLog(@"share");
//
//        }];
//    }
//}

+ (void)shareWorkWithWorkId:(NSString *)workId img:(UIImage *)img workName:(NSString *)workName isVideo:(BOOL)isVideo{
    //1、创建分享参数
    NSArray* imageArray = nil;
    if( img ){
        //宽高不一致裁剪
//        if (img.size.width != img.size.height) {
//            UIImage *scaleImg = [img imageByScalingToSize:CGSizeMake(100, 100)];
//                    if( scaleImg )
//                        imageArray = @[scaleImg];
//        }
        //裁剪,为了防止图片过大，分享失败的问题
        UIImage *scaleImg = [img imageByScalingToSizeNotChange:CGSizeMake(img.size.width/3, img.size.height/3)];
        if( scaleImg )
            imageArray = @[scaleImg];
        //否则不裁剪
        //else
//        imageArray = @[img];
    }else{
        imageArray = @[[UIImage imageNamed:@"share_logo"]];
    }
    
    
//    （注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传image参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    if (imageArray && workId) {
//        NSString *prefix = @"http://www.aipp3d.com:9000/work/share/";

        NSString *shareUrl = [self shareWorkUrlWithWorkId:workId isVideo:isVideo];
        NSLog(@"workShareUrl - %@",shareUrl);
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:NSLocalizedString(@"莱搭秀作品分享", nil)
                                         images:imageArray
                                            url:[NSURL URLWithString:shareUrl]
                                          title:workName
                                           type:SSDKContentTypeWebPage];
        //有的平台要客户端分享需要加此方法，例如微博
        [shareParams SSDKEnableUseClientShare];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [self shareWithParameters:shareParams items:@[@(SSDKPlatformTypeWechat),@(SSDKPlatformTypeQQ),@(SSDKPlatformTypeSinaWeibo)]];
    }
}

+ (NSString *)shareWorkUrlWithWorkId:(NSString *)workId isVideo:(BOOL)isVideo{
    NSString *midUrl = @"/product/api/work/share/";//@"work/share/";
    if( isVideo ){
        midUrl = @"/product/api/video/share/";//@"/api/work/share/";//@"video/share/";
    }
    NSString *prefix = [TSConstantServerUrl stringByAppendingString:midUrl];
    NSString *shareUrl = [prefix stringByAppendingString:workId];
    
    return shareUrl;
}

+ (void)shareWorkQRCodeWithWorkQRImg:(UIImage *)qrImg wrokImg:(UIImage*)workImg completeBlock:(void (^)(BOOL, NSError *))completeBlock{
    
    if( qrImg == nil ){
        completeBlock(NO,[NSError errorWithDomain:@"-1" code:-1 userInfo:@{@"kErrorDefaultKey":@"获取二维码失败"}]);
        return;
    }
    
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:4];
    NSMutableArray *imgNames = [NSMutableArray arrayWithCapacity:4];
    NSMutableArray *types = [NSMutableArray arrayWithCapacity:4];
    
    [titles addObject:NSLocalizedString(@"保存至相册", nil)];
    [imgNames addObject:@"share_download"];
    [types addObject:@(SSDKPlatformTypeUnknown)];

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        //微信
        [imgNames addObject:@"share_wecat"];
        [imgNames addObject:@"share_friends"];
        
        [types addObject:@(SSDKPlatformSubTypeWechatSession)];
        [types addObject:@(SSDKPlatformSubTypeWechatTimeline)];
        
        [titles addObject:NSLocalizedString(@"微信", nil)];
        [titles addObject:NSLocalizedString(@"朋友圈", nil)];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
        //Qq
        [imgNames addObject:@"share_qq"];
        [types addObject:@(SSDKPlatformTypeQQ)];
        [titles addObject:NSLocalizedString(@"QQ好友", nil)];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
        //Qq
        [imgNames addObject:@"share_space"];
        [types addObject:@(SSDKPlatformSubTypeQZone)];
        [titles addObject:NSLocalizedString(@"QQ空间", nil)];
    }
    
    if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weibosdk://"]]){
        [imgNames addObject:@"share_weibo"];
        [types addObject:@(SSDKPlatformTypeSinaWeibo)];
        [titles addObject:NSLocalizedString(@"微博", nil)];
    }
    
    [XWShareView shareView].shareTitles = titles;
    [XWShareView showWithShareBtnImgNames:imgNames bgImg:workImg qrImg:qrImg icon:[UIImage imageNamed:@"share_logo"] qrDes:NSLocalizedString(@"扫码看详情", nil) handleShareBtnBlock:^(NSUInteger index) {
        UIImage *resultImg = [TSHelper generateQrImgWithImgShareView:[XWShareView shareView]];
        
        if( resultImg == nil ){
            completeBlock(NO,[NSError errorWithDomain:@"-1" code:-1 userInfo:@{@"kErrorDefaultKey":@"生成图片失败"}]);
            return;
        }
        
        NSLog(@"%lu=idx",(unsigned long)index);
        if( index == 0 ){
            //保存至相册
            UIImageWriteToSavedPhotosAlbum(resultImg, nil, nil, nil);
            completeBlock(YES,nil);
        }
        else if(types.count > index ){
            
            NSNumber *num = (NSNumber*)types[index];
            SSDKPlatformType pt = (SSDKPlatformType)(num.integerValue);
            //                              [self shareTextToPlatformType:pt sharedUrl:url];
            
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            [shareParams SSDKSetupShareParamsByText:nil
                                             images:@[resultImg]
                                                url:nil
                                              title:nil
                                               type:SSDKContentTypeImage];
            //有的平台要客户端分享需要加此方法，例如微博
            [shareParams SSDKEnableUseClientShare];
            [ShareSDK share:pt parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                if( completeBlock ){
                    completeBlock(NO, error);
                }
            }];
        }
    }];
}

+ (void)thirdLoginWithType:(NSInteger)type completeBlock:(void (^)(NSDictionary *, NSError *))completeBlock{
    SSDKPlatformType platform = SSDKPlatformTypeWechat;
    if( type ==  3 ){
        platform = SSDKPlatformTypeQQ;
    }else if( type == 4 ){
        //微信
        platform = SSDKPlatformTypeWechat;
    }else if( type == 5 ){
        //微博
        platform = SSDKPlatformTypeSinaWeibo;
    }
    else if( type == 6 ){
        platform = SSDKPlatformTypeFacebook;
    }
    else if( type == 7 ){
        platform = SSDKPlatformTypeTwitter;
    }
    
    //已经授权，则清除授权
    if( [ShareSDK hasAuthorized:platform] ){
        [ShareSDK cancelAuthorize:platform result:^(NSError *error) {
            [self getUserInfoWithPlatform:platform type:type completeBlock:completeBlock];
        }];
    }
    //未授权，直接授权
    else{
        [self getUserInfoWithPlatform:platform type:type completeBlock:completeBlock];
    }
}

+ (void)getUserInfoWithPlatform:(SSDKPlatformType)platform type:(NSInteger)type completeBlock:(void (^)(NSDictionary *, NSError *))completeBlock{
     [ShareSDK getUserInfo:platform
               onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         NSDictionary *dic = nil;
         NSError *retErr = error;
         if (state == SSDKResponseStateSuccess)
         {
             
//             NSLog(@"uid=%@",user.uid);
//             NSLog(@"%@",user.credential);
             NSLog(@"token=%@",user.credential.token);
//             NSLog(@"nickname=%@",user.nickname);
             
//             @"socialOpenId":userId,
//             @"socialType":@"99",
//             @"socialName":un,
//             @"socialImage":@""
             
             dic = @{
                     @"socialOpenId":user.uid,
                     @"socialType":@(type),
                     @"socialName":user.nickname,
                     @"socialImage":user.icon
                     };
             NSLog(@"\n----\ndic=%@\n------",dic);
         }
         
         else
         {
             NSLog(@"%@",error);
         }
         
         if( dic == nil ){
             retErr = [KError errorWithCode:KErrorCodeDefault msg:@"获取用户信息失败"];
         }
         if( completeBlock ){
             completeBlock(dic,retErr);
         }
     }];
}

+ (BOOL)isEnglishLanguage{
    NSString *homeTitle = NSLocalizedString(@"TabbarHomeTitle", nil);
    BOOL isEnglishLaunage = [homeTitle containsString:@"Home"];
    return isEnglishLaunage;
}

+ (void)showSelectShootModeAlertWithSelectBlock:(void (^)(NSInteger))selectBlock{

//    TSAlertView *alertView = [TSAlertView showAlertWithTitle:@"模式选择" des:@"请选择您要拍摄的模式" handleBlock:^(NSInteger index) {
//
//    }];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"模式选择", nil) message:NSLocalizedString(@"请选择您要拍摄的模式", nil) preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *ac1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"视频拍摄", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if( selectBlock ){
            selectBlock(0);
        }
    }];
    
    UIAlertAction *ac2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"三维拍摄", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if( selectBlock ){
            selectBlock(1);
        }
    }];
    [ac addAction:ac1];
    [ac addAction:ac2];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
}

#pragma mark - 分享作品的本地视频
+ (void)shareWorkVideoWithVideoUrl:(NSURL *)videoUrl videoCover:(UIImage *)workImg workName:(NSString*)workName completeBlock:(void (^)(NSError *))completeBlock{
    if( videoUrl == nil ){
        completeBlock([NSError errorWithDomain:@"-1" code:-1 userInfo:@{@"kErrorDefaultKey":@"获取视频失败"}]);
        return;
    }
    
    NSArray* imageArray = nil;
    if( workImg ){
        //裁剪,为了防止图片过大，分享失败的问题
        CGSize toSize = CGSizeMake(workImg.size.width/3, workImg.size.height/3);
        UIImage *scaleImg = [workImg imageByScalingToSizeNotChange:toSize];
        if( scaleImg )
            imageArray = @[scaleImg];
            }else{
                imageArray = @[[UIImage imageNamed:@"share_logo"]];
            }
    
    [self shareMenuVideoWithTitle:workName text:@"莱搭秀作品分享" thumbImg:imageArray[0] videoUrl:videoUrl];
}

/**
 分享菜单 视频
 */
+ (void)shareMenuVideoWithTitle:(NSString*)title text:(NSString*)text thumbImg:(id)timg videoUrl:(NSURL*)videoUrl
{
    //设置显示平台 不支持视频分享的 新浪微博 不加入 朋友圈官方暂不支持视频分享 qq好友不支持分享视频
    
    //Facebook 相册视频 客户端分享 , 本地视频 使用应用内分享
    //FacebookMessager 支持 本地视频 和 相册视频 客户端分享
    //Instagram 支持 本地视频 和 相册视频 客户端分享
    //Twitter 支持 本地视频 应用内分享
    //YouTube 支持 本地视频 应用内分享
    //QZone 只支持相册视频 客户端分享
    //微信好友&收藏 只支持本地文件 客户端分享
    //美拍 支持 本地视频 和 相册视频 客户端分享
    NSArray *items = @[
                       @(SSDKPlatformSubTypeWechatSession),
                       @(SSDKPlatformSubTypeWechatFav),
                       @(SSDKPlatformSubTypeQZone),
                       @(SSDKPlatformTypeSinaWeibo),
                       ];
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    NSString *filePath = videoUrl.path;//[[NSBundle mainBundle] pathForResource:@"cat" ofType:@"mp4"];
    [shareParams SSDKSetupShareParamsByText:text
                                     images:nil
                                        url:[NSURL fileURLWithPath:filePath]
                                      title:nil
                                       type:SSDKContentTypeVideo];
    //设置微信好友的视频分享
    [shareParams SSDKSetupWeChatParamsByText:text
                                       title:title
                                         url:nil
                                  thumbImage:timg
                                       image:nil
                                musicFileURL:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil
                         sourceFileExtension:@"mp4"
                              sourceFileData:filePath
                                        type:SSDKContentTypeFile
                          forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    //设置微信收藏的视频分享
    [shareParams SSDKSetupWeChatParamsByText:text
                                       title:title
                                         url:nil
                                  thumbImage:timg
                                       image:nil
                                musicFileURL:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil
                         sourceFileExtension:@"mp4"
                              sourceFileData:filePath
                                        type:SSDKContentTypeFile
                          forPlatformSubType:SSDKPlatformSubTypeWechatFav];
    
    //设置新浪微博分享
    [shareParams SSDKSetupSinaWeiboShareParamsByText:text title:title images:timg video:filePath url:nil latitude:0 longitude:0 objectID:nil isShareToStory:NO type:SSDKContentTypeVideo];
    
    //设置保存视频并获取相册地址 并设置QQ视频分享
    NSURL *url = [NSURL URLWithString:filePath];
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error) {
        [shareParams SSDKSetupQQParamsByText:text
                                       title:title
                                         url:assetURL
                               audioFlashURL:nil
                               videoFlashURL:nil
                                  thumbImage:timg
                                      images:nil
                                        type:SSDKContentTypeVideo
                          forPlatformSubType:SSDKPlatformSubTypeQZone];
        [self shareWithParameters:shareParams items:items ];
//    filePath:filePath];
    }];
}

+ (void)shareWithParameters:(NSMutableDictionary *)shareParams items:(NSArray *)items //filePath:(NSString *)filePath
{
    UIView *view = [UIApplication sharedApplication].keyWindow;
    SSUIShareSheetConfiguration *con = [SSUIShareSheetConfiguration new];
    con.languageCode = [TSLanguageModel currLanguageModel].languageCode;
    
    [ShareSDK showShareActionSheet:view customItems:items shareParams:shareParams sheetConfiguration:con onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        
       
        //循环删除 复制密码视图
        UIView *sv = [UIApplication sharedApplication].keyWindow;
        for( UIView *v in sv.subviews ){
            if( [v isKindOfClass:NSClassFromString(@"TSCopyShareWorkPwdView")] ){
                [v removeFromSuperview];
                break;
            }
        }
        
        if( state == SSDKResponseStateSuccess ){
            [HTProgressHUD showSuccess:NSLocalizedString(@"分享成功", nil)];
        }
        else if( state == SSDKResponseStateFail ){
            [HTProgressHUD showSuccess:NSLocalizedString(@"分享失败", nil)];
        }
    }];
}
#pragma mark - 弹窗缓存
//+ (BOOL)isCanShow
/**
 是否展示过 裁切后，不可去底提示
 
 @return YES 展示过，NO 未展示
 */
+ (BOOL)isShowedClipAlert{
    NSString *clipKey = @"TSHelperClipedNotClearBgKey11";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if( ![ud boolForKey:clipKey] ){
        [ud setBool:YES forKey:clipKey];
        return NO;
    }
    
    return YES;
}

/**
 是否展示过贴图后，不可去底提示
 
 @return YES展示过，NO 未展示
 */
+ (BOOL)isShowedPosterAlert{
    NSString *posterKey = @"TSHelperPosteredNotClearBgKey11";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if( ![ud boolForKey:posterKey] ){
        [ud setBool:YES forKey:posterKey];
        return NO;
    }
    
    return YES;
}

#pragma mark __退底Id缓存管理

+ (NSString *)maskClearImgPath {
    NSString *path =
    [[PPFileManager sharedFileManager] getSanWorkImgPathWithImgAllName:@"maskclearImgDir"];
    return path;
}

+ (NSString *)clearedImgWorkPath {
    NSString *path =
    [[PPFileManager sharedFileManager] getSanWorkImgPathWithImgAllName:@"clearImgDir"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:path isDirectory:nil] ==NO ){
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return path;
}

+ (NSString *)takePhotoImgPath {
    NSString *path =
    [[PPFileManager sharedFileManager] getSanWorkImgPathWithImgAllName:@"takePhotoImgDir"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:path isDirectory:nil] ==NO ){
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)getSaveWorkImgNameAtIndex:(NSUInteger)idx{

    return [NSString stringWithFormat:@"%02lu.jpg",(unsigned long)idx];
}

- (BOOL)addNewClearId:(NSString*)cid{
    if([cid isKindOfClass:[NSString class]] ==NO ) return NO;
    
    NSMutableArray *cids = [NSMutableArray array];
    if( _clearBgImgIds.count ){
        [cids addObjectsFromArray:_clearBgImgIds];
    }
    [cids addObject:cid];
    _clearBgImgIds = cids;
    [[NSUserDefaults standardUserDefaults] setObject:cids forKey:[self clearIdCachekey]];

    //添加一个新的id进来，就开始轮训
    [self startQueryClearImgsIsSuccess];
    
    return YES;
}

- (BOOL)removeCid:(NSString*)cid{
    if([cid isKindOfClass:[NSString class]] ==NO ) return NO;
    
    NSArray *arrs = [self getClearIds];
    if( arrs.count && [arrs containsObject:cid] ){
        NSMutableArray *cids = [NSMutableArray arrayWithArray:arrs];
        [cids removeObject:cid];
        
        if( [cids count] == 0 ){
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self clearIdCachekey]];
            _clearBgImgIds = nil;
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:cids forKey:[self clearIdCachekey]];
            _clearBgImgIds = cids;
        }
        return YES;
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self clearIdCachekey]];
        _clearBgImgIds = nil;
        return YES;
    }
    return NO;
}

- (NSArray<NSString*>*)getClearIds{
    
    if( _clearBgImgIds.count ) return _clearBgImgIds;
    
    NSArray *ids =
    [[NSUserDefaults standardUserDefaults] objectForKey:[self clearIdCachekey]];
    if( [ids isKindOfClass:[NSArray class]] && ids.count){
        _clearBgImgIds = ids;
        return ids;
    }

    return nil;
}

- (NSString*)clearIdCachekey{
    return @"TSHelpCahceKeyClearBgImgId";
}

- (void)startQueryClearImgsIsSuccess{
    [_timer invalidate];
    if( _timer ==nil ){
        _timer = [NSTimer scheduledTimerWithTimeInterval:60*2 target:self selector:@selector(startQueryTimer) userInfo:nil repeats:YES];
    }
    
    [_timer fire];
}

- (void)invaliteTimer{
    [_timer invalidate];
    _timer = nil;
}

#pragma mark __退底是否完成查询

- (void)startQueryTimer{
    NSArray *arr = [self getClearIds];
    if(arr ==nil || arr.count ==0 ){
        [self invaliteTimer];
        return;
    }
    NSString *cid = arr[0];
//    [self requestClearIsSuccessWithClearId:cid];
}

//- (void)requestClearIsSuccessWithClearId:(NSString*)clearId{
//    NSString *cid = clearId;
////    cid = @"48669226-dd8b-433a-b817-4bd6a70cf091";
//    TSDataProcess *dp = [TSDataProcess sharedDataProcess];
//    [dp queryClearBgIsCompleteWithClearId:cid completeBlock:^(NSError *err, NSArray *clearImgUrls,NSString *clearId) {
//        if( err )  return ;
//
//        //清除退底id
//        BOOL isSuccess = clearImgUrls.count;
//        if( isSuccess==NO ) return;
//
//        //退底完成 。则停止轮训
//        [self invaliteTimer];
//
//        [self.clearBgImgPaths removeAllObjects];
//        //服务端退底完成，则开始下载退底图片
//        [self downloadClearImgWithClearId:clearId imgUrls:clearImgUrls];
//    }];
//}

//- (void)downloadClearImgWithClearId:(NSString*)clearId imgUrls:(NSArray*)imgUrls{
//    [self downloadClearImgWithClearId:clearId imgUrls:imgUrls idx:0 completeBlock:^{
//       //下载完成
//        if( self.clearBgImgPaths.count != imgUrls.count ){
//            //下载失败。
//            
//        }else{
//            //下载所有图片成功
//            
//            //退底成功，则清除已缓存的退底id
//            [self removeCid:clearId];
//            
//            //查看是否还有再轮训的id,若无，则停止轮训
//            if( [self getClearIds] == nil ){
//                [self invaliteTimer];
//            }else{
//                [self startQueryTimer];
//            }
//            
//            //更新本地作品缓存
//            [self updateLocalworkWithClearBgImgPaths:_clearBgImgPaths clearId:clearId];
//            
//            //并更改首页进度视图的状态
//            [[TSClearBgStateView shareClearBgStateView] setIsClearedBgImg:YES];
//        }
//    }];
//}

//- (void)downloadClearImgWithClearId:(NSString*)clearId imgUrls:(NSArray*)imgUrls idx:(NSUInteger)idx completeBlock:(void(^)(void))completeBlock{
//
//    if( idx == imgUrls.count ){
//        if( completeBlock ){
//            completeBlock();
//        }
//
//        return;
//    }
//
//    NSString *url = nil;
//    if( imgUrls.count > idx ){
//        url = imgUrls[idx];
//    }
//    [self downloadClearImgWithClearId:clearId url:url completeBlock:^(NSError *err, NSString *imgAllPath) {
//        if( err ==nil && imgAllPath ){
//            [self.clearBgImgPaths addObject:imgAllPath];
//        }
//
//        [self downloadClearImgWithClearId:clearId imgUrls:imgUrls idx:idx+1 completeBlock:completeBlock];
//    }];
//}

//- (void)downloadClearImgWithClearId:(NSString*)clearId url:(NSString*)url completeBlock:(void(^)(NSError *err,NSString *imgAllPath))completeBlock{
//    TSDataProcess *dp = [TSDataProcess sharedDataProcess];
//    [dp downLoadClearImgWithUrl:url clearId:clearId completeBlock:^(NSError *err, NSString *imgAllPath) {
//        if( completeBlock ){
//            completeBlock(err,imgAllPath);
//        }
//    }];
//}

#pragma mark __退底成功后，更新作品缓存
- (void)updateLocalworkWithClearBgImgPaths:(NSArray*)imgPaths clearId:(NSString*)cid{
    NSArray *datas =
    [[PPLocalFileManager shareLocalFileManager] getLocalFilesInfo];
    
    for( TSWorkModel *wm in datas) {
        if( [wm isKindOfClass:[TSWorkModel class]] ){
            if( wm.clearBgWorkId && cid ){
                if( [wm.clearBgWorkId isEqualToString:cid] ){
                    
                    wm.clearBgImgPathArr = imgPaths;
                    wm.clearState = TSWorkClearBgStateCleared;
                    
                    [[PPLocalFileManager shareLocalFileManager] updateModel:wm atIndex:wm.imgDataIndex];
                    
                    break;
                }
            }
        }
    }
}


#pragma mark - 用户部分

/**
 根据账号，判断该账户是否是邮箱注册的
 
 @param account 账号，如手机号或邮箱
 @return 邮箱YES，其他NO
 */
- (BOOL)isEmailUserWithAccount:(NSString*)account{
    if( [account isKindOfClass:[NSString class]] ){
        if( [account containsString:@"@"] ){
            return YES;
        }
    }
    
    return NO;
}


#pragma mark - 检查用户是否掉线
+ (void)checkUserIsOfflineWithCtrl:(UIViewController*)ctrl offlineBlock:(void(^)(void))offlineBlock{
    
    //若未登录，则不进行检查
    if( ctrl.dataProcess.userModel == nil ) return;
    
    [ctrl dispatchAsyncQueueWithName:@"checkIsLogout" block:^{
        [[TSDataProcess sharedDataProcess] userInfoWithCompleteBlock:^(NSError *err) {
            [ctrl dispatchAsyncMainQueueWithBlock:^{
//                if(err && [[KError errorMsgWithError:err] containsString:@"重新登录"] ){
                if( err ==nil ) return;
                
                    [ctrl showErrMsgWithError:err];
                    if( offlineBlock ){
                        offlineBlock();
                    }
//                }
            }];
        }];
    }];
    
}

#pragma mark - Private

+ (UINavigationController*)naviCtrlWithRootCtrlName:(NSString*)cn{
    if( [cn isKindOfClass:[NSString class]] ){
        UIViewController *ctrl = [NSClassFromString(cn) new];
        if( [ctrl isKindOfClass:[UIViewController class]] ){
            UINavigationController *naviCtrl =
            [[TSNaviCtrl alloc] initWithRootViewController:ctrl];
            [naviCtrl configNavigationCtrl];
            [naviCtrl setNavigationBarBgClear];
            return naviCtrl;
        }
    }
    return [UINavigationController new];
}

- (NSMutableArray *)clearBgImgPaths{
    if( !_clearBgImgPaths ){
        _clearBgImgPaths = [NSMutableArray new];
    }
    return _clearBgImgPaths;
}

+ (UIImage*)generateQrImgWithImgShareView:(XWShareView*)shareView{
    //将所有的视图size放大3倍。生成图片。然后再缩放回去。
    [XWShareView scaleQRImgViewFrame:2];
    
    UIImage *img =
    [UIImage imageWithView:[XWShareView shareView].bgImgView];
    
    [XWShareView scaleQRImgViewFrame:1];
    
    return img;
}


@end
