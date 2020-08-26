//
//  TSFindCtrl.m
//  ThreeShow
//
//  Created by wkun on 2019/2/17.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSFindCtrl.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSFindCell.h"
#import "TSFindModel.h"
#import "HTTableView.h"
#import "MJRefresh.h"
#import "TSFindTypeModel.h"
#import "HTNoDataView.h"
#import "TSWebPageCtrl.h"
#import "KError.h"
#import "HTProgressHUD.h"
#import "TSConstants.h"

@interface TSFindCtrl ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) TSFindTypeModel *typeModel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *datas;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) HTNoDataView *noDataView;
@property (nonatomic, strong) HTProgressHUD *hud;
@end

@implementation TSFindCtrl

- (id)initWithTypeModel:(TSFindTypeModel *)typeModel{
    self = [super init];
    if( self ){
        _typeModel = typeModel;
    }
    return self;
}

- (void)reloadData{
    [self.tableView.mj_header beginRefreshing];
}

- (void)cancleLoadingData{
    
}

#pragma mark - ViewLife

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height-TABBAR_VIWE_HEIGHT);
}

#pragma mark - LoadDatas
- (void)loadDatas:(id)obj{
    if( [obj isKindOfClass:[MJRefreshNormalHeader class]] ){
        //下拉
        _pageIndex = 0;
        [self resetNoMoreDataWithTableView:self.tableView];
    }else{
        _pageIndex ++;
    }
    
    [self dispatchAsyncQueueWithName:@"loadDataQ" block:^{
        [self.dataProcess findListWithTypeId:self.typeModel.ID pageNum:_pageIndex completeBlock:^(NSError *err, NSArray *datas) {
            [self dispatchAsyncMainQueueWithBlock:^{
                if( err ){
                    NSString *msg =
                    [KError errorMsgWithError:err];
                    
                    //为了解决最后一页数据加载完后，再次上拉刷新，会提示以下错误，
                    //所以，若提示以下错误则不弹窗口
                    BOOL isLastPageData = ![msg containsString:@"请添加该图文数据"];
                    if( isLastPageData ){
                        [self showErrMsgWithError:err];
                    }
                    
                }else{
                    if( _pageIndex == 0 ){
                        _datas = datas;
                    }else{
                        if( _datas.count ){
                            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_datas];
                            if( datas ){
                                [tempArr addObjectsFromArray:datas];
                            }
                            _datas = tempArr;
                        }
                    }
                    [self.tableView reloadData];
                }
                self.noDataView.hidden = (_datas.count );
                [self endRefreshWithIsHeadFresh:(_pageIndex==0) isHaveNewData:datas.count tableView:self.tableView];
            }];
        }];
    }];
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseId = @"cellReuseID";
    TSFindCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if( !cell ){
        cell = [[TSFindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.model = (TSFindModel*)[self modelAtIndex:indexPath.row datas:_datas modelClass:[TSFindModel class]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 105;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    TSFindModel *model = _datas[indexPath.row];
    
    NSString *url = [NSString stringWithFormat:@"%@/news/index.html?id=%@",TSConstantServerUrl,model.newsId];
    TSWebPageCtrl *pc  = [TSWebPageCtrl new];
    pc.title = model.title;
    pc.pageUrl = url;
    pc.hidesBottomBarWhenPushed = YES;
    [self pushViewCtrl:pc];
    
//    [self getDetailIdWithNewsId:model.newsId title:model.title];
}

- (void)getDetailIdWithNewsId:(NSString*)nid title:(NSString*)title{
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.dataProcess findDetailIdWithNewsId:nid completeBlock:^(NSError *err, NSString *detailId) {
            [self dispatchAsyncMainQueueWithBlock:^{
                [self.hud hide];
                if( err ){
                    [self showErrMsgWithError:err];
                }else{
                    NSString *url = [NSString stringWithFormat:@"%@/news/index.html?id=%@",TSConstantServerUrl,detailId];
                    TSWebPageCtrl *pc  = [TSWebPageCtrl new];
                    pc.title = title;
//                    pc.htmlString = model.htmlContent;
                    pc.pageUrl = url;
                    pc.hidesBottomBarWhenPushed = YES;
                    [self pushViewCtrl:pc];
                }
            }];
        }];
    });
}

#pragma mark - Property

- (UITableView *)tableView{
    if( !_tableView) {
        _tableView = [[HTTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        UIView *fv =[[UIView alloc] init];
        
        fv.frame = CGRectMake(0, 0, SCREEN_WIDTH, 15);
        fv.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = fv;
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.bounces = YES;
        [self.view addSubview:_tableView];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
        [self configRefreshTableView:_tableView freshSel:@selector(loadDatas:)];
    }
    
    return _tableView;
}

- (HTNoDataView *)noDataView {
    if( !_noDataView ){
        NSString *text = NSLocalizedString(@"ProductInfoNO", nil);
        CGFloat iy = NAVGATION_VIEW_HEIGHT+41;
        _noDataView = [[HTNoDataView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-iy-TABBAR_VIWE_HEIGHT) text:text action:@selector(reloadData) target:self];
        _noDataView.hideReloadBtn = NO;
        
        [self.tableView addSubview:_noDataView];
    }
    return _noDataView;
}


@end
