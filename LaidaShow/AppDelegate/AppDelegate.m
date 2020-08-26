//
//  AppDelegate.m
//  ThreeShow
//
//  Created by hitomedia on 02/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "AppDelegate.h"
#import "TSHelper.h"
#import "AppDelegate+ShareSDK.h"
#import "PPFileManager.h"
#import "AppDelegate+Orientation.h"
#import <UMCommon/UMCommon.h>
#import "AppDelegate+AvoidCrash.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - 崩溃日志处理
void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    //打印错误信息：
    NSLog(@"exception type : %@ \n crash reason : %@ \n call stack info : %@", name, reason, arr);
}

#pragma mark - 程序启动生命周期
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    
    //日志记录，开发时，把这注释掉，因为输出会被重定向。打包时，再加上这行即可
    //[self redirectNSlogToDocumentFolder];
    
    //崩溃日志
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    //avoidcrash 会引起莫名其妙的崩溃
//    [self configAvoidCrash];
    
    [self setupUMeng];
    
    [self configShareSDK];
    
    self.isForcePortrait = 1;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.rootViewController = [TSHelper getRootCtrl];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
    
    //解决第一次 弹出键盘卡顿问题
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"NO LONGER PROMT1"] isEqual:@"1"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"NO LONGER PROMT1"];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [TSHelper disconnectedBlueTooth];
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    
    if (self.isForcePortrait == 1){
        
        return UIInterfaceOrientationMaskPortrait;
        
    }else if(self.isForcePortrait == 2){
        
        return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskPortrait;
        
    }else if (self.isForcePortrait == 3){
        
        return UIInterfaceOrientationMaskLandscapeRight;
        
    }else{
        
        return UIInterfaceOrientationMaskPortrait;
    }
}


#pragma mark - 日志收集
- (void)redirectNSlogToDocumentFolder
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *fileName = [NSString stringWithFormat:@"LOG-%@.txt",[dateformat stringFromDate:[NSDate date]]];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{

    NSLog(@"AppDelegate中调用applicationDidReceiveMemoryWarning:");
}

#pragma mark - UMengAnalysic(友盟统计)
- (void)setupUMeng{
    [UMConfigure initWithAppkey:@"5f3b86ecb4b08b653e968345" channel:@"App Store"];
}

@end
