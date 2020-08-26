//
//  TSModifyPwdCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 10/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSModifyPwdCtrl.h"
#import "UIViewController+Ext.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSLoginTextField.h"
#import "TSConstants.h"
#import "KValidate.h"
#import "KError.h"
#import "HTProgressHUD.h"
#import "NSString+Ext.h"

@interface TSModifyPwdCtrl ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView       *bgView;
@property (nonatomic, strong) UITextField  *confirmPwdTf;
@property (nonatomic, strong) UITextField  *pwdTf;
@property (nonatomic, strong) UITextField  *newPwdTf;
@property (nonatomic, strong) HTProgressHUD *hud;

@end

@implementation TSModifyPwdCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelfData];
    self.navigationItem.title = NSLocalizedString(@"ModifyPwdPageTitle", nil);//@"修改密码";
    
    [self addRightBarItemWithTitle:NSLocalizedString(@"ModifyPwdConfirmText", nil) action:@selector(handleConfirmBtn)];
    
    [self doLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doLayout{
    CGFloat ix = 15;
    self.pwdTf.frame = CGRectMake(ix, 0, SCREEN_WIDTH-2*ix, 44);
    self.newPwdTf.frame = CGRectMake(_pwdTf.x, _pwdTf.bottom, _pwdTf.width, _pwdTf.height);
    self.confirmPwdTf.frame = CGRectMake(_pwdTf.x, _newPwdTf.bottom, _pwdTf.width, _pwdTf.height);
    
    self.bgView.frame = CGRectMake(0, NAVGATION_VIEW_HEIGHT, SCREEN_WIDTH, _confirmPwdTf.bottom);
}

- (void)modifyPwd{
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess modifyPwd:[_newPwdTf.text md5] oldPwd:[_pwdTf.text md5] completBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                [HTProgressHUD showSuccess:NSLocalizedString(@"ModifyPwdSuccess", nil)];//@"修改密码成功"
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
}

#pragma mark - TouchEvents
- (void)handleConfirmBtn{
    NSInteger code = -1;
    BOOL ret =
    [KValidate validateModifyPwdWithOldPwd:_pwdTf.text newPwd:_newPwdTf.text confirmPwd:_confirmPwdTf.text errCode:&code];
    if( ret==NO ){
        NSString *msg = [KError errorMsgWithCode:code];
        [HTProgressHUD showError:msg];
        return;
    }
    
    [self modifyPwd];
}

- (void)handleClearConfirmPwdBtn:(UIButton*)btn{
    self.confirmPwdTf.text = @"";
}

- (void)handleClearPwdBtn:(UIButton*)btn{
    
    self.pwdTf.text = @"";
}

- (void)handleClearNewPwdBtn:(UIButton*)btn{
    self.newPwdTf.text = @"";
}

#pragma mark - UITextFieldDelegate
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
        _confirmPwdTf.placeholder = NSLocalizedString(@"ModifyAgainNewPwdHolder", nil);//@"再次输入新密码";
        _confirmPwdTf.font = [UIFont systemFontOfSize:15];
        _confirmPwdTf.returnKeyType = UIReturnKeyDone;
        _confirmPwdTf.delegate = self;
        _confirmPwdTf.secureTextEntry = YES;
        _confirmPwdTf.rightViewMode = UITextFieldViewModeWhileEditing;
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
        _pwdTf.placeholder = NSLocalizedString(@"ModifyPwdOldHolder", nil);//@"原密码";
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

- (UITextField *)newPwdTf {
    if( !_newPwdTf ){
        _newPwdTf = [[TSLoginTextField alloc] init];
        _newPwdTf.textColor = self.confirmPwdTf.textColor;
        _newPwdTf.placeholder = NSLocalizedString(@"ModifyNewPwdHolder", nil);//@"输入新密码";
        _newPwdTf.font = _confirmPwdTf.font;
        _newPwdTf.rightViewMode = UITextFieldViewModeWhileEditing;
        _newPwdTf.returnKeyType = UIReturnKeyDone;
        _newPwdTf.secureTextEntry = YES;
        _newPwdTf.delegate = self;
        
        UIButton *seeBtn = [UIButton new];
        seeBtn.frame = CGRectMake(0, 0, 30, 40);
        [seeBtn setImage:[UIImage imageNamed:@"pc_clear_text"] forState:UIControlStateNormal];
        [seeBtn addTarget:self action:@selector(handleClearNewPwdBtn:) forControlEvents:UIControlEventTouchUpInside];
        _newPwdTf.rightView = seeBtn;

        [self.bgView addSubview:_newPwdTf];
        
        [self addDoneBtnWithView:(UITextView*)_newPwdTf];
    }
    return _newPwdTf;
}
@end
