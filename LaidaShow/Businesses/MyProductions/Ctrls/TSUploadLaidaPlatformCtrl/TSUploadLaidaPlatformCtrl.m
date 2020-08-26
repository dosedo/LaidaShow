//
//  TSUploadLaidaPlatformCtrl.m
//  LaidaShow
//
//  Created by Met on 2020/8/25.
//  Copyright © 2020 deepai. All rights reserved.
//

#import "TSUploadLaidaPlatformCtrl.h"
#import "UIViewController+Ext.h"
#import "KScrollView.h"
#import "TSLoginTextField.h"
#import "TSUserModel.h"

@interface TSUploadLaidaPlatformCtrl ()<UITextFieldDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextField  *phoneTf;
@property (nonatomic, strong) UITextField  *pwdTf;
@property (nonatomic, strong) UIButton     *remeberPwdBtn;
@property (nonatomic, strong) UIButton     *loginBtn;
@property (nonatomic, strong) HTProgressHUD *hud;
@end

@implementation TSUploadLaidaPlatformCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"上传莱搭平台", nil);
    [self addLeftBarItemWithAction:@selector(handleBack) imgName:@"pc_close"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addHideKeyboardGestureToView];
    
    [self initViews];
    
    [self updatePwdValueFromCache];
}

#pragma mark - Private
- (void)initViews{
                  
    CGFloat iLeft = 35;
    self.phoneTf.frame = CGRectMake(iLeft, NAVGATION_VIEW_HEIGHT+30, SCREEN_WIDTH-2*iLeft, 35);
    self.pwdTf.frame = CGRectMake(iLeft, _phoneTf.bottom+20, _phoneTf.width, _phoneTf.height);
    
    CGFloat iw = 260;
    self.remeberPwdBtn.frame = CGRectMake(_phoneTf.x, _pwdTf.bottom+10, iw, 40);
    
    self.loginBtn.frame = CGRectMake(_pwdTf.x, _remeberPwdBtn.bottom+30, _pwdTf.width, 44);

    self.scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

#pragma mark - CachePwd
- (void)cachePwd{
    
    NSString *key = [self cachedKey];
    if( key == nil ) return;
    
    NSString *un = self.phoneTf.text;
    NSString *pwd = self.pwdTf.text;
    
    NSString *gap = @"^^";
    NSString *str = [NSString stringWithFormat:@"%@%@%@",un,gap,pwd];
    
    [[NSUserDefaults standardUserDefaults] setValue:str forKey:key];
}

- (void)updatePwdValueFromCache{
    NSString *key = [self cachedKey];
    if( key == nil ) return;
    NSString *gap = @"^^";
    
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    if( [str isKindOfClass:[NSString class]] ){
        if( [str containsString:gap] ){
            NSArray *arr = [str componentsSeparatedByString:gap];
            _phoneTf.text = arr[0];
            _pwdTf.text = arr[1];
        }
    }
}

- (void)clearCached{
    NSString *key = [self cachedKey];
    if( key == nil ) return;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (NSString*)cachedKey{
    NSString *uid = self.dataProcess.userModel.userId;
    if( uid.length ==0 ) return nil;
    
    return [NSString stringWithFormat:@"TSUploadLaidaPlatformU%@KEY",uid];
}

#pragma mark - TouchEvents

- (void)handleRemeberBtn{
    self.remeberPwdBtn.selected = !self.remeberPwdBtn.isSelected;
}

- (void)handleClearPhoneBtn:(UIButton*)btn{
    self.phoneTf.text = @"";
}

- (void)handleSeeBtn:(UIButton*)btn{
    btn.selected = !btn.isSelected;
    
    self.pwdTf.secureTextEntry = !btn.isSelected;
}

- (void)handleSure{
    
    if( _phoneTf.text.length ==0 ){
        [HTProgressHUD showError:NSLocalizedString(@"请输入用户名", nil)];
        return;
    }
    
    if( _pwdTf.text.length ==0 ){
        [HTProgressHUD showError:NSLocalizedString(@"请输入密码", nil)];
        return;
    }
    
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        [self.dataProcess uploadWorkToLaidaWithWorkId:self.workId userName:_phoneTf.text pwd:_pwdTf.text completeBlock:^(NSArray *arr, NSError *err) {
            
            [self dispatchAsyncMainQueueWithBlock:^{
                [self.hud hide];
                if( err ){
                    [self showErrMsgWithError:err];
                }else{
                    
                    //打开记住密码，则缓存。否则清空
                    if( self.remeberPwdBtn.isSelected ){
                        [self cachePwd];
                    }else{
                        [self clearCached];
                    }
                    
                    [HTProgressHUD showSuccess:NSLocalizedString(@"上传成功", nil)];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }];
    });
}

- (void)handleBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if( [string isEqualToString:@""]) return YES;
    
    //无论密码还是用户名 不能多于30个字符
    if( textField.text.length >= 30 ) return NO;
    
    return  YES;
}

#pragma mark - Propertys
- (UIScrollView *)scrollView {
    if( !_scrollView ){
        _scrollView = [[KScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:_scrollView];
        
        //适配ios11
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _scrollView;
}

- (UITextField *)phoneTf {
    if( !_phoneTf ){
        _phoneTf = [[TSLoginTextField alloc] init];
        _phoneTf.textColor = [UIColor colorWithRgb51];
        _phoneTf.placeholder = NSLocalizedString(@"UserInfoUserName", nil);
        _phoneTf.font = [UIFont systemFontOfSize:15];
        _phoneTf.returnKeyType = UIReturnKeyDone;
        _phoneTf.delegate = self;
        _phoneTf.keyboardType = UIKeyboardTypeDefault;
        _phoneTf.rightViewMode = UITextFieldViewModeWhileEditing;
        [self.scrollView addSubview:_phoneTf];
        
        UIButton *seeBtn = [UIButton new];
        seeBtn.frame = CGRectMake(0, 0, 30, 40);
        [seeBtn setImage:[UIImage imageNamed:@"pc_clear_text"] forState:UIControlStateNormal];
        [seeBtn addTarget:self action:@selector(handleClearPhoneBtn:) forControlEvents:UIControlEventTouchUpInside];
        _phoneTf.rightView = seeBtn;
        
        [self addDoneBtnWithView:(UITextView*)_phoneTf];
    }
    return _phoneTf;
}

- (UITextField *)pwdTf {
    if( !_pwdTf ){
        _pwdTf = [[TSLoginTextField alloc] init];
        _pwdTf.textColor = self.phoneTf.textColor;
        _pwdTf.placeholder = NSLocalizedString(@"密码", nil);
        _pwdTf.font = _phoneTf.font;
        _pwdTf.rightViewMode = UITextFieldViewModeAlways;
        _pwdTf.returnKeyType = UIReturnKeyDone;
        _pwdTf.delegate = self;
        _pwdTf.secureTextEntry = YES;
    
        [self.scrollView addSubview:_pwdTf];
        
        UIButton *seeBtn = [UIButton new];
        seeBtn.frame = CGRectMake(0, 0, 30, 40);
        [seeBtn setImage:[UIImage imageNamed:@"pc_see_secure_pwd"] forState:UIControlStateNormal];
        [seeBtn setImage:[UIImage imageNamed:@"pc_see_secure_pwd_s"] forState:UIControlStateSelected];
        [seeBtn addTarget:self action:@selector(handleSeeBtn:) forControlEvents:UIControlEventTouchUpInside];
        _pwdTf.rightView = seeBtn;
    
        [self addDoneBtnWithView:(UITextView*)_pwdTf];
    }
    return _pwdTf;
}

- (UIButton *)remeberPwdBtn {
    if( !_remeberPwdBtn ){
        _remeberPwdBtn = [[UIButton alloc] init];
        _remeberPwdBtn.backgroundColor = [UIColor clearColor];
        [_remeberPwdBtn setTitle:NSLocalizedString(@"记住账号密码", nil) forState:UIControlStateNormal];
        [_remeberPwdBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
        _remeberPwdBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _remeberPwdBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [_remeberPwdBtn setImage:[UIImage imageNamed:@"lu_check_n"] forState:UIControlStateNormal];
        [_remeberPwdBtn setImage:[UIImage imageNamed:@"lu_check_s"] forState:UIControlStateSelected];
        [_remeberPwdBtn addTarget:self action:@selector(handleRemeberBtn) forControlEvents:UIControlEventTouchUpInside];
        _remeberPwdBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        _remeberPwdBtn.selected = YES;
        [self.scrollView addSubview:_remeberPwdBtn];
    }
    return _remeberPwdBtn;
}

- (UIButton *)loginBtn {
    if( !_loginBtn ){
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue"] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue_hi"] forState:UIControlStateHighlighted];
        
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        [_loginBtn setTitle:NSLocalizedString(@"WorkEditBottomMusicConfirmText", nil) forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_loginBtn addTarget:self action:@selector(handleSure) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn cornerRadius:5];
//        _loginBtn.enabled = NO;
        [self.scrollView addSubview:_loginBtn];
    }
    return _loginBtn;
}

@end
