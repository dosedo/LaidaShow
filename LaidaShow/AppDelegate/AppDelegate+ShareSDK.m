//
//  AppDelegate+ShareSDK.m
//  ThreeShow
//
//  Created by hitomedia on 16/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "AppDelegate+ShareSDK.h"

#import <ShareSDKUI/SSUIEditorViewStyle.h>
#import <ShareSDK/ShareSDK.h>

@implementation AppDelegate (ShareSDK)

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions

- (BOOL)configShareSDK{
    
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
//        [platformsRegister setupQQWithAppId:@"1106518906" appkey:@"csj3CqvSWZ4BntUd"];
        [platformsRegister setupQQWithAppId:@"1106518906" appkey:@"csj3CqvSWZ4BntUd" enableUniversalLink:NO universalLink:nil];
        [platformsRegister setupWeChatWithAppId:@"wxcb66f965211e8373" appSecret:@"f1f29637e3fd4da62c9a735158cd5e17" universalLink:
         @"https://show.schengroup.com/laidashow/app/"];
        [platformsRegister setupSinaWeiboWithAppkey:@"1258928429" appSecret:@"7aaa53c525b490f7335248d3eeff76eb" redirectUrl:@"http://show.schengroup.com"];
//        [platformsRegister setupFacebookWithAppkey:/*@"169413583763244"*/@"745483082476124" appSecret:@"afc5cc0d4efe655b4c38f62baf29b201" displayName:@"莱搭e城"];
//        [platformsRegister setupTwitterWithKey:@"rOO632FNkzF4za7YBanIvGGCM" secret:@"EEBJOfPRJUlpY7it5bWcsXnF51T6iHgmIeZmWDZ86cHvf76fyR"
//        redirectUrl:@"http://www.schengroup.com"];
    }];
    
    return YES;
}

@end
