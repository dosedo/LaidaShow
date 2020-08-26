//
//  TSHomeProductionCtrl.m
//  ThreeShow
//
//  Created by cgw on 2018/9/25.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSHomeProductionCtrl.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "XWPageViewCtrl.h"
#import "TSProductionCtrl.h"
#import "XWPageTopView.h"
#import "XWPageViewAppearance.h"
#import "TSUserModel.h"
#import "TSSearchWorkCtrl.h"
#import "MyPublic.h"
#import "MyBleClass.h"
#import "TSTakePhotoCtrl.h"
#import "HTProgressHUD.h"
#import "TSDeviceConnectCtrl.h"
#import "TSHelper.h"
#import "TSWebPageCtrl.h"
#import "TSConstants.h"
#import "NSString+Ext.h"
#import "CYPrivacyViewController.h"

#import "YQAssetOperator.h"

@interface TSHomeProductionCtrl ()<XWPageViewCtrlDelegate>
@property (nonatomic, strong) UIView *naviBgView;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, assign) NSUInteger isLoadedNum;
@property (nonatomic,strong) UIAlertController *alert;
@end

@implementation TSHomeProductionCtrl{
    NSArray *_ctrls;
    NSUInteger _selectedItemIdx;
}

- (id)initWithSelectedItemIdx:(NSUInteger)idx{
    self = [super init];
    if( self ){
        _selectedItemIdx = idx;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelfData];
    [self addNaviBlueImageBg];
    
    [self addRightBarItemWithAction:@selector(handleSearch) imgName:@"all_search"];

    self.navigationItem.leftBarButtonItems = @[[UIBarButtonItem new]];
//    NSString *un = NSLocalizedString(@"HomeProductionCtrlTitle", nil);
//    self.navigationItem.title = un;
    [self setNaviWhiteColorTitle:NSLocalizedString(@"HomeProductionCtrlTitle", nil)];
    
    _isLoadedNum =0;
    [self initCtrls];
    
    [self addNotifications];
    
    self.cameraBtn.hidden = NO;
    
    [self alertWithMessage:NSLocalizedString(@"感谢您下载莱搭秀!当您开始使用本软件时，我们可能会对您的部分个人信息进行收集、使用和共享，请仔细阅读莱搭秀隐私政策，并确定了解我们对您个人信息的处理规则,包括：\n\n我们如何收集和使用您的个人信息\n我们如何保护和保留您的个人信息\n未成年人信息的保护\n如何联系我们\n\n如您同意《莱搭秀服务协议及隐私政策》，请点击“我同意”开始使用我们的产品和服务，我们尽全力保护您的个人信息安全。",nil)];
    
    //创建Gif图相册，为了存储Gif图片。每次保存Gif图时，也会检查是否创建了Gif。若存在则不创建。有待优化
    [[YQAssetOperator alloc] initWithFolderName:@"Gif"];
}

- (void)alertWithMessage:(NSString *)msg{
    
    self.alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"PrivacyPolicySummary",nil) message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionAgree = [UIAlertAction actionWithTitle:NSLocalizedString(@"PrivacyPolicyAgree",nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NO LONGER PROMT"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }];
    UIAlertAction *actionCancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"PersonPrivacyPolicy",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self privacyContentBtnClicked];
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NO LONGER PROMT"];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"NO LONGER PROMT1"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    [actionAgree setValue:[UIColor orangeColor] forKey:@"_titleTextColor"];
    [actionCancle setValue:[UIColor grayColor] forKey:@"_titleTextColor"];
    
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:msg];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init]; paragraph.alignment = NSTextAlignmentLeft;
    [alertControllerMessageStr setAttributes:@{NSParagraphStyleAttributeName:paragraph} range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [self.alert setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    [self.alert addAction:actionAgree];
    [self.alert addAction:actionCancle];
    if ([self isAlertUpdateAgain] == NO ) {//点击不再提示，则以后不会提示；否则弹出更新提示
        [self  presentViewController:self.alert animated:YES completion:nil];
        
    }
}

- (BOOL)isAlertUpdateAgain{
    BOOL res = [[NSUserDefaults standardUserDefaults] objectForKey:@"NO LONGER PROMT"];
    return res;
}

- (void)privacyContentBtnClicked {
    CYPrivacyViewController *privacyVC = [[CYPrivacyViewController alloc] init];
    [self.navigationController pushViewController:privacyVC animated:YES];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //进入本页面时，重新数据加载
//    [self reloadData];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"NO LONGER PROMT1"] isEqual:@"1"] && [self isAlertUpdateAgain] == NO) {//点击不再提示，则以后不会提示；否则弹出更新提示
        [self  presentViewController:self.alert animated:YES completion:nil];
    }
    
    self.tabBarController.tabBar.hidden = NO;
    
    //适配ios13，导航风格变黑，状态栏才会变白
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if( self.tabBarController.selectedIndex != self.tabBarController.view.tag ) return;
    
    //适配ios13，导航风格变浅，状态栏才会变黑
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //离开本页面时，取消数据的加载
    if(_ctrls.count >_selectedItemIdx ){
        TSProductionCtrl *oc = _ctrls[_selectedItemIdx];
        if( [oc isKindOfClass:[TSProductionCtrl class]] ){
            [oc cancleLoadingData];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData{
    [self reloadDataAtIndex:self.apearance.currItemIndex];
}

- (void)setCurrSelectedItemIndex:(NSUInteger)idx{
    if( _ctrls.count == 0 ) return;
    
    CGFloat offsetX = (SCREEN_WIDTH/_ctrls.count)*idx;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0)];
}

- (void)dealloc{
    [self removeNotifications];
}

#pragma mark - Notifications
- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataNoti) name:TSConstantNotificationLoginSuccess object:nil];
}

- (void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationLoginSuccess object:nil];
}

- (void)reloadDataNoti{
    _isLoadedNum = 0;
    
    [self reloadData];
}

#pragma mark - Private
- (void)initCtrls{
    self.apearance.topViewItemStyle = XWPageTopViewItemStyleUniformlySpaced; //Item等间距
    self.apearance.currItemIndex = _selectedItemIdx;
    self.apearance.itemMaxCount = 6;
    self.apearance.lineViewWidth = 60;
//    self.apearance.itemMinWidth = 90; 
    self.apearance.itemXGap = 33;
    self.apearance.itemEdgeDistance = 20;
    self.apearance.itemTitleColor  = [UIColor colorWithRgb51];
    self.apearance.itemSelectedTitleColor = [UIColor colorWithRgb_0_151_216];
    self.apearance.lineColor = [UIColor colorWithRgb_0_151_216];
    self.apearance.topViewBackColor = [UIColor whiteColor];
    self.apearance.topViewItemColor = [UIColor whiteColor];
    self.apearance.lineScrollViewBackColor = [UIColor whiteColor];//colorWithRgb221];
    self.apearance.topViewOriginY = NAVGATION_VIEW_HEIGHT;//self.naviBgView.bottom;
    self.apearance.topViewHeight = 41;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.topView.showSearchView = NO;
    self.delegate = self;
    
    NSArray *titles = @[NSLocalizedString(@"推荐", nil),
                        NSLocalizedString(@"家居", nil),
                        NSLocalizedString(@"鞋服", nil),
                        NSLocalizedString(@"箱包", nil),
                        NSLocalizedString(@"文创", nil),
                        NSLocalizedString(@"动漫", nil),
                        NSLocalizedString(@"古玩", nil),
                        NSLocalizedString(@"珠宝", nil)];

//    推荐：100，3C数码：1，珠宝：2，古玩：3，服装：4，其他：99“这样
//    NSArray *categorys = @[@"100",@"1",@"2",@"3",@"4",@"99"];
    NSMutableArray *ctrls = [NSMutableArray new];
    for(NSUInteger i=0; i<titles.count ; i++){
        NSString *cati = @"100";
        if( i>0 ) cati = @(i).stringValue;
        TSProductionCtrl *pc = [[TSProductionCtrl alloc] initWithCategory:cati];//categorys[i]];
        [ctrls addObject:pc];
    }
    _ctrls = ctrls;
    [self resetViewCtrls:ctrls titles:titles];
    [self reloadDataAtIndex:self.apearance.currItemIndex];
    _isLoadedNum = ((self.apearance.currItemIndex==0?1:(self.apearance.currItemIndex*2)) | _isLoadedNum);
}

- (void)reloadDataAtIndex:(NSUInteger)idx{
    if( idx < _ctrls.count ){
        TSProductionCtrl *ctrl = _ctrls[idx];
        if( [ctrl isKindOfClass:[TSProductionCtrl class]] ){
            [ctrl reloadData];
        }
    }
}

- (void)cancleLoadingDataAtIndex:(NSUInteger)idx{
    if( idx < _ctrls.count ){
        TSProductionCtrl *ctrl = _ctrls[idx];
        if( [ctrl isKindOfClass:[TSProductionCtrl class]] ){
            [ctrl cancleLoadingData];
        }
    }
}

#pragma mark - TouchEvents

//- (void)handleUserCenter{
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//}

- (void)handleSearch{
    TSSearchWorkCtrl *wc = [TSSearchWorkCtrl new];
    wc.hidesBottomBarWhenPushed = YES;
    [self pushViewCtrl:wc];
}

#pragma mark - XWPageControllerDelegate
- (void)pageViewCtrl:(XWPageViewCtrl *)pvCtrl scrollToPage:(NSUInteger)pageIndex{
    NSUInteger idx = (pageIndex==0?1:(pageIndex*2)); //idx = 1 2 4
    if ( (idx & _isLoadedNum) != idx ){
        //该Ctrl未加载过数据
        [self reloadDataAtIndex:pageIndex];
        _isLoadedNum = (_isLoadedNum | idx);
    }
}

- (void)pageViewCtrl:(XWPageViewCtrl *)pvCtrl scrollFromPage:(NSUInteger)pageIndex{
    [self cancleLoadingDataAtIndex:pageIndex];
}

#pragma mark - Propertys

//- (UIButton *)cameraBtn {
//    if( !_cameraBtn ){
//        _cameraBtn = [[UIButton alloc] init];
//        [_cameraBtn setImage:[UIImage imageNamed:@"home_camera"] forState:UIControlStateNormal];
//        [_cameraBtn addTarget:self action:@selector(handleGotoCamera) forControlEvents:UIControlEventTouchUpInside];
//        CGFloat wh = 80,iy = SCREEN_HEIGHT-wh-30;
//        _cameraBtn.frame = CGRectMake((SCREEN_WIDTH-wh)/2, iy, wh, wh);
//        [self.view addSubview:_cameraBtn];
//    }
//    return _cameraBtn;
//}
#pragma mark - status bar
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
