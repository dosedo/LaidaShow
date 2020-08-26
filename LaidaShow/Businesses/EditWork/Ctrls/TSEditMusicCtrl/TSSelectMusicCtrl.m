//
//  TSSelectMusicCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSSelectMusicCtrl.h"
#import "UIView+LayoutMethods.h"
#import "UIViewController+Ext.h"
#import "UIColor+Ext.h"
#import "HTProgressHUD.h"
#import "HTTableView.h"
#import "TSSelectMusicCell.h"
#import "TSSelectMusicModel.h"
#import "PPAudioPlay.h"
#import "HTSearchQuestionView.h"
#import "HTNoDataView.h"

@interface TSSelectMusicCtrl ()<UITableViewDelegate,UITableViewDataSource,PPAudioPlayDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *datas;
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, assign) NSInteger   selectIndex;
@property (nonatomic, strong) PPAudioPlay *audioPlayer;
@property (nonatomic, strong) HTSearchQuestionView *searchView;
@property (nonatomic, strong) NSArray *tempDatas;
@property (nonatomic, strong) HTNoDataView *noDataView;

@end

@implementation TSSelectMusicCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelfData];
    self.navigationItem.title = NSLocalizedString(@"WorkEditBottomMusicPageTitle", nil);//@"音乐";
    [self addRightBarItemWithTitle:NSLocalizedString(@"WorkEditBottomMusicConfirmText", nil) action:@selector(handleSureBtn)];
    _selectIndex = -1;
//    self.tableView.hidden = NO;
    [self loadDatas];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.audioPlayer endPlay];
}

- (void)loadDatas{
    NSArray *urls = @[
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/4 in A Minor.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/The piano dance.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/Prelude In C Major.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/3 in F Major.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/Passepied.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/Rondeaux.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/K_448.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/Schwarze Tasten Etude.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/Chopsticks.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/Largo from Winter.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/L’istesso tempo.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/Allegro moderato.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/Slow Dancing In The Dark.mp3",
    @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/The wonderful night of the violin.mp3"];
    
    NSMutableArray *arr = [NSMutableArray new];
    for( NSUInteger i=0; i<urls.count; i++ ){
        TSSelectMusicModel *mm = [TSSelectMusicModel new];
        mm.url = urls[i];
        
        if( mm.url ){
            NSString *lastStr = [mm.url lastPathComponent];
            mm.name = lastStr;
        }
        
        [arr addObject:mm];
    }
    
    _datas = arr;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TouchEvents
- (void)handleSureBtn{
    //设置为已播放状态，这样离开页面，还未播放音乐，则不会继续播放
    [PPAudioPlay shareAudioPlay].needEndWhenStartPlaying = YES;
    [self.audioPlayer endPlay];
    [self.navigationController popViewControllerAnimated:YES];
    if( self.selectCompleteBlock ){
        TSSelectMusicModel *mm = nil;
        if( _selectIndex >=0 && _selectIndex < _datas.count ){
            mm = _datas[_selectIndex];
        }
        self.selectCompleteBlock(mm);
    }
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseId = @"personCenterCellReuseID";
    TSSelectMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if( !cell ){
        cell = [[TSSelectMusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSUInteger idx = indexPath.row;
    cell.model = (TSSelectMusicModel*)[self modelAtIndex:idx datas:_datas modelClass:[TSSelectMusicModel class]];
    NSLog(@"idx======%ld",idx);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TSSelectMusicCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if( cell.model.isPlaying ){
        cell.selected = NO;
        _selectIndex = -1;
        cell.model.isPlaying = NO;
        [self.audioPlayer endPlay];
        
    }else{
        cell.model.isPlaying = YES;
        _selectIndex = indexPath.row;
        [self.audioPlayer startPlayWithUrl:cell.model.url];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    TSSelectMusicCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.model.isPlaying = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self removeKeyBoard];
}

#pragma mark - AudioPlayDelegate
- (void)audioPlayEndPlay:(PPAudioPlay *)auidoPlay{
    if( _selectIndex>=0 && _selectIndex < _datas.count ){
        TSSelectMusicModel *mm = _datas[_selectIndex];
        mm.isPlaying = NO;
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)removeKeyBoard{
    [self.tableView endEditing:YES];
    [self.view endEditing:YES];
}

#pragma mark - SearchBarDelegate
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    if( self.searchView.cancleBtn.isHidden ){
        CGRect fr = self.searchView.frame;
        [self.searchView changeFrame:fr showCancleBtn:YES];
//        _tempPage = _page;
        _tempDatas = _datas;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if( searchText ==nil || [searchText isEqualToString:@" "] || [searchText isEqualToString:@""] ) return;
    
    NSMutableArray *arr = [NSMutableArray new];
    for( TSSelectMusicModel *mm in _datas ){
        if( [mm.name containsString:searchText] ){
            [arr addObject:mm];
        }
    }
    
    _datas = arr;
    self.noDataView.hidden = (arr.count);
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self removeKeyBoard];
//    [self requestDatasWithKeyword:searchBar.text obj:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self removeKeyBoard];
    
    CGRect fr = self.searchView.frame;
    [self.searchView changeFrame:fr showCancleBtn:NO];
    
    _datas = _tempDatas;
    searchBar.text = nil;
    
    self.noDataView.hidden = YES;//(_datas.count);
    [self.tableView reloadData];
}

#pragma mark - Property

- (UITableView *)tableView{
    if( !_tableView) {
        _tableView = [[HTTableView alloc] init];
        CGFloat iy = self.searchView.y;
        _tableView.frame = CGRectMake(0, iy, SCREEN_WIDTH, SCREEN_HEIGHT-iy);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        UIView *fv =[[UIView alloc] init];
        
        fv.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
        fv.backgroundColor = [UIColor clearColor];
        fv.opaque = YES;
        _tableView.tableFooterView = fv;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.bounces = YES;
        
        [self.view addSubview:_tableView];
        
        if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0") ){
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
//
        [self.view bringSubviewToFront:self.noDataView];
    }
    return _tableView;
}

- (PPAudioPlay *)audioPlayer {
    if( !_audioPlayer ){
        _audioPlayer = [PPAudioPlay shareAudioPlay];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}

- (HTSearchQuestionView *)searchView {
    
    if( !_searchView ){
        CGFloat ih = 65;
        CGFloat iy = NAVGATION_VIEW_HEIGHT;
        _searchView = [[HTSearchQuestionView alloc] initWithFrame:CGRectMake(0, iy, SCREEN_WIDTH, ih)];
        _searchView.cancleBtn.hidden = YES;
        NSString *holder = NSLocalizedString(@"SearchTextHolder", nil);
        if( holder ){
            NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:holder];
            [as addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor colorWithRgb153]} range:NSMakeRange(0, holder.length)];
            if( @available(iOS 13.0, *) ){
                _searchView.searchView.searchBar.searchTextField.attributedPlaceholder = as;
            }else{
                _searchView.searchView.searchBar.placeholder = holder;
            }
        }
//        _searchView.searchView.searchBar.placeholder = holder;;//@"按用户名或作品名称描述搜索";
        _searchView.searchView.searchBar.delegate = self;
        [_searchView.searchView cornerRadius:5];
        _searchView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_searchView];
        
        [_searchView changeFrame:_searchView.frame showCancleBtn:NO];

        
        __weak typeof(self) weakSelf = self;
        _searchView.handleCancleBlock = ^{
             [weakSelf searchBarCancelButtonClicked: weakSelf.searchView.searchView.searchBar];
        };
        
        //暂时隐藏搜索
        _searchView.hidden = YES;
    }
    return _searchView;
}

- (HTNoDataView *)noDataView {
    if( !_noDataView ){
        NSString *text = @"无相关内容";//NSLocalizedString(@"ProductInfoNO", nil);
        CGFloat iy = self.searchView.bottom;
        _noDataView = [[HTNoDataView alloc] initWithFrame:CGRectMake(0, iy, SCREEN_WIDTH, SCREEN_HEIGHT-iy) text:text action:@selector(reloadData) target:self];
        _noDataView.imgView.image = nil;
        _noDataView.hideReloadBtn = YES;
        _noDataView.hidden = YES;
        [self.view addSubview:_noDataView];
    }
    return _noDataView;
}


@end
