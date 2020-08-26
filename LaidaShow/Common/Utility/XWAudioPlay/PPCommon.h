//
//  PPCommon.h
//  PaiPai
//
//  Created by wkun on 12/23/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PPCommon : NSObject

+(NSString*)getFullUrlWithSuffixPath:(NSString*)suffixPath;

/**是否登录,如果没有登录跳转到登录页*/
+ (BOOL)isLoginedWithNaviCtrl:(UINavigationController *)navCtrl;
@end
