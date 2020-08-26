//
//  TSForgetPwdPhoneCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 05/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSForgetPwdPhoneCtrl.h"
#import "UIViewController+Ext.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSLoginTextField.h"
#import "TSConstants.h"
#import "KValidate.h"
#import "KError.h"
#import "TSForgetPwdSetNewPwdCtrl.h"
#import "HTProgressHUD.h"

@interface TSForgetPwdPhoneCtrl ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField  *phoneTf;
@property (nonatomic, strong) UIButton     *nextBtn;
@property (nonatomic, strong) HTProgressHUD *hud;
@end

@implementation TSForgetPwdPhoneCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addLeftBarItemWithAction:@selector(handleBack) imgName:@"pc_close"];
    self.navigationItem.title = NSLocalizedString(@"ForgetPwdPageTitle", nil);//@"忘记密码";
//    [self addTextFieldTextChangeNotification];
    
    [self doLayout];
    
    [self.phoneTf becomeFirstResponder];
    
    self.phoneTf.text = self.userAcccount;
}

- (void)dealloc{
//    [self removeTextFieldNotifacion];
}

#pragma mark - Private
- (void)validatePhoneIsExist{
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess userIsExistWithPhone:self.phoneTf.text completeBlock:^(BOOL isExist, NSError *err) {
        
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                if( isExist == NO ){
                    [HTProgressHUD showError:NSLocalizedString(@"ForgetPwdUserIsExist", nil) ];//@"用户不存在，请注册"
                }else{
            
                    TSForgetPwdSetNewPwdCtrl *fc = [TSForgetPwdSetNewPwdCtrl new];
                    fc.phone = self.phoneTf.text;
                    [self pushViewCtrl:fc];
                }
            }
        }];
    }];
}

#pragma mark - Layout
- (void)doLayout{
    CGFloat ix = 35,ih = 45;
    CGFloat iy = NAVGATION_VIEW_HEIGHT-64+100;
    self.phoneTf.frame = CGRectMake(ix, iy,SCREEN_WIDTH-2*ix, ih);
    self.nextBtn.frame = CGRectMake(ix, _phoneTf.bottom+65, _phoneTf.width, 40);
}

#pragma mark - Notification

- (void)addTextFieldTextChangeNotification{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChangeOneCI:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:self.phoneTf];
}

- (void)removeTextFieldNotifacion{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.phoneTf];
}


-(void)textFieldTextDidChangeOneCI:(NSNotification *)notification
{
    if( _phoneTf.text.length >= TSConstantPhoneNumLen ){
        self.nextBtn.enabled = YES;
    }else{
        self.nextBtn.enabled = NO;
    }
}


#pragma mark - TouchEvents

- (void)handleClearPhoneBtn:(UIButton*)btn{
    self.phoneTf.text = @"";
}

- (void)handleNextBtn{
    NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    NSString *mobileRegex = @"^(0|86|17951)?(13[0-9]|15[012356789]|17[0678]|18[0-9]|14[57])[0-9]{8}$";
    NSPredicate *premobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",mobileRegex];
    //此处返回的是BOOL类型,YES or NO;
    if ([pre evaluateWithObject:self.phoneTf.text]==NO&&[premobile evaluateWithObject:self.phoneTf.text]==NO) {
        [HTProgressHUD showSuccess:NSLocalizedString(@"邮箱或手机格式错误", nil)];
    }
    else{
        [self validatePhoneIsExist];
    }
    
    return;
    
    [self.dataProcess verifyCodeWithPhone:self.phoneTf.text type:@"1" deviceType:3 completeBlock:^(NSDictionary *rusult, NSError *err) {
        NSLog(@"forget -- %@",rusult);
        [_hud hide];
        if (err) {
            [self showErrMsgWithError:err];
            [HTProgressHUD showError:NSLocalizedString(@"ForgetPwdUserIsExist", nil) ];//@"用户不存在，请注册"
            //[self.timer endTimer];
        }else{
            //[HTProgressHUD showSuccess:NSLocalizedString(@"RegisterSendCodeSuccess", nil)];//@"验证码已发送，请注意查收"];
            [HTProgressHUD showSuccess:rusult[@"msg"]];
            if (![rusult[@"msg"] containsString:@"不存在"]) {
                //[self.timer startTimer];
                [HTProgressHUD showSuccess:NSLocalizedString(@"RegisterSendCodeSuccess", nil)];//@"验证码已发送，请注意查收"];
                TSForgetPwdSetNewPwdCtrl *fc = [TSForgetPwdSetNewPwdCtrl new];
                fc.phone = self.phoneTf.text;
                [self pushViewCtrl:fc];
            }
        }
    }];
//    else
//        [self.dataProcess resetPwdWithPhone:self.phoneTf.text code:<#(NSString *)#> pwd:<#(NSString *)#> completeBlock:^(NSError *err) {
//
//        }];
}

- (void)handleBack{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITextFieldDelgate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if( [textField isEqual:_phoneTf] ){

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
       else if (textField.text.length== TSConstantPhoneNumLen && ![string isEqualToString:@""]) {
            return NO;
        }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - Propertys

- (UITextField *)phoneTf {
    if( !_phoneTf ){
        _phoneTf = [[TSLoginTextField alloc] init];
        _phoneTf.textColor = [UIColor colorWithRgb51];
        _phoneTf.placeholder = NSLocalizedString(@"ForgetPwdPhoneHolder", nil);
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

- (UIButton *)nextBtn {
    if( !_nextBtn ){
        _nextBtn = [[UIButton alloc] init];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue"] forState:UIControlStateNormal];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue_hi"] forState:UIControlStateHighlighted];
        
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        [_nextBtn setTitle:NSLocalizedString(@"ForgetPwdNextText", nil) forState:UIControlStateNormal];
        _nextBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_nextBtn addTarget:self action:@selector(handleNextBtn) forControlEvents:UIControlEventTouchUpInside];
        [_nextBtn cornerRadius:5];
//        _nextBtn.enabled = NO;
        [self.view addSubview:_nextBtn];
    }
    return _nextBtn;
}

@end
