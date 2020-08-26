//
//  TSSelectDeviceCtrl.m
//  ThreeShow
//
//  Created by wkun on 2019/2/24.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSSelectDeviceCtrl.h"
#import "UIView+LayoutMethods.h"
#import "UIViewController+Ext.h"
#import "UIColor+Ext.h"

@interface TSSelectDeviceCtrl ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *datas;
@end

@implementation TSSelectDeviceCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelfData];
    
    self.navigationItem.title = NSLocalizedString(@"PersonDeviceSelect", nil);
    
    [self loadDatas];
}

- (void)loadDatas{
    _datas = self.dataProcess.deviceListDatas;
    [self.tableView reloadData];
}

#pragma mark delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseId = @"hangyeCelRuese";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    UIImageView *arrowView = nil;
    if( cell ==nil ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorWithRgb102];
        
        UIImageView *arrowV = [UIImageView new];
        arrowV.image = [UIImage imageNamed:@"product_choose"];
        CGSize size = CGSizeMake(35/2.0, 12.0);
        CGFloat cellH = 50;
        arrowV.frame = CGRectMake(SCREEN_WIDTH-size.width-15, (cellH-size.height)/2, size.width, size.height);
        arrowV.tag = 123123;
        [cell.contentView addSubview:arrowV];
        
        arrowView = arrowV;
    }else{
        arrowView = (UIImageView*)[cell.contentView viewWithTag:123123];
    }
    
    if( indexPath.row < self.datas.count ){
        NSString *str = _datas[indexPath.row];
        cell.textLabel.text = str;
    }
    
    NSInteger selectIndex = [self.dataProcess selectedDeviceIndex];
    arrowView.hidden = !(selectIndex == indexPath.row);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.dataProcess updateSelectDeviceAtIndex:indexPath.row];
    [self.tableView reloadData];
    if( self.handleSelectBlock ){
        if( indexPath.row < self.datas.count ){
//            NSString *str = _datas[indexPath.row];
            [self.navigationController popViewControllerAnimated:YES];
            
            self.handleSelectBlock(indexPath.row);
        }
    }
}

- (UITableView *)tableView {
    if( !_tableView ){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        //        [self configheaderRefreshTableView:_tableView freshSel:@selector(loadData:)];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        CGFloat iy = NAVGATION_VIEW_HEIGHT;
        _tableView.frame = CGRectMake(0, iy, SCREEN_WIDTH,SCREEN_HEIGHT-iy);
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end

