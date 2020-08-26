//
//  TSPersonCenterCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 02/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSPersonCenterCtrl.h"
#import "TSPersonCenterCell.h"
#import "TSPersonCenterCellModel.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "UILabel+Ext.h"
#import "TSUserModel.h"
#import "UIImageView+WebCache.h"
#import "TSLoginCtrl.h"
//#import "UIViewController+MMDrawerController.h"
#import "TSConstants.h"
#import "TSDataBase.h"
#import "HTProgressHUD.h"
#import "HTTableView.h"
#import "TSUserInfoCtrl.h"
#import "NSString+Ext.h"
#import "TSWebPageCtrl.h"
#import "TSCourseCtrl.h"
#import "TSFeedbackCtrl.h"
#import "TSAboutCtrl.h"
#import "TSDeviceConnectCtrl.h"
#import "TSMyWorkCtrl.h"

#import "TSEditClipCtrl.h"
#import "TSVersionModel.h"
#import "TSAboutCtrl/TSAboutSVCtrl.h"
#import "TSUserInfoView.h"
#import "TSSelectDeviceCtrl.h"
#import "TSHelper.h"
#import "TSNoticeCtrl.h"
#import "UIBarButtonItem+Badge.h"
#import "TSLanguageSetView.h"
#import "AppDelegate+RootCtrl.h"
#import "TSLanguageModel.h"

#import "TSGuideCtrl.h"

#import <objc/runtime.h>

@interface TSPersonCenterCtrl ()<UITableViewDelegate,UITableViewDataSource>

//@property (nonatomic, strong) UIImageView *headImgView;
//@property (nonatomic, strong) UILabel     *nameL;
@property (nonatomic, strong) TSUserInfoView *userView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *datas;
@property (nonatomic, strong) HTProgressHUD *hud;


/// cell上的发现新版本文字
@property (nonatomic, strong) NSString *versionUpdateText;

@end

@implementation TSPersonCenterCtrl{
    BOOL _isHaveNewVersion; //默认为NO
    UIBarButtonItem *_rightItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor whiteColor];
//    self.edgesForExtendedLayout = UIRectEdgeAll;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configSelfData];
    [self addNaviBlueImageBg];
    
//    self.navigationItem.title = NSLocalizedString(@"TabbarMe", nil);
    [self setNaviWhiteColorTitle:NSLocalizedString(@"TabbarMe", nil)];
    _isHaveNewVersion = NO;
    
    //隐藏返回按钮
    self.navigationItem.leftBarButtonItems = @[[UIBarButtonItem new]];
    [self addRightBarItemWithAction:@selector(handleNotice) imgName:@"mine_notice"];
    
    _rightItem = [self getRightBarItem];
    _rightItem.badgeBGColor = [UIColor redColor];
    _rightItem.badgeTextColor = [UIColor redColor];
    _rightItem.badgeMinSize = 2;
    
    [self addNotificaitonObserver];
    
        
    [self.dataProcess appLastVersionWithCompleteBlock:^(BOOL isHaveNewVersion, NSString *newVersionNum, NSError *err) {
        if( err ==nil ){
            if( isHaveNewVersion ){
                _versionUpdateText = newVersionNum;
            }
        }
        
        [self loadDatas];
    }];
//    [self checkIsHaveNewVersionIsShowHud:NO];
    
    //第一次进来，如果登录了。就获取一次用户数据，然后刷新
    [self loginSuccessNoti];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    if( self.dataProcess.userModel == nil ){
        [self loadDatas];
    }else{
        
        //若离线了，则刷新数据
        [TSHelper checkUserIsOfflineWithCtrl:self offlineBlock:^{
            [self loadDatas];
        }];
        
        [self checkIsHaveNewMsg];
    }
    //适配ios13，导航风格变黑，状态栏才会变白
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self setUserInfoData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //切换tabbar ，则什么也不做
    if( self.tabBarController.selectedIndex != self.tabBarController.view.tag ) return;
    //适配ios13，导航风格变浅，状态栏才会变黑
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self updateCacheSize];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [self removeNotifacionObserver];
}

#pragma mark - Private

//检查是否有新消息，有就展示小红点。
- (void)checkIsHaveNewMsg{
    
    if( [self isLogined] == NO ){
        _rightItem.badgeValue = @"0";
        return;
    }
    
    [self dispatchAsyncQueueWithName:@"newMsgQ" block:^{
        [self.dataProcess userMsgCountWithCompleteBlock:^(NSError *err, NSInteger count) {
            [self dispatchAsyncMainQueueWithBlock:^{
                NSString *badge = @"0";
                if( count > 0 ){
                    badge = @"1";
                }
                _rightItem.badgeValue = badge;
                
                CGRect fr = _rightItem.badge.frame;
                fr.size = CGSizeMake(10, 10);
                fr.origin.y = 5;
                _rightItem.badge.frame = fr;
                
                [_rightItem.badge cornerRadius:5];
            }];
        }];
    }];
}

- (void)loadDatas{
    [self dispatchAsyncQueueWithName:@"loadDatasQ" block:^{
        
        NSArray *leftTexts = @[NSLocalizedString(@"PersonDeviceConnect", nil),
//                               NSLocalizedString(@"PersonDeviceSelect", nil),
                               NSLocalizedString(@"PersonCourse", nil),
                               NSLocalizedString(@"PersonHelp", nil),
                               
                               NSLocalizedString(@"PersonFeedback", nil),
                               NSLocalizedString(@"PersonAboutProduct", nil),
                               NSLocalizedString(@"PersonClearCache", nil),
                               NSLocalizedString(@"PersonLanguageSetTitleKey", nil),
                               ];
        NSArray *leftImgNames = @[@"mine_connection",
//                                  @"mine_choose",
                                  @"mine_video",
                                  @"mine_help",
                                  @"mine_opinion",
                                  @"mine_about",
                                  @"mine_remove",
                                  @"mine_en"
                               ];
        NSMutableArray *arr = [NSMutableArray new];
        for( NSUInteger i=0; i<leftTexts.count; i++ ){
            TSPersonCenterCellModel *cm = [TSPersonCenterCellModel new];
            cm.leftText = leftTexts[i];
            cm.leftImgName = leftImgNames[i];
            if( i==5 ){
                cm.rightText = @"0.0M";
            }
            [arr addObject:cm];
        }
        
        if( [self isLogined] ){
            TSPersonCenterCellModel *cm = [TSPersonCenterCellModel new];
            cm.leftText = NSLocalizedString(@"PersonLogoutText", nil);
            cm.leftImgName = @"mine_exit";
            [arr addObject:cm];
        }
        
        if( self.dataProcess.versionModel.showUpdateItem == YES ){
            NSLog(@"----showupdateBtn----");
            TSPersonCenterCellModel *vm = [TSPersonCenterCellModel new];
            vm.leftText = NSLocalizedString(@"PersonVersionUpdate", nil);
            vm.leftImgName = @"mine_update";
            vm.rightText = _versionUpdateText;
            //NSLocalizedString(@"PersonFindNewVersion", nil);
            [arr insertObject:vm atIndex:3];
        }
        
        _datas = arr;
        
        [self dispatchAsyncMainQueueWithBlock:^{
            [self.tableView reloadData];
            
            [self setUserInfoData];
            [self doLayoutWithWidth:self.view.width];
        }];
    }];
}

- (void)updateCacheSize{
    [self dispatchAsyncQueueWithName:@"loadCacheSizeQ" block:^{
        CGFloat size = [[TSDataBase sharedDataBase] cacheSize];
        [self dispatchAsyncMainQueueWithBlock:^{
           [self updateCacheSize:size];
        }];
    }];
}

- (void)updateCacheSize:(CGFloat)size{
    NSUInteger cacheIndex = 5;
    if( self.dataProcess.versionModel.showUpdateItem == YES ){
        cacheIndex = 6;
    }
    
    if( cacheIndex < _datas.count ){
        TSPersonCenterCellModel *cm = _datas[cacheIndex];
        cm.rightText = [NSString stringWithFormat:@"%.1lfM",size];
//        NSIndexPath *cacheIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
//        [self.tableView reloadRowsAtIndexPaths:@[cacheIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView reloadData];
    }
}

- (void)checkIsHaveNewVersionIsShowHud:(BOOL)showHud{
    
//    //暂时屏蔽该功能
    //return;
    
    if( showHud )
        _hud = [HTProgressHUD showMessage:NSLocalizedString(@"正在检测更新", nil) toView:self.view];
    [self.dataProcess appLastVersionWithCompleteBlock:^(BOOL isHaveNewVersion, NSString *newVersionNumStr, NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            if( showHud ){
                [self->_hud hide];
            }
            if( err ){
                if( showHud ){
                    [self showErrMsgWithError:err];
                }
            }else{
                self->_isHaveNewVersion = isHaveNewVersion;
                [self updateVersionUpdateText:newVersionNumStr];
                if( showHud ){
                    [self showCheckVersionResultWithIsNew:self->_isHaveNewVersion versionDes:newVersionNumStr];
                }
            }
        }];
    }];
}

- (void)updateVersionUpdateText:(NSString*)text{
    NSInteger vidx = 3;
    if( _datas.count > vidx ){
        TSPersonCenterCellModel *cm = _datas[vidx];
        cm.rightText = text;
        
        [self.tableView reloadData];
    }
}

- (void)showCheckVersionResultWithIsNew:(BOOL)isNew versionDes:(NSString*)vDes{
    if( isNew ){

        NSString *title = NSLocalizedString(@"PersonFindNewVersion", nil);
        NSString *msg = vDes;
//        self.dataProcess.versionModel.DESCRIPTION;
    
//        [self showAlertViewWithTitle:title msg:msg okBlock:^{
//
//            [self.dataProcess openApplicationInAppStore];
//
//        } cancleBlock:^{
//
//        } ];
        
        [self showAlertViewWithTitle:title msg:msg okBlock:^{
            [self.dataProcess openApplicationInAppStore];
        } cancleBlock:^{
            
        } okTitle:NSLocalizedString(@"去更新", nil) cancleTitle:nil];
        
    }else{
        [HTProgressHUD showSuccess:NSLocalizedString(@"PersonIsLatestVersion", nil) toView:self.view];
    }
}

- (void)setUserInfoData{
    
    TSUserModel *um = self.dataProcess.userModel;
    self.userView.model = um;
}

- (NSInteger)indexWithIndexPath:(NSIndexPath*)ip{
    NSInteger section = ip.section;
    if( section == 0 ){
        return ip.row;
    }
    
    if( section == 1 ){
        return ip.row + 3;
    }
    
    if( section == 2 ){

        BOOL showUpdateBtn = self.dataProcess.versionModel.showUpdateItem;
        return ip.row + 8-(showUpdateBtn?0:1);
    }
    
    return 0;
}


- (void)clearDataCache{
    [self dispatchAsyncQueueWithName:@"clearQ" block:^{
        [[TSDataBase sharedDataBase] clearCache];
        [self dispatchAsyncMainQueueWithBlock:^{
            [HTProgressHUD showSuccess:NSLocalizedString(@"PersonCleardCache", nil)];///@"已清除缓存"];
            [self updateCacheSize];
        }];
    }];
}

- (void)addNotificaitonObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNoti) name:TSConstantNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyHeadImgSuccessNoti) name:TSConstantNotificationModifyUserImgSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyUserNameSuccessNoti) name:TSConstantNotificationModifyUserNameSuccess object:nil];
}

- (void)removeNotifacionObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationModifyUserNameSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationModifyUserImgSuccess object:nil];
}

- (void)logout{

    [self.dataProcess logoutWithCompleteBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                [HTProgressHUD showSuccess:NSLocalizedString(@"PersonLogoutSuccess", nil)];//@"退出成功"];
                [self logoutSuccess];
            }
        }];
    }];
}

- (void)gotoUserInfoCtrl{
    TSUserInfoCtrl *ic = [TSUserInfoCtrl new];
    ic.hidesBottomBarWhenPushed = YES;
    [self pushViewCtrl:ic];
}

//- (void)gotoMyWorkCtrls{
//    TSMyWorkCtrl *wc = [[TSMyWorkCtrl alloc] initWithSelectedItemIdx:0];
//    [self pushViewCtrl:wc];
//}

- (void)gotoHelpCtrl{
    TSWebPageCtrl *pc  = [TSWebPageCtrl new];
    pc.title = NSLocalizedString(@"HelpPageTitle", nil);//@"系统帮助";
    pc.pageUrl = [TSConstantServerUrl stringByAppendingPathComponent:@"help-en.html"];//@"http://www.aipp3d.com:9000/help-en.html";
    if( [[NSString getPreferredLanguage] containsString:@"zh-Han"] ){
        //中文环境
        pc.pageUrl = [TSConstantServerUrl stringByAppendingPathComponent:@"help.html"]; //@"http://www.aipp3d.com:9000/help.html";
    }
    pc.hidesBottomBarWhenPushed = YES;
    [self pushViewCtrl:pc];
}

- (void)gotoVideoCourseCtrl{
    TSCourseCtrl *cc = [TSCourseCtrl new];
    cc.hidesBottomBarWhenPushed = YES;
    [self pushViewCtrl:cc];
}

- (void)gotoFeedBackCtrl{
    
    if( [self isLoginedWithGotoLoginCtrl]==NO ) return;
    
    TSFeedbackCtrl *bc = [TSFeedbackCtrl new];
    bc.hidesBottomBarWhenPushed = YES;
    [self pushViewCtrl:bc];
}

- (void)gotoAboutCtrl{
//    TSAboutCtrl *ac = [TSAboutCtrl new];
//    [self.mm_drawerController pushViewCtrl:ac];
    TSAboutSVCtrl *ac = [TSAboutSVCtrl new];
    ac.hidesBottomBarWhenPushed = YES;
    [self pushViewCtrl:ac];
    
}

- (void)gotoDeviceCtrl{
    TSDeviceConnectCtrl *cc = [TSDeviceConnectCtrl new];
    cc.hidesBottomBarWhenPushed = YES;
    cc.needGotoCamera = NO;
    [self pushViewCtrl:cc];
}

//切换语言后，直接重新更换根视图，并进入语言页面
- (void)updateRootCtrl{
    
    //重置所有的共用ctrl实例
    [TSDataProcess sharedDataProcess].helper = [TSHelper new];
    
    AppDelegate *del = ((AppDelegate*)([UIApplication sharedApplication].delegate));
    del.window.rootViewController = [TSHelper getRootCtrl];
    
//    [TSLanguageModel setLanguageWithModel:[TSLanguageModel currLanguageModel]];
    
    UITabBarController *tabbar = (UITabBarController*)(del.window.rootViewController);
    if( [tabbar isKindOfClass:[UITabBarController class]] ){
        [tabbar setSelectedIndex:3];
        
//        FTSystemSettingCtrl *sc = [FTSystemSettingCtrl new];
//        sc.hidesBottomBarWhenPushed = YES;
//        UINavigationController *navi = tabbar.selectedViewController;
//        if( [navi isKindOfClass:[UINavigationController class]] ){
//            [navi pushViewController:sc animated:NO];
//        }
    }
}


#pragma mark - Layout

- (void)doLayoutWithWidth:(CGFloat)width{
    CGFloat tableviewX = 0;
    CGFloat tableviewW = width-tableviewX;
//    CGRect fr = self.headImgView.frame;
//    fr.origin.x = (tableviewW-fr.size.width)/2 + tableviewX;
//    self.headImgView.frame = fr;
//
//    CGFloat nameH = [self.nameL labelSizeWithMaxWidth:tableviewW].height;
//    CGFloat yGap = 10,iRight = 15;
//    self.nameL.frame = CGRectMake(tableviewX+iRight, self.headImgView.bottom+yGap, tableviewW-iRight*2, nameH);
//
    CGFloat iy = NAVGATION_VIEW_HEIGHT;
    self.tableView.frame = CGRectMake(tableviewX, iy, tableviewW, SCREEN_HEIGHT-iy);
}

#pragma mark - Notifacitons

- (void)loginSuccessNoti{
    
    if( self.dataProcess.userModel == nil ) return;
    
    //登录成功的通知
    //登录成功，拉取一次用户信息
    [self.dataProcess userInfoWithCompleteBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            [self setUserInfoData];
            
            [self loadDatas];
            
            [self updateCacheSize];
        }];
    }];
}

- (void)modifyHeadImgSuccessNoti{
    [self.dataProcess userInfoWithCompleteBlock:^(NSError *err) {
        if( err ) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
           [self updateHeadImg];
        });
    }];
}

- (void)modifyUserNameSuccessNoti{
    self.userView.nameL.text = self.dataProcess.userModel.userName;
//    self.userView.signatureL.text = self.dataProcess.userModel.signature;
    
    TSUserModel *um = self.dataProcess.userModel;
    NSString *sign = NSLocalizedString(@"UserInfoSignatureDefault", nil);
    if( um.signature.length ){
        sign = um.signature;
    }
    
    NSString *markText = [NSLocalizedString(@"UserInfoSignatureMark", nil) stringByAppendingString:@":"];
    self.userView.signatureL.text = [markText stringByAppendingString:sign];
}

#pragma mark - NotiPrivate

- (void)logoutSuccess{
    [self setUserInfoData];
//    if(_datas.count ==9 ){
//        NSMutableArray *arr = [NSMutableArray arrayWithArray:_datas];
//        [arr removeLastObject];
//        _datas = arr;
//        [self.tableView reloadData];
//    }
    
    [self loadDatas];
    
    _rightItem.badgeValue = @"0";
    
    //退出成功，发送重新刷新首页列表数据
    [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationLoginSuccess object:nil];
}

- (void)updateHeadImg{
    
    NSURL *url = [NSURL URLWithString:self.dataProcess.userModel.userImgUrl];
    [self.userView.headImgView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRefreshCached];
}


#pragma mark - TouchEvents
- (void)handleUserView{
    if( ![self isLoginedWithGotoLoginCtrlWithPushCtrl:self] ) return;
    
    [self gotoUserInfoCtrl];
}

- (void)handleNotice{
    NSLog(@"-----");
    if([self isLoginedWithGotoLoginCtrl]==NO ) return;
    
    TSNoticeCtrl *nc = [TSNoticeCtrl new];
    nc.hidesBottomBarWhenPushed = YES;
    [self pushViewCtrl:nc];
}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if( section == 0 ){
        return 3;
    }
    
    if( section == 1 ){
        BOOL showUpdateBtn = self.dataProcess.versionModel.showUpdateItem;
        return 4-(showUpdateBtn?0:1) + 1; //+1 为语言设置
    }
    
    if( [self isLogined] ){
        return 1;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *reuseId = @"personCenterCellReuseID";
    TSPersonCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if( !cell ){
        cell = [[TSPersonCenterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        cell.showLeftImg = YES;
    }
    NSUInteger idx = [self indexWithIndexPath:indexPath];
    cell.model = (TSPersonCenterCellModel*)[self modelAtIndex:idx datas:_datas modelClass:[TSPersonCenterCellModel class]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if( section == 0 )
//        return 0;
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if( section == 0 ) return nil;
    CGFloat ih = [self tableView:tableView heightForHeaderInSection:section];
    UIView *view =  [UIView new];
    view.backgroundColor = self.view.backgroundColor;
    view.frame = CGRectMake(0, 0, tableView.width, ih);
    
//    UIView *line = [UIView new];
//    ih = 0.5;
//    line.frame = CGRectMake(0, (view.height-ih)/2, view.width, ih);
//    line.backgroundColor = [UIColor colorWithRgb221];
//    [view addSubview:line];
    
    return view;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

//    TSGuideCtrl *cc = [TSGuideCtrl new];
////    cc.imgs = @[[UIImage imageNamed:@"demo.jpeg"]];
//    [self pushViewCtrl:cc];
//    return;
 
    BOOL showUpdateBtn = self.dataProcess.versionModel.showUpdateItem;
    NSUInteger tempInt = 1;
    if( showUpdateBtn ) tempInt = 0;
    NSUInteger idx = [self indexWithIndexPath:indexPath];
    
    idx = idx+1;
    
    if( idx == 1 ){
        //设备连接
        [self gotoDeviceCtrl];
    }
//    else if (idx == 1 ){
//        //产品选择
//        TSSelectDeviceCtrl *dc = [TSSelectDeviceCtrl new];
//        dc.hidesBottomBarWhenPushed = YES;
//        [self pushViewCtrl:dc];
//    }
    else if( idx == 2 ){
        //视频教程
        [self gotoVideoCourseCtrl];
    }
    else if(idx == 3 ){
        [self gotoHelpCtrl];
    }
//
//    else if( idx == 4 ){
//        //清空缓存
//        [self clearDataCache];
//    }
    else if( idx == 4 && showUpdateBtn){
        [self checkIsHaveNewVersionIsShowHud:YES];
        //暂时用本地更新的方法
        //[self checkNewVersion];
    }
    else if( idx == 5-tempInt ){
        //意见反馈
        [self gotoFeedBackCtrl];
        
    }else if( idx==6-tempInt ){
        [self gotoAboutCtrl];
    }
    else if( idx == 7-tempInt ){
        //清除缓存
        [self clearDataCache];
    }
    
    else if( idx == 8-tempInt ){
        //语言设置
        [TSLanguageSetView showWithComplete:^{
            [self updateRootCtrl];
        }];
    }
    
    else if( idx == 9-tempInt ){
        //退出登录
        [self showAlertViewWithTitle:nil msg:NSLocalizedString(@"PersonSureQuitting", nil) okBlock:^{
            [self logout];
        } cancleBlock:^{
            
        }];
    }
}

#pragma mark - 版本更新提示(本地比较版本号)
-(void)checkNewVersion{
    //定义的app的地址
    NSString *urld = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@",@"1132012014"];
    //网络请求app的信息，主要是取得我说需要的Version
    NSURL *url = [NSURL URLWithString:urld];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10]; [request setHTTPMethod:@"POST"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary *receiveStatusDic=[[NSMutableDictionary alloc]init];
        if (data) {
            //data是有关于App所有的信息
            NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if ([[receiveDic valueForKey:@"resultCount"] intValue]>0) {
                [receiveStatusDic setValue:@"1" forKey:@"status"]; [receiveStatusDic setValue:[[[receiveDic valueForKey:@"results"] objectAtIndex:0] valueForKey:@"version"] forKey:@"version"];
                //请求的有数据，进行版本比较
                [self performSelectorOnMainThread:@selector(receiveData:) withObject:receiveStatusDic waitUntilDone:NO];
                
            }else{
                
                [receiveStatusDic setValue:@"-1" forKey:@"status"];
                
            }
            
        }else{
            
            [receiveStatusDic setValue:@"-1" forKey:@"status"];
        }
        
    }];
    [task resume];
}

-(void)receiveData:(id)sender {
    //获取APP自身版本号
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"]; NSArray *localArray = [localVersion componentsSeparatedByString:@"."];
    NSArray *versionArray = [sender[@"version"] componentsSeparatedByString:@"."];
    if ((versionArray.count == 3) && (localArray.count == versionArray.count)) {
        
        if ([localArray[2] intValue]>=[versionArray[2] intValue]) {
            [self showNoNewVersion];
        }
        if ([localArray[0] intValue] < [versionArray[0] intValue]) {
            [self updateVersion];
            
        }else if ([localArray[0] intValue] == [versionArray[0] intValue]){
            if ([localArray[1] intValue] < [versionArray[1] intValue]) {
            [self updateVersion];
                
            }else if ([localArray[1] intValue] == [versionArray[1] intValue]){
                if ([localArray[2] intValue] < [versionArray[2] intValue]) {
                    [self updateVersion];
                }
            }
        }
    }
}

-(void)updateVersion{
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"发现新版本，是否前往应用商店更新？",nil)];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"更新提示",nil) message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"更新",nil)style:UIAlertActionStyleDestructive handler:^(UIAlertAction*action) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/moispano/id1132012014?mt=8"]];
        //[[UIApplication sharedApplication]openURL:url];
        [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @YES} completionHandler:^(BOOL success) {
            NSLog(@"成功回到");
        }];
        
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:cancleAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)showNoNewVersion{
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    NSString *msg = [NSString stringWithFormat:@"%@ %@",localVersion,NSLocalizedString(@"已是最新版本",nil)];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"版本提示",nil) message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定",nil) style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:cancleAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Property

- (UITableView *)tableView{
    if( !_tableView) {
        _tableView = [[HTTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        UIView *fv =[[UIView alloc] init];
        
        fv.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
        fv.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = fv;
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.bounces = YES;
        _tableView.tableHeaderView = self.userView;
        [self.view addSubview:_tableView];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }

    return _tableView;
}

- (TSUserInfoView *)userView {
    if( !_userView ){
        _userView = [[TSUserInfoView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
        _userView.backgroundColor = [UIColor whiteColor];
//        [self.view addSubview:_userView];
        
        _userView.userInteractionEnabled = YES;
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserView)];
        [_userView addGestureRecognizer:ges];
    }
    return _userView;
}

#pragma mark - status bar
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//- (UIImageView *)headImgView {
//    if( !_headImgView ){
//        _headImgView = [[UIImageView alloc] init];
//        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
//        _headImgView.backgroundColor = [UIColor whiteColor];
//        CGFloat wh = 80;
//        _headImgView.frame = CGRectMake(0, 64, wh, wh);
//        [_headImgView cornerRadius:wh/2];
//        [self.view addSubview:_headImgView];
//
//        _headImgView.userInteractionEnabled = YES;
//        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeadImg)];
//        [_headImgView addGestureRecognizer:ges];
//    }
//    return _headImgView;
//}
//
//- (UILabel *)nameL {
//    if( !_nameL ){
//        _nameL = [[UILabel alloc] init];
//        _nameL.textAlignment = NSTextAlignmentCenter;
//
//        _nameL.font = [UIFont systemFontOfSize:15];
//        _nameL.textColor = [UIColor colorWithRgb51];
//        _nameL.numberOfLines = 0;
//
//        [self.view addSubview:_nameL];
//        _nameL.userInteractionEnabled = YES;
//        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNameL)];
//        [_nameL addGestureRecognizer:ges];
//    }
//    return _nameL;
//}

@end
