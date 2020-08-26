//
//  HTModifyNickNameCtrl.m
//  Hitu
//
//  Created by hitomedia on 16/7/18.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import "HTModifyNickNameCtrl.h"
#import "UIViewController+Ext.h"
//#import "Constants.h"
#import "KValidate.h"
#import "KError.h"
#import "KTextView.h"
#import "NSString+Ext.h"
#import "HTProgressHUD.h"
#import "TSConstants.h"

@interface HTModifyNickNameCtrl ()<UITextFieldDelegate,KTextViewDelegate>

@property (nonatomic, strong) UITextField *nickNameTf;
@property (nonatomic, strong) UILabel *desL;                //昵称限制描述
@property (nonatomic, strong) UIView *naviBgView;
@property (nonatomic, strong) UIButton *queryBtn;
@property (nonatomic, strong) HTProgressHUD *hud;
//@property (nonatomic, assign) NSUInteger maxWordCount; //输入汉字的最大个数
//修改签名
@property (nonatomic, strong) KTextView *textView;
@property (nonatomic, assign) NSInteger restInputCount ; //剩余数量


@end

@implementation HTModifyNickNameCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelfData];
    [self setNavigationItemTitle];
    
    self.nickNameTf.text =_nickName;
    self.textView.text = _nickName;
    
    self.nickNameTf.placeholder = _placeHolder;
    self.textView.placeHolder = _placeHolder;

    [self addRightBarItemWithTitle:NSLocalizedString(@"ModifyUserNameCompleteText", nil)
                            action:@selector(hanldeSaveBtn:)];

    int length = [NSString convertToInt:_nickName];
    [self updateRestCountWithTextLength:length];
    
    self.nickNameTf.hidden = (_type == 1 || _type == 7);
    self.textView.hidden = !_nickNameTf.isHidden;
    self.desL.hidden = ([self getMaxWordCountWithType:_type]==-1);
    
    if( _type == 3 ){
        //修改手机号。
        self.nickNameTf.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    if( _textView.hidden == NO ){
        CGRect fr = self.desL.frame;
        fr.origin.y = self.textView.bottom;
        self.desL.frame = fr;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self.nickNameTf];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self.textView];
    
    
    //暂时隐藏计数
    self.desL.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if( self.textView.isHidden==NO ){
        [self.textView becomeFirstResponder];
    }
    else{
        [self.nickNameTf becomeFirstResponder];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark - Public

#pragma mark - Private

/**
 输入的最大字数，若为-1，则为不限制字数

 @param type 类型
 @return 字数的最大值，-1不限制字数
 */
- (NSInteger)getMaxWordCountWithType:(NSUInteger)type{
    return _maxWordCount;
    
//    if( type ==0 ){
//        //昵称的最大长度
//        return 10;
//    }else if (type==1 ){
//        //签名的最大长度
//        return 30;
//    }else if( _type == 2 ){
//        // @"修改姓名/花名";
//        return 5;
//    }
//    else if( _type == 3 ){
//        // @"修改手机号";
//    }
//    else if( _type == 4 ){
//        // @"修改职位";
//    }
//    else if( _type == 5 ){
//        // @"修改邮箱";
//    }
//    else if( _type == 6 ){
//        // @"修改公司";
//    }
//    else if( _type == 7 ){
//        // @"修改地址";
//    }
//
//    return -1;
}

- (void)setNavigationItemTitle{
    self.navigationItem.title = self.itemTitle;
//    if( _type ==0 ){
//        self.navigationItem.title = @"修改昵称";
//    }else if( _type == 1 ){
//        self.navigationItem.title = @"修改签名";
//    }
//    else if( _type == 2 ){
//        self.navigationItem.title = @"修改姓名/花名";
//    }
//    else if( _type == 3 ){
//        self.navigationItem.title = @"修改手机号";
//    }
//    else if( _type == 4 ){
//        self.navigationItem.title = @"修改职位";
//    }
//    else if( _type == 5 ){
//        self.navigationItem.title = @"修改邮箱";
//    }
//    else if( _type == 6 ){
//        self.navigationItem.title = @"修改公司";
//    }
//    else if( _type == 7 ){
//        self.navigationItem.title = @"修改地址";
//    }
}

- (void)updateDesTextWithRestWordCount:(NSInteger)restCount{
    _restInputCount = restCount;
    self.desL.text = [NSString stringWithFormat:@"还可以输入%d个字",(int)restCount];
}

- (void)updateRestCountWithTextLength:(NSInteger)length{
    NSInteger maxCount = [self getMaxWordCountWithType:_type];
    NSInteger restCount = maxCount-length;
    if( restCount <0 ){
        restCount = 0;
    }else if( restCount > maxCount ){
        restCount = maxCount;
    }
    
    [self updateDesTextWithRestWordCount:maxCount-length];
}

#pragma mark - RequestData
- (void)startModifyNickName{
    
    if( [NSString isEmpty:self.nickNameTf.text]){
        [HTProgressHUD showError:@"请输入昵称"];
        return;
    }
    
    NSInteger errCode = 0;
    BOOL suc = [KValidate validateUserName:self.nickNameTf.text minLen:TSConstantUserNameMinLen maxLen:TSConstantUserNameMaxLen errCode:&errCode];
    if( !suc ){
        NSString *errDes = [KError errorMsgWithCode:errCode];
        [HTProgressHUD showError:errDes];
        return;
    }
    
    //修改昵称
    HTProgressHUD *hud = [HTProgressHUD showMessage:nil toView:self.view];
    __weak typeof (self) weakSelf = self;
    NSString *text = self.nickNameTf.text;
    [self dispatchAsyncQueueWithName:@"modifyName" block:^{
//        NSError *err = nil;
//        [[HTDataProcess sharedDataProcess] modifyNickNameWithNewName:text err:&err];
        [self.dataProcess modifyUserName:text completBlock:^(NSError *err) {
            
            [weakSelf dispatchAsyncMainQueueWithBlock:^{
                [hud hide];
                if( err ){
                    [weakSelf showErrMsgWithError:err];
                }else{
                    [HTProgressHUD showSuccess:NSLocalizedString(@"ModifySuccess", nil) ];//@"修改成功"
                    [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationModifyUserNameSuccess object:nil];
                    
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }];
        }];
    }];
}

- (void)requestModifySignature{
    NSString*sign = self.textView.text;
    if( [NSString isEmpty:sign] ){
        [HTProgressHUD showError:@"请输入签名"];
        return;
    }
    
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess modifyUserSigature:sign completBlock:^(NSError *err){
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( err ){
                [self showErrMsgWithError:err];
            }else{
//                [HTProgressHUD showSuccess:@"修改成功"];
                [HTProgressHUD showSuccess:NSLocalizedString(@"ModifySuccess", nil) ];
                [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationModifyUserNameSuccess object:nil];

                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
}

- (void)modifyNameCardInfo{
    NSString*sign = self.nickNameTf.text;
    if( self.textView.hidden == NO ) {
        sign = self.textView.text;
    }
    if( [NSString isEmpty:sign] ){
        [HTProgressHUD showError:@"请输入内容"];
        return;
    }
    
    if( _type == 3 ){
        //修改手机号，则验证手机号
        NSInteger errCode = KErrorCodeDefault;
        BOOL ret =
        [KValidate validatePhoneNum:sign errCode:&errCode];
        if( !ret ){
            NSString *msg =
            [KError errorMsgWithCode:errCode];
            [HTProgressHUD showError:msg];
            return;
        }
    }
    
    if( _completeBlock ){
        _completeBlock(sign,self.type);
    }
    [self.navigationController popViewControllerAnimated:YES];
 /*暂时不用该接口修改
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess modfiyNameCardInfoWithType:_type-2 newContent:sign completeBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                [HTProgressHUD showSuccess:@"修改成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
  */
}

#pragma mark - TouchEvents

- (void)hanldeSaveBtn:(id)obj{
    
    if( _restInputCount< 0 && _maxWordCount > 0){
        [HTProgressHUD showError:@"字数超过限制"];
        return;
    }

    
    if( _type == 0 ){
        [self startModifyNickName];
    }
    else if( _type == 1 ){
        //修改签名
        [self requestModifySignature];
    }else{
        //修改名片的信息
        [self modifyNameCardInfo];
    }
    
    
    
//    else if( _type == 2 ){
//        // @"修改姓名/花名";
//    }
//    else if( _type == 3 ){
//        // @"修改手机号";
//    }
//    else if( _type == 4 ){
//        // @"修改职位";
//    }
//    else if( _type == 5 ){
//        // @"修改邮箱";
//    }
//    else if( _type == 6 ){
//        // @"修改公司";
//    }
//    else if( _type == 7 ){
//        // @"修改地址";
//    }
}

#pragma mark - TextField Extentions
- (NSRange) selectedRangeWithTextField:(UITextField*)tf
{
    UITextPosition* beginning = tf.beginningOfDocument;
    
    UITextRange* selectedRange = tf.markedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [tf offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [tf offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (NSString*)removeMarkedTextWithTextField:(UITextField*)textField{
    NSString *tfText = textField.text;
    UITextRange *tr = textField.markedTextRange;
    if( tr ){
        NSRange selectedTextRange = [self selectedRangeWithTextField:textField];
        if( selectedTextRange.length ){
            if( selectedTextRange.length == tfText.length ){
                //全部都是选中的部分
                tfText = @"";
            }
            else
                if( selectedTextRange.location ==0 && selectedTextRange.length < tfText.length ){
                    //输入的部分 在字符串的开始位置.则截取后半部分
                    tfText = [tfText substringFromIndex:selectedTextRange.length];
                }else if( selectedTextRange.location+selectedTextRange.length == tfText.length ){
                    //输入的部分 在字符串的后部分，则截取前半部分
                    tfText = [tfText substringToIndex:selectedTextRange.location];
                }else{
                    ////输入的部分 在字符串的中间。则截取两端
                    NSString* s1 = [tfText substringFromIndex:selectedTextRange.length];
                    NSString* s2 = [tfText substringToIndex:selectedTextRange.location];
                    tfText = [NSString stringWithFormat:@"%@%@",s2,s1];
                }
        }
    }
    
    return tfText;
}

#pragma mark - UITextfield Field

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if( _type == 3 ){
        //修改手机号
        if(textField.text.length==11 && [string isEqualToString:@""]==NO )
            return NO;
        return YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    [self updateRestCountWithTextLength:0];
    return YES;
}

- (void)textDidChange:(NSNotification*)noti{
    UITextField *tf = noti.object;

    NSString *tfText = tf.text;
    tfText = [self removeMarkedTextWithTextField:tf];
    int length = [NSString convertToInt:tfText];

    [self updateRestCountWithTextLength:length];
}

#pragma mark - textviewdelegate

- (BOOL)kTextView:(KTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string{
    
    return YES;
}

#pragma mark - Propertys
- (UITextField *)nickNameTf{
    if( !_nickNameTf ){
        _nickNameTf = [[UITextField alloc] init];
        CGFloat ix = 0;
        CGFloat iw = SCREEN_WIDTH-2*ix;
        _nickNameTf.frame = CGRectMake(ix, NAVGATION_VIEW_HEIGHT, iw, 44);
        _nickNameTf.backgroundColor = [UIColor whiteColor];
        _nickNameTf.textColor = [UIColor colorWithRgb51];
        _nickNameTf.font = [UIFont fontNormal];
        _nickNameTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
        _nickNameTf.leftView = view;
        _nickNameTf.leftViewMode = UITextFieldViewModeAlways;
        _nickNameTf.delegate = self;
        _nickNameTf.placeholder = @"请输入";
        [self.view addSubview:_nickNameTf];
    }
    return _nickNameTf;
}

- (UILabel *)desL{
    if( !_desL){
        _desL = [[UILabel alloc] init];
        _desL.frame = CGRectMake(self.nickNameTf.x+15, self.nickNameTf.bottom, self.nickNameTf.width, 24);
        _desL.textAlignment = NSTextAlignmentLeft;
        _desL.font = [UIFont systemFontOfSize:14];
        _desL.textColor = [UIColor colorWithRgb102];
        
        [self.view addSubview:_desL];
    }
    return _desL;
}

//- (UIView*)naviBgView {
//    if( !_naviBgView ){
//        _naviBgView = [self addNaviBgView];
//    }
//    return _naviBgView;
//}

- (KTextView *)textView {
    if( !_textView ){
        _textView = [[KTextView alloc] init];
        _textView.frame = CGRectMake(0, NAVGATION_VIEW_HEIGHT, SCREEN_WIDTH, 100);
        _textView.placeHolder = @"请输入";
        _textView.textColor = [UIColor colorWithRgb51];
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.del = self;
        _textView.placeHdLbl.textColor = [UIColor colorWithRgb102];
        _textView.scrollEnabled = YES;
        
        UIEdgeInsets contentInset = UIEdgeInsetsMake(15, 15, 15, 15);
        _textView.textContainerInset = contentInset;//UIEdgeInsetsMake(15, 15, 15, 15);
        CGRect fr = _textView.placeHdLbl.frame;
        fr.origin = CGPointMake(contentInset.left+5, contentInset.top);
        fr.size.width = _textView.width-contentInset.left-contentInset.right-3;
        _textView.placeHdLbl.frame = fr;

        [self.view addSubview:_textView];
    }
    return _textView;
}

@end
