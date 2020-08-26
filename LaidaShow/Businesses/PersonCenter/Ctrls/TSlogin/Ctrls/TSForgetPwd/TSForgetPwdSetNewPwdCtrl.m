//
//  TSForgetPwdSetNewPwdCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 05/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSForgetPwdSetNewPwdCtrl.h"
#import "UIViewController+Ext.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSLoginTextField.h"
#import "TSConstants.h"
#import "KValidate.h"
#import "KError.h"
#import "KTimer.h"
#import "HTProgressHUD.h"
#import "NSString+Ext.h"
#import "TSLoginCtrl.h"

@interface TSForgetPwdSetNewPwdCtrl ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView       *bgView;
@property (nonatomic, strong) UITextField  *confirmPwdTf;
@property (nonatomic, strong) UITextField  *pwdTf;
@property (nonatomic, strong) UITextField  *codeTf;
@property (nonatomic, strong) UIButton     *codeBtn;
@property (nonatomic, strong) UIButton     *nextBtn;
@property (nonatomic, strong) KTimer       *timer;
@property (nonatomic, strong) HTProgressHUD *hud;
@end

@implementation TSForgetPwdSetNewPwdCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addLeftBarItemWithAction:@selector(handleBack) imgName:@"pc_close"];
    self.navigationItem.title = NSLocalizedString(@"ForgetPwdPageTitle", nil);
    [self addTextFieldTextChangeNotification];
    
    [self.codeTf becomeFirstResponder];
    
    //一进来主动获取一次验证码
    [self handleCodeBtn:self.codeBtn];
}

- (void)dealloc{
    [self removeTextFieldNotifacion];
}

#pragma mark - Private
- (void)sendVericodeWithPhone:(NSString*)phone{
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess verifyCodeWithPhone:phone type:@"1" deviceType:3 completeBlock:^(NSDictionary*rusult,NSError *err) {
        [self.hud hide];
        if( err ){
            [self showErrMsgWithError:err];
//            [self.timer endTimer];
            //            self.codeBtn.selected = NO;
        }else{
            [HTProgressHUD showSuccess:NSLocalizedString(@"RegisterSendCodeSuccess", nil)];//@"验证码已发送，请注意查收"];
            [self.timer startTimer];
        }
    }];
}

//- (void)validateCode{
//    _hud = [HTProgressHUD showMessage:nil toView:self.view];
//    [self.dataProcess validateCodeWithPhone:_phone code:_codeTf.text completeBlock:^(NSError *err) {
//        [self dispatchAsyncMainQueueWithBlock:^{
//            
//            if( err ){
//                [_hud hide];
//                NSString *errCodeStr =NSLocalizedString(@"ForgetValidateCode", nil);//验证码无效
//                NSString *msg = [NSString stringWithFormat:@"%@",errCodeStr];
//                //[self showErrMsgWithError:err];
//                [self showErrMsg:msg];
//            }else{
//                [self resetPwd];
//            }
//        }];
//    }];
//
//}

- (void)resetPwd{
//    NSString *un = [self randGenerateUserName];
    NSString *pwd = [_pwdTf.text md5];
    [self.dataProcess resetPwdWithPhone:self.phone code:_codeTf.text pwd:pwd completeBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                [HTProgressHUD showSuccess:NSLocalizedString(@"重置密码成功", nil)];

                [self handleGotoLogin];
            }
        }];
    }];
}


#pragma mark - Layout

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self doLayout];
}

- (void)doLayout{
    CGFloat ix = 35,ih = 295;
    CGFloat iw = SCREEN_WIDTH-2*ix;
    CGFloat iy = NAVGATION_VIEW_HEIGHT-64+100;
    self.bgView.frame = CGRectMake(ix, iy, iw, ih);
    
    self.codeTf.frame = CGRectMake(0, 0, _bgView.width, 45);
    CGFloat yGap = 25;
    self.pwdTf .frame = CGRectMake(0, _codeTf.bottom+yGap, _codeTf.width, _codeTf.height);
    self.confirmPwdTf  .frame = CGRectMake(0, _pwdTf.bottom+yGap, _pwdTf.width, _pwdTf.height);
    
    self.nextBtn.frame = CGRectMake(0, _confirmPwdTf.bottom+65, _confirmPwdTf.width, 40);

}

#pragma mark - Notification


- (void)addTextFieldTextChangeNotification{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChangeOneCI:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:self.confirmPwdTf];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChangeOneCI:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:self.pwdTf];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChangeOneCI:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:self.codeTf];
}

- (void)removeTextFieldNotifacion{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.confirmPwdTf];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.pwdTf];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.codeTf];
}


-(void)textFieldTextDidChangeOneCI:(NSNotification *)notification
{
    UITextField *textfield=[notification object];
    if( [textfield isEqual:self.confirmPwdTf] || [textfield isEqual:self.pwdTf] || [textfield isEqual:self.codeTf]){
        if( _confirmPwdTf.text.length && _pwdTf.text.length && _codeTf.text.length == TSConstantVerificationCodeLen){
            self.nextBtn.enabled = YES;
        }else{
            self.nextBtn.enabled = NO;
        }
    }
}

#pragma mark - TouchEvents

- (void)handleClearConfirmPwdBtn:(UIButton*)btn{
    self.confirmPwdTf.text = @"";
}

- (void)handleClearPwdBtn:(UIButton*)btn{

    self.pwdTf.text = @"";
}

//- (void)handleUserPotocol{
//
//}

- (void)handleGotoLogin{
    
    UIViewController *ctrl =
    [self getCtrlAtNavigationCtrlsWithCtrlClass:[TSLoginCtrl class]];
    if( ctrl ){
        [self.navigationController popToViewController:ctrl animated:YES];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)handleNextBtn{
//    NSInteger errCode = KErrorCodeDefault;
//    BOOL validte = [KValidate validatePhoneNum:self.confirmPwdTf.text errCode:&errCode];
//    if( validte==NO ){
//        NSString *msg = [KError errorMsgWithCode:errCode];
//        [self showErrMsg:msg];
//        return;
//    }
//    [self resetPwd];
    
    if(self.codeTf.text.length ==0 ){
        [self showErrMsg:@"请输入验证码"];
        return;
    }
    
    if(self.codeTf.text.length != TSConstantVerificationCodeLen ){
        [self showErrMsg:@"请输入正确的验证码"];
        return;
    }
    
    if(self.pwdTf.text.length ==0 ){
        [self showErrMsg:@"请输入密码"];
        return;
    }
    
    if(self.confirmPwdTf.text.length ==0 ){
        [self showErrMsg:@"请输入确认密码"];
        return;
    }
    
    NSInteger len = self.pwdTf.text.length;
    if( ( ![self.confirmPwdTf.text isEqualToString:self.pwdTf.text] )){
        NSString *errCodeStr = NSLocalizedString(@"ForgetPwdDifferent", nil);//@"两次输入密码不一致"
        NSString *msg = [NSString stringWithFormat:@"%@",errCodeStr];
        [self showErrMsg:msg];
        //[self showErrMsg:@"两次输入密码不一致"];
        return;
    }
    
    if( len < TSConstantAccountPwdMinLen || len > TSConstantAccountPwdMaxLen ){
        NSString *prefix = NSLocalizedString(@"RegisterPwdLenPrefixDes", nil);
        NSString *tail = NSLocalizedString(@"RegisterPwdLenTailDes", nil);
        NSString *msg = [NSString stringWithFormat:@"%@%ld~%ld%@",prefix,TSConstantAccountPwdMinLen,TSConstantAccountPwdMaxLen,tail];
        [self showErrMsg:msg];
        return;
    }
    
    //[self validateCode];
    [self resetPwd];
}

- (void)handleBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleCodeBtn:(UIButton*)btn{
//    NSInteger errCode = KErrorCodeDefault;
//    BOOL validte = [KValidate validatePhoneNum:_phone errCode:&errCode]&&[KValidate validateEmail:_phone errCode:&errCode];
//    if( validte==NO ){
//        NSString *msg = [KError errorMsgWithCode:errCode];
//        [self showErrMsg:msg];
//        return;
//    }
    
    [self sendVericodeWithPhone:_phone];
//    [self.timer startTimer];
}

#pragma mark - UITextFieldDelgate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    {
        
        if( [textField isEqual:self.codeTf] ){
            if (textField.text.length== TSConstantVerificationCodeLen && ![string isEqualToString:@""]) {
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

#pragma mark - Propertys

- (UIView *)bgView {
    if( !_bgView ){
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:_bgView];
    }
    return _bgView;
}

- (UITextField *)confirmPwdTf {
    if( !_confirmPwdTf ){
        _confirmPwdTf = [[TSLoginTextField alloc] init];
        _confirmPwdTf.textColor = [UIColor colorWithRgb51];
        _confirmPwdTf.placeholder = NSLocalizedString(@"ForgetConfirmPwdHolder", nil);
        _confirmPwdTf.font = [UIFont systemFontOfSize:15];
        _confirmPwdTf.returnKeyType = UIReturnKeyDone;
        _confirmPwdTf.delegate = self;
        _confirmPwdTf.rightViewMode = UITextFieldViewModeWhileEditing;
        _confirmPwdTf.secureTextEntry = YES;
        [self.bgView addSubview:_confirmPwdTf];
        
        UIButton *seeBtn = [UIButton new];
        seeBtn.frame = CGRectMake(0, 0, 30, 40);
        [seeBtn setImage:[UIImage imageNamed:@"pc_clear_text"] forState:UIControlStateNormal];
        [seeBtn addTarget:self action:@selector(handleClearConfirmPwdBtn:) forControlEvents:UIControlEventTouchUpInside];
        _confirmPwdTf.rightView = seeBtn;
        
        [self addDoneBtnWithView:(UITextView*)_confirmPwdTf];
    }
    return _confirmPwdTf;
}

- (UITextField *)pwdTf {
    if( !_pwdTf ){
        _pwdTf = [[TSLoginTextField alloc] init];
        _pwdTf.textColor = self.confirmPwdTf.textColor;
        _pwdTf.placeholder = NSLocalizedString(@"ForgetSetPwdHolder", nil);
        _pwdTf.font = _confirmPwdTf.font;
        _pwdTf.rightViewMode = UITextFieldViewModeWhileEditing;
        _pwdTf.returnKeyType = UIReturnKeyDone;
        _pwdTf.delegate = self;
        _pwdTf.secureTextEntry = YES;
        [self.bgView addSubview:_pwdTf];
        
        UIButton *seeBtn = [UIButton new];
        seeBtn.frame = CGRectMake(0, 0, 30, 40);
        [seeBtn setImage:[UIImage imageNamed:@"pc_clear_text"] forState:UIControlStateNormal];
        [seeBtn addTarget:self action:@selector(handleClearPwdBtn:) forControlEvents:UIControlEventTouchUpInside];
        _pwdTf.rightView = seeBtn;
        
        [self addDoneBtnWithView:(UITextView*)_pwdTf];
    }
    return _pwdTf;
}

- (UITextField *)codeTf {
    if( !_codeTf ){
        _codeTf = [[TSLoginTextField alloc] init];
        _codeTf.textColor = self.confirmPwdTf.textColor;
        _codeTf.placeholder = NSLocalizedString(@"ForgetVerfiCodeHolder", nil);
        _codeTf.font = _confirmPwdTf.font;
        _codeTf.rightViewMode = UITextFieldViewModeAlways;
        _codeTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        _codeTf.returnKeyType = UIReturnKeyDone;
        _codeTf.keyboardType = UIKeyboardTypeNumberPad;
        _codeTf.delegate = self;
        _codeTf.rightViewMode = UITextFieldViewModeAlways;
//        _codeTf.rightView = self.codeBtn;
        
        UIView *v = [UIView new];
        [v addSubview:self.codeBtn];
        v.frame = self.codeBtn.frame;
        _codeTf.rightView = v;
        
        [self.bgView addSubview:_codeTf];
    }
    return _codeTf;
}

- (UIButton *)codeBtn {
    if( !_codeBtn ){
        _codeBtn = [[UIButton alloc] init];
        
        [_codeBtn setTitle:NSLocalizedString(@"RegisterSendCodeTitle", nil) forState:UIControlStateNormal];
        _codeBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:13.0];
        [_codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_codeBtn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateDisabled];
        [_codeBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue"] forState:UIControlStateNormal];
        [_codeBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue_hi"] forState:UIControlStateHighlighted];
        [_codeBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_disable220"] forState:UIControlStateDisabled];
        [_codeBtn addTarget:self action:@selector(handleCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _codeBtn.frame = CGRectMake(0, 0, 115, 30);
        [_codeBtn cornerRadius:_codeBtn.height/2];
    }
    return _codeBtn;
}

- (KTimer *)timer{
    if( !_timer ){
        _timer = [[KTimer alloc] initWithButton:self.codeBtn];
    }
    return _timer;
}


- (UIButton *)nextBtn {
    if( !_nextBtn ){
        _nextBtn = [[UIButton alloc] init];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue"] forState:UIControlStateNormal];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue_hi"] forState:UIControlStateHighlighted];
        
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        [_nextBtn setTitle:NSLocalizedString(@"ForgetConfirmBtnTitle", nil) forState:UIControlStateNormal];
        _nextBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_nextBtn addTarget:self action:@selector(handleNextBtn) forControlEvents:UIControlEventTouchUpInside];
        [_nextBtn cornerRadius:5];
        _nextBtn.enabled = NO;
        [self.bgView addSubview:_nextBtn];
    }
    return _nextBtn;
}

@end

