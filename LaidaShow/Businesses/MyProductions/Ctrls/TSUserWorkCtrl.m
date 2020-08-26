//
//  TSUserWorkCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 15/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
// metwen

#import "TSUserWorkCtrl.h"
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
#import "KError.h"
#import "TSWorkTypeSelectView.h"
#import "TSVideoWorkDetailCtrl.h"
#import "TSEditVideoWorkCtrl.h"

@interface TSUserWorkCtrl ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TSProductCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray          *datas;
@property (nonatomic, assign) NSInteger        pageIndex;
@property (nonatomic, assign) TSUserWorkType   type;
@property (nonatomic, strong) NSArray          *localDatas;
@property (nonatomic, strong) HTNoDataView     *noDataView;
@property (nonatomic, strong) TSWorkTypeSelectView *typeSelectView;

@end

@implementation TSUserWorkCtrl

- (id)initWithType:(TSUserWorkType)type{
    self = [super init];
    if( self ){
        _type = type;
    }
    return self;
}

- (void)reloadData {
    
    [self beginHeadRefreshWithTableView:self.collectionView];
    
    [self updateNoDataViewTextAndStatus];
}

- (void)cancleLoadingData{
//    [self beginHeadRefreshWithTableView:self.collectionView];
}

#pragma mark - ViewLife

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViews];
    
    if( self.type == TSUserWorkTypeLocal ){
        //本地作品不让上拉加载
        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    }
    
    [self beginHeadRefreshWithTableView:self.collectionView];
    
    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateNoDataViewTextAndStatus];
//    //即将进入本页面时，进行数据的加载更新（点赞状态的实时更新）

    [self addNotifications];
    
    if( self.type != TSUserWorkTypeLocal ){
        [TSHelper checkUserIsOfflineWithCtrl:self offlineBlock:^{
            [self.collectionView.mj_header beginRefreshing];
        }];
    }
}

- (void)dealloc{
    [self removeNotifications];
}

#pragma mark - Notifications
- (void)addNotifications{
    NSString *name = TSConstantNotificationDeleteWorkLocal;
    if( _type != TSUserWorkTypeLocal){
        name = TSConstantNotificationDeleteWorkOnLine;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOnlineWork) name:TSConstantNotificationUserCancleCollect object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOnlineWork) name:TSConstantNotificationLoginSuccess object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOnlineWork) name:name object:nil];
}

- (void)removeNotifications{
    NSString *name = TSConstantNotificationDeleteWorkLocal;
    if( _type != TSUserWorkTypeLocal){
        name = TSConstantNotificationDeleteWorkOnLine;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationUserCancleCollect object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationLoginSuccess object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:name object:nil];
}

- (void)deleteOnlineWork{
    [self beginHeadRefreshWithTableView:self.collectionView];
}

#pragma mark - Private

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGFloat iy = 0;
    if( _type != TSUserWorkTypeCollect ){
        iy = self.typeSelectView.bottom;
    }
    self.collectionView.frame = CGRectMake(0, iy, self.view.width, self.view.height-TABBAR_VIWE_HEIGHT-iy);
}

- (void)loadDatas:(id)obj{
    if( _type == TSUserWorkTypeLocal ){
        [self loadLocalDatas];
    }
    else{
        //用户未登录，则不必拉数据
        if( self.dataProcess.userModel == nil ){
            _datas = nil;
            [self.collectionView reloadData];
            self.noDataView.hidden = NO;
            [self endRefreshWithIsHeadFresh:YES isHaveNewData:nil tableView:self.collectionView];
        
        }else{
            
            if(_type == TSUserWorkTypeLinePublic ){
                [self loadLineDatas:obj isPublic:YES];
            }
            else if( _type == TSUserWorkTypeLinePrivate ){
                [self loadLineDatas:obj isPublic:NO];
            }
            else{
                [self loadCollectDatas:obj];
            }
        }
    }
}

- (void)loadLineDatas:(id)obj isPublic:(BOOL)isPublic{
    if( [obj isKindOfClass:[MJRefreshNormalHeader class]] ){
        //下拉
        _pageIndex = 0;
        [self resetNoMoreDataWithTableView:self.collectionView];
    }else{
        _pageIndex ++;
    }
    [self.dataProcess myOnlineWorkListWithPageIndex:_pageIndex isPublic:isPublic type:self.typeSelectView.selectedIndex completeBlock:^(NSArray *datas, NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            if( err ){
                NSString *errMsg = [KError errorMsgWithError:err];
                if( [errMsg containsString:@"请重新登录"] && self.dataProcess.userModel ){
                    self.noDataView.hidden = NO;
                    _datas = nil;
                    [self.collectionView reloadData];
                }
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

- (void)loadLocalDatas{
    [self dispatchAsyncQueueWithName:@"loadLocalDataQ" block:^{
        NSArray *datas =
        [[PPLocalFileManager shareLocalFileManager] getLocalFilesInfo];
        NSLog(@"加载本地作品 -- %@",datas);
        if( [datas isKindOfClass:[NSMutableArray class]] ){
            NSMutableArray *mutaDatas = (NSMutableArray*)datas;
            datas = [[mutaDatas reverseObjectEnumerator] allObjects];
        }
        
//        _localDatas = datas;
        NSMutableArray *localDatas = [NSMutableArray new];
        NSMutableArray *arr = [NSMutableArray new];
        for( TSWorkModel *wm in datas ){
            
            BOOL isVideoWork = self.typeSelectView.selectedIndex == 1;
            if( isVideoWork ){
                if( wm.isVideoWork ==NO ) continue;
            }else{
                if( wm.isVideoWork ) continue;
            }
            
            
            [localDatas addObject:wm];
            
            TSProductModel *pm = [TSProductModel new];
            pm.productName = wm.workName;
            pm.userName = self.dataProcess.userModel.userName;
            pm.userImgUrl = self.dataProcess.userModel.userImgUrl;
            
            
            NSMutableArray *imgArr = [NSMutableArray new];
            NSMutableArray *clearImgArr = [NSMutableArray new];
            NSMutableArray *maskPathArr = [NSMutableArray new];
            NSUInteger i=0;
            for( NSString *imgPath in wm.imgPathArr ){
                if( [imgPath isKindOfClass:[NSString class]] ){
                    //根据文件名 重新获取一次 图片的路径，保存时的路径有可能更改
                    NSString *newImgPath =
                    [[TSPathManager sharePathManager] getNewPathByReplaceOldDocPathWithPath:imgPath];
                    if( newImgPath ){
                        [imgArr addObject:newImgPath];
                    }
                }
                
                if( wm.clearBgImgPathArr.count > i ){
                    NSString *oldPath = wm.clearBgImgPathArr[i];
                    NSString *clearPath =
                    [[TSPathManager sharePathManager] getNewPathByReplaceOldDocPathWithPath:oldPath];
                    if( oldPath ){
                        [clearImgArr addObject:clearPath];
                    }
                }
                
                if( wm.maskImgPathArr.count > i ){
                    NSString *oldPath = wm.maskImgPathArr[i];
                    NSString *clearPath =
                    [[TSPathManager sharePathManager] getNewPathByReplaceOldDocPathWithPath:oldPath];
                    if( oldPath ){
                        [maskPathArr addObject:clearPath];
                    }
                }
                
                i++;
            }

            
            wm.imgPathArr = imgArr;
            if( clearImgArr.count ){
                wm.clearBgImgPathArr = clearImgArr;
                
                NSString *imgPath = wm.clearBgImgPathArr[0];
                if( [imgPath isKindOfClass:[NSString class]] ){
                    pm.productImgUrl = imgPath;
                }
            }
            else if( wm.imgPathArr.count ){
                NSString *imgPath = wm.imgPathArr[0];
                if( [imgPath isKindOfClass:[NSString class]] ){
                    pm.productImgUrl = imgPath;
                }
            }
            
            if( maskPathArr.count ){
                wm.maskImgPathArr = maskPathArr;
            }
            
            if( isVideoWork ){
                pm.productImgUrl = [[TSPathManager sharePathManager] getNewPathByReplaceOldDocPathWithPath:wm.coverPath];
                wm.videoPath = [[TSPathManager sharePathManager] getNewPathByReplaceOldDocPathWithPath:wm.videoPath];
            }

            [arr addObject:pm];
        }
        
        _datas = arr;
        _localDatas = localDatas;
        [self dispatchAsyncMainQueueWithBlock:^{
            self.noDataView.hidden = _datas.count;
            [self.collectionView reloadData];
            [self endRefreshWithIsHeadFresh:YES isHaveNewData:YES tableView:self.collectionView];
        }];
    }];
}

- (void)loadCollectDatas:(id)obj{
    if( [obj isKindOfClass:[MJRefreshNormalHeader class]] ){
        //下拉
        _pageIndex = 0;
        [self resetNoMoreDataWithTableView:self.collectionView];
    }else{
        _pageIndex ++;
    }
    [self.dataProcess myCollectWorkListWithPageIndex:_pageIndex completeBlock:^(NSArray *datas, NSError *err) {
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

- (void)initViews{
    
    _pageIndex = 0;
    self.view.backgroundColor = [UIColor colorWithRgb_240_239_244];
}

#pragma mark - Private

- (void)deleteWorkWithCell:(TSProductCell*)cell{
    if( cell ){
        NSIndexPath *ip =
        [self.collectionView indexPathForCell:cell];
        if( self.localDatas.count > ip.row ){
            TSWorkModel *wm = _localDatas[ip.row];
            if( [wm isKindOfClass:[TSWorkModel class]] ){
               
                [self dispatchAsyncQueueWithName:@"DeleteQ" block:^{
                    [[PPLocalFileManager shareLocalFileManager] removeFileWithIndex:wm.imgDataIndex];
                }];
                
                NSMutableArray *datas = [NSMutableArray arrayWithArray:_datas];
                NSInteger idx = -1;
                if(cell.model && [datas containsObject:cell.model] ){
                    idx = [datas indexOfObject:cell.model];
                    [datas removeObject:cell.model];
                }
                
                _datas = datas;
                if( idx >= 0 ){
                    NSMutableArray *localDatas = [NSMutableArray arrayWithArray:_localDatas];
                    if( localDatas.count > idx){
                        [localDatas removeObjectAtIndex:idx];
                    }
                    _localDatas = localDatas;
                }
                
                [self.collectionView reloadData];
                [HTProgressHUD showError:NSLocalizedString(@"WorkDeleteSuccess", nil)];//@"删除成功"
            }
        }
    }
}

- (void)updateNoDataViewTextAndStatus{

    if( _type != TSUserWorkTypeLocal ){
        UIView *res = [self.noDataView viewWithTag:[self getTagBase]];
        UIView *login = [self.noDataView viewWithTag:[self getTagBase]+1];
        
        BOOL isLogin = [self isLogined];
        res.hidden = isLogin;
        login.hidden = isLogin;
        
        NSString *text = NSLocalizedString(@"WorkMore", nil);//@"需要登录后才能看到更多作品哦...";
        if( isLogin ){
            text = NSLocalizedString(@"WorkNo", nil); //@"暂时还没有作品哦";
        }
        self.noDataView.textLabel.text = text;
    }
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
    if( _type == TSUserWorkTypeLocal ){
        //删除作品
        __weak typeof(self) weakSelf = self;

        NSString *title = NSLocalizedString(@"WorkDetailConfirmDeleteWorkTitle", nil);
        NSString *msg = NSLocalizedString(@"WorkDetailConfirmDeleteWorkDes", nil);
        
        [TSAlertView showAlertWithTitle:title des:msg handleBlock:^(NSInteger index) {
//            [weakSelf deleteWork];
            [weakSelf deleteWorkWithCell:cell];
        }];
    }
    else{
        //点赞 or 取消赞
        [self praiseOrCancleWithCell:cell handlePraiseBtn:praiseBtn];
    }
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
    
    if( _type == TSUserWorkTypeLocal ){
        [cell.praiseBtn setImage:[UIImage imageNamed:@"work_del"] forState:UIControlStateNormal];
        [cell.praiseBtn setImage:[UIImage imageNamed:@"work_del"] forState:UIControlStateSelected];
        cell.selected = NO;
        [cell.praiseBtn setTitle:nil forState:UIControlStateNormal];
    }

    return cell;
}

#pragma mark - collection view delegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    if(![self isLoginedWithGotoLoginCtrl]) return;
    
    TSProductCell *cell = (TSProductCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if( ![cell isKindOfClass:[TSProductCell class]] ){
        return;
    }
    
    if( _type == TSUserWorkTypeLocal ){
        if( _localDatas.count > indexPath.row ){
        
            TSLocalWorkDetailCtrl *dc = [TSLocalWorkDetailCtrl new];
            dc.model = _localDatas[indexPath.row];
            dc.model.isLocalWork = YES;
            dc.hidesBottomBarWhenPushed = YES;
            [self pushViewCtrl:dc];
        }
    }else{

        if( cell.model.isVideoWork ){
            TSVideoWorkDetailCtrl *dc = [TSVideoWorkDetailCtrl new];
            dc.dataModel = cell.model.dm;
            dc.coverImg = cell.productImgView.image;
            dc.hidesBottomBarWhenPushed =YES;
            [self pushViewCtrl:dc];
        }else{
            
//            TSEditVideoWorkCtrl *wc = [TSEditVideoWorkCtrl new];
//            wc.model = [TSWorkModel new];
//            wc.model.videoPath = @"/Users/cgw/Desktop/video_200411.mp4";
//            wc.hidesBottomBarWhenPushed = YES;
//            [self pushViewCtrl:wc];
//            return;
            
            TSProductionDetailCtrl *dc = [TSHelper sharedProductionDetailCtrl];//
            dc.dataModel = cell.model.dm;
            dc.hidesBottomBarWhenPushed =YES;
//            [dc reloadData];
            [self pushViewCtrl:dc];
        }
    }
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
        if( _type != TSUserWorkTypeLocal ){
            //添加注册登录的按钮。只是先隐藏，
            
            CGFloat iw = 100,ih = 40;
            CGFloat ix = (_noDataView.width-iw*2)/3;
            CGFloat iy = _noDataView.textLabel.bottom + 20;
            UIButton *btn = [UIButton new];
            [btn setTitle:NSLocalizedString(@"LoginRegisterBtnTitle", nil) forState:UIControlStateNormal];//@"注册"
            [btn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRgb153] forState:UIControlStateHighlighted];
            [btn cornerRadius:3];
            btn.layer.borderWidth  = 0.5;
            btn.layer.borderColor = [UIColor colorWithRgb153].CGColor;
            btn.frame = CGRectMake(ix, iy, iw, ih);
            [btn addTarget:self action:@selector(handleRegister) forControlEvents:UIControlEventTouchUpInside];
            [_noDataView addSubview:btn];
            btn.tag = [self getTagBase]+0;
            btn.hidden = YES;
            
            UIButton *btn1 = [UIButton new];
            [btn1 setTitle:NSLocalizedString(@"LoginBtnTitle", nil) forState:UIControlStateNormal];//@"登录"
            [btn1 setTitleColor:[UIColor colorWithRgb_0_151_216] forState:UIControlStateNormal];
            [btn1 setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateHighlighted];
            [btn1 cornerRadius:3];
            btn1.layer.borderWidth  = 0.5;
            btn1.layer.borderColor = [UIColor colorWithRgb_0_151_216].CGColor;
            btn1.frame = CGRectMake(ix+btn.right, iy, iw, ih);
            [btn1 addTarget:self action:@selector(handleLogin) forControlEvents:UIControlEventTouchUpInside];
            [_noDataView addSubview:btn1];
            btn1.tag = [self getTagBase]+1;
            btn1.hidden = YES;
        }
        
        [self.collectionView addSubview:_noDataView];
    }
    return _noDataView;
}

- (TSWorkTypeSelectView*)typeSelectView{
    if( !_typeSelectView ){
        _typeSelectView = [[TSWorkTypeSelectView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 34) inView:self.view];
        _typeSelectView.backgroundColor = self.view.backgroundColor;
        __weak typeof(self) wk = self;
        _typeSelectView.selectBlock = ^(NSInteger selectIndex) {
            [wk reloadData];
        };
    }
    return _typeSelectView;
}


@end
