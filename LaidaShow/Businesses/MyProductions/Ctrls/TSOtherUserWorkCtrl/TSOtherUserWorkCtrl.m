//
//  TSOtherUserWorkCtrl.m
//  ThreeShow
//
//  Created by wkun on 2019/3/16.
//  Copyright © 2019 deepai. All rights reserved.
////
#import "TSOtherUserWorkCtrl.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "MJRefresh.h"
#import "TSProductCell.h"
#import "TSProductModel.h"
#import "TSProductionDetailCtrl.h"
#import "TSHelper.h"
#import "PPLocalFileManager.h"
#import "TSWorkModel.h"
#import "PPFileManager.h"
#import "TSLocalWorkDetailCtrl.h"
#import "HTProgressHUD.h"
#import "TSConstants.h"
#import "TSProductDataModel.h"
#import "NSString+Ext.h"
#import "HTNoDataView.h"
#import "TSLoginCtrl.h"
#import "TSRegisterCtrl.h"
#import "TSAlertView.h"
#import "TSUserModel.h"
#import "TSPathManager.h"
#import "TSOnlineServiceCtrl.h"

@interface TSOtherUserWorkCtrl ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TSProductCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray          *datas;
@property (nonatomic, assign) NSInteger        pageIndex;
//@property (nonatomic, assign) TSUserWorkType   type;
@property (nonatomic, strong) NSArray          *localDatas;
@property (nonatomic, strong) HTNoDataView     *noDataView;

@end

@implementation TSOtherUserWorkCtrl

#pragma mark - ViewLife

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configSelfData];
    
    [self beginHeadRefreshWithTableView:self.collectionView];
    
    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    [TSHelper checkUserIsOfflineWithCtrl:self offlineBlock:^{
//        [self.collectionView.mj_header beginRefreshing];
//    }];
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
    [self beginHeadRefreshWithTableView:self.collectionView];
}

#pragma mark - Private

//- (void)viewWillLayoutSubviews{
//    [super viewWillLayoutSubviews];
//
//    self.collectionView.frame = CGRectMake(0, 0, self.view.width, self.view.height-TABBAR_VIWE_HEIGHT);
//}

- (void)loadDatas:(id)obj{
    [self loadLineDatas:obj];
}

- (void)loadLineDatas:(id)obj{
    if( [obj isKindOfClass:[MJRefreshNormalHeader class]] ){
        //下拉
        _pageIndex = 0;
        [self resetNoMoreDataWithTableView:self.collectionView];
    }else{
        _pageIndex ++;
    }
    [self.dataProcess otherUserWorkWithUserId:self.userId pageNum:_pageIndex completeBlock:^(NSArray *datas, NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            if( err ){
                [self showErrMsgWithError:err];
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
                
                [self.collectionView reloadData];
            }
            
            self.noDataView.hidden = _datas.count;
            [self endRefreshWithIsHeadFresh:(_pageIndex==0) isHaveNewData:datas.count tableView:self.collectionView];

        }];
    }];
}

#pragma mark - TouchEvents
- (void)handleRegister{
    TSRegisterCtrl *rc = [TSRegisterCtrl new ];
    rc.hidesBottomBarWhenPushed = YES;
    [self pushViewCtrl:rc];
}

- (void)handleLogin{
    TSLoginCtrl *lc = [TSLoginCtrl new];
    [self pushViewCtrl:lc];
}

#pragma mark - CellDelegate

- (void)productCell:(TSProductCell *)cell handlePraiseBtn:(UIButton *)praiseBtn{
    //点赞 or 取消赞
    [self praiseOrCancleWithCell:cell handlePraiseBtn:praiseBtn];
}

- (void)praiseOrCancleWithCell:(TSProductCell *)cell handlePraiseBtn:(UIButton *)praiseBtn{
    //点赞 or 取消赞 需要登录
    if( [self isLoginedWithGotoLoginCtrl] == NO ) return;
    
    BOOL isPraise = !cell.model.isPraised;
    [self.dataProcess praiseOrCancle:isPraise workId:[NSString stringWithObj:cell.model.dm.ID] completeBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                if( isPraise ){
                    
                    [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailPraisedSuccess", nil)];//@"点赞成功"];
                }else{
                    [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailCancleSuccess", nil)];
                }
                
                praiseBtn.selected = !praiseBtn.isSelected;
                cell.model.isPraised = isPraise;
                NSInteger lastCount = cell.praiseBtn.titleLabel.text.integerValue;
                if( isPraise ) lastCount++;
                else lastCount--;
                if( lastCount < 0 ) lastCount = 0;
                cell.model.praiseCount = @(lastCount).stringValue;
                cell.model.dm.praise = cell.model.praiseCount;
                cell.model.dm.liked = @(isPraise).stringValue;
                [cell.praiseBtn setTitle:cell.model.praiseCount forState:UIControlStateNormal];
            }
        }];
    }];
}

#pragma mark -  Collection View DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TSProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TSProductCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    cell.tag = indexPath.row;
    
    TSProductModel *mm = (TSProductModel*)[self modelAtIndex:indexPath.row datas:_datas modelClass:[TSProductModel class]];
    cell.model = mm;
    
//    if( _type == TSUserWorkTypeLocal ){
//        [cell.praiseBtn setImage:[UIImage imageNamed:@"work_del"] forState:UIControlStateNormal];
//        [cell.praiseBtn setImage:[UIImage imageNamed:@"work_del"] forState:UIControlStateSelected];
//        cell.selected = NO;
//        [cell.praiseBtn setTitle:nil forState:UIControlStateNormal];
//    }
    
    return cell;
}

#pragma mark - collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TSProductCell *cell = (TSProductCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if( ![cell isKindOfClass:[TSProductCell class]] ){
        return;
    }

    TSProductionDetailCtrl *dc = [TSHelper sharedProductionDetailCtrl];//
    dc.dataModel = cell.model.dm;
    dc.hidesBottomBarWhenPushed =YES;
//    [dc reloadData];
    [self pushViewCtrl:dc];
}


#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    
    CGFloat ih = BOTTOM_NOT_SAVE_HEIGHT;
    return CGSizeMake(SCREEN_WIDTH, ih);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *rv = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GroupListHeader" forIndexPath:indexPath];
    rv.backgroundColor = [UIColor clearColor];
    
    return rv;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat ah = 480/2.0,aw = 270/2.0; //设计的宽和高
    
    ah=420; aw = 345;
    
    CGFloat iw = (SCREEN_WIDTH-3*10)/2;
    CGFloat ih = iw *(ah/aw) + 61; //66为底部的用户高度
    return CGSizeMake(iw, ih);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    CGFloat iLeft = 10;
    return UIEdgeInsetsMake(iLeft, iLeft, iLeft, iLeft);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

#pragma mark - Propertys

- (UICollectionView *)collectionView {
    if( !_collectionView ){
        //        UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] initWithType:AlignWithLeft betweenOfCell:5];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat iy = NAVGATION_VIEW_HEIGHT;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, iy, SCREEN_WIDTH, SCREEN_HEIGHT-iy) collectionViewLayout:layout];
        [_collectionView registerClass:[TSProductCell class] forCellWithReuseIdentifier:NSStringFromClass([TSProductCell class])];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GroupListHeader"];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [self configRefreshTableView:(UITableView*)_collectionView freshSel:@selector(loadDatas:)];
        [self.view addSubview:_collectionView];
        
        if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0") ){
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (HTNoDataView *)noDataView {
    if( !_noDataView ){
        NSString *text = NSLocalizedString(@"ProductInfoNO", nil); //@"暂无作品";
        
        _noDataView = [[HTNoDataView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVGATION_VIEW_HEIGHT) text:text action:nil target:nil];
        _noDataView.hideReloadBtn = YES;
        
        [self.collectionView addSubview:_noDataView];
    }
    return _noDataView;
}
@end
