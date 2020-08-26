//
//  TSRegisterCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 05/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSRegisterCtrl.h"
#import "UIViewController+Ext.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSLoginTextField.h"
#import "TSConstants.h"
#import "KValidate.h"
#import "KError.h"
#import "KTimer.h"
#import "TSWebPageCtrl.h"
#import "HTProgressHUD.h"
#import "NSString+Ext.h"
#import "MBProgressHUD.h"
#import "TSHelper.h"
#import "TSLoginCtrl.h"

@interface TSRegisterCtrl ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView       *bgView;
@property (nonatomic, strong) UITextField  *phoneTf;
@property (nonatomic, strong) UITextField  *pwdTf;
@property (nonatomic, strong) UITextField  *codeTf;
@property (nonatomic, strong) UIButton     *codeBtn;
@property (nonatomic, strong) UIButton     *registerBtn;
@property (nonatomic, strong) UILabel      *gotoLoginL;
@property (nonatomic, strong) UILabel      *userPotocolL; //用户协议
@property (nonatomic, strong) KTimer       *timer;
@property (nonatomic, strong) HTProgressHUD *hud;
@end

@implementation TSRegisterCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addLeftBarItemWithAction:@selector(handleBack) imgName:@"pc_close"];
    self.navigationItem.title = NSLocalizedString(@"RegisterBtnTitle", nil);//@"注册";
    [self addTextFieldTextChangeNotification];
    
    [self.phoneTf becomeFirstResponder];
    
    [self addHideKeyboardGestureToView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)dealloc{
    [self removeTextFieldNotifacion];
}

#pragma mark - Private
//- (void)sendVericodeWithPhone:(NSString*)phone{
//
//    [self.dataProcess verifyCodeWithPhone:phone type:@"0" deviceType:3 completeBlock:^(NSError *err) {
//        NSLog(@"err -%@",err);
//        if( err ){
//
//            [self showErrMsgWithError:err];
//            [self.timer endTimer];
////            self.codeBtn.selected = NO;
//        }else{
//            [HTProgressHUD showSuccess:NSLocalizedString(@"RegisterSendCodeSuccess", nil)];//@"验证码已发送，请注意查收"];
//        }
//    }];
//}


- (void)validateCode{
    
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess validateCodeWithPhone:_phoneTf.text code:_codeTf.text completeBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{

            if( err ){
                [_hud hide];
                NSString *msg = [NSString stringWithFormat:@"%@",NSLocalizedString(@"ValidateCode", nil)];
                //[self showErrMsgWithError:err];
                [self showErrMsg:msg];
                [HTProgressHUD showError:msg];
            }else{
                [self registerUser];
            }
        }];
    }];
}

- (void)registerUser{
    NSString *un = [self randGenerateUserName];
    NSString *pwd = [_pwdTf.text md5];
    NSInteger type = [[TSHelper sharedHelper] isEmailUserWithAccount:self.phoneTf.text]?1:0;
    [self.dataProcess registerWithPhone:_phoneTf.text code:_codeTf.text name:un pwd:pwd registerType:type completeBlock:^(NSError *err) {
        
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( err ){
                [self showErrMsgWithError:err];
//                [HTProgressHUD showSuccess:@"注册失败"];
            }else{
                [HTProgressHUD showSuccess:NSLocalizedString(@"注册成功", nil)];
                [self handleGotoLogin];
            }
        }];
    }];
}

//- (void)validatePhoneIsExist{
//    _hud = [HTProgressHUD showMessage:nil toView:self.view];
//    [self.dataProcess userIsExistWithPhone:self.phoneTf.text completeBlock:^(BOOL isExist, NSError *err) {
//
//        [self dispatchAsyncMainQueueWithBlock:^{
//            [_hud hide];
//            if( err ){
//                [self showErrMsgWithError:err];
//            }else{
//                if( isExist == NO ){//如果不存在该手机号，则·进行发送验证码的操作
//
//                    [self sendVericodeWithPhone:_phoneTf.text];
//
//                    if( self.codeTf.isFirstResponder == NO ){
//                        [self.codeTf becomeFirstResponder];
//                    }
//
//                    [self.timer startTimer];
//                }else{
//                    [HTProgressHUD showError:NSLocalizedString(@"UserRegistered", nil)];//@"用户已存在，请登录"
//                }
//            }
//        }];
//    }];
//}

- (NSString*)randGenerateUserName{
    NSInteger num = rand()%100000;
    NSInteger num2 = rand()%100000;
    NSString *prefix = @"LaiDaShow";
    return [NSString stringWithFormat:@"%@%ld%ld",prefix,num,num2];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self doLayout];
}

- (void)doLayout{
    CGFloat ix = 35,ih = 340;
    CGFloat iw = SCREEN_WIDTH-2*ix;
    CGFloat iy = NAVGATION_VIEW_HEIGHT-64+100;
    self.bgView.frame = CGRectMake(ix, iy, iw, ih);
    
    self.phoneTf.frame = CGRectMake(0, 0, _bgView.width, 45);
    CGFloat yGap = 25;
    self.codeTf .frame = CGRectMake(0, _phoneTf.bottom+yGap, _phoneTf.width, _phoneTf.height);
    self.pwdTf  .frame = CGRectMake(0, _codeTf.bottom+yGap, _phoneTf.width, _phoneTf.height);
    
    self.registerBtn.frame = CGRectMake(0, _pwdTf.bottom+65, _pwdTf.width, 40);
    ih = 30;
    self.gotoLoginL .frame = CGRectMake(0, _bgView.height-ih, _bgView.width, ih);
    
    iy = SCREEN_HEIGHT-ih-10-BOTTOM_NOT_SAVE_HEIGHT;
    self.userPotocolL.frame = CGRectMake(0, iy, SCREEN_WIDTH, ih);
}

#pragma mark - Notification

- (void)addTextFieldTextChangeNotification{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChangeOneCI:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:self.phoneTf];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChangeOneCI:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:self.pwdTf];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChangeOneCI:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:self.codeTf];
}

- (void)removeTextFieldNotifacion{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.phoneTf];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.pwdTf];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.codeTf];
}


-(void)textFieldTextDidChangeOneCI:(NSNotification *)notification
{
    UITextField *textfield=[notification object];
    if( [textfield isEqual:self.phoneTf] || [textfield isEqual:self.pwdTf] || [textfield isEqual:self.codeTf]){
        
        if( (_phoneTf.text.length/*==TSConstantPhoneNumLen*/  && _pwdTf.text.length>=6 && _codeTf.text.length == TSConstantVerificationCodeLen) || _codeTf.text.length == 4){
            self.registerBtn.enabled = YES;
        }else{
            self.registerBtn.enabled = NO;
        }
    }
    
}

#pragma mark - TouchEvents

- (void)handleClearPhoneBtn:(UIButton*)btn{
    self.phoneTf.text = @"";
}

- (void)handleSeeBtn:(UIButton*)btn{
    btn.selected = !btn.isSelected;
    
    self.pwdTf.secureTextEntry = !btn.isSelected;
}

- (void)handleUserPotocol{
    TSWebPageCtrl *pc  = [TSWebPageCtrl new];
    pc.title = NSLocalizedString(@"RegisterDisclaimer", nil);//@"免责声明";

    pc.pageUrl =  [TSConstantServerUrl stringByAppendingPathComponent:@"disclaimer-en.html"];//@"http://www.aipp3d.com:9000/disclaimer-en.html";
    if( [[NSString getPreferredLanguage] containsString:@"zh-Han"] ){
        //中文环境
        pc.pageUrl = [TSConstantServerUrl stringByAppendingPathComponent:@"disclaimer.html"];//@"http://www.aipp3d.com:9000/disclaimer.html";
    }
    [self pushViewCtrl:pc];
}

- (void)handleGotoLogin{
    
    TSLoginCtrl *loginCtrl = (TSLoginCtrl*)[self getCtrlAtNavigationCtrlsWithCtrlClass:[TSLoginCtrl class]];
    if( loginCtrl ){
        [self.navigationController popToViewController:loginCtrl animated:YES];
    }else{
        TSLoginCtrl *lc = [TSLoginCtrl new];
        [self pushViewCtrl:lc];
    }
    
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleRegister{
    
    NSInteger errCode = KErrorCodeDefault;
    BOOL validte = [KValidate validatePhoneNum:self.phoneTf.text errCode:&errCode]||[KValidate validateEmail:self.phoneTf.text errCode:&errCode];
    if( validte==NO ){
        NSString *msg = [KError errorMsgWithCode:errCode];
        [self showErrMsg:msg];
        return;
    }

    NSInteger len = self.pwdTf.text.length;
    if( len < TSConstantAccountPwdMinLen || len > TSConstantAccountPwdMaxLen ){
        NSString *prefix = NSLocalizedString(@"RegisterPwdLenPrefixDes", nil);
        NSString *tail = NSLocalizedString(@"RegisterPwdLenTailDes", nil);
        NSString *msg = [NSString stringWithFormat:@"%@%ld~%ld%@",prefix,TSConstantAccountPwdMinLen,TSConstantAccountPwdMaxLen,tail];

        [self showErrMsg:msg];
        return;
    }
    
//    [self validateCode];
    
    [self registerUser];
}

- (void)handleBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleCodeBtn:(UIButton*)btn{
    //NSInteger errCode = KErrorCodeDefault;
    //先检验手机号码和邮箱的有效性
    NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    NSString *mobileRegex = @"^(0|86|17951)?(13[0-9]|15[012356789]|17[0678]|18[0-9]|14[57])[0-9]{8}$";
    NSPredicate *premobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",mobileRegex];
    //此处返回的是BOOL类型,YES or NO;
    if ([pre evaluateWithObject:self.phoneTf.text]==NO&&[premobile evaluateWithObject:self.phoneTf.text]==NO) {
        [HTProgressHUD showSuccess:NSLocalizedString(@"邮箱或手机格式错误", nil)];
    }
    else
    //检验手机号是否注册过
    //[self validatePhoneIsExist];
    [self.dataProcess verifyCodeWithPhone:_phoneTf.text type:@"0" deviceType:3 completeBlock:^(NSDictionary *rusult, NSError *err) {
        [_hud hide];
        if (err) {
            [self showErrMsgWithError:err];
//            [self.timer endTimer];
        }else{
            [HTProgressHUD showSuccess:NSLocalizedString(@"RegisterSendCodeSuccess", nil)];//@"验证码已发送，请注意查收"];
            [self.timer startTimer];
//            [HTProgressHUD showSuccess:rusult[@"msg"]];
//            if (![rusult[@"msg"] containsString:@"已经存在"]) {
//                [self.timer startTimer];
//                [HTProgressHUD showSuccess:NSLocalizedString(@"RegisterSendCodeSuccess", nil)];//@"验证码已发送，请注意查收"];
//            }
        }
    }];
}

#pragma mark - UITextFieldDelgate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    {
        if( [textField isEqual:_phoneTf] ){
            
//            if (textField.text.length == TSConstantPhoneNumLen && ![string isEqualToString:@""]) {
//                return NO;
//            }
            if (textField.text == self.phoneTf.text) {
                //这里的if时候为了获取删除操作,如果没有次if会造成当达到字数限制后删除键也不能使用的后果.
                if (range.length == 1 && string.length == 0) {
                    return YES;
                }
                //so easy
                else if (self.phoneTf.text.length >= TSConstantPhoneNumLen) {
                    self.phoneTf.text = [textField.text substringToIndex:TSConstantPhoneNumLen];
                    return NO;
                }
            }
        }
        else if( [textField isEqual:self.codeTf] ){
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

- (UITextField *)phoneTf {
    if( !_phoneTf ){
        _phoneTf = [[TSLoginTextField alloc] init];
        _phoneTf.textColor = [UIColor colorWithRgb51];
        _phoneTf.placeholder = NSLocalizedString(@"RegisterPhoneHolder", nil);
        _phoneTf.font = [UIFont systemFontOfSize:15];
        _phoneTf.returnKeyType = UIReturnKeyDone;
        _phoneTf.delegate = self;
        _phoneTf.keyboardType = UIKeyboardTypeDefault;
        _phoneTf.rightViewMode = UITextFieldViewModeWhileEditing;
        [self.bgView addSubview:_phoneTf];
        
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
        _pwdTf.placeholder = NSLocalizedString(@"RegisterSetPwdHolder", nil);
        _pwdTf.font = _phoneTf.font;
        _pwdTf.rightViewMode = UITextFieldViewModeAlways;
        _pwdTf.returnKeyType = UIReturnKeyDone;
        _pwdTf.delegate = self;
        _pwdTf.secureTextEntry = YES;
        [self.bgView addSubview:_pwdTf];
        
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
        
        //为了适配ios13
        UIView *rv = [UIView new];
        rv.frame = self.codeBtn.frame;
        [rv addSubview:self.codeBtn];
        _codeTf.rightView = rv;
     
        [self.bgView addSubview:_codeTf];
        
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

- (KTimer *)timer{
    if( !_timer ){
        _timer = [[KTimer alloc] initWithButton:self.codeBtn];
    }
    return _timer;
}

- (UIButton *)registerBtn {
    if( !_registerBtn ){
        _registerBtn = [[UIButton alloc] init];
        [_registerBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue"] forState:UIControlStateNormal];
        [_registerBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue_hi"] forState:UIControlStateHighlighted];
        
        [_registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        [_registerBtn setTitle:NSLocalizedString(@"RegisterBtnTitle", nil) forState:UIControlStateNormal];
        _registerBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    
        [_registerBtn addTarget:self action:@selector(handleRegister) forControlEvents:UIControlEventTouchUpInside];
        [_registerBtn cornerRadius:5];
        _registerBtn.enabled = NO;
        [self.bgView addSubview:_registerBtn];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"iscode"]!=nil) {
            _registerBtn.enabled = YES;
        }
    }
    return _registerBtn;
}

- (UILabel *)gotoLoginL {
    if( !_gotoLoginL ){
        _gotoLoginL = [[UILabel alloc] init];
        _gotoLoginL.userInteractionEnabled = YES;
        _gotoLoginL.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:_gotoLoginL];
        
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGotoLogin)];
        [_gotoLoginL addGestureRecognizer:tap];
        
        //设置文本
        
        NSString *prefixStr = NSLocalizedString(@"RegisterGotoLoginTextPrefix", nil);
        NSString *tailStr   = NSLocalizedString(@"RegisterGotoLoginTextTail", nil);
       
        NSString *str = [prefixStr stringByAppendingString:tailStr];
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor colorWithRgb102]}];
        
        [as addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRgb_0_151_216] range:[str rangeOfString:tailStr]];
        _gotoLoginL.attributedText = as;
    }
    return _gotoLoginL;
}

- (UILabel *)userPotocolL {
    if( !_userPotocolL ){
        _userPotocolL = [[UILabel alloc] init];
        _userPotocolL.userInteractionEnabled = YES;
        _userPotocolL.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_userPotocolL];
        
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserPotocol)];
        [_userPotocolL addGestureRecognizer:tap];
        
        //设置文本
        NSString *prefixStr = NSLocalizedString(@"RegisterUserProtocolTextPrefix", nil);//@"注册即表示同意";
        NSString *tailStr   = NSLocalizedString(@"RegisterUserProtocolTextTail", nil);
        NSString *str = [NSString stringWithFormat:@"%@《%@》",prefixStr,tailStr];
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor colorWithRgb102]}];
        
        [as addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRgb_0_151_216] range:[str rangeOfString:tailStr]];
        _userPotocolL.attributedText = as;
    }
    return _userPotocolL;
}

@end
