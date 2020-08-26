//
//  PPCommon.m
//  PaiPai
//
//  Created by wkun on 12/23/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import "PPCommon.h"
#import "Header.h"
#import "CheckMobileTool.h"
static NSString *userURL;

@implementation PPCommon

+(NSString*)getFullUrlWithSuffixPath:(NSString*)suffixPath{
    if( suffixPath == nil )
        return nil;
    if ([CheckMobileTool checkMobileType] == CheckMobileToolMobileTypeForeign) {        //  如果是在国外
        userURL = IP_Foreign;
    } else  {                                                                                                                             //  如果没有服务商或者在国内
        userURL = IP_China;
    }
    NSString *sp = [suffixPath substringFromIndex:1];
    return [NSString stringWithFormat:@"%@%@",userURL,sp];
}
+ (BOOL)isLoginedWithNaviCtrl:(UINavigationController *)navCtrl{
    
   userInfoEntity *userInfo = [NSUserDefaults standardUserDefaults].userInfo;
    if (userInfo.token == nil) {
        [MBProgressHUD showError:NSLocalizedString(@"Please login first", nil)];
    registerOrLoadViewController *registerVc = [[registerOrLoadViewController alloc] init];
        if (navCtrl) {
            registerVc.hidesBottomBarWhenPushed = YES;
            [navCtrl pushViewController:registerVc animated:YES];
            
        }
        return NO;
    }
    return YES;
}
@end
