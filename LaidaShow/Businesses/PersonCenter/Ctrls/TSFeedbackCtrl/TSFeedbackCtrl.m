//
//  TSFeedbackCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 11/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSFeedbackCtrl.h"
#import "UIViewController+Ext.h"
#import "KTextView.h"
#import "HTProgressHUD.h"
#import "KValidate.h"

@interface TSFeedbackCtrl ()<KTextViewDelegate,UITextFieldDelegate>
@property (nonatomic, strong) KTextView *textView;
@property (nonatomic, strong) UITextField *phoneTf;
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) UIButton *rightBtn;
@end

@implementation TSFeedbackCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelfData];
    self.navigationItem.title = NSLocalizedString(@"FeedbackPageTitle", nil);//@"意见反馈";
    [self addRightBarItemWithTitle:NSLocalizedString(@"FeedbackCommitText", nil) action:@selector(handleCommit)];
    
    [self addHideKeyboardGestureToView];
    
    [self.textView becomeFirstResponder];
    self.phoneTf.hidden = NO;
    
    _rightBtn = [self getButtonAtRightBarItem];
    _rightBtn.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TouchEvents
- (void)handleCommit{
    [self.view endEditing:YES];
    
//    NSString *msg = NSLocalizedString(@"DeviceConnectFailPleaseFresh", nil); //@"连接设备失败,请刷新设备列表"
//    [self showAlertViewWithTitle:nil msg:msg okBlock:^{
//        //        [self stopScan:nil];
//        //        [self handleFreshBtn:self.freshBtn];
//    } cancleBlock:nil];
//    
//    return;
    
//    "FeedbackPleaseInputContent"="Please input content";
//    "FeedbackPleaseContentLimitToMaxLen"="Content is too long";
//    "FeedbackPleaseInputPhone"="Please input phone";
//    "FeedbackPhoneInvalidate"=
    if( self.textView.text.length < 5 ){
        [HTProgressHUD showError:NSLocalizedString(@"FeedbackPleaseInputContent", nil)];
        
        return;
    }
    
    if( self.textView.text.length >  140 ){
        [HTProgressHUD showError:NSLocalizedString(@"FeedbackPleaseContentLimitToMaxLen", nil)];
        
        return;
    }

    
//    if( self.phoneTf.text.length == 0 ){
//        [HTProgressHUD showError:NSLocalizedString(@"FeedbackPleaseInputPhone", nil)];
//
//        return;
//    }
    
    NSInteger ec = 0;
    BOOL validatePhone =
    [KValidate validatePhoneNum:self.phoneTf.text errCode:&ec];
    
    BOOL validateEmail =
    [KValidate validateEmail:self.phoneTf.text errCode:&ec];
    
    if( validatePhone==NO && validateEmail==NO  ){
        [HTProgressHUD showError:NSLocalizedString(@"FeedbackPhoneInvalidate", nil)];
        
        return;
    }
    
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess feedbackWithContent:self.textView.text phone:self.phoneTf.text completBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                [HTProgressHUD showSuccess:NSLocalizedString(@"FeedbackSuccess", nil)];//@"意见反馈成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
}

#pragma mark - KTextViewDelegate
- (void)kTextViewDidChange:(KTextView *)textView{
    BOOL enable = textView.text.length>=1;
    if( enable && _rightBtn.isEnabled==NO ){
        _rightBtn.enabled = enable;
    }else if( enable == NO && _rightBtn.isEnabled ){
        _rightBtn.enabled = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger emailMaxLen = 64;
    if (textField.text.length == emailMaxLen && ![string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

#pragma mark - Propertys
- (KTextView *)textView {
    if( !_textView ){
        _textView = [[KTextView alloc] init];
        _textView.textColor = [UIColor colorWithRgb51];
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.textContainerInset = UIEdgeInsetsMake(15, 15, 15, 15);
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.del = self;
        
        CGRect fr = _textView.placeHdLbl.frame;
        fr.size.height = 13;
        fr.origin = CGPointMake(15, 15);
        _textView.placeHdLbl.frame = fr;
        _textView.scrollEnabled = YES;
        _textView.placeHolder = NSLocalizedString(@"FeedbackAdviseHolder", nil);//@"告诉我们您遇到的问题或者意见及反馈";
        _textView.placeHdLbl.textColor = [UIColor colorWithRgb153];
        _textView.backgroundColor = [UIColor whiteColor];

        [self.view addSubview:_textView];
        
        _textView.frame = CGRectMake(0, NAVGATION_VIEW_HEIGHT, SCREEN_WIDTH, 175);
        [self addDoneBtnWithView:_textView];
    }
    return _textView;
}

- (UITextField *)phoneTf {
    if( !_phoneTf ){
        _phoneTf = [[UITextField alloc] init];
        _phoneTf.textColor = [UIColor colorWithRgb51];
        _phoneTf.font = [UIFont systemFontOfSize:15];
        
        _phoneTf.placeholder = NSLocalizedString(@"FeedbackContactPhoneHolder", nil);//@"请输入联系方式，便于我们联系您";
        _phoneTf.keyboardType = UIKeyboardTypeASCIICapable;
        _phoneTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTf.backgroundColor = [UIColor whiteColor];
        _phoneTf.delegate = self;
        UILabel *leftL = [UILabel new];
        leftL.text =NSLocalizedString(@"FeedbackContactPhoneText", nil); //@"联系电话";
        leftL.font = [UIFont systemFontOfSize:15];
        leftL.adjustsFontSizeToFitWidth = YES;
        leftL.textColor = [UIColor colorWithRgb51];
        leftL.textAlignment = NSTextAlignmentCenter;
        UIView *lv = [UIView new];
        [lv addSubview:leftL];
        _phoneTf.leftView = lv;
        _phoneTf.leftViewMode = UITextFieldViewModeAlways;
        
        [self.view addSubview:_phoneTf];
        
        _phoneTf.frame = CGRectMake(0, self.textView.bottom+5, SCREEN_WIDTH, 44);
        leftL.frame = CGRectMake(0, 0, 84, 44);
        
        lv.frame = leftL.frame;
    }
    return _phoneTf;
}

@end
