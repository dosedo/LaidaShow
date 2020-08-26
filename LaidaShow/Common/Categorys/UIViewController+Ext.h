//
//  UIViewController+Ext.h
//  Hitu
//
//  Created by hitomedia on 16/6/21.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+Ext.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSDataProcess.h"
#import <WebKit/WebKit.h>
#import "UINavigationController+Ext.h"
#import "HTProgressHUD.h"

@interface UIViewController (ViewTag)

extern NSInteger const TagNaviBgView;

@end

@interface UIViewController (Ext)

- (void)configSelfData;

/**
 *  替换掉系统的返回按钮
 */
-(void)changeBackBarItem;
-(void)changeBackBarItemWithAction:(SEL)action;

/**
 *  添加导航栏左侧按钮
 */
-(void)addLeftBarItem;
-(void)addLeftBarItemWithAction:(SEL)action;
-(void)addLeftBarItemWithAction:(SEL)action imgName:(NSString*)imgName;
- (void)addLeftBarItemWithTitle:(NSString *)title action:(SEL)action;


/**
 *  添加右侧导航栏按钮
 *
 *  @param title 按钮标题
 */

-(void)addRightBarItemWithTitle:(NSString*)title
                         action:(SEL)action;

-(void)addRightBarItemWithTitle:(NSString*)title
                         action:(SEL)action
                      titleFont:(UIFont*)font;
-(void)addRightBarItemWithAction:(SEL)action
                         imgName:(NSString*)imgName;
-(void)addRightBarItemWithTitle:(NSString *)title
                        imgName:(NSString*)imgName
                     selImgName:(NSString*)selImgName
                         action:(SEL)action
                     titleColor:(UIColor*)color
                      titleFont:(UIFont*)font;
-(void)addRightBarItemWithTitle:(NSString *)title
                        imgName:(NSString*)imgName
                     selImgName:(NSString*)selImgName
                         action:(SEL)action
                  textAlignment:(NSTextAlignment)textAlignment;

- (UIButton*)getButtonAtRightBarItem;

- (UIBarButtonItem *)getRightBarItem;

#pragma mark - NavigationBar
/**
 设置导航栏透明
 */
- (void)setNavigationBarBgClear;

/**
 配置导航栏背景，仅仅为了将 背景视图的初始化写在Ctrl的类别中。

 */
- (UIView*)getNaviBgView;

/**
 添加蓝色导航背景
 */
- (void)addNaviBlueImageBg;

- (void)setStatusBarStyleIsDefault:(BOOL)isDefault;

/**
 导航栏白色标题

 @param title 标题内容
 */
- (void)setNaviWhiteColorTitle:(NSString*)title;

#pragma mark - View
- (NSInteger)getTagBase;

//-(WKWebView*)getWebView;
/**
 *  当前ctrl 是否正在显示
 *
 *  @return 显示YES，未显示NO
 */
- (BOOL)isViewShowing;

- (void)configRefreshTableView:(UIScrollView*)tableView freshSel:(SEL)freshSel;

- (void)configheaderRefreshTableView:(UIScrollView*)tableView freshSel:(SEL)freshSel;
/**
 是否正在下拉刷新

 @return 是YES， 没有NO
 */
- (BOOL)isTableViewHeadRefreshing:(UIScrollView*)tableView;

- (void)beginHeadRefreshWithTableView:(UIScrollView*)tb;

- (void)beginfootedRefreshWithTableView:(UIScrollView*)tableView;

- (void)endRefreshWithIsHeadFresh:(BOOL)isHeadFresh isHaveNewData:(BOOL)isHaveNewData tableView:(UIScrollView*)tableView;
- (void)endRefreshWithMJRefresh:(NSObject*)refObj isHaveNewData:(BOOL)isHaveNewData tableView:(UIScrollView*)tableView;

- (void)resetNoMoreDataWithTableView:(UIScrollView*)tableView;

- (void)showAlertViewWithTitle:(NSString *)title msg:(NSString*)msg okBlock:(void(^)(void))okBlock cancleBlock:(void(^)(void))cancleBlock;
- (void)showAlertViewWithTitle:(NSString *)title msg:(NSString*)msg okBlock:(void(^)(void))okBlock cancleBlock:(void(^)(void))cancleBlock okTitle:(NSString*)ot cancleTitle:(NSString*)ct;

#pragma mark __NoDataView
- (void)showNoDataViewWithFrame:(CGRect)fr err:(NSError*)err loadDataSel:(SEL)loadDataSel;

- (void)hideNoDataView;

#pragma mark - UITextField

/**
 给键盘添加完成按钮

 @param tvTextView textview或者textfiled的实例 （可强转）
 */

- (void)addDoneBtnWithView:(UITextView*)tvTextView;

//添加收回键盘收拾到本控制器的根视图
- (void)addHideKeyboardGestureToView;

#pragma mark - Tabbar
//- (void)setTabbarBackGroundWithIsClear:(BOOL)isClear;

#pragma mark - NativeString

- (NSString*)stringWithKey:(NSString*)key;

#pragma mark - UIViewController

/**
 push ctrl with animate

 @param ctrl 需要push的实力
 */
- (void)pushViewCtrl:(UIViewController*)ctrl;

/**
 pop到某个ctrl

 @param ctrlClass 要得到的ctrl的类Class 如：[UIViewController class],
 若导航控制器中，不存在该ctrl,则pop到上一ctrl
 */
- (void)popToCtrlWithClass:(Class)ctrlClass;

/**
 得到导航控制器的viewControllers 数组中的某一个ctrl的实例

 @param ctrlClass 要得到的ctrl的类Class 如：[UIViewController class]
 @return
 */
- (UIViewController*)getCtrlAtNavigationCtrlsWithCtrlClass:(Class)ctrlClass;
#pragma mark - WKWebView
-(void)loadHtmlWithWebView:(WKWebView*)webView filePath:(NSString*)fp;

#pragma mark - Login

- (BOOL)isLogined;

- (BOOL)isLoginedWithGotoLoginCtrl;

- (BOOL)isLoginedWithGotoLoginCtrlWithPushCtrl:(UIViewController*)puchCtrl;

- (void)goto12306LoginCtrlWithHidesBottomBarWhenPushed:(BOOL)hideBottom;

- (void)goto12306LoginCtrlWithHidesBottomBarWhenPushed:(BOOL)hideBottom loginSuccessBlock:(void(^)(id obj))loginSuccessBlock;

#pragma mark - ErrorMsg

- (void)showErrMsgWithError:(NSError*)err;
//- (void)showErrMsgAlertWithError:(NSError*)err;
//- (void)showErrMsgAlertWithError:(NSError*)err okBlock:(void(^)())okBlock;
//- (void)showErrMsgAlertWithError:(NSError*)err okBlock:(void(^)())okBlock okTitle:(NSString*)ot;
//- (void)showErrMsgWithErrCode:(NSInteger)code;
//
//- (NSString*)errMsgWithError:(NSError*)err;
//
//- (void)showMsgWithErrMsg:(NSString*)errMsg successMsg:(NSString*)successMsg;
- (void)showErrMsg:(NSString*)errMsg;

#pragma mark - Dispatch 

/**
 *  获取一个新的线程
 *
 *  @param queueName         线程名字
 *  @param newQueueBlock     新线程的代码块，若存在错误，会返回错误信息；否则，返回nil
 *  @param mainBlock         主线程的代码块，errMsg：错误信息传递参数
 *  @param isNeedProgressHud 是否需要自动添加进度条
 */
- (void)dispatchAsyncWithQueueName:(const NSString*)queueName newQueueBlock:(NSError*(^)(void))newQueueBlock mainQueueBlock:(void(^)(NSError *err))mainBlock isNeedProgressHud:(BOOL)isNeedProgressHud;

/**
 *  获取一个新的线程，注意：会自动添加进度指示条
 *
 *  @param queueName         线程名字
 *  @param newQueueBlock     新线程的代码块，若存在错误，会返回错误信息；否则，返回nil
 *  @param mainBlock         主线程的代码块，errMsg：错误信息传递参数
 */
- (void)dispatchAsyncWithQueueName:(const NSString*)queueName newQueueBlock:(NSError*(^)(void))newQueueBlock mainQueueBlock:(void(^)(NSError *err))mainBlock;

/**
 *  获取一个异步新线程,不包含主线程回调
 *
 *  @param queueName  线程名字
 *  @param queueBlock 新线程的代码块
 */
- (void)dispatchAsyncQueueWithName:(const NSString*)queueName block:(dispatch_block_t)queueBlock;

- (void)dispatchAsyncDelay:(NSUInteger)second mainBlock:(dispatch_block_t)mainBlock;

- (void)dispatchAsyncMainQueueWithBlock:(dispatch_block_t)mainBlock;

#pragma mark - DataProcess

- (TSDataProcess*)dataProcess;

- (NSObject*)modelAtIndex:(NSUInteger)index datas:(NSArray*)datas modelClass:(Class)classType;
- (NSObject*)modelAtIndexPath:(NSIndexPath*)indexPath datas:(NSArray*)datas modelClass:(Class)classType;

#pragma makr - 内存管理数据

/**
 获得当前设备的可用内存

 @return 多少MB
 */
- (double)availableMemory;
/**
 得到设备已经使用的内存

 @return 使用了多少MB
 */
- (double)usedMemory;

@end





