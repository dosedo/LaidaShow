//
//  CYPrivacyViewController.m
//  ThreeShow
//
//  Created by DeepAI on 2018/11/15.
//  Copyright © 2018年 deepai. All rights reserved.
//

#import "CYPrivacyViewController.h"
#import <WebKit/WebKit.h>

@interface CYPrivacyViewController ()<WKUIDelegate, WKNavigationDelegate>
@property (strong, nonatomic)  WKWebView *webview;
@end

@implementation CYPrivacyViewController

- (WKWebView *)webview
{
    if (_webview == nil)
    {
        _webview = [[WKWebView alloc] init];
        _webview.frame = self.view.bounds;
        _webview.backgroundColor = [UIColor clearColor];
        
        _webview.UIDelegate = self;
        _webview.navigationDelegate = self;
        
    }
    
    return _webview;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = NSLocalizedString(@"PrivacyPolicy", nil);//@"三围秀隐私政策";
    [self.view addSubview:self.webview];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"privacy" ofType:@"html"];
    NSString *htmlstring  =[[NSString alloc] initWithContentsOfFile:filePath encoding:(NSUTF8StringEncoding) error:nil];
    
    [self.webview loadHTMLString:htmlstring baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]]];
    
}

@end
