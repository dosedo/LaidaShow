//
//  TSReportCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 16/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSReportCtrl.h"
#import "UIView+LayoutMethods.h"
#import "UIViewController+Ext.h"
#import "UIColor+Ext.h"
#import "HTProgressHUD.h"
#import "HTTableView.h"
#import "TSSelectMusicCell.h"
#import "TSSelectMusicModel.h"
#import "PPAudioPlay.h"
#import "XWSheetView.h"

@interface TSReportCtrl ()<UITableViewDelegate,UITableViewDataSource,PPAudioPlayDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *datas;
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, assign) NSInteger   selectIndex;
@property (nonatomic, strong) PPAudioPlay *audioPlayer;

@end

@implementation TSReportCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self configSelfData];
//    self.navigationItem.title = NSLocalizedString(@"Report", nil);//@"举报"
//    [self addRightBarItemWithTitle:NSLocalizedString(@"CoifimReport", nil) action:@selector(handleSureBtn)];
//    [self getButtonAtRightBarItem].enabled = NO;
//    _selectIndex = -1;
//    [self loadDatas];
    
    self.view.backgroundColor = [UIColor clearColor];
//    self.navigationItem.leftBarButtonItems = @[[UIBarButtonItem new]];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
//    [self.audioPlayer endPlay];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    [self loadDatas];
}

- (void)loadDatas{
    
    NSArray *names = @[NSLocalizedString(@"GarbageMarketing", nil),NSLocalizedString(@"Sensitive information", nil),NSLocalizedString(@"Pornographic pornography", nil),NSLocalizedString(@"CHEAT", nil),NSLocalizedString(@"TORT", nil),NSLocalizedString(@"OTHERS", nil)];//@"垃圾营销"@"敏感信息"@"淫秽色情"@"欺诈"@"侵权"@"其他"
    
    __weak typeof(self) weakSelf = self;
    [XWSheetView showWithTitles:names handleIndexBlock:^(NSInteger index) {
        [weakSelf handleSheetIndex:index];
    }];
    
    NSMutableArray *arr = [NSMutableArray new];
    for( NSUInteger i=0; i<names.count; i++ ){
        TSSelectMusicModel *mm = [TSSelectMusicModel new];
        mm.name = names[i];
        [arr addObject:mm];
    }

    _datas = arr;
//    [self.tableView reloadData];
}

- (void)handleSheetIndex:(NSInteger)index{
    [HTProgressHUD showSuccess:NSLocalizedString(@"ReportInfoSuccess", nil)];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TouchEvents
- (void)handleSureBtn{
    [HTProgressHUD showSuccess:NSLocalizedString(@"ReportInfoSuccess", nil)];//举报成功
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseId = @"personCenterCellReuseID";
    TSSelectMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if( !cell ){
        cell = [[TSSelectMusicCell alloc] initReportCellWithReuseID:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSUInteger idx = indexPath.row;
    cell.model = (TSSelectMusicModel*)[self modelAtIndex:idx datas:_datas modelClass:[TSSelectMusicModel class]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    TSSelectMusicCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self getButtonAtRightBarItem].enabled = YES;
//    if( cell.model.isPlaying ){
//        cell.selected = NO;
//        _selectIndex = -1;
//        cell.model.isPlaying = NO;
//        [self.audioPlayer endPlay];
//
//    }else{
//        cell.model.isPlaying = YES;
//        _selectIndex = indexPath.row;
//        [self.audioPlayer startPlayWithUrl:cell.model.url];
//    }
}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
//    TSSelectMusicCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.model.isPlaying = NO;
//}

#pragma mark - AudioPlayDelegate
- (void)audioPlayEndPlay:(PPAudioPlay *)auidoPlay{
    if( _selectIndex>=0 && _selectIndex < _datas.count ){
        TSSelectMusicModel *mm = _datas[_selectIndex];
        mm.isPlaying = NO;
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Property

- (UITableView *)tableView{
    if( !_tableView) {
        _tableView = [[HTTableView alloc] init];
        _tableView.frame = CGRectMake(0, NAVGATION_VIEW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVGATION_VIEW_HEIGHT);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        UIView *fv =[[UIView alloc] init];
        
        fv.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
        fv.backgroundColor = [UIColor clearColor];
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

@end

