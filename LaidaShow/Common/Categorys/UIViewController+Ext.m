//
//  UIViewController+Ext.m
//  Hitu
//
//  Created by hitomedia on 16/6/21.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import "UIViewController+Ext.h"
#import "UIColor+Ext.h"
#import "KError.h"
#import "TSDataProcess.h"
#import "TSLoginCtrl.h"
#import "HTNaviBgView.h"
#import "MJRefresh.h"
#import "HTProgressHUD.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "TSCourseCtrl.h"
#import "TSDataBase.h"
#import "TSConstants.h"

@implementation UIViewController (Ext)

- (void)extracted {
    [self changeBackBarItem];
}

- (void)configSelfData{
    self.view.backgroundColor = [UIColor colorWithRgb_240_239_244];
    [self getNaviBgView];
    [self extracted];
}


#pragma mark - Public

-(void)changeBackBarItemWithAction:(SEL)action{
    self.navigationItem.leftBarButtonItems = [self leftItemsWithTarget:self
                                                                action:action];
}

-(void)changeBackBarItem{
    [self changeBackBarItemWithAction:@selector(handleBackBtn:)];
}

-(void)addLeftBarItemWithAction:(SEL)action{
    self.navigationItem.leftBarButtonItems = [self leftItemsWithTarget:self
                                                                action:action
                                                               imgName:@"arrow_left_51"];
}

- (void)addLeftBarItemWithAction:(SEL)action imgName:(NSString *)imgName{
    NSArray *btns = [self leftItemsWithTarget:self action:action imgName:imgName];
    self.navigationItem.leftBarButtonItems = btns;
}

-(void)addLeftBarItem{
    [self addLeftBarItemWithAction:@selector(handleLeftBtn:)];
}

- (void)addLeftBarItemWithTitle:(NSString *)title action:(SEL)action{
    UIBarButtonItem *bar =
    [self barItemWithNormalTitle:title normalImage:nil hightImage:nil selectedImg:nil andTarget:self andAction:action titleAlignment:NSTextAlignmentLeft contentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.navigationItem.leftBarButtonItem = bar;
}

- (void)addRightBarItemWithTitle:(NSString *)title
                          action:(SEL)action{
    self.navigationItem.rightBarButtonItems = [self rightItemsWithTitle:title
                                                                imgName:nil
                                                             selImgName:nil
                                                                 action:action
                                                              titleFont:[UIFont systemFontOfSize:15.0]
                                               titleColor:nil];
}

-(void)addRightBarItemWithTitle:(NSString *)title
                        imgName:(NSString *)imgName
                     selImgName:(NSString *)selImgName
                         action:(SEL)action
                     titleColor:(UIColor*)color
                      titleFont:(UIFont *)font{
    self.navigationItem.rightBarButtonItems = [self rightItemsWithTitle:title
                                                                imgName:imgName
                                                             selImgName:selImgName
                                                                 action:action
                                                              titleFont:font
                                               titleColor:color];
}

-(void)addRightBarItemWithTitle:(NSString *)title imgName:(NSString *)imgName selImgName:(NSString *)selImgName action:(SEL)action textAlignment:(NSTextAlignment)textAlignment{
    
    UIBarButtonItem *rightBarItem = [self barItemWithNormalTitle:title
                                                     normalImage:imgName
                                                      hightImage:nil
                                                     selectedImg:selImgName
                                                       andTarget:self andAction:action titleAlignment:NSTextAlignmentRight];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
    negativeSpacer.width = -5;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightBarItem];
    
}

- (UIButton *)getButtonAtRightBarItem{
    NSArray *btns =
    self.navigationItem.rightBarButtonItems;
    for( UIBarButtonItem *bi in btns ){
        if( [bi.customView isKindOfClass:[UIButton class]] ){
//            bi.enabled = NO;
            return (UIButton*)(bi.customView);
        }
    }
    return nil;
}

- (UIBarButtonItem *)getRightBarItem{
    NSArray *btns =
    self.navigationItem.rightBarButtonItems;
    for( UIBarButtonItem *bi in btns ){
        if( [bi.customView isKindOfClass:[UIButton class]] ){
            //            bi.enabled = NO;
            return bi;
        }
    }
    return nil;
}
-(void)addRightBarItemWithTitle:(NSString *)title action:(SEL)action titleFont:(UIFont*)font{
    [self addRightBarItemWithTitle:title
                           imgName:nil selImgName:nil
                            action:action titleColor:nil titleFont:nil];
}

- (void)addRightBarItemWithAction:(SEL)action imgName:(NSString *)imgName{
    [self addRightBarItemWithTitle:nil imgName:imgName selImgName:nil action:action textAlignment:NSTextAlignmentLeft];
}

#pragma mark - NavigationBar

- (UIView*)addNaviBgViewWithNoHaveBottomLine{
    HTNaviBgView *navi = (HTNaviBgView*)[self addNaviBgView];
    if( [navi isKindOfClass:[HTNaviBgView class]] ){
        navi.bottomLine.hidden = YES;
    }
    return navi;
}

- (UIView*)addNaviBgView {
    UIView *navi = [self.view viewWithTag:TagNaviBgView];
    if( [navi isKindOfClass:[HTNaviBgView class]] ) return navi;
    
    UIView *bgView = [[HTNaviBgView alloc] init];
    bgView.tag = TagNaviBgView;
    CGFloat navH = NAVGATION_VIEW_HEIGHT;
    bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, navH);
    bgView.backgroundColor = [UIColor whiteColor];//colorWithRgb_24_148_209];
    [self.view addSubview:bgView];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    return bgView;
}

- (UIView*)getNaviBgView {

    return [self addNaviBgView];
}

- (void)setNavigationBarBgClear{
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)addNaviBlueImageBg{
    UIView *naviV = [self getNaviBgView];
    naviV.backgroundColor = [UIColor colorWithRgb_0_151_216];
//    UIImageView *iv = [UIImageView new];
//    iv.frame = naviV.bounds;
//    iv.contentMode = UIViewContentModeScaleToFill;
//    [naviV addSubview:iv];
//
//    iv.image = [UIImage imageNamed:@"bar_bg"];
}

- (void)setStatusBarStyleIsDefault:(BOOL)isDefault{
    [[UIApplication sharedApplication] setStatusBarStyle:isDefault?UIStatusBarStyleDefault:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setNaviWhiteColorTitle:(NSString *)title{
    
    UILabel *lbl = [UILabel new];
    lbl.frame = CGRectMake(0, 0, 100, 40);
    lbl.text = title;
    lbl.font = [UIFont fontWithName:@"STHeitiSC-Light"//@"STHeitiSC-Light"
                               size:18.0];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = lbl;
}

#pragma mark - Views

- (NSInteger)getTagBase{
    return 999;
}

- (BOOL)isViewShowing{
    return self.view.window && self.isViewLoaded;
}

- (void)configRefreshTableView:(UIScrollView*)tableView freshSel:(SEL)freshSel{
    
    if( [self respondsToSelector:freshSel] ){
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:freshSel];
        tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:freshSel];
    }
}

- (void)configheaderRefreshTableView:(UIScrollView*)tableView freshSel:(SEL)freshSel{
    
    if( [self respondsToSelector:freshSel] ){
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:freshSel];
    }
}

- (BOOL)isTableViewHeadRefreshing:(UIScrollView*)tableView{
    return tableView.mj_header.isRefreshing;
}

- (void)beginHeadRefreshWithTableView:(UIScrollView*)tb{
    if( tb.mj_header.isRefreshing ==NO )
        [tb.mj_header beginRefreshing];
}

- (void)beginfootedRefreshWithTableView:(UIScrollView*)tableView{
    [tableView.mj_footer beginRefreshing];
}

- (void)endRefreshWithIsHeadFresh:(BOOL)isHeadFresh isHaveNewData:(BOOL)isHaveNewData tableView:(UIScrollView*)tableView{
    
    if (isHeadFresh) {
        if( tableView.mj_header.isRefreshing ){
            [tableView.mj_header endRefreshing];
        }
        if( tableView.mj_footer.isRefreshing )
            [tableView.mj_footer resetNoMoreData];
    }else if (isHaveNewData){
        if( tableView.mj_footer.isRefreshing )
            [tableView.mj_footer endRefreshing];
    }else{
        if( tableView.mj_footer.isRefreshing )
            [tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (void)resetNoMoreDataWithTableView:(UITableView*)tableView{
    [tableView.mj_footer resetNoMoreData];
}


#pragma mark __NoDataView
//- (void)showNoDataViewWithFrame:(CGRect)fr err:(NSError*)err loadDataSel:(SEL)loadDataSel{
//
//    NSUInteger tag = [self noDataViewTag];
//    NSString *text = [KError errorMsgWithError:err];
//    BOOL hideBtn = (err.code == ReturnCodeNoData.integerValue);
//    NoDataView *noDataView = [self.view viewWithTag:tag];
//    if( ![noDataView isKindOfClass:[NoDataView class]] ){
//        noDataView = [[NoDataView alloc] initWithFrame:fr text:text action:loadDataSel target:self];
//        noDataView.tag = tag;
//        [self.view addSubview:noDataView];
//    }else{
//        noDataView.hidden = NO;
//        noDataView.text = text;
//    }
//    noDataView.hideReloadBtn = hideBtn;
//}

- (void)hideNoDataView{
    [self.view viewWithTag:[self noDataViewTag]].hidden = YES;
}

- (NSUInteger)noDataViewTag{
    return 19980890;
}
#pragma mark __AlertView

- (void)showAlertViewWithTitle:(NSString *)title msg:(NSString*)msg okBlock:(void(^)())okBlock cancleBlock:(void(^)(void))cancleBlock{
    [self showAlertViewWithTitle:title msg:msg okBlock:okBlock cancleBlock:cancleBlock okTitle:nil cancleTitle:nil];
}

- (void)showAlertViewWithTitle:(NSString *)title msg:(NSString*)msg okBlock:(void(^)(void))okBlock cancleBlock:(void(^)(void))cancleBlock okTitle:(NSString*)ot cancleTitle:(NSString*)ct {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    if( cancleBlock ){
        if( [ct isKindOfClass:[NSString class]] == NO){
            ct = NSLocalizedString(@"WorkDetailSheetCancle", nil);//@"取消";
        }
        [ac addAction:[UIAlertAction actionWithTitle:ct style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setNeedsStatusBarAppearanceUpdate];
            cancleBlock();
        }]];
    }

    
    if( okBlock ){
        if( [ot isKindOfClass:[NSString class]] == NO){
            ot = NSLocalizedString(@"WorkEditBottomMusicConfirmText", nil);//@"确定";
        }
        [ac addAction:[UIAlertAction actionWithTitle:ot style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            //解决Alert弹出后，状态栏变白的问题
            [self setNeedsStatusBarAppearanceUpdate];
            okBlock();
        }]];
    }
    
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - UITextField

- (void)addDoneBtnWithView:(UITextView*)tvTextView{
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [topView setBarStyle:UIBarStyleDefault];
    
    UIBarButtonItem * helloButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(tlcategory_dismissKeyBoard)];
    doneButton.tintColor = [UIColor colorWithRed:0 green:160/255.0 blue:233/255.0 alpha:1];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:helloButton,btnSpace,doneButton,nil];
    [topView setItems:buttonsArray];
    [tvTextView setInputAccessoryView:topView];
}

//添加收回键盘收拾到本控制器的根视图
- (void)addHideKeyboardGestureToView{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tlcategory_dismissKeyBoard)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tap];
}

- (void)tlcategory_dismissKeyBoard{
    [self.view endEditing:YES];
}

#pragma mark - Tabbar
//- (void)setTabbarBackGroundWithIsClear:(BOOL)isClear{
//    HTTabbarCtrl *tbCtrl = (HTTabbarCtrl*)self.tabBarController;
//    if( [tbCtrl isKindOfClass:[HTTabbarCtrl class]] ){
//        
//        [tbCtrl updateTabbarWithSelectedIndex:!isClear];
//    }
//}

#pragma mark - NativeString

- (NSString *)stringWithKey:(NSString *)key{
    if( key == nil )
        return key;
    return NSLocalizedString(key, nil);
}

#pragma mark - UIViewController

/**
 push ctrl with animate
 
 @param ctrl 需要push的实力
 */
- (void)pushViewCtrl:(UIViewController*)ctrl{
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)popToCtrlWithClass:(Class)ctrlClass{
    for( UIViewController *ctrl in self.navigationController.viewControllers ){
        if( [ctrl isKindOfClass:ctrlClass] ){
            [self.navigationController popToViewController:ctrl animated:YES];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIViewController *)getCtrlAtNavigationCtrlsWithCtrlClass:(Class)ctrlClass{
    if( ctrlClass == nil ) return nil;
    for( UIViewController *ctrl in self.navigationController.viewControllers ){
        if( [ctrl isKindOfClass:ctrlClass] ){
            return ctrl;
        }
    }
    return nil;
}

#pragma mark - WKWebView
-(void)loadHtmlWithWebView:(WKWebView*)webView filePath:(NSString*)fp{
    NSString *filePath = fp;//[[NSBundle mainBundle] pathForResource:@"provisions" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:filePath]];
}

#pragma mark - Login

- (BOOL)isLogined{
    
    return [TSDataProcess sharedDataProcess].userModel;
}

- (BOOL)isLoginedWithGotoLoginCtrl{
    return [self isLoginedWithGotoLoginCtrlWithPushCtrl:self];
}

- (BOOL)isLoginedWithGotoLoginCtrlWithPushCtrl:(UIViewController*)puchCtrl{
    BOOL isLogin = [self isLogined];
    
    if( isLogin == NO ){
        TSLoginCtrl *lc = [[TSLoginCtrl alloc ] init];
        lc.hidesBottomBarWhenPushed = YES;
        UIViewController *pc = self;
        if( puchCtrl ){
            pc = puchCtrl;
        }
        
        [pc.navigationController pushViewController:lc animated:YES];
    }
    
    return isLogin;
}

//- (BOOL)isLoginedWithLoginCtrlNeedNavBgView:(BOOL)needNavBgView isNeedBackBtn:(BOOL)isNeedBackBtn{
//    BOOL isLogin = ([[HTDataProcess sharedDataProcess] userModel]);
//
//    if( isLogin == NO ){
//        HTLoginCtrl *lc = [[HTLoginCtrl alloc ] init];
//        if( isNeedBackBtn )
//            lc.hidesBottomBarWhenPushed = YES;
//        lc.isNeedNavBg = needNavBgView;
//        lc.isNeedBackBtn = isNeedBackBtn;
//        [self.navigationController pushViewController:lc animated:YES];
//    }
//
//    return isLogin;
//}

//- (void)goto12306LoginCtrlWithHidesBottomBarWhenPushed:(BOOL)hideBottom{
//    HT12306LoginCtrl *lc = [[HT12306LoginCtrl alloc] init];
//    lc.hidesBottomBarWhenPushed = hideBottom;
//    [self.navigationController pushViewController:lc animated:YES];
//}
//
//- (void)goto12306LoginCtrlWithHidesBottomBarWhenPushed:(BOOL)hideBottom loginSuccessBlock:(void (^)(id))loginSuccessBlock{
//    HT12306LoginCtrl *lc = [[HT12306LoginCtrl alloc] init];
//    lc.hidesBottomBarWhenPushed = hideBottom;
//    lc.loginSuccessBlock = loginSuccessBlock;
//    [self.navigationController pushViewController:lc animated:YES];
//}
//
#pragma mark - Error Msg

- (void)showErrMsg:(NSString *)errMsg{
    [HTProgressHUD showError:errMsg];
}

- (void)showErrMsgWithError:(NSError *)err{
    
    if( [self isViewShowing] == NO ) return;

    NSString *errMsg = [KError errorMsgWithError:err];
    if( [errMsg containsString:@"请重新登录"] && self.dataProcess.userModel ){
        [[TSDataBase sharedDataBase] removeUserModel];
        
        [self isLoginedWithGotoLoginCtrl];
//        TSLoginCtrl *lc = [[TSLoginCtrl alloc ] init];
//        lc.hidesBottomBarWhenPushed = YES;
//        UIViewController *pc = self;
//        [pc.navigationController pushViewController:lc animated:YES];
    }
    [self showErrMsg:errMsg];
}
//
//- (void)showErrMsgAlertWithError:(NSError*)err{
//    if( [self isViewShowing] == NO ) return;
//    NSString *errMsg = [KError errorMsgWithError:err];
//    [self showAlertViewWithTitle:nil msg:errMsg okBlock:^{
//        
//    } cancleBlock:nil];
//}

//- (void)showErrMsgAlertWithError:(NSError*)err okBlock:(void(^)())okBlock{
//    [self showErrMsgAlertWithError:err okBlock:okBlock okTitle:nil];
//}

//- (void)showErrMsgAlertWithError:(NSError*)err okBlock:(void(^)())okBlock okTitle:(NSString*)ot{
//    if( [self isViewShowing] == NO ) return;
//    NSString *errMsg = [KError errorMsgWithError:err];
//    if( err.code == ReturnCodeNotLogined ){
//        [self goto12306LoginCtrlWithHidesBottomBarWhenPushed:YES loginSuccessBlock:^(id obj) {
//            [self.navigationController popViewControllerAnimated:YES];
//        }];
//    }
//    else
//        [self showAlertViewWithTitle:nil msg:errMsg okBlock:okBlock cancleBlock:nil okTitle:ot cancleTitle:nil];
//}
//
//- (void)showErrMsgWithErrCode:(NSInteger)code{
//    if( [self isViewShowing] == NO ) return;
//    
//    NSString *errDes = [KError errorMsgWithCode:code];
//    [HTProgressHUD showError:errDes];
//}

//- (NSString *)errMsgWithError:(NSError *)err{
//
//    if( err ){
//        NSString *msg = [KError errorMsgWithError:err];
//        return msg;
//    }
//    return nil;
//}
//
//- (void)showMsgWithErrMsg:(NSString *)errMsg successMsg:(NSString *)successMsg{
//    
//    if( [self isViewShowing] == NO ) return;
//    
//    if( errMsg.length > 0 ){
//        [HTProgressHUD showError:errMsg];
//    }
//    else if( successMsg.length > 0 ){
//        [HTProgressHUD showSuccess:successMsg];
//    }
//}

#pragma mark - Dispatch

//- (void)dispatchAsyncWithQueueName:(const NSString *)queueName newQueueBlock:(NSError*(^)(void))newQueueBlock mainQueueBlock:(void(^)(NSError *err))mainBlock isNeedProgressHud:(BOOL)isNeedProgressHud{
//    
//    HTProgressHUD *hud = nil;
//    if( isNeedProgressHud ){
//       hud = [HTProgressHUD showMessage:nil toView:self.view];
//    }
//    dispatch_queue_t queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
//    dispatch_async(queue, ^{
//        NSError* errMsg = nil;
//        if( newQueueBlock ){
//            errMsg = newQueueBlock();
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( isNeedProgressHud ){
//                [hud hide];
//            }
//            
//            if( mainBlock ){
//                mainBlock(errMsg);
//            }
//        });
//    });
//}

- (void)dispatchAsyncWithQueueName:(const NSString *)queueName newQueueBlock:(NSError*(^)(void))newQueueBlock mainQueueBlock:(void(^)(NSError *err))mainBlock{
    
    [self dispatchAsyncWithQueueName:queueName newQueueBlock:newQueueBlock mainQueueBlock:mainBlock isNeedProgressHud:YES];
}

- (void)dispatchAsyncQueueWithName:(const NSString *)queueName block:(dispatch_block_t)queueBlock{
    dispatch_queue_t queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, queueBlock);
}

- (void)dispatchAsyncDelay:(NSUInteger)second mainBlock:(dispatch_block_t)mainBlock{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       
                       if( mainBlock ){
                           mainBlock();
                       }
                   });
}

- (void)dispatchAsyncMainQueueWithBlock:(dispatch_block_t)mainBlock{
    dispatch_async(dispatch_get_main_queue(), ^{
        if( mainBlock ){
            mainBlock();
        }
    });
}

#pragma mark - DataProcess

- (TSDataProcess*)dataProcess{
    return [TSDataProcess sharedDataProcess];
}

- (NSObject *)modelAtIndex:(NSUInteger)index datas:(NSArray *)datas modelClass:(Class)classType{
    if( [datas isKindOfClass:[NSArray class]] ){
        if( datas.count > index ){
            id obj = datas[index];
            if( [obj isKindOfClass:classType] ){
                return obj;
            }
        }
    }
    
    return nil;
}

- (NSObject *)modelAtIndexPath:(NSIndexPath *)indexPath datas:(NSArray *)datas modelClass:(Class)classType{
    if( [datas isKindOfClass:[NSArray class]] ){
        if( datas.count > indexPath.section ){
            NSArray *arr = datas[indexPath.section];
            if( [arr isKindOfClass:[NSArray class]] ){
                if( arr.count > indexPath.row ){
                    id obj = arr[indexPath.row];
                    if( [obj isKindOfClass:classType] ){
                        return obj;
                    }
                }
                
            }
        }
    }
    
    return nil;
}

#pragma makr - 内存管理数据

- (double)availableMemory
{
    vm_statistics_data_t vmStats;
    
    mach_msg_type_number_t infoCount =HOST_VM_INFO_COUNT;
    
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               
                                               HOST_VM_INFO,
                                               
                                               (host_info_t)&vmStats,
                                               
                                               &infoCount);
    
    
    
    if (kernReturn != KERN_SUCCESS) {
        
        return NSNotFound;
        
    }
    return ((vm_page_size *vmStats.free_count) /1024.0) / 1024.0;
}

- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    
    mach_msg_type_number_t infoCount =TASK_BASIC_INFO_COUNT;
    
    kern_return_t kernReturn =task_info(mach_task_self(),
                                        
                                        TASK_BASIC_INFO,
                                        
                                        (task_info_t)&taskInfo,
                                        
                                        &infoCount);
    if (kernReturn != KERN_SUCCESS
        
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
    
}

/*
- (void)popSelfAfterDelay1s{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)popSelfAfterDelay:(NSTimeInterval)ti{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ti * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
*/

#pragma mark - Private
-(UIBarButtonItem*)backItemWithTarget:(id)target action:(SEL)action{
    return [self  backItemWithTarget:target action:action imgName:nil];
}

-(NSArray*)leftItemsWithTarget:(id)target action:(SEL)action{
    return [self leftItemsWithTarget:target action:action imgName:nil];
}

-(NSArray*)leftItemsWithTarget:(id)target action:(SEL)action imgName:(NSString*)imgName{
    
    UIBarButtonItem *backBarItem = [self backItemWithTarget:target action:action];
    if( imgName && imgName.length > 0 ){
        backBarItem = [self  backItemWithTarget:target action:action imgName:imgName];
    }
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
    negativeSpacer.width = -5;
    return @[negativeSpacer,backBarItem];
}

-(NSArray*)rightItemsWithTitle:(NSString*)title imgName:(NSString*)imgName selImgName:(NSString*)selImgName action:(SEL)action titleFont:(UIFont*)font titleColor:(UIColor*)titleColor{
    UIBarButtonItem *rightBarItem = [self barItemWithNormalTitle:title
                                                     normalImage:imgName
                                                      hightImage:nil
                                                     selectedImg:selImgName
                                                       andTarget:self andAction:action
                                                       titleFont:font titleColor:titleColor];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
    negativeSpacer.width = -5;
    return @[negativeSpacer,rightBarItem];
}

-(UIBarButtonItem*)backItemWithTarget:(id)target action:(SEL)action imgName:(NSString*)imgName{
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(-10, 0, 45, 40);
    NSString *name = @"arrow_left_51";
    if( imgName && imgName.length > 0 ){
        name = imgName;
    }
    [button setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, button.frame.size.width - button.currentImage.size.width);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    if( [target respondsToSelector:action] ){
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (UIBarButtonItem *)barItemWithNormalTitle:(NSString *)title normalImage:(NSString *)normalI hightImage:(NSString *)hightI selectedImg:(NSString*)seletImgName andTarget:(id)target andAction:(SEL)action titleFont:(UIFont*)font titleColor:(UIColor*)titleColor{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 80, 40);
    [button setImage:[UIImage imageNamed:normalI] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:hightI] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:seletImgName] forState:UIControlStateSelected];
    if( [titleColor isKindOfClass:[UIColor class]] )
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    if( button.currentImage ){
        button.imageEdgeInsets = UIEdgeInsetsMake(0, button.frame.size.width - button.currentImage.size.width, 0, 0);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
    else{
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        [button setTitleColor:[UIColor colorWithWhite:0.8 alpha:0.9] forState:UIControlStateHighlighted];
        
    }
    UIFont *titleFont = [UIFont systemFontOfSize:16.0];
    if( font ){
        titleFont = font;
    }
    [button setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateDisabled];
    [button.titleLabel setFont:titleFont];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (UIBarButtonItem *)barItemWithNormalTitle:(NSString *)title normalImage:(NSString *)normalI hightImage:(NSString *)hightI selectedImg:(NSString*)seletImgName andTarget:(id)target andAction:(SEL)action titleAlignment:(NSTextAlignment)ta{
    UIControlContentHorizontalAlignment ha = UIControlContentHorizontalAlignmentRight;
    if( [UIImage imageNamed:normalI] ){
        ha =  UIControlContentHorizontalAlignmentCenter;
    }
    
    return
    [self barItemWithNormalTitle:title normalImage:normalI hightImage:hightI selectedImg:seletImgName andTarget:target andAction:action titleAlignment:ta contentHorizontalAlignment:ha];
}

- (UIBarButtonItem *)barItemWithNormalTitle:(NSString *)title normalImage:(NSString *)normalI hightImage:(NSString *)hightI selectedImg:(NSString*)seletImgName andTarget:(id)target andAction:(SEL)action titleAlignment:(NSTextAlignment)ta contentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentAli{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    CGSize tileSize = [self lableSizeWithText:title font:[UIFont systemFontOfSize:14.0] width:100];
    button.frame = CGRectMake(0, 0, 70, 40);
    [button setImage:[UIImage imageNamed:normalI] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:hightI] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:seletImgName] forState:UIControlStateSelected];
    if( button.currentImage ){
        button.imageEdgeInsets = UIEdgeInsetsMake(0, button.frame.size.width - button.currentImage.size.width-3, 0, 3);
        CGFloat titleToImg = 3.0;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, button.frame.size.width-button.currentImage.size.width*2 - tileSize.width - titleToImg, 0, button.currentImage.size.width+titleToImg);
//        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
//    else{
//        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    }
    if( normalI == nil ){
        [button setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.9] forState:UIControlStateHighlighted];
    }
    [button.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    if( [target respondsToSelector:action] ){
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    button.titleLabel.textAlignment = ta;
    button.contentHorizontalAlignment = contentAli;
    [button setTitleColor:[UIColor colorWithRgb_24_148_209] forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(CGSize)lableSizeWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width{
    CGSize size = CGSizeMake(width, MAXFLOAT);
    return [ text boundingRectWithSize:size
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{NSFontAttributeName:font} context:nil].size;
}

#pragma mark - TouchEvents
- (void)handleBackBtn:(id)obj{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Other

/**
 *  隐藏StatusBar
 *
 *  @return YES 隐藏。NO 显示。
 */
//- (BOOL)prefersStatusBarHidden{
//    return YES;
//}

@end


@implementation UIViewController(ViewTag)

NSInteger const TagNaviBgView = 987654321;

@end
