//
//  TSMyWorkCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 15/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSMyWorkCtrl.h"

#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "XWPageViewCtrl.h"
#import "TSUserWorkCtrl.h"
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
#import "TSConstants.h"

@interface TSMyWorkCtrl ()<XWPageViewCtrlDelegate>
@property (nonatomic, strong) UIView *naviBgView;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, assign) NSUInteger isLoadedNum;
@end

@implementation TSMyWorkCtrl{
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
//    [self configSelfData];
    self.view.backgroundColor = [UIColor colorWithRgb_240_239_244];
    [self getNaviBgView];
    [self addNaviBlueImageBg];
    
    [self addRightBarItemWithAction:@selector(handleSearch) imgName:@"all_search"];

//    self.navigationItem.title = NSLocalizedString(@"TabbarWork", nil);//MyworkPageTitle -- 游客
    [self setNaviWhiteColorTitle:NSLocalizedString(@"TabbarWork", nil)];
    _isLoadedNum =0;
    [self initCtrls];
//    [self changeBackBarItemWithAction:@selector(handleBack)];
    self.cameraBtn.hidden = YES;
    
    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //即将进入本页面时，进行数据的加载更新（点赞状态的实时更新）
    
    //[self reloadData];
    
    self.tabBarController.tabBar.hidden = NO;
    //适配ios13，导航风格变黑，状态栏才会变白
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //防止切换tabbar时，会有黑色一闪而过
    if( self.tabBarController.selectedIndex != self.tabBarController.view.tag ) return;
    //适配ios13，导航风格变浅，状态栏才会变黑
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //离开本页面时，取消数据的加载
    if(_ctrls.count >_selectedItemIdx ){
        TSUserWorkCtrl *oc = _ctrls[_selectedItemIdx];
        if( [oc isKindOfClass:[TSUserWorkCtrl class]] ){
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataNoti) name:TSConstantNotificationDeleteWorkOnLine object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataNoti) name:TSConstantNotificationLoginSuccess object:nil];
}

- (void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationDeleteWorkOnLine object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationLoginSuccess object:nil];
}

- (void)reloadDataNoti{
    
    _isLoadedNum = 0;
    [self reloadData];
}

#pragma mark - Private
- (void)initCtrls{
    self.apearance.currItemIndex = _selectedItemIdx;
    self.apearance.itemMaxCount = 3;
    self.apearance.lineViewWidth = 0;
    self.apearance.itemXGap = 0;
    self.apearance.itemEdgeDistance = 0;
    self.apearance.lineViewWidth=60;
    self.apearance.itemTitleColor  = [UIColor colorWithRgb51];
    self.apearance.itemSelectedTitleColor = [UIColor colorWithRgb_0_151_216];
    self.apearance.lineColor = [UIColor colorWithRgb_0_151_216];
    self.apearance.topViewBackColor = [UIColor whiteColor];
    self.apearance.topViewItemColor = [UIColor whiteColor];
    self.apearance.lineScrollViewBackColor = [UIColor colorWithRgb238];
//    self.apearance.lineBackViewColor = [UIColor colorWithRgb245];
    self.apearance.topViewOriginY = NAVGATION_VIEW_HEIGHT;//self.naviBgView.bottom;
    self.apearance.topViewHeight = 41;
    self.topView.showSearchView = NO;
    self.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
//    NSArray *titles = @[NSLocalizedString(@"MyworkLocalWork", nil),
//                        NSLocalizedString(@"MyworkOnlineWork", nil),
//                        NSLocalizedString(@"MyworkFavirateWork", nil)];
    
    NSArray *titles = @[NSLocalizedString(@"本地展厅", nil),
                        NSLocalizedString(@"私人展厅", nil),
                        NSLocalizedString(@"公开展厅", nil),
                        NSLocalizedString(@"收藏展厅", nil)];
    
    NSArray *ctrls = @[[[TSUserWorkCtrl alloc] initWithType:TSUserWorkTypeLocal],
                       [[TSUserWorkCtrl alloc] initWithType:TSUserWorkTypeLinePrivate],
                       [[TSUserWorkCtrl alloc] initWithType:TSUserWorkTypeLinePublic],
                       [[TSUserWorkCtrl alloc] initWithType:TSUserWorkTypeCollect]];
    _ctrls = ctrls;
    [self resetViewCtrls:ctrls titles:titles];

    [self reloadDataAtIndex:self.apearance.currItemIndex];
    _isLoadedNum = ((self.apearance.currItemIndex==0?1:(self.apearance.currItemIndex*2)) | _isLoadedNum);
}

- (void)reloadDataAtIndex:(NSUInteger)idx{
    //[self isLogined]?un:NSLocalizedString(@"MyworkPageTitle", nil);
    if( idx < _ctrls.count ){
        TSUserWorkCtrl *ctrl = _ctrls[idx];
        if( [ctrl isKindOfClass:[TSUserWorkCtrl class]] ){
            [ctrl reloadData];
        }
    }
}

- (void)cancleLoadingDataAtIndex:(NSUInteger)idx{
    if( idx < _ctrls.count ){
        TSUserWorkCtrl *ctrl = _ctrls[idx];
        if( [ctrl isKindOfClass:[TSUserWorkCtrl class]] ){
            [ctrl cancleLoadingData];
        }
    }
}

#pragma mark - TouchEvents

//- (void)handleBack{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

- (void)handleSearch{
    TSSearchWorkCtrl *wc = [TSSearchWorkCtrl new];
    wc.hidesBottomBarWhenPushed = YES;
    [self pushViewCtrl:wc];
}

//- (void)handleGotoCamera{
//    if([MyPublic shareMyBleClass].connectedShield.state == CBPeripheralStateConnected ){
//        
//        //连接中 直接去拍照
//        TSTakePhotoCtrl *pc = [TSHelper shareTakePhotoCtrl];//[TSTakePhotoCtrl new];
//        [pc resetDatas];
//        [self pushViewCtrl:pc];
//    }else{
//        //未连接，先去链接页面
//        [HTProgressHUD showError:NSLocalizedString(@"ConnectEquipment", nil)];//@"请先连接设备"
//        TSDeviceConnectCtrl *cc = [TSDeviceConnectCtrl new];
//        [self pushViewCtrl:cc];
//    }
//}


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
