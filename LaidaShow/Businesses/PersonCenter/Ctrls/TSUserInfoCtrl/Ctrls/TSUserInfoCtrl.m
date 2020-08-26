//
//  TSUserInfoCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 10/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSUserInfoCtrl.h"
#import "UIColor+Ext.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSPersonCenterCell.h"
#import "TSPersonCenterCellModel.h"
#import "HTTableView.h"
#import "TSUserModel.h"
#import "UIImageView+WebCache.h"
#import "WXWPhotoPicker.h"
#import "HTProgressHUD.h"
#import "TSConstants.h"
#import "HTModifyNickNameCtrl.h"
#import "TSModifyPwdCtrl.h"
#import "TSHelper.h"

@interface TSUserInfoCtrl ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIImageView *topImgView;
@property (nonatomic, strong) UIImageView *headImgView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *datas;
@property (nonatomic, strong) HTProgressHUD *hud;
@end

@implementation TSUserInfoCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRgb_240_239_244];
    [self addLeftBarItemWithAction:@selector(handleBack) imgName:@"arrow_left_102"];
    
    [self loadDatas];
    
    [self addNotificaitonObserver];
}

- (void)dealloc{
    [self removeNotifacionObserver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//"ModifyUserSignPageTitle"="个性签名";
//"ModifyUserSignHolder"="请输入新个性签名";
//"ModifyUserNosign"="还没有
#pragma mark - Private
- (void)gotoModifySignCtrl{
    HTModifyNickNameCtrl *nc = [HTModifyNickNameCtrl new];
    nc.itemTitle = NSLocalizedString(@"ModifyUserSignPageTitle", nil);//@"修改签名";
    nc.maxWordCount = 100;
    nc.placeHolder = NSLocalizedString(@"ModifyUserSignHolder", nil);//@"请输入用户名";
    nc.nickName = self.dataProcess.userModel.signature;
    nc.type = 1;
    [self pushViewCtrl:nc];
}

- (void)gotoModifyNameCtrl{
    HTModifyNickNameCtrl *nc = [HTModifyNickNameCtrl new];
    nc.itemTitle = NSLocalizedString(@"ModifyUserNamePageTitle", nil);//@"修改用户名";
    nc.maxWordCount = TSConstantUserNameMaxLen;
    nc.placeHolder = NSLocalizedString(@"ModifyUserNameHolder", nil);//@"请输入用户名";
    nc.nickName = self.dataProcess.userModel.userName;
    nc.type = 0;
    [self pushViewCtrl:nc];
}

#pragma mark - Notifications
- (void)addNotificaitonObserver{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyUserNameSuccessNoti) name:TSConstantNotificationModifyUserNameSuccess object:nil];
}

- (void)removeNotifacionObserver{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationModifyUserNameSuccess object:nil];
}

- (void)modifyUserNameSuccessNoti{

    if( _datas.count > 0 ){
//        TSPersonCenterCellModel *cm = _datas[0];
//        cm.rightText = self.dataProcess.userModel.userName;
//
//        [self.tableView reloadData];
        
        [self loadDatas];
    }
}

#pragma mark - TouchEvents
- (void)handleBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - LoadDatas
- (void)loadDatas{
    TSUserModel *um = [self.dataProcess userModel];
    TSPersonCenterCellModel *cm = [TSPersonCenterCellModel new];
    cm.leftText = NSLocalizedString(@"UserInfoUserName", nil);//@"用户名";
    cm.rightText = um.userName;
    
    TSPersonCenterCellModel *cm0 = [TSPersonCenterCellModel new];
    cm0.leftText = NSLocalizedString(@"ModifyUserSignPageTitle", nil);//@"个性签名";
    cm0.rightText = um.signature;
    if( cm0.rightText.length == 0 ){
        cm0.rightText = NSLocalizedString(@"ModifyUserNosign", nil);
    }
    
    TSPersonCenterCellModel *cm1 = [TSPersonCenterCellModel new];
    cm1.leftText = NSLocalizedString(@"UserInfoUserAccount", nil);//@"账号";
    cm1.rightText = um.phone;
    
    if( um.phone ==nil && um.email ){
        cm1.rightText = um.email;
    }
    
    NSMutableArray *arr = [NSMutableArray new];
    [arr addObject:cm];
    [arr addObject:cm0];
    [arr addObject:cm1];
    if( um.isThirdLogin){
        cm1.rightText = NSLocalizedString(@"UserInfoThirdLoginText", nil);//@"第三方登录";
    }
    else{
        TSPersonCenterCellModel *cm2 = [TSPersonCenterCellModel new];
        cm2.leftText = NSLocalizedString(@"UserInfoUserPwd", nil);//@"密码";
        cm2.rightText = @"*****";
        
        [arr addObject:cm2];
    }
    
    _datas = arr;
    [self.tableView reloadData];
    
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:um.userImgUrl] placeholderImage:[UIImage imageNamed:TSConstantDefaultHeadImgName]];
}

#pragma mark - 修改头像
- (void)startModifyHeadImg{
    WXWPhotoPicker *pp = [WXWPhotoPicker sharedPhotoPicker];
    [pp showActionSheetInView:self.view  fromController:self allowImgEdit:YES completion:^(NSArray *images) {
        
        if( images.count ){
            if( [images[0] isKindOfClass:[UIImage class] ] ){

                [self uploadImg:images[0]];
            }
        }
        
        NSLog(@"选择完成");
    } cancelBlock:^{
        NSLog(@"取消选择");
    }];
}

- (void)uploadImg:(UIImage*)img{
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self dispatchAsyncQueueWithName:@"uploadHeadImg" block:^{
        
        [self.dataProcess modifyUserImg:img completBlock:^(NSError *err) {
            [self dispatchAsyncMainQueueWithBlock:^{
                [_hud hide];
                if( err ){
                    [self showErrMsgWithError:err];
                }
                else{
                    
                    
                    
                    [HTProgressHUD showSuccess:NSLocalizedString(@"ModifyUserHeadImgSuccess", nil)];//@"头像修改成功"
                    [[NSUserDefaults standardUserDefaults] setObject:@"headImg" forKey:@"ModifyUserHeadImgSuccess"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
//                    [self updateHeadImg];
                    
                    self.headImgView.image = img;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationModifyUserImgSuccess object:nil];
                }
            }];
        }];
    }];
}

- (void)updateHeadImg{
    NSURL *url = [NSURL URLWithString:self.dataProcess.userModel.userImgUrl];
    [self.headImgView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRefreshCached];
}

#pragma mark - TouchEvents
- (void)handleHeadImg{
    [self handleModifyHeadImg];
}

- (void)handleModifyHeadImg{
    [self startModifyHeadImg];
}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseId = @"personInfoCellReuseID";
    TSPersonCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if( !cell ){
        cell = [[TSPersonCenterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        cell.line.hidden = NO;
    }
    
    NSUInteger idx = indexPath.row;
    if( idx == 2 ){
        cell.showArrow = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        cell.showArrow = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.model = (TSPersonCenterCellModel*)[self modelAtIndex:idx datas:_datas modelClass:[TSPersonCenterCellModel class]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if( indexPath.row == 2 ){
        //点击账号 啥也不干
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger idx = indexPath.row;
    if( idx == 0 ){
        //修改用户名
        [self gotoModifyNameCtrl];
    }
    else if( idx == 1 ){
        [self gotoModifySignCtrl];
    }
    else if( idx == 3 ){
        //手机号登录的修好 密码，第三方登录无此选项
        TSModifyPwdCtrl *pc = [TSModifyPwdCtrl new];
        [self pushViewCtrl:pc];
    }
}

#pragma mark - Property

- (UITableView *)tableView{
    if( !_tableView) {
        _tableView = [[HTTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        UIView *fv =[[UIView alloc] init];
        
        fv.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
        fv.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = fv;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.bounces = NO;
        _tableView.tableHeaderView = self.topImgView;
        
        [self.view addSubview:_tableView];
        
        CGFloat iy = NAVGATION_VIEW_HEIGHT-64 + STATUS_BAR_HEIGHT;
        _tableView.frame = CGRectMake(0, iy, SCREEN_WIDTH, SCREEN_HEIGHT-iy);
        
        if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0") ){
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (UIImageView *)headImgView {
    if( !_headImgView ){
        _headImgView = [[UIImageView alloc] init];
        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
        _headImgView.backgroundColor = [UIColor whiteColor];
//        [self.view addSubview:_headImgView];
        
        _headImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeadImg)];
        [_headImgView addGestureRecognizer:ges];
    }
    return _headImgView;
}

- (UIImageView *)topImgView {
    if( !_topImgView ){
        _topImgView = [[UIImageView alloc] init];
        _topImgView.image = [UIImage imageNamed:@"pc_info_bg"];
        CGSize size = _topImgView.image.size;
        CGFloat ih = SCREEN_WIDTH *(size.height/size.width);
        _topImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, ih);
        
        CGFloat wh = 80;
        self.headImgView.frame = CGRectMake((_topImgView.width-wh)/2, 54, wh, wh);
        [self.headImgView cornerRadius:wh/2];
        [_topImgView addSubview:self.headImgView];
        
        UIButton *modfiyBtn = [UIButton new];
        CGFloat iw = 83;ih=26;
        modfiyBtn.frame = CGRectMake((_topImgView.width-iw)/2, _headImgView.bottom+15, iw, ih);
        [modfiyBtn cornerRadius:3];
        modfiyBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        modfiyBtn.layer.borderWidth = 0.5;
        [modfiyBtn setTitle:NSLocalizedString(@"UserInfoModifyHeadImgText", nil) forState:UIControlStateNormal];
        modfiyBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [modfiyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [modfiyBtn setTitleColor:[UIColor colorWithRgb221] forState:UIControlStateHighlighted];
        [modfiyBtn addTarget:self action:@selector(handleModifyHeadImg) forControlEvents:UIControlEventTouchUpInside];
        [_topImgView addSubview:modfiyBtn];
        //TSUserModel *um = [self.dataProcess userModel];
//        if (um.phone==nil) {
//            modfiyBtn.hidden = YES;
//        }
        _topImgView.userInteractionEnabled = YES;
    }
    return _topImgView;
}

@end
