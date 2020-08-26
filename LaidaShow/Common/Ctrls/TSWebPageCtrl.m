//
//  TSWebPageCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 05/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSWebPageCtrl.h"
#import "UIViewController+Ext.h"
//#import "NJKWebViewProgress.h"
//#import "NJKWebViewProgressView.h"
#import "UIView+LayoutMethods.h"
#import <WebKit/WebKit.h>
#import "WKWebView+Progress.h"

@interface TSWebPageCtrl ()<WKUIDelegate,WKNavigationDelegate>
{
//    NJKWebViewProgressView *_progressView;
//    NJKWebViewProgress *_progressProxy;
}

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation TSWebPageCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.extendedLayoutIncludesOpaqueBars = YES;

//    _progressProxy = [[NJKWebViewProgress alloc] init];
//    _progressProxy.webViewProxyDelegate = self;
//    _progressProxy.progressDelegate = self;
//    self.webView.delegate = _progressProxy;
    
    self.webView.hidden = NO;
    
//    CGRect navBounds = self.navigationController.navigationBar.bounds;
//    CGRect barFrame = CGRectMake(0,
//                                 navBounds.size.height - 2,
//                                 navBounds.size.width,
//                                 2);
//    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
//    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    _progressView.progressBarView.backgroundColor = [UIColor colorWithRgb_0_151_216];
//    _progressView.fadeOutDelay = 0.3;
//    [_progressView setProgress:0 animated:YES];
//    [self.navigationController.navigationBar addSubview:_progressView];
    
    [self changeBackBarItemWithAction:@selector(handleBack)];
    
    UIView *rt = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 1)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rt];
    //设置标题视图的宽度
    [self requedDatas];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
//    [_progressView setProgress:0];
}

#pragma mark - View Life Cycle

- (void)handleBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Public Methods

- (void)setPageUrl:(NSString *)pageUrl{
    _pageUrl = pageUrl;
    
}

#pragma mark - Private Methods

- (void)requedDatas{
    NSString *pageUrl = _pageUrl;
    if(pageUrl==nil || ([pageUrl isKindOfClass:[NSString class]] && pageUrl.length >3 ) == NO ){
        
        if( self.htmlString )
            [self loadHtmlStringData];
        else{
            [self loadHtmlWithFileName:self.fileName];
        }
        return;
    }
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:pageUrl]];
    [self.webView loadRequest:req];
}

- (void)loadHtmlStringData{
    
    if( [self.htmlString isKindOfClass:[NSString class]] == NO ) return;
    
    //添加Header， 解决字小的问题
    NSString *headerString = @"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>";
    self.htmlString = [headerString stringByAppendingString:self.htmlString];
//    [strongSelf.contentWebView loadHTMLString:[headerString stringByAppendingString:model.detail] baseURL:nil];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"findDetail.html"];
    if( [fm fileExistsAtPath:filePath] ){
        [fm removeItemAtPath:filePath error:nil];
    }
    
    [self.htmlString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSString *htmlString = self.htmlString;
    
    [self.webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:filePath]];
}

- (void)loadHtmlWithFileName:(NSString*)fileName{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"html"];
    NSString *htmlString =
    [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:filePath]];
}

#pragma mark Delegate

- (void)webViewDidFinishLoad:(id)webView{
    
//    [_progressView setProgress:1.0];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSString *js = @"function imgAutoFit() { \
    var imgs = document.getElementsByTagName('img'); \
    for (var i = 0; i < imgs.length; ++i) {\
    var img = imgs[i];   \
    img.style.width = %f;   \
    img.style.height = 'auto'; \
    } \
    }";
    js = [NSString stringWithFormat:js, [UIScreen mainScreen].bounds.size.width - 20];
    
//    [webView stringByEvaluatingJavaScriptFromString:js];
//    [webView stringByEvaluatingJavaScriptFromString:@"imgAutoFit()"];
}

#pragma mark - WebViewNaviDelegate

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_AVAILABLE(ios(10.0)){
    return YES;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
//    [self addUserIdToWeb:nil];
    NSLog(@"111");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //调整图片宽度为屏幕的宽度
//    NSString *js1=@"var script = document.createElement('script');"
//"script.type = 'text/javascript';"
//"script.text = \"function ResizeImages() { "
//"var myimg,oldwidth;"
//"var maxwidth = %f;"
//"for(i=0;i <document.images.length;i++){"
//"myimg = document.images[i];"
//"if(myimg.width > maxwidth){"
//"oldwidth = myimg.width;"
//"myimg.width = %f;"
//"}"
//"}"
//"}\";"
//    "document.getElementsByTagName('head')[0].appendChild(script);";
//
//    js1 = [NSString stringWithFormat:js1,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.width-20];
    
    
    NSString *js = @"function imgAutoFit() { \
    var imgs = document.getElementsByTagName('img'); \
    for (var i = 0; i < imgs.length; ++i) {\
    var img = imgs[i];   \
    img.style.width = %f;   \
    img.style.height = 'auto'; \
    } \
    }";
    js = [NSString stringWithFormat:js, [UIScreen mainScreen].bounds.size.width - 20];


    [webView evaluateJavaScript:js completionHandler:nil];

    [webView evaluateJavaScript:@"imgAutoFit();"completionHandler:nil];
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    //弹出空白提示视图
}

#pragma mark - WebViewUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"sssss");
    decisionHandler(WKNavigationResponsePolicyAllow);
}


#pragma mark - Propertys

- (WKWebView *)webView{
    if( !_webView ){
        
        [self getNaviBgView];
        
        //进行配置控制器
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        //实例化对象
        configuration.userContentController = [WKUserContentController new];

        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = preferences;

        CGFloat iy = NAVGATION_VIEW_HEIGHT;
        CGSize size = self.view.frame.size;
        CGRect frame = CGRectMake(0, iy, size.width, size.height-iy);
        _webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
        _webView.backgroundColor = [UIColor colorWithRgb_240_239_244];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
//        [_webView addProgress];
        [self.view addSubview:_webView];
    }
    return _webView;
}

@end

