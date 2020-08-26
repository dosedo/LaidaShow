//
//  TSProductionCtrl.m
//  ThreeShow
//
//  Created by cgw on 2018/9/25.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSProductionCtrl.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+Ext.h"
#import "MJRefresh.h"
#import "TSProductCell.h"
#import "TSProductModel.h"
#import "TSProductDataModel.h"
#import "TSProductionDetailCtrl.h"
//#import "TSHelper.h"
//#import "TSMyWorkCtrl.h"
#import "NSString+Ext.h"
#import "HTProgressHUD.h"
#import "TSConstants.h"
#import "HTNoDataView.h"
#import "TSClearBgStateView.h"
#import "TSHelper.h"
#import "TSOtherUserWorkCtrl.h"

@interface TSProductionCtrl ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TSProductCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray          *datas;
@property (nonatomic, assign) NSInteger        pageIndex;
//@property (nonatomic, strong) UIButton         *cameraBtn;
@property (nonatomic, strong) HTNoDataView     *noDataView;
@property (nonatomic, assign) NSString* category;
@property (nonatomic, strong) NSString* tid;
@end

@implementation TSProductionCtrl

- (id)initWithCategory:(NSString*)category{
    self = [super init];
    if( self ){
        _category = category;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViews];
    
    [self reloadData];
    
//    [self addNotifications];
    
    double am = [self availableMemory];
    double um = [self usedMemory];
    NSLog(@"%s___首次加载内存其情况__awailable=%fMB,used=%fMB",__func__,am,um);
}

- (void)dealloc{
//    [self removeNotifications];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, 0, self.view.width, self.view.height-TABBAR_VIWE_HEIGHT);
}

#pragma mark - Public
- (void)reloadData {
    [self beginHeadRefreshWithTableView:self.collectionView];
}

- (void)cancleLoadingData{
    
}

#pragma mark - Private

- (void)loadDatas:(id)obj{
    NSLog(@"---走这里---%@",_category);
    if( [obj isKindOfClass:[MJRefreshNormalHeader class]] ){
        //下拉
        _pageIndex = 0;
        [self resetNoMoreDataWithTableView:self.collectionView];
    }else{
        _pageIndex ++;
    }
    
    if ([_category isEqualToString:@"100"]) {
        
        [self dispatchAsyncQueueWithName:@"loadDataQ" block:^{
            [self.dataProcess allProductListWithPageIndex:_pageIndex tid:@"1" completeBlock:^(NSArray *datas, NSError *err) {
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
                    self.noDataView.hidden = (_datas.count );
                    [self endRefreshWithIsHeadFresh:(_pageIndex==0) isHaveNewData:datas.count tableView:self.collectionView];
                }];
            }];
        }];
    }
    else
        
        [self dispatchAsyncQueueWithName:@"loadDataNq" block:^{
            [self.dataProcess allProductListWithPageIndex:_pageIndex category:_category tid:_tid completeBlock:^(NSArray *datas, NSError *err) {
                
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
                    self.noDataView.hidden = (_datas.count );
                    [self endRefreshWithIsHeadFresh:(_pageIndex==0) isHaveNewData:datas.count tableView:self.collectionView];
                }];
            }];
        }];
}

- (void)initViews{
    
    _pageIndex = 0;
    
//    [self getNaviBgView];
    
    self.view.backgroundColor = [UIColor colorWithRgb_240_239_244];
    self.collectionView.hidden = NO;
}

#pragma mark - TouchEvents

- (void)handleReloadBtn{
    [self beginHeadRefreshWithTableView:self.collectionView];
}

#pragma mark - CellDelegate

- (void)productCell:(TSProductCell *)cell handleHeadImgView:(UIImageView *)imageview{
    TSOtherUserWorkCtrl *wc = [TSOtherUserWorkCtrl new];
    wc.userId = cell.model.dm.uid;
    wc.title = cell.model.dm.userName;
    wc.hidesBottomBarWhenPushed = YES;
    [self pushViewCtrl:wc];
}

- (void)productCell:(TSProductCell *)cell handlePraiseBtn:(UIButton *)praiseBtn{
    //点赞 or 取消赞 需要登录
    if( [self isLoginedWithGotoLoginCtrl] == NO ) return;
    
    BOOL isPraise = !cell.model.isPraised;
    [self.dataProcess praiseOrCancle:isPraise workId:[NSString stringWithObj:cell.model.dm.ID] completeBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                if( isPraise ){
                    [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailPraisedSuccess", nil)];//@"点赞成功"
                    
                }else{
                    [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailCancleSuccess", nil)];//@"取消成功"
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
    
    cell.model = (TSProductModel*)[self modelAtIndex:indexPath.row datas:_datas modelClass:[TSProductModel class]];
//    NSLog(@"cell.model.productImgUrl- %@",cell.model.productImgUrl);
    return cell;
}

#pragma mark - collection view delegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    if(![self isLoginedWithGotoLoginCtrl]) return;
    
    TSProductCell *cell = (TSProductCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if( ![cell isKindOfClass:[TSProductCell class]] ){
        return;
    }
    
    cell.delegate = self;
    TSProductionDetailCtrl *dc = [TSHelper sharedProductionDetailCtrl];//[TSProductionDetailCtrl new];
    dc.hidesBottomBarWhenPushed = YES;
    dc.dataModel = cell.model.dm;
    dc.thumbImg = cell.productImgView.image;
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
        
        if( @available(iOS 11.0,*)){
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
        NSString *text = NSLocalizedString(@"ProductInfoNO", nil);
        _noDataView = [[HTNoDataView alloc] initWithFrame:self.collectionView.bounds text:text action:@selector(handleReloadBtn) target:self];
        _noDataView.hideReloadBtn = NO;
        
        [self.collectionView addSubview:_noDataView];
    }
    return _noDataView;
}

@end
