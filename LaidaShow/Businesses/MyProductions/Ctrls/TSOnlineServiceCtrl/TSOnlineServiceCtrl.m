//
//  TSOnlineServiceCtrl.m
//  ThreeShow
//
//  Created by wkun on 2019/3/14.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSOnlineServiceCtrl.h"
#import "UIViewController+Ext.h"
#import "KTextView.h"
#import "HTProgressHUD.h"
#import "TSProductDataModel.h"
#import "TSProductionDetailModel.h"

@interface TSOnlineServiceCtrl ()
@property (nonatomic, strong) KTextView *textView;
@property (nonatomic, strong) HTProgressHUD *hud;
@end

@implementation TSOnlineServiceCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelfData];
    self.navigationItem.title = NSLocalizedString(@"WorkOnlineServiceApply", nil);
    [self addRightBarItemWithTitle:NSLocalizedString(@"FeedbackCommitText", nil) action:@selector(handleRight)];
    
    _textView = [[KTextView alloc] init];
    _textView.frame = CGRectMake(0, NAVGATION_VIEW_HEIGHT, SCREEN_WIDTH, 230);
    _textView.textColor = [UIColor colorWithRgb51];
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.placeHolder = NSLocalizedString(@"WorkOnlineServiceWorkMsgHolder", nil);
    _textView.scrollEnabled = YES;
    _textView.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15);
    CGRect fr = _textView.placeHdLbl.frame;
    fr.origin.x = 20;
    fr.origin.y = 10;
    _textView.placeHdLbl.frame = fr;
    [self.view addSubview:_textView];
    
    [self addHideKeyboardGestureToView];
}

- (void)handleRight{
    NSLog(@"1111");
    
    NSString *text = self.textView.text;
    if( text.length < 5 ){
        [HTProgressHUD showError:NSLocalizedString(@"FeedbackPleaseInputContent", nil)];
    }else if( text.length > 140 ){
        [HTProgressHUD showError:NSLocalizedString(@"FeedbackPleaseContentLimitToMaxLen", nil)];
    }
    else{
        
        _hud = [HTProgressHUD showMessage:nil toView:self.view];
       [self dispatchAsyncQueueWithName:@"onlineQ" block:^{
           [self.dataProcess startOnlineServiceWithWorkId:self.detailModel.dm.ID des:text workImgUrl:self.detailModel.dm.picture completeBlock:^(NSError *err) {
               [self dispatchAsyncMainQueueWithBlock:^{
                   [_hud hide];
                   
                   if( err ){
                       [self showErrMsgWithError:err];
                   }else{
                       [HTProgressHUD showError:NSLocalizedString(@"WorkOnlineServiceSuccess", nil)];
                       
                       self.detailModel.isCanOnline = NO;
                       self.detailModel.dm.segmentStatus = @"1";
                       [self.navigationController popViewControllerAnimated:YES];
                   }
               }];
           }];
       }];
    }
}

#pragma mark - getter

@end
