//
//  TSNoticeCtrl.m
//  ThreeShow
//
//  Created by wkun on 2019/3/10.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSNoticeCtrl.h"
#import "HTTableView.h"
#import "UIViewController+Ext.h"
#import "TSNoticeModel.h"
#import "TSNoticeCell.h"
#import "MJRefresh.h"
#import "HTNoDataView.h"
#import "TSProductionDetailCtrl.h"
#import "TSProductDataModel.h"
#import "TSHelper.h"
#import "HTProgressHUD.h"
#import "NSString+Ext.h"
#import "TSConstants.h"

@interface TSNoticeCtrl ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, assign) NSInteger pageIndex; //从1开始
@property (nonatomic, strong) HTNoDataView *noDataView;
@property (nonatomic, strong) HTProgressHUD *hud;
@end

@implementation TSNoticeCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelfData];
    
    self.navigationItem.title = NSLocalizedString(@"WorkOnlineSericeMsgTitle", nil);
    
    [self.tableView.mj_header beginRefreshing];
    
    [self modifyMsgStatusIsReaded];
    
    [self addNotifications];
}

- (void)dealloc{
    [self removeNotifications];
}

#pragma mark - Notifications
- (void)addNotifications{
    NSString *name = TSConstantNotificationDeleteWorkOnLine;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOnlineWork) name:name object:nil];
}

- (void)removeNotifications{
    NSString *name = TSConstantNotificationDeleteWorkOnLine;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:name object:nil];
}

- (void)deleteOnlineWork{
    [self beginHeadRefreshWithTableView:self.tableView];
}

#pragma mark - Loaddatas

//每次进入都将未读消息设置为已读
- (void)modifyMsgStatusIsReaded{
    [self dispatchAsyncQueueWithName:@"modifyMsgStatusQ" block:^{
        [self.dataProcess modifyMsgStatusIsReadedWithCompleteBlock:^(NSError *err) {
      
        }];
    }];
}

- (void)loadData:(id)obj{
    if( [obj isKindOfClass:[MJRefreshNormalHeader class]] ){
        //下拉
        _pageIndex = 1;
        [self resetNoMoreDataWithTableView:self.tableView];
    }else{
        _pageIndex ++;
    }
    
    [self dispatchAsyncQueueWithName:@"loadDataQ" block:^{
        [self.dataProcess onlineServiceWorkListWithUserNameOrWorkName:nil type:2 pageNum:_pageIndex completeBlock:^(NSError *err, NSArray *datas) {
            
            [self dispatchAsyncMainQueueWithBlock:^{
                if( err ){
                    [self showErrMsgWithError:err];
                }else{
                    if( _pageIndex == 1 ){
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
                [self endRefreshWithIsHeadFresh:(_pageIndex==1) isHaveNewData:datas.count tableView:self.tableView];
            }];
        }];
    }];
}

- (void)requestWorkDetailWithId:(NSString*)wid{
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self dispatchAsyncQueueWithName:@"detailQ" block:^{
        [self.dataProcess workDetailWithId:wid completeBlock:^(TSProductDataModel *dataModel, NSError *er) {
            [self dispatchAsyncMainQueueWithBlock:^{
                [_hud hide];
                
                if( er ){
                    [self showErrMsgWithError:er];
                }else{
                    [self gotoDetailCtrlWithDm:dataModel];
                }
            }];
        }];
    }];
}

#pragma mark - Private
- (void)gotoDetailCtrlWithDm:(TSProductDataModel*)dm{
    TSProductionDetailCtrl *dc = [TSHelper sharedProductionDetailCtrl];//
    dc.dataModel = dm;
    dc.hidesBottomBarWhenPushed =YES;
//    [dc reloadData];
    [self pushViewCtrl:dc];
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseId = @"personCenterCellReuseID";
    TSNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if( !cell ){
        cell = [[TSNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    NSUInteger idx = indexPath.row;
    cell.model = (TSNoticeModel*)[self modelAtIndex:idx datas:_datas modelClass:[TSNoticeModel class]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TSNoticeModel *model = _datas[indexPath.row];
    
    [self requestWorkDetailWithId:[NSString stringWithObj:model.originDic[@"pid"]]];
}

#pragma mark - Property

- (UITableView *)tableView{
    if( !_tableView) {
        _tableView = [[HTTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.frame = CGRectMake(0, NAVGATION_VIEW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVGATION_VIEW_HEIGHT);
        
        UIView *fv =[[UIView alloc] init];
        fv.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
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
        
        [self configRefreshTableView:_tableView freshSel:@selector(loadData:)];
    }
    
    return _tableView;
}

- (HTNoDataView *)noDataView {
    if( !_noDataView ){
        NSString *text =  NSLocalizedString(@"哎呀~(^0^)……什么都没有！", nil);//NSLocalizedString(@"ProductInfoNO", nil);
        CGFloat iy = NAVGATION_VIEW_HEIGHT+0.5;
        _noDataView = [[HTNoDataView alloc] initWithFrame:CGRectMake(0, iy, SCREEN_WIDTH, SCREEN_HEIGHT-iy) text:text action:@selector(reloadData) target:self];
        _noDataView.hideReloadBtn = YES;;
        _noDataView.backgroundColor = [UIColor whiteColor];
        _noDataView.imgView.hidden = YES;
        _noDataView.textLabel.textColor = [UIColor colorWithRgb102];
        
        CGRect fr = _noDataView.textLabel.frame;
        fr.origin.y = self.view.center.y - 50;
        _noDataView.textLabel.frame = fr;

        [self.view addSubview:_noDataView];
    }
    return _noDataView;
}

@end
