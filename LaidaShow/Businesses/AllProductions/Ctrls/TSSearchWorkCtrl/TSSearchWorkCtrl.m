//
//  TSSearchWorkCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 17/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSSearchWorkCtrl.h"
#import "UIViewController+Ext.h"
#import "HTSearchQuestionView.h"
#import "HTNoDataView.h"
#import "HTProgressHUD.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSDataBase.h"
#import "HTTableView.h"
#import "TSProductCell.h"
#import "TSProductModel.h"
#import "TSProductDataModel.h"
#import "TSProductionDetailCtrl.h"
#import "NSString+Ext.h"
#import "TSHelper.h"
#import "TSConstants.h"
#import "MJRefresh.h"

@interface TSSearchWorkCtrl ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TSProductCellDelegate>
@property (nonatomic, strong) HTSearchQuestionView *searchView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) HTNoDataView *noDataView;
@property (nonatomic, strong) HTProgressHUD *hud;

//搜索结果部分
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray          *searchDatas;
@property (nonatomic, assign) NSInteger        pageIndex;

@end

@implementation TSSearchWorkCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.searchView.searchView.searchBar.delegate = self;
    
    //    [self beginHeadRefreshWithTableView:self.tableView];
    
    [self.searchView.searchView.searchBar becomeFirstResponder];
//    self.noDataView.hidden = YES;
    
    [self loadDatas];
    
    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

-  (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)dealloc{
    [self removeNotifications];
}

#pragma mark - Private


- (void)loadDatas{
    
    _datas = [[TSDataBase sharedDataBase] historySearchDatas];
    [self.tableView reloadData];
}

- (void)setTableViewFooterAndHeader{
    CGFloat ih = 44;
    
    UILabel *titleL = [UILabel new];
    titleL.text = NSLocalizedString(@"SearchHistoryText", nil);//@"搜索历史";
    titleL.textColor = [UIColor colorWithRgb51];
    titleL.font = [UIFont systemFontOfSize:16];
    titleL.frame = CGRectMake(15, 0, SCREEN_WIDTH-15, ih);
    
    UIView *header = [UIView new];
    header.backgroundColor = [UIColor whiteColor];
    header.frame = CGRectMake(0, 0, SCREEN_WIDTH, ih);
    [header addSubview:titleL];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor colorWithRgb221];
    line.frame = CGRectMake(titleL.x, titleL.bottom-0.5, titleL.width, 0.5);
    [header addSubview:line];
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = [UIColor colorWithRgb221];
    line1.frame = CGRectMake(titleL.x, 0, titleL.width, 0.5);
    [header addSubview:line1];
    
    _tableView.tableHeaderView = header;
    
    UIButton *clearBtn = [UIButton new];
    [clearBtn setTitle:NSLocalizedString(@"SearchCleanHistory", nil) forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(handleClearHistory) forControlEvents:UIControlEventTouchUpInside];
    [clearBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
    [clearBtn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateHighlighted];
    clearBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    clearBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    clearBtn.backgroundColor = [UIColor colorWithRgb245];
    clearBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, ih);
    
    _tableView.tableFooterView = clearBtn;
}

- (void)startSearchText:(NSString*)text{
    if(text ==nil || [text isEqualToString:@""] ) return;
    
//    self.tableView.hidden = YES;
    self.collectionView.hidden = NO;
    [self.view endEditing:YES];
    [[TSDataBase sharedDataBase] insertHistorySearchWord:text];
    [self loadDatas];
    
    [self beginHeadRefreshWithTableView:self.collectionView];
}

#pragma mark - TouchEvents
- (void)handleClearHistory{
    [[TSDataBase sharedDataBase] deleteHistorySearchDatas];
    
    _datas = nil;
    [self.tableView reloadData];
}

#pragma mark - 🍐tableviewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseId = @"NOAnswerQuestionCellReuseId";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if( !cell ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithRgb51];
    
        UIImage *img = [UIImage imageNamed:@"sreach_clear"];
//        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
//        iv.frame = CGRectMake(0, 0, img.size.width, img.size.height);
//        cell.accessoryView = iv;
        
//        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        UIButton *btn = [UIButton new];
        btn.userInteractionEnabled = YES;
        btn.frame = CGRectMake(0, 0, 44, 44);
        [btn setImage:img forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(handleDeleteBtn:event:) forControlEvents:UIControlEventTouchUpInside];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        cell.accessoryView = btn;
    }
    
    if( _datas.count > indexPath.row ){
        cell.textLabel.text = _datas[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if( _datas.count > indexPath.row ){
        NSString * text = _datas[indexPath.row];
        self.searchView.searchView.searchBar.text = text;
        [self startSearchText:text];
    }
}

- (void)handleDeleteBtn:(id)sender event:(id)event
{
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.tableView];
    NSIndexPath *indexPath= [self.tableView indexPathForRowAtPoint:touchPoint];
    
    NSLog(@"%@",indexPath);
    
    if( indexPath ==nil  || self.datas.count == 0 ) return;
    
    //只有一条数据，则直接清空
    if( self.datas.count == 1){
        [self handleClearHistory];
    }
    else{
        //删除该行的数据
        
        NSMutableArray *tempDatas = [NSMutableArray arrayWithArray:self.datas];
        if( tempDatas.count > indexPath.row ){
            NSString *searchText = tempDatas[indexPath.row];
            [tempDatas removeObjectAtIndex:indexPath.row];
            _datas = tempDatas;
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [self dispatchAsyncQueueWithName:@"deleteSearchItemQ" block:^{
                [[TSDataBase sharedDataBase] deleteHistoryWithText:searchText];
            }];
        }
    }
}

#pragma mark __UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    
//    [self loadDatas];
    
    [self startSearchText:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    if( searchBar.text.length == 0 ){
        self.noDataView.hidden = YES;
//        self.tableView.hidden = NO;
        self.collectionView.hidden = YES;
    }
}

#pragma mark - Propertys
- (UIView *)topView {
    if( !_topView ){
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor whiteColor];
        CGFloat ih = (NAVGATION_VIEW_HEIGHT-64) + 85;
        _topView.frame = CGRectMake(0, 0, SCREEN_WIDTH, ih);
        
        [self.view addSubview:_topView];
    }
    return _topView;
}

- (HTSearchQuestionView *)searchView {
    if( !_searchView ){
        CGFloat ih = 65;
        CGFloat iy = self.topView.bottom-ih;
        _searchView = [[HTSearchQuestionView alloc] initWithFrame:CGRectMake(0, iy, SCREEN_WIDTH, ih)];
        _searchView.searchView.searchBar.placeholder = NSLocalizedString(@"SearchTextHolder", nil);//@"按用户名或作品名称描述搜索";
        
        [self.topView addSubview:_searchView];
        
        __weak typeof(self) weakSelf = self;
        _searchView.handleCancleBlock = ^{
            [weakSelf.searchView.searchView.searchBar resignFirstResponder];
            //            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _searchView;
}

- (UITableView *)tableView {
    if( !_tableView ){
        _tableView = [[HTTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        //        [self configRefreshTableView:_tableView freshSel:@selector(loadData:)];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        CGFloat iy = self.topView.bottom+7.5;
        _tableView.frame = CGRectMake(0, iy, SCREEN_WIDTH, SCREEN_HEIGHT-iy);
        [self.view addSubview:_tableView];
        
        [self setTableViewFooterAndHeader];
    }
    return _tableView;
}

- (HTNoDataView *)noDataView {
    if( !_noDataView ){
        CGRect fr = self.collectionView.bounds;fr.origin.y =0;
        _noDataView = [[HTNoDataView alloc] initWithFrame:fr text:NSLocalizedString(@"NoRelevantContent", nil) action:nil target:nil];//@"无相关内容"
        _noDataView.textLabel.textColor = [UIColor colorWithRgb51];
        _noDataView.textLabel.font = [UIFont systemFontOfSize:15];
        
//        _noDataView.imgView.image = [UIImage imageNamed:@"qw_search_nodata"];
        _noDataView.hideReloadBtn = YES;
        _noDataView.backgroundColor = [UIColor whiteColor];
        [self.collectionView addSubview:_noDataView];
    }
    return _noDataView;
}

#pragma mark -  ******搜索结果部分*******

#pragma mark - Notifications
- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOnlineWork) name:TSConstantNotificationDeleteWorkOnLine object:nil];
}

- (void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationDeleteWorkOnLine object:nil];
}

- (void)deleteOnlineWork{
    [self beginHeadRefreshWithTableView:self.collectionView];
}

#pragma mark - Private

- (void)loadDatas:(id)obj{

    if( [obj isKindOfClass:[MJRefreshNormalHeader class]] ){
        //下拉
        _pageIndex = 0;
        [self resetNoMoreDataWithTableView:self.collectionView];
        _hud = [HTProgressHUD showMessage:nil toView:self.view];
    }else{
        _pageIndex ++;
    }
    NSString *keyWords = self.searchView.searchView.searchBar.text;
    [self.dataProcess searchWorkWithWord:keyWords pageIndex:_pageIndex completeBlock:^(NSArray *datas, NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                if( _pageIndex == 0 ){
                    _searchDatas = datas;
                }else{
                    if( _searchDatas.count ){
                        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_searchDatas];
                        if( datas ){
                            [tempArr addObjectsFromArray:datas];
                        }
                        _searchDatas = tempArr;
                    }
                }
                
                [self.collectionView reloadData];
            }
            
            self.noDataView.hidden = (_searchDatas.count );
            [self endRefreshWithIsHeadFresh:(_pageIndex==0) isHaveNewData:datas.count tableView:self.collectionView];
        }];
    }];
}


#pragma mark - CellDelegate

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
                    [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailPraisedSuccess", nil)];
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
    return _searchDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TSProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TSProductCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    cell.tag = indexPath.row;
    
    cell.model = (TSProductModel*)[self modelAtIndex:indexPath.row datas:_searchDatas modelClass:[TSProductModel class]];
    
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
    //    dc.imgUrls = cell.model.dm.picUrls;
    dc.dataModel = cell.model.dm;
    //    dc.isNeedReloadData = YES;
//    [dc reloadData];
    [self pushViewCtrl:dc];
    //    [dc reloadData];
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
    
    CGFloat ah = 340/2.0,aw = 270/2.0; //设计的宽和高
    
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

- (UICollectionView *)collectionView {
    if( !_collectionView ){

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat iy = NAVGATION_VIEW_HEIGHT+7.5;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, iy, SCREEN_WIDTH, SCREEN_HEIGHT-iy) collectionViewLayout:layout];
        [_collectionView registerClass:[TSProductCell class] forCellWithReuseIdentifier:NSStringFromClass([TSProductCell class])];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GroupListHeader"];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor colorWithRgb_240_239_244];
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


@end
