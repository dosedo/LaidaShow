//
//  TSAboutSVCtrl.m
//  ThreeShow
//
//  Created by DeepAI on 2018/11/15.
//  Copyright © 2018年 deepai. All rights reserved.
//

#import "TSAboutSVCtrl.h"
#import "TSAboutCtrl.h"
#import "CYPrivacyViewController.h"
#import "CYTableViewItem.h"
#import "TSWebPageCtrl.h"
#import "UIViewController+Ext.h"
#import "TSLanguageModel.h"

@interface TSAboutSVCtrl ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UITableViewCell *cell;
@property (nonatomic,strong) NSMutableArray *items;
@end


#define SettingCellID @"SettingCellID"
@implementation TSAboutSVCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelfData];
    self.view.backgroundColor = [UIColor colorWithWhite:240 / 255.0 alpha:1];
    [self setupNav];
    [self setupUI];
}

- (void)setupNav {
    self.navigationItem.title =NSLocalizedString(@"PersonAboutProduct", nil);// 关于产品
}

- (void)setupUI {
    
    //tableView
    CGFloat tableViewX = 0;
    CGFloat tableViewY = 0;
    CGFloat tableViewW = self.view.frame.size.width;
    CGFloat tableViewH = self.view.frame.size.height - 44;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(tableViewX, tableViewY, tableViewW, tableViewH) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];

}

#pragma mark - getters
- (NSMutableArray *)items {
    if (_items == nil) {
        _items = [NSMutableArray array];
    
        [_items addObject:[[CYTableViewItem alloc]initWithImage:nil text:NSLocalizedString(@"AboutUsPageTitle", nil) detailText:nil desVC:[TSAboutCtrl class] accessoryType:UITableViewCellAccessoryDisclosureIndicator]];
        [_items addObject:[[CYTableViewItem alloc]initWithImage:nil text:NSLocalizedString(@"PersonPrivacyPolicy", nil) detailText:nil desVC:[TSAboutCtrl class] accessoryType:UITableViewCellAccessoryDisclosureIndicator]];

    }
    return _items;
}

#pragma mark - 这两个方法是让原装的cell的分割线左边距为0

- (void)viewDidLayoutSubviews {
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}


#pragma mark - tableViewdataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SettingCellID];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    }
    
    CYTableViewItem *item = self.items[indexPath.row];
    cell.accessoryType = item.accessoryType;
    cell.imageView.image = item.image;
    cell.textLabel.text = item.text;
    cell.detailTextLabel.text = item.detailText;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CYTableViewItem *item = self.items[indexPath.row];
    return item.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"abbout-----");
    
    if (indexPath.row == 0) {//
        TSAboutCtrl *ac = [[TSAboutCtrl alloc] init];
        [self.navigationController pushViewController:ac animated:YES];
    }
    if (indexPath.row == 1) {//
//        CYPrivacyViewController *ac = [[CYPrivacyViewController alloc] init];
//        [self.navigationController pushViewController:ac animated:YES];
        
        TSWebPageCtrl *pc = [TSWebPageCtrl new];
        pc.title = NSLocalizedString(@"PrivacyPolicy", nil);//@"三围秀隐私政策";
//        pc.fileName = @"privacy";
        if( [[TSLanguageModel currLanguageModel].languageCode isEqualToString:@"en"] ){
            pc.fileName = @"privacyEN";
        }else{
            pc.fileName = @"privacyCN";
        }
        [self.navigationController pushViewController:pc animated:YES];
    }
    
}


@end
