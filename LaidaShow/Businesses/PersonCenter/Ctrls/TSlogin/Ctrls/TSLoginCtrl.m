//
//  TSLoginCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSLoginCtrl.h"
#import "TSLoginTextField.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "UILabel+Ext.h"
#import "TSConstants.h"
#import "KError.h"
#import "KValidate.h"
#import "UIViewController+Ext.h"
#import "TSRegisterCtrl.h"
#import "KScrollView.h"
#import "TSForgetPwdPhoneCtrl.h"
#import "NSString+Ext.h"
#import "HTProgressHUD.h"
#import "TSHelper.h"
#import "DSAppleLogin.h"
#import "KTimer.h"
#import "KValidate.h"
#import "TSUserModel.h"
#import "TSBindPhoneCtrl.h"

static NSInteger const gTagBase = 100;

@interface TSLoginCtrl ()<UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView  *logoImgView;
@property (nonatomic, strong) UITextField  *phoneTf;
@property (nonatomic, strong) UITextField  *pwdTf;
@property (nonatomic, strong) UITextField  *codeTf;
@property (nonatomic, strong) UIButton     *forgetPwdBtn;
@property (nonatomic, strong) UIButton     *loginBtn;
@property (nonatomic, strong) UIButton     *registerBtn;
@property (nonatomic, strong) UIButton     *loginMethodType;
@property (nonatomic, strong) UIButton     *codeBtn;
@property (nonatomic, strong) KTimer       *timer;
@property (nonatomic, strong) HTProgressHUD *hud;

@end

@implementation TSLoginCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addLeftBarItemWithAction:@selector(handleBack) imgName:@"pc_close"];
    [self addTextFieldTextChangeNotification];
    
    [self initViews];
    
    [self addHideKeyboardGestureToView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)dealloc{
    [self removeTextFieldNotifacion];
}

#pragma mark - Private
- (void)initViews{
    self.logoImgView.image = [UIImage imageNamed:@"pc_login_logo"];
    
    CGSize imgSize = self.logoImgView.image.size;
    if( imgSize.height <=0 ) imgSize.height = 1;
    CGFloat imgH = imgSize.height;
    CGFloat imgW = imgSize.width;//imgH*(imgSize.width/imgSize.height);
    self.logoImgView.frame = CGRectMake((SCREEN_WIDTH-imgW)/2, (NAVGATION_VIEW_HEIGHT-64)+92, imgW, imgH);
    
    CGFloat iLeft = 35;
    self.phoneTf.frame = CGRectMake(iLeft, _logoImgView.bottom+50, SCREEN_WIDTH-2*iLeft, 35);
    self.pwdTf.frame = CGRectMake(iLeft, _phoneTf.bottom+20, _phoneTf.width, _phoneTf.height);
    self.codeTf.frame = self.pwdTf.frame;
    CGFloat iw = 120;
    self.forgetPwdBtn.frame = CGRectMake(_pwdTf.right-iw, _pwdTf.bottom, iw, 40);
    self.loginMethodType.frame = CGRectMake(_pwdTf.left, _pwdTf.bottom, iw, 40);
    
    self.loginBtn.frame = CGRectMake(_pwdTf.x, _forgetPwdBtn.bottom+30, _pwdTf.width, 44);
    self.registerBtn.frame = CGRectMake(_loginBtn.x, _loginBtn.bottom, _loginBtn.width, _loginBtn.height);
    self.scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    UIView *markLine = [UIView new];
    markLine.backgroundColor = [UIColor colorWithRgb221];
    iLeft = 10;
    markLine.frame = CGRectMake(iLeft, _registerBtn.bottom+80, SCREEN_WIDTH-2*iLeft, 1);
    [self.scrollView addSubview:markLine];
    
    UILabel *thridLoginMarkL = [UILabel new];
    thridLoginMarkL.backgroundColor = [UIColor whiteColor];
    thridLoginMarkL.text = NSLocalizedString(@"LoginThirdLoginText", nil);
    thridLoginMarkL.font = [UIFont systemFontOfSize:14];
    thridLoginMarkL.textColor = [UIColor colorWithRgb102];
    thridLoginMarkL.textAlignment = NSTextAlignmentCenter;
    iw = [thridLoginMarkL labelSizeWithMaxWidth:150].width + 20;
    CGFloat ih = 20;
    thridLoginMarkL.frame = CGRectMake((SCREEN_WIDTH-iw)/2, markLine.center.y-ih/2, iw, ih);
    [self.scrollView addSubview:thridLoginMarkL];
    CGFloat xGap = 30;
    
    NSArray *imgNames = @[@"pc_share_qq",@"pc_share_wxchat",@"pc_share_sinaweibo"]; //,@"pc_share_facebook",@"pc_share_twitter"];
    
    //ios 添加苹果登录
    if (@available(iOS 13.0, *)) {
        NSMutableArray *arr = [NSMutableArray new];
        [arr addObjectsFromArray:imgNames];
        [arr addObject:@"appleLogin"];
        imgNames = arr;
        
        xGap = 20;
    }
    CGFloat wh = 40;
    //50
    iLeft = (SCREEN_WIDTH-wh*imgNames.count-(imgNames.count-1)*xGap)/2;
    CGFloat contentH = self.scrollView.height;
    for( NSUInteger i=0; i<imgNames.count; i++ ){
        
        CGFloat ix = iLeft + (wh+xGap)*i;
        CGRect fr = CGRectMake(ix, thridLoginMarkL.bottom+30, wh, wh);
        UIButton *btn = [UIButton new];
        [btn setBackgroundImage:[UIImage imageNamed:imgNames[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(handleThirdLoginBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i+gTagBase;
        [btn cornerRadius:wh/2];
        btn.frame = fr;
        [self.scrollView addSubview:btn];
        
        if( i==0 ){
            if( btn.bottom + 20 > contentH ){
                contentH = btn.bottom + 20;
            }
        }
    }
    
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, contentH)];
    
    //设置默认为密码登录
    self.loginMethodType.selected = YES;
    [self handleLoginMethodBtn];
}

#pragma mark - Request

- (void)login{

    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    
    NSString *pwd = [_pwdTf.text md5];
    BOOL isCodeLogin = _loginMethodType.selected;
    if( isCodeLogin ) pwd = _codeTf.text;
    
    [self.dataProcess loginWithPhone:_phoneTf.text md5Pwd:pwd isCodeLogin:isCodeLogin completeBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                [self loginSuccess];
            }
        }];
    }];
}

- (void)thirdLoginWithDic:(NSDictionary*)dic{
    
    NSDictionary *tdic = dic;
    if( [tdic isKindOfClass:[NSDictionary class]] ){
        NSMutableDictionary *td = [NSMutableDictionary dictionaryWithDictionary:tdic];
        NSString *un = tdic[@"socialName"];
        if( un.length ==0 ){
            td[@"socialName"] = [NSString stringWithFormat:@"svshow%3d",rand()%1000];
        }
        tdic = td;
    }
    
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess thirdLoginWithPara:tdic completBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( err ){
                [self showErrMsgWithError:err];
            }else{
//                [self loginSuccess];
                [self thirdLoginSuccess];
                
            }
        }];
    }];
}

- (void)thirdLoginSuccess{
    //三方登录成功，去拉取个人信息，判断是否有手机号，若有，则不再绑定。无，去绑定页面
    
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.dataProcess userInfoWithNeedCallback:YES completeBlock:^(NSError *err) {
            
            [self dispatchAsyncMainQueueWithBlock:^{
                [self.hud hide ];
                if( err ){
                    [self showErrMsgWithError:err];
                }else{
                    //存在电话，则直接登录成功
                    if( self.dataProcess.userModel.phone.length >5 ){
                        [self loginSuccess];
                    }else{
                        TSBindPhoneCtrl *pc = [TSBindPhoneCtrl new];
                        [self pushViewCtrl:pc];
                    }
                }
            }];
        }];
    });
}

- (void)loginSuccess{
    
    [HTProgressHUD showSuccess:NSLocalizedString(@"PersonLoginSuccess", nil)];//@"登录成功"];
    if( self.fromGuide ){
        UIViewController *rootVc = [TSHelper rootCtrl];
//        [self presentViewController:rootVc animated:NO completion:nil];
        [UIApplication sharedApplication].keyWindow.rootViewController = rootVc;
        [TSHelper sharedHelper].guideRootCtrl = nil;
    }else{
        [self.navigationController popViewControllerAnimated:YES];
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
//    UITextField *textfield=[notification object];
//    if( [textfield isEqual:self.phoneTf] || [textfield isEqual:self.pwdTf] ){
//        if( _phoneTf.text.length >= TSConstantPhoneNumLen && _pwdTf.text.length ){
//            self.loginBtn.enabled = YES;
//        }else{
//            self.loginBtn.enabled = NO;
//        }
//    }
    
    //验证码登录
    if( self.loginMethodType.isSelected ){
        if( _phoneTf.text.length == TSConstantPhoneNumLen && self.codeTf.text.length == 6 ){
            self.loginBtn.enabled = YES;
        }else{
            self.loginBtn.enabled = NO;
        }
    }
    //密码登录
    else{
        if( _phoneTf.text.length >3 && self.pwdTf.text.length >= 6 ){
            self.loginBtn.enabled = YES;
        }else{
            self.loginBtn.enabled = NO;
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

- (void)handleForgetBtn{
    TSForgetPwdPhoneCtrl *pc = [TSForgetPwdPhoneCtrl new];
    pc.userAcccount = self.phoneTf.text;
    [self pushViewCtrl:pc];
}

- (void)handleLogin{
    
    NSInteger errCode = KErrorCodeDefault;
    BOOL validte = [KValidate validatePhoneNum:self.phoneTf.text errCode:&errCode]||[KValidate validateEmail:self.phoneTf.text errCode:&errCode];
    if(validte==NO){
        NSLog(@"====errCode~~%ld====",errCode);
        //NSString *msg = [KError errorMsgWithCode:errCode];
        NSString *errCodeStr =NSLocalizedString(@"LoginWrongDes", nil);
        NSString *msg = [NSString stringWithFormat:@"%@",errCodeStr];
        [self showErrMsg:msg];
        return;
    }
    
//    NSInteger len = self.pwdTf.text.length;
//    NSInteger phoneLen = self.phoneTf.text.length;
//    if( len < TSConstantAccountPwdMinLen || len > TSConstantAccountPwdMaxLen ||phoneLen< TSConstantPhoneNumLen ){
//        NSString *errCodeStr =NSLocalizedString(@"LoginWrongDes", nil);
//        NSString *msg = [NSString stringWithFormat:@"%@",errCodeStr];
//        [self showErrMsg:msg];
//        return;
//    }

    [self login];
}

- (void)handleRegister{
    TSRegisterCtrl *rc = [TSRegisterCtrl new ];
    [self pushViewCtrl:rc];
}
//socialName:演不完的冬天
//socialOpenId:27B04A53D38B79E2F07F6EAE6285EE9D
//socialImage:http://thirdqq.qlogo.cn/g?b=oidb%26k=fOQRLSMc97DnJzcV2DLBicw%26s=100%26t=1555303826
//socialType:3
- (void)handleThirdLoginBtn:(UIButton*)btn{
    
    if( btn.tag == gTagBase+ 3 ){
        //苹果登录
        NSLog(@"apple login");
        [[DSAppleLogin shareAppleLogin] handleAuthorizationAppleIDButtonPress];
        
        __weak typeof(self) weakSelf = self;
        [DSAppleLogin shareAppleLogin].competeBlock = ^(NSString * _Nonnull userId, NSString * _Nonnull name) {
            if( userId ){
                NSString *un = name?name:[NSString stringWithFormat:@"苹果%3d",rand()%1000];
                NSDictionary *dic = @{
                @"socialOpenId":userId,
                @"socialType":@"99",
                @"socialName":un,
                @"socialImage":@""
                };
                [weakSelf thirdLoginWithDic:dic];
            }else{
                [HTProgressHUD showError:@"获取授权失败"];
            }
        };
        return;
    }
//    NSInteger type = 0;
//    if( btn.tag == gTagBase +0 ){
//        //QQ登录
//        type = 1;
//    }
//    else if( btn.tag == gTagBase +1 ){
//        //微信登录
//        type = 0;
//    }
//    else {
//        //微博登录
//        type = 2;
//    }
    
    NSInteger type = btn.tag - gTagBase +3;
    __weak typeof(self) weakSelf = self;
    [TSHelper thirdLoginWithType:type completeBlock:^(NSDictionary *dic, NSError *err) {
        if( err ){
            [weakSelf showErrMsgWithError:err];
        }else{
            [weakSelf thirdLoginWithDic:dic];
        }
    }];
}

- (void)handleBack{
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
    //获取登录验证码
    [self.dataProcess verifyCodeWithPhone:_phoneTf.text type:@"2" deviceType:3 completeBlock:^(NSDictionary *rusult, NSError *err) {
        [_hud hide];
        if (err) {
            [self showErrMsgWithError:err];
        }else{
//            [HTProgressHUD showSuccess:rusult[@"msg"]];
            [self.timer startTimer];
            [HTProgressHUD showSuccess:NSLocalizedString(@"RegisterSendCodeSuccess", nil)];
        }
    }];
}

//登录方式切换
- (void)handleLoginMethodBtn{
    
    self.loginMethodType.selected = !self.loginMethodType.selected;
    
    BOOL isCodeLogin = self.loginMethodType.selected;
    
    self.pwdTf.hidden = isCodeLogin;
    self.codeTf.hidden = !self.pwdTf.hidden;
    
    self.phoneTf.placeholder = isCodeLogin?NSLocalizedString(@"手机号", nil):NSLocalizedString(@"LoginPhoneHolder", nil);
    self.phoneTf.keyboardType = isCodeLogin?UIKeyboardTypeNumberPad:UIKeyboardTypeEmailAddress;
    
    [self.view endEditing:YES];
    [self.phoneTf becomeFirstResponder];
}

#pragma mark - UITextFieldDelgate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    {
        if([string isEqualToString:@""]) return YES;
        
        //验证码登录
        if( self.loginMethodType.selected ){
            if( [textField isEqual:_phoneTf] ){
                if( textField.text.length >= TSConstantPhoneNumLen ){
                    return NO;
                }
            }else if( [textField isEqual:_codeTf] ){
                if( _codeTf.text.length >= 6 ){
                    return NO;
                }
            }
        }
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}
//#pragma mark - 键盘收回 添加完成Done按钮
//- (void)addDoneBtnWithView:(UITextView*)tvTextView{
//    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
//    [topView setBarStyle:UIBarStyleDefault];
//
//    UIBarButtonItem * helloButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//
//    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//
//    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
//
//    NSArray * buttonsArray = [NSArray arrayWithObjects:helloButton,btnSpace,doneButton,nil];
//    [topView setItems:buttonsArray];
//    [tvTextView setInputAccessoryView:topView];
//}
//
//-(IBAction)dismissKeyBoard
//{
//    [self.view endEditing:YES];
//}

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

- (UIImageView *)logoImgView {
    if( !_logoImgView ){
        _logoImgView = [[UIImageView alloc] init];
        
        [self.scrollView addSubview:_logoImgView];
    }
    return _logoImgView;
}

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
        _pwdTf.placeholder = NSLocalizedString(@"LoginPwdHolder", nil);
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

- (UIButton *)forgetPwdBtn {
    if( !_forgetPwdBtn ){
        _forgetPwdBtn = [[UIButton alloc] init];
        _forgetPwdBtn.backgroundColor = [UIColor clearColor];
        [_forgetPwdBtn setTitle:NSLocalizedString(@"LoginForgetPwdTitle", nil) forState:UIControlStateNormal];
        [_forgetPwdBtn sizeToFit];
        [_forgetPwdBtn setTitleColor:self.pwdTf.textColor forState:UIControlStateNormal];
        [_forgetPwdBtn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateHighlighted];
        _forgetPwdBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _forgetPwdBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_forgetPwdBtn addTarget:self action:@selector(handleForgetBtn) forControlEvents:UIControlEventTouchUpInside];
        _forgetPwdBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.scrollView addSubview:_forgetPwdBtn];
    }
    return _forgetPwdBtn;
}

- (UIButton *)loginBtn {
    if( !_loginBtn ){
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue"] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue_hi"] forState:UIControlStateHighlighted];
        
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        [_loginBtn setTitle:NSLocalizedString(@"LoginBtnTitle", nil) forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_loginBtn addTarget:self action:@selector(handleLogin) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn cornerRadius:5];
        _loginBtn.enabled = NO;
        [self.scrollView addSubview:_loginBtn];
    }
    return _loginBtn;
}

- (UIButton *)registerBtn {
    if( !_registerBtn ){
        _registerBtn = [[UIButton alloc] init];
        _registerBtn.backgroundColor = [UIColor clearColor];
        [_registerBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
        [_registerBtn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateHighlighted];

        [_registerBtn setTitle:NSLocalizedString(@"LoginRegisterBtnTitle", nil) forState:UIControlStateNormal];
        _registerBtn.titleLabel.font = self.loginBtn.titleLabel.font;
        [_registerBtn addTarget:self action:@selector(handleRegister) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:_registerBtn];
    }
    return _registerBtn;
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
        _codeTf.hidden = YES;
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


- (UIButton *)loginMethodType{
    if( !_loginMethodType ){
        _loginMethodType = [UIButton new];
        [_loginMethodType setTitle:NSLocalizedString(@"验证码登录", nil) forState:UIControlStateNormal];
        [_loginMethodType setTitle:NSLocalizedString(@"密码登录", nil) forState:UIControlStateSelected];
        [_loginMethodType sizeToFit];
        [_loginMethodType setTitleColor:self.pwdTf.textColor forState:UIControlStateNormal];
        [_loginMethodType setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateHighlighted];
        _loginMethodType.titleLabel.font = [UIFont systemFontOfSize:13];
        _loginMethodType.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_loginMethodType addTarget:self action:@selector(handleLoginMethodBtn) forControlEvents:UIControlEventTouchUpInside];
        _loginMethodType.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.scrollView addSubview:_loginMethodType];
    }
    return _loginMethodType;
}

- (KTimer *)timer{
    if( !_timer ){
        _timer = [[KTimer alloc] initWithButton:self.codeBtn];
    }
    return _timer;
}

@end



