//
//  TSFindHomeCtrl.m
//  ThreeShow
//
//  Created by wkun on 2019/2/23.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSFindHomeCtrl.h"
#import "UIViewController+Ext.h"
#import "XWPageViewAppearance.h"
#import "XWPageTopView.h"
#import "UIColor+Ext.h"
#import "TSFindCtrl.h"
#import "HTProgressHUD.h"
#import "TSFindTypeModel.h"
#import "TSHelper.h"
#import "HTNoDataView.h"

@interface TSFindHomeCtrl ()<XWPageViewCtrlDelegate>
@property (nonatomic, strong) UIView *naviBgView;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, assign) NSUInteger isLoadedNum;
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) HTNoDataView *noDataView;
@end

@implementation TSFindHomeCtrl{
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

#pragma mark - ViewLife

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSelfData];
    [self addNaviBlueImageBg];
    
//    self.navigationItem.title = NSLocalizedString(@"FindCtrlTitle", nil);
    [self setNaviWhiteColorTitle:NSLocalizedString(@"FindCtrlTitle", nil)];
    _isLoadedNum =0;

    //隐藏返回按钮
    self.navigationItem.leftBarButtonItems = @[[UIBarButtonItem new]];
    
    [self loadTypeDatas];
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
    
    if( self.tabBarController.selectedIndex != self.tabBarController.view.tag ) return;
    //适配ios13，导航风格变浅，状态栏才会变黑
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //离开本页面时，取消数据的加载
    if(_ctrls.count >_selectedItemIdx ){
//        TSUserWorkCtrl *oc = _ctrls[_selectedItemIdx];
//        if( [oc isKindOfClass:[TSUserWorkCtrl class]] ){
//            [oc cancleLoadingData];
//        }
    }
}

#pragma mark - LoadDatas

- (void)loadTypeDatas{
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self dispatchAsyncQueueWithName:@"loadTypeQ" block:^{
        [self.dataProcess findTypeDatasWithCompleteBlock:^(NSError *err, NSArray *datas) {
            [self dispatchAsyncMainQueueWithBlock:^{
                [_hud hide];
                if( err ){
                    [self showErrMsgWithError:err];
                }else{
                    
                    [self initCtrlsWithModels:datas];
                }
                
                self.noDataView.hidden = (err==nil && datas.count );
            }];
        }];
    }];
}

- (void)reloadData{
    [self reloadDataAtIndex:self.apearance.currItemIndex];
}

- (void)reloadDataAtIndex:(NSUInteger)idx{
    if( idx < _ctrls.count ){
        TSFindCtrl *ctrl = _ctrls[idx];
        if( [ctrl isKindOfClass:[TSFindCtrl class]] ){
            [ctrl reloadData];
        }
    }
}


- (void)setCurrSelectedItemIndex:(NSUInteger)idx{
    if( _ctrls.count == 0 ) return;
    
    CGFloat offsetX = (SCREEN_WIDTH/_ctrls.count)*idx;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0)];
}

#pragma mark - Private
- (void)initCtrlsWithModels:(NSArray*)models{
    
    BOOL isEnglishLaunage = [TSHelper isEnglishLanguage];
    
//    self.apearance.topViewItemStyle = isEnglishLaunage?XWPageTopViewItemStyleUniformlySpaced:XWPageTopViewItemStyleMonospaced; //Item等间距
    self.apearance.topViewItemStyle = XWPageTopViewItemStyleMonospaced;
    
    self.apearance.currItemIndex = _selectedItemIdx;
    self.apearance.itemMaxCount = 3;
    self.apearance.lineViewWidth = 60;
    self.apearance.itemMinWidth = 90;
    self.apearance.itemXGap = 20;
    self.apearance.itemEdgeDistance = 25;
    self.apearance.itemTitleColor  = [UIColor colorWithRgb51];
    self.apearance.itemSelectedTitleColor = [UIColor colorWithRgb_0_151_216];
    self.apearance.lineColor = [UIColor colorWithRgb_0_151_216];
    self.apearance.topViewBackColor = [UIColor whiteColor];
    self.apearance.topViewItemColor = [UIColor whiteColor];
    self.apearance.lineBackViewColor = [UIColor colorWithRgb238];
    self.apearance.lineScrollViewBackColor = [UIColor whiteColor];
    self.apearance.topViewOriginY = NAVGATION_VIEW_HEIGHT;//self.naviBgView.bottom;
    self.apearance.topViewHeight = 41;
    self.topView.showSearchView = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    
//    NSArray *titles = @[NSLocalizedString(@"MyworkLocalWork", nil),
//                        NSLocalizedString(@"MyworkOnlineWork", nil),
//                        NSLocalizedString(@"MyworkFavirateWork", nil)];
//
//    NSArray *ctrls = @[[[TSFindCtrl alloc] initWithType:TSFindTypeCompanyNews],
//                       [[TSFindCtrl alloc] initWithType:TSFindTypeIndustryNews],
//                       [[TSFindCtrl alloc] initWithType:TSFindTypeProductNews]];
    
    
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:models.count];
    NSMutableArray *ctrls  = [NSMutableArray arrayWithCapacity:models.count];
    for( TSFindTypeModel *tm in models ){
        if( isEnglishLaunage ){
            if( tm.ywTypeName.length ==0 ){
                [titles addObject:tm.typeName];
            }else
                [titles addObject:tm.ywTypeName];
        }else
            [titles addObject:tm.typeName];
        [ctrls addObject:[[TSFindCtrl alloc] initWithTypeModel:tm]];
    }
    
    _ctrls = ctrls;
    [self resetViewCtrls:ctrls titles:titles];
    
    [self reloadDataAtIndex:self.apearance.currItemIndex];
    _isLoadedNum = ((self.apearance.currItemIndex==0?1:(self.apearance.currItemIndex*2)) | _isLoadedNum);
}

- (HTNoDataView *)noDataView {
    if( !_noDataView ){
        NSString *text = NSLocalizedString(@"哎呀~(^0^)……什么都没有！", nil);
        CGFloat iy = NAVGATION_VIEW_HEIGHT;
        _noDataView = [[HTNoDataView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-iy-TABBAR_VIWE_HEIGHT) text:text action:@selector(loadTypeDatas) target:self];
        _noDataView.hideReloadBtn = NO;
        
        [self.view addSubview:_noDataView];
    }
    return _noDataView;
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
//    [self cancleLoadingDataAtIndex:pageIndex];
}

#pragma mark - status bar
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
