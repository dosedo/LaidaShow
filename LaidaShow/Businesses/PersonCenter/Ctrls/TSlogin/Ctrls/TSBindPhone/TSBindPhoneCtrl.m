//
//  TSBindPhoneCtrl.m
//  LaidaShow
//
//  Created by Met on 2020/8/10.
//  Copyright © 2020 deepai. All rights reserved.
//

#import "TSBindPhoneCtrl.h"
#import "UIViewController+Ext.h"
#import "HTProgressHUD.h"
#import "TSConstants.h"
#import "KValidate.h"
#import "KError.h"
#import "KTimer.h"
#import "TSLoginTextField.h"
#import "TSDataBase.h"
#import "TSHelper.h"

@interface TSBindPhoneCtrl ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *phoneTf;
@property (nonatomic, strong) UITextField *codeTf;
@property (nonatomic, strong) UIButton *codeBtn;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) KTimer *timer;
@end

@implementation TSBindPhoneCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"绑定手机号", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    [self addLeftBarItemWithAction:@selector(handleBack) imgName:@"pc_close"];
    [self addTextFieldTextChangeNotification];
    
    [self initViews];
    
    [self addHideKeyboardGestureToView];
}

#pragma mark - Private
- (void)initViews{
 
    CGFloat iLeft = 35;
    self.phoneTf.frame = CGRectMake(iLeft, NAVGATION_VIEW_HEIGHT+30, SCREEN_WIDTH-2*iLeft, 35);
    
    self.codeTf.frame = CGRectMake(iLeft, _phoneTf.bottom+20, _phoneTf.width, _phoneTf.height);
    
    self.loginBtn.frame = CGRectMake(_codeTf.x, _codeTf.bottom+40, _codeTf.width, 44);
}

- (void)loginSuccess{
    
    [HTProgressHUD showSuccess:NSLocalizedString(@"绑定成功", nil)];//@"登录成功"];
    
    BOOL fromGuide = self.tabBarController ==nil;
    if( fromGuide ){
        UIViewController *rootVc = [TSHelper rootCtrl];
//        [self presentViewController:rootVc animated:NO completion:nil];
        [UIApplication sharedApplication].keyWindow.rootViewController = rootVc;
        [TSHelper sharedHelper].guideRootCtrl = nil;
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
        //发送登录成功的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationLoginSuccess object:nil];
    }
}

#pragma mark - Notification

- (void)addTextFieldTextChangeNotification{

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChangeOneCI:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:self.phoneTf];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChangeOneCI:)
      name:UITextFieldTextDidChangeNotification
    object:self.codeTf];
}

- (void)removeTextFieldNotifacion{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.phoneTf];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.codeTf];
}

-(void)textFieldTextDidChangeOneCI:(NSNotification *)notification
{
    //绑定手机号
    if( _phoneTf.text.length == TSConstantPhoneNumLen && self.codeTf.text.length == 6 ){
        self.loginBtn.enabled = YES;
    }else{
        self.loginBtn.enabled = NO;
    }
}

#pragma mark - TouchEvents

- (void)handleClearPhoneBtn:(UIButton*)btn{
    self.phoneTf.text = @"";
}

- (void)handleBack{
    //不绑定手机号，清空登录信息
    [[TSDataBase sharedDataBase] removeUserModel];
    
//    //因为绑定后
//    id vc = self.navigationController.viewControllers[0];
//    if( [vc isKindOfClass:NSClassFromString(@"TSPersonCenterCtrl")] ){
//        if( [vc respondsToSelector:NSSelectorFromString(@"logoutSuccess")] ){
//            [vc performSelector:NSSelectorFromString(@"logoutSuccess")];
//        }
//    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleCodeBtn:(UIButton*)btn{
    NSInteger errCode = KErrorCodeDefault;
    //先检验手机号码
    BOOL ret = [KValidate validatePhoneNum:self.phoneTf.text errCode:&errCode];
    
    if( ret==NO ){
        [HTProgressHUD showSuccess:NSLocalizedString(@"请输入正确的手机号", nil)];
        return;
    }

    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    //获取绑定验证码
    [self.dataProcess verifyCodeWithPhone:_phoneTf.text type:@"0" deviceType:3 completeBlock:^(NSDictionary *rusult, NSError *err) {
        [_hud hide];
        if (err) {
            [self showErrMsgWithError:err];
        }else{
            
            [self.timer startTimer];
            [HTProgressHUD showSuccess:NSLocalizedString(@"RegisterSendCodeSuccess", nil)];
        }
    }];
}

//绑定手机号
- (void)handleLogin{
    NSInteger errCode = KErrorCodeDefault;
    BOOL validte = [KValidate validatePhoneNum:self.phoneTf.text errCode:&errCode];
    if(validte==NO){
        NSString *msg =NSLocalizedString(@"LoginWrongDes", nil);
        [self showErrMsg:msg];
        return;
    }
    
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.dataProcess bindUserWithPhone:self.phoneTf.text code:self.codeTf.text completeBlock:^(NSError *err) {
            [self dispatchAsyncMainQueueWithBlock:^{
                [self.hud hide];
                if( err ){
                    [self showErrMsgWithError:err];
                }else{
                    [self loginSuccess];
                }
            }];
        }];
    });
}

#pragma mark - UITextFieldDelgate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    {
        if([string isEqualToString:@""]) return YES;
        
        if( [textField isEqual:_phoneTf] ){
            if( textField.text.length >= TSConstantPhoneNumLen ){
                return NO;
            }
        }else if( [textField isEqual:_codeTf] ){
            if( _codeTf.text.length >= 6 ){
                return NO;
            }
        }
    
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - SetupUI
- (UITextField *)phoneTf {
    if( !_phoneTf ){
        _phoneTf = [[TSLoginTextField alloc] init];
        _phoneTf.textColor = [UIColor colorWithRgb51];
        _phoneTf.placeholder = NSLocalizedString(@"LoginPhoneHolder", nil);
        _phoneTf.font = [UIFont systemFontOfSize:15];
        _phoneTf.returnKeyType = UIReturnKeyDone;
        _phoneTf.delegate = self;
        _phoneTf.keyboardType = UIKeyboardTypeDefault;
        _phoneTf.rightViewMode = UITextFieldViewModeWhileEditing;
        [self.view addSubview:_phoneTf];
        
        UIButton *seeBtn = [UIButton new];
        seeBtn.frame = CGRectMake(0, 0, 30, 40);
        [seeBtn setImage:[UIImage imageNamed:@"pc_clear_text"] forState:UIControlStateNormal];
        [seeBtn addTarget:self action:@selector(handleClearPhoneBtn:) forControlEvents:UIControlEventTouchUpInside];
        _phoneTf.rightView = seeBtn;
        
        [self addDoneBtnWithView:(UITextView*)_phoneTf];
    }
    return _phoneTf;
}

- (UITextField *)codeTf {
    if( !_codeTf ){
        _codeTf = [[TSLoginTextField alloc] init];
        _codeTf.textColor = self.phoneTf.textColor;
        _codeTf.placeholder = NSLocalizedString(@"RegisterVerfiCodeHolder", nil);
        _codeTf.font = _phoneTf.font;
        _codeTf.rightViewMode = UITextFieldViewModeAlways;
        _codeTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        _codeTf.returnKeyType = UIReturnKeyDone;
        _codeTf.keyboardType = UIKeyboardTypeNumberPad;
        _codeTf.delegate = self;
        _codeTf.rightViewMode = UITextFieldViewModeAlways;
//        _codeTf.rightView = self.codeBtn;
//        _codeTf.hidden = YES;
        //为了适配ios13
        UIView *rv = [UIView new];
        rv.frame = self.codeBtn.frame;
        [rv addSubview:self.codeBtn];
        _codeTf.rightView = rv;
     
        [self.view addSubview:_codeTf];
        
        [self addDoneBtnWithView:(UITextView*)_codeTf];
    }
    return _codeTf;
}

- (UIButton *)codeBtn {
    if( !_codeBtn ){
        _codeBtn = [[UIButton alloc] init];

        [_codeBtn setTitle:NSLocalizedString(@"RegisterSendCodeTitle", nil) forState:UIControlStateNormal];
        _codeBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:13.0];
        _codeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_codeBtn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateDisabled];
        UIImage *bgImg = [UIColor.colorWithRgb_0_151_216 imageWithSize:CGSizeMake(10, 10)];
        [_codeBtn setBackgroundImage:bgImg forState:UIControlStateNormal];
        UIImage *dBgImg = [[UIColor colorWithWhite:230/255.0 alpha:1] imageWithSize:CGSizeMake(10,10)];
        [_codeBtn setBackgroundImage:dBgImg forState:UIControlStateDisabled];
        [_codeBtn addTarget:self action:@selector(handleCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
        _codeBtn.frame = CGRectMake(0, 0, 115, 30);
        
        [_codeBtn cornerRadius:_codeBtn.height/2];
    }
    return _codeBtn;
}

- (UIButton *)loginBtn {
    if( !_loginBtn ){
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue"] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue_hi"] forState:UIControlStateHighlighted];
        
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        [_loginBtn setTitle:NSLocalizedString(@"ClearBgSelectDeviceBtnTitleSure", nil) forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_loginBtn addTarget:self action:@selector(handleLogin) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn cornerRadius:5];
        _loginBtn.enabled = NO;
        [self.view addSubview:_loginBtn];
    }
    return _loginBtn;
}

- (KTimer *)timer{
    if( !_timer ){
        _timer = [[KTimer alloc] initWithButton:self.codeBtn];
    }
    return _timer;
}

@end
