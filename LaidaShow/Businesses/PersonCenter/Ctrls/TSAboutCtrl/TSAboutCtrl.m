//
//  TSAboutCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 11/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSAboutCtrl.h"
#import "UIView+LayoutMethods.h"
#import "UIViewController+Ext.h"
#import "UIColor+Ext.h"
#import "TSAboutSVCtrl.h"

@interface TSAboutCtrl ()
@property (nonatomic, strong) UIImageView *logoImgV;
@property (nonatomic, strong) UILabel     *versionL;
@property (nonatomic, strong) UIButton    *companyPageUrlBtn;
@property (nonatomic, strong) UILabel    *copyrightL;
@end

@implementation TSAboutCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelfData];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"AboutUsPageTitle", nil);//@"关于我们";
    
    self.logoImgV.image = [UIImage imageNamed:@"pc_login_logo"];
    self.copyrightL.text = @"2016©️ALL Rights Reserved";
    [self.companyPageUrlBtn setTitle:@"show.schengroup.com" forState:UIControlStateNormal];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *appName = NSLocalizedString(@"LaiDaShow", nil) ;//[infoDictionary objectForKey:@"CFBundleDisplayName"];@"三围秀"
    NSString *Version = NSLocalizedString(@"Version", nil);
    self.versionL.text = [NSString stringWithFormat:@"%@    %@%@",appName,app_Version,Version];//版本
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGFloat wh = 60;
    self.logoImgV.frame = CGRectMake((SCREEN_WIDTH-wh)/2, NAVGATION_VIEW_HEIGHT+50, wh, wh+30);
    self.versionL.frame = CGRectMake(0, _logoImgV.bottom+10, SCREEN_WIDTH, 22);
    
    CGFloat ih = 18,toBottom = 10+BOTTOM_NOT_SAVE_HEIGHT;
    self.copyrightL.frame = CGRectMake(0, SCREEN_HEIGHT-ih-toBottom, SCREEN_WIDTH, ih);
    CGFloat iw = 200;ih = 25;
    self.companyPageUrlBtn.frame = CGRectMake((SCREEN_WIDTH-iw)/2, _copyrightL.y-ih, iw, ih);
}

#pragma mark - TouchEvents
- (void)handlePageUrlBtn{
    
    NSString *url = [NSString stringWithFormat:@"http://%@",self.companyPageUrlBtn.titleLabel.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    //[self.navigationController pushViewController:[[TSAboutCtrl alloc]init] animated:YES];
}

#pragma mark - Propertys

- (UIImageView *)logoImgV {
    if( !_logoImgV ){
        _logoImgV = [[UIImageView alloc] init];
        _logoImgV.image = [UIImage imageNamed:@""];
        [_logoImgV cornerRadius:3];
//        _logoImgV.backgroundColor = [UIColor colorWithRgb85];
        _logoImgV.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_logoImgV];
    }
    return _logoImgV;
}

- (UILabel *)versionL {
    if( !_versionL ){
        _versionL = [[UILabel alloc] init];
        _versionL.font = [UIFont systemFontOfSize:15];
        _versionL.textColor = [UIColor colorWithRgb51];
        _versionL.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:_versionL];
    }
    return _versionL;
}

- (UIButton *)companyPageUrlBtn {
    if( !_companyPageUrlBtn ){
        _companyPageUrlBtn = [[UIButton alloc] init];
        [_companyPageUrlBtn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateNormal];
        _companyPageUrlBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_companyPageUrlBtn addTarget:self action:@selector(handlePageUrlBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_companyPageUrlBtn];
    }
    return _companyPageUrlBtn;
}

- (UILabel *)copyrightL {
    if( !_copyrightL ){
        _copyrightL = [[UILabel alloc] init];
        _copyrightL.textColor = [UIColor colorWithRgb102];
        _copyrightL.font = [UIFont systemFontOfSize:12];
        _copyrightL.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:_copyrightL];
    }
    return _copyrightL;
}

@end
