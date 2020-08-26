//
//  TSDeviceConnectCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 12/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSDeviceConnectCtrl.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSDeviceConnectCell.h"
#import "TSDeviceCellModel.h"
#import "HTTableView.h"
#import "MyBleClass.h"
#import "HTProgressHUD.h"
#import "TSTakePhotoCtrl.h"
#import "TSHelper.h"
#import "TSShootVideoCtrl.h"

@interface TSDeviceConnectCtrl ()<UITableViewDelegate,UITableViewDataSource,MyBleDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas; //已连接的设备
@property (nonatomic, strong) NSMutableArray *noConnectDatas;  //未连接的设备数据
@property (nonatomic, strong) UILabel     *noteL;
@property (nonatomic, strong) UIButton    *freshBtn;
@property (nonatomic, strong) UILabel     *scanTitleL;
@property (nonatomic, strong) MyBleClass  *bluetoothManager;
@property (nonatomic, strong) NSTimer     *scanTimer; //扫描计时 。超过10秒停止扫描
@property (nonatomic, strong) NSTimer     *connectTimer; //超过20秒，则停止连接
@property (nonatomic, assign) BOOL        isScaning;

@end

@implementation TSDeviceConnectCtrl

- (instancetype)init{
    self = [super init];
    if( self ){
        _needGotoCamera = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelfData];
    self.navigationItem.title = NSLocalizedString(@"DeviceConnectPageTitle", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.noteL.text = NSLocalizedString(@"DevicePleaseConnectedDeviceText", nil);
    [self addRightBarItemWithTitle:NSLocalizedString(@"DeviceConnectGotoTakePhotoText", nil) action:@selector(handleGotoCamera)];
    UIButton *rightBtn = [self getButtonAtRightBarItem];
    
    if( self.bluetoothManager.connectedShield.state != 2 ){
        //未连接,则扫描设备
        [self searchBluetoothDevice];
        _isScaning = YES;
    }
    else{
        _isScaning = NO;
    }
    rightBtn.enabled = !_isScaning;
    [self reloadDeviceDatas];
    //上来加载下数据,展示header
//    [self.tableView reloadData];
    
//    rightBtn.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [MyPublic shareMyBleClass].delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self stopScan:nil];
    self.bluetoothManager.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public
- (void)appExit{
    //app退出时，断开蓝牙
    
    if ([self.bluetoothManager connectedShield].state == CBPeripheralStateConnected) {
        [self.bluetoothManager MybleDisConnectBleAll];
    }
}

#pragma mark - Priavte
- (void)searchBluetoothDevice{
    if( [self checkBluetoothState] == NO ) return;
    
    [self.bluetoothManager MybleStartFindBle:YES];
    _freshBtn.selected = NO;
    _isScaning         = YES;
    [self startTimer];
}

- (BOOL)checkBluetoothState{
    //10.0以上 ，判断蓝牙状态
    BOOL ret = YES;
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ){
        
        if(self.bluetoothManager.cbManager.state == CBManagerStatePoweredOff){
           
            [self showAlertViewWithTitle:nil msg:NSLocalizedString(@"BluetoothOFF",nil) okBlock:^{
                [self stopScan:nil];//蓝牙尚未打开,请打开蓝牙Bluetooth has not been turned on. Please turn on Bluetooth.
            } cancleBlock:nil];
            ret = NO;
        }
        
        else if(self.bluetoothManager.cbManager.state == CBManagerStateUnsupported){
            
            [self showAlertViewWithTitle:nil msg:NSLocalizedString(@"BluetoothNotSuppered",nil) okBlock:^{
                [self stopScan:nil];//@"设备不支持蓝牙"Bluetooth is not supported by device.
            } cancleBlock:nil];
            ret = NO;
        }
        
//        else if(self.bluetoothManager.cbManager.state == CBManagerStateUnknown){
//
//            [self showAlertViewWithTitle:nil msg:@"蓝牙未知错误" okBlock:^{
//                [self stopScan:nil];
//            } cancleBlock:nil];
//            ret = NO;
//        }
        
        else if(self.bluetoothManager.cbManager.state == CBManagerStateUnauthorized){
            
            [self showAlertViewWithTitle:nil msg:NSLocalizedString(@"BluetoothNoPremission",nil) okBlock:^{
                [self stopScan:nil];//@"没有使用蓝牙的权限，请开启权限" No permission to use Bluetooth, please open the right
            } cancleBlock:nil];
            ret = NO;
        }
    }
    return ret;
}

//开始计时
- (void)startTimer{
    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopScan:) userInfo:@"timer" repeats:NO];
}

//停止扫描设备
- (void)stopScan:(id)obj{
    [_scanTimer invalidate];
    _scanTimer = nil;
    
    [self.bluetoothManager MybleStopFindBle];
    _freshBtn.selected = YES;
    _isScaning         = NO;
    [self updateScanTitleTextWithIsStopScan:YES];
    BOOL showHud = obj;
    if( showHud ){
        if( self.bluetoothManager.shields.count==0 ){
//            [HTProgressHUD showError:@"未发现设备"];
            [self showAlertViewWithTitle:nil msg:NSLocalizedString(@"DeviceConnectNotFindDeviceText", nil) okBlock:^{

            } cancleBlock:nil];
        }
    }
}

- (void)startConnectTimer{
    _connectTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(stopConnect:) userInfo:@"timer" repeats:NO];
}

//停止连接蓝牙设备
- (void)stopConnect:(id)obj{
    [_connectTimer invalidate];
    _connectTimer = nil;

    BOOL showHud = obj;
    if( showHud ){

        NSString *msg = NSLocalizedString(@"DeviceConnectFailPleaseFresh", nil); //@"连接设备失败,请刷新设备列表"
        [self showAlertViewWithTitle:nil msg:msg okBlock:^{
            [self stopScan:nil];
            [self handleFreshBtn:self.freshBtn];
        } cancleBlock:nil];
    }
}

- (void)updateScanTitleTextWithIsStopScan:(BOOL)isStop{
    if( isStop ){
        _scanTitleL.text = NSLocalizedString(@"DeviceConnectDetectedDeviceText", nil);//@"检测到的设备";
    }else{
        _scanTitleL.text = NSLocalizedString(@"DeviceConnectDetectingDeviceText", nil);//@"检测设备中...";
    }
}

- (void)updateFreshBtnSelectedWithIsStopScan:(BOOL)isStop{
    self.freshBtn.selected = !isStop;
}

- (BOOL)isScanning{
//    return self.bluetoothManager.cbManager.isScanning;
    return _isScaning;
}

- (void)reloadDeviceDatas{
    [self.datas removeAllObjects];
    [self.noConnectDatas removeAllObjects];
    for(CBPeripheral *per in self.bluetoothManager.shields ){
        if( per.state == CBPeripheralStateConnected ){
            [self.datas addObject:per];
        [[NSUserDefaults standardUserDefaults] setObject:per.name forKey:@"blename"];
        }else{
            [self.noConnectDatas addObject:per];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"blename"];
        }
    }
    
    CBPeripheral *connectedPeri = self.bluetoothManager.connectedShield;
    if(connectedPeri && [_datas containsObject:connectedPeri]==NO && connectedPeri.state == CBPeripheralStateConnected ){
        [_datas addObject:connectedPeri];
    }
    
    [self dispatchAsyncMainQueueWithBlock:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - TouchEvents
- (void)handleFreshBtn:(UIButton*)btn{
//    [self handleGotoCamera];
//    return;
    
    //选中，即是刷新
    if( [self isScanning] ==NO ){
        
        //刷新时，清除未连接的设备
        if( self.noConnectDatas.count ){
            [self.bluetoothManager.shields removeObjectsInArray:self.noConnectDatas];
        }
        [self reloadDeviceDatas];
        
        [self updateScanTitleTextWithIsStopScan:NO];
        [self searchBluetoothDevice];
    }else{
        [self stopScan:nil];
    }
}

- (void)handleGotoCamera{
    
    [TSHelper showSelectShootModeAlertWithSelectBlock:^(NSInteger idx) {
        if( idx == 1 ){
            //连接中 直接去拍照
            TSTakePhotoCtrl *pc = [TSHelper shareTakePhotoCtrl];//[TSTakePhotoCtrl new];
            pc.hidesBottomBarWhenPushed = YES;
            [pc resetDatas];
            [self pushViewCtrl:pc];
        }else if( idx == 0 ){
            TSShootVideoCtrl *vc = [TSShootVideoCtrl new];
            vc.hidesBottomBarWhenPushed = YES;
            [self pushViewCtrl:vc];
        }
    }];
    
//    TSShootVideoCtrl *vc = [TSShootVideoCtrl new];
//    vc.hidesBottomBarWhenPushed = YES;
//    [self pushViewCtrl:vc];
//
//    return;
//
//
//    TSTakePhotoCtrl *pc = [TSHelper shareTakePhotoCtrl];//[TSTakePhotoCtrl new];
//    [pc resetDatas];
//    [self pushViewCtrl:pc];
}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if( section == 0 ){
        return _datas.count;
    }
    
    if( section == 1 ){
        return _noConnectDatas.count;
    }
    
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseId = @"personCenterCellReuseID";
    TSDeviceConnectCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if( !cell ){
        cell = [[TSDeviceConnectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    NSUInteger idx = indexPath.row;
    NSArray *arr = _datas;
    if( indexPath.section == 1 ){
        arr = _noConnectDatas;
    }
    cell.model = (CBPeripheral*)[self modelAtIndex:idx datas:arr modelClass:[CBPeripheral class]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if( section == 0 ){
        //当没有已连接的设备时，不显示该header
        if( self.datas.count ==0 ){
            return 0;
        }
    }
    
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    CGFloat ih = [self tableView:tableView heightForHeaderInSection:section];
    UIView *view =  [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake(0, 0, tableView.width, ih);
    
    UILabel *lbl = [UILabel new];
    lbl.textColor = [UIColor colorWithRgb51];
    lbl.font = [UIFont systemFontOfSize:15];
    lbl.frame = CGRectMake(15, 0, 200, ih);
    [view addSubview:lbl];
    
    if( section == 0 ){
        lbl.text = NSLocalizedString(@"DeviceConnectedDeviceText", nil);
    }else {
        _scanTitleL = lbl;
        
        BOOL isStop = ![self isScanning];
        
        [self updateScanTitleTextWithIsStopScan:isStop];
        
        UIButton *btn = _freshBtn;
        if( _freshBtn == nil ){
            btn = [UIButton new];
            _freshBtn = btn;
            [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            [btn addTarget:self action:@selector(handleFreshBtn:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:NSLocalizedString(@"DeviceConnectStopRefreshDeviceListTitle", nil) forState:UIControlStateNormal];
            [btn setTitle:NSLocalizedString(@"DeviceConnectRefreshDeviceListTitle", nil) forState:UIControlStateSelected];
            CGFloat iw = 60;
            btn.frame = CGRectMake(view.width-iw, 0, iw, ih);
        }
        
        btn.selected = isStop;
        [btn removeFromSuperview];
        [view addSubview:btn];
    }
    
    UIView *line = [UIView new];
    line.frame = CGRectMake(0, ih-0.5, view.width, 0.5);
    line.backgroundColor =[UIColor colorWithRgb221];
    [view addSubview:line];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.bluetoothManager connectedShield].state == CBPeripheralStateConnected) {
        [self.bluetoothManager MybleDisConnectBleAll];
    }
    if (self.noConnectDatas && self.noConnectDatas.count > indexPath.row) {
        CBPeripheral *per = [self.noConnectDatas objectAtIndex:indexPath.row];
        [self.bluetoothManager connectingBleWithShield:per];
        [self startConnectTimer];
        
        //链接时停止扫描
        [self stopScan:nil];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - BluetoothDelegate
//如果发现设备调用 设备的数量
-(void)MyBleDelegateDiscover : (int) bleNum
{
    [self.noConnectDatas removeAllObjects];

    if (![self.noConnectDatas containsObject:self.bluetoothManager.shields]) {
        [self.noConnectDatas addObjectsFromArray:self.bluetoothManager.shields];
    }

    [self.tableView reloadData];
}
//更新当前的连接状态
- (void)MyBleDelegateSetConnectBool:(BOOL)thisBool err:(NSError*)err{
    
//    if( err ){
//        if( thisBool == YES )
//            [HTProgressHUD showError:@"蓝牙连接失败"];
//        return;
//    }
    
    [self stopConnect:nil];
    [self getButtonAtRightBarItem].enabled = thisBool;
    if (thisBool == YES) {
        NSLog(@"已连接蓝牙设备%s",__FUNCTION__);
        if( _needGotoCamera ){
            [self handleGotoCamera];
        }
    }else{
        NSLog(@"已关闭蓝牙设备%s",__FUNCTION__);
        //[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"blename"];
        [HTProgressHUD showSuccess:NSLocalizedString(@"BluetoothStateDisconnect", nil)];//@"蓝牙设备断开"Bluetooth device disconnect
    }
    
    [self reloadDeviceDatas];
}
//
-(void)MyBleDelegateDisConnectBle : (NSData *) readData
{
    //   NSLog(@"View Read leng = %ld ** %@",(unsigned long)readData.length,readData);
}

#pragma mark - Property

- (UITableView *)tableView{
    if( !_tableView) {
        _tableView = [[HTTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        CGFloat iy = NAVGATION_VIEW_HEIGHT;
        _tableView.frame = CGRectMake(0, iy, SCREEN_WIDTH, self.noteL.y-iy-10);
        
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

- (UILabel *)noteL {
    if( !_noteL ){
        _noteL = [[UILabel alloc] init];
        _noteL.textAlignment = NSTextAlignmentCenter;
        _noteL.font = [UIFont systemFontOfSize:15];
        _noteL.textColor = [UIColor colorWithRgb51];
        
        CGFloat ih = 20;
        _noteL.frame = CGRectMake(0, SCREEN_HEIGHT-ih-BOTTOM_NOT_SAVE_HEIGHT-10, SCREEN_WIDTH, ih);

        [self.view addSubview:_noteL];
    }
    return _noteL;
}

- (MyBleClass *)bluetoothManager {
    if( !_bluetoothManager ){
        _bluetoothManager = [MyPublic shareMyBleClass];
        _bluetoothManager.delegate = self;
    }
    return _bluetoothManager;
}

- (NSMutableArray *)datas {
    if( !_datas ){
        _datas = [[NSMutableArray alloc] init];
    }
    return _datas;
}

- (NSMutableArray *)noConnectDatas {
    if( !_noConnectDatas ){
        _noConnectDatas = [[NSMutableArray alloc] init];
    }
    return _noConnectDatas;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
