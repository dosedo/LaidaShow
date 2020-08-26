//
//  TSLanguageModel.m
//  ThreeShow
//
//  Created by wkun on 2020/1/1.
//  Copyright © 2020 deepai. All rights reserved.
//

#import "TSLanguageModel.h"

@implementation TSLanguageModel

@end
@implementation TSLanguageModel(Manager)

- (void)setabc{
       //切换语言
    //    NSArray *lans = @[@"en"];  //想切换成英文版设置此种语言代码
    //    [[NSUserDefaults standardUserDefaults] setObject:lans forKey:@"AppleLanguages"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 保存 Device 的现语言 (英语 法语 ，，，)
        NSMutableArray *userDefaultLanguages = [[NSUserDefaults standardUserDefaults]
                                                objectForKey:@"AppleLanguages"];
    //zh-hans
        // 强制 成 简体中文
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"en",nil]
                                                      forKey:@"AppleLanguages"];
        //接下来就是你想要的中文了

        //用完了，转回来， 还原Device 的语言
    //     [[NSUserDefaults standardUserDefaults] setObject:userDefaultLanguages forKey:@"AppleLanguages"];

}

+ (NSArray<TSLanguageModel *> *)languageDatas{
    TSLanguageModel *chineseM = [TSLanguageModel new];
    chineseM.languageName = @"中文";
    chineseM.languageCode = @"zh-Hans";
    
//    TSLanguageModel *chineseFM = [TSLanguageModel new];
//    chineseFM.languageName = @"繁体中文";
//    chineseFM.languageCode = @"zh-Hant";
    
    TSLanguageModel *englishM = [TSLanguageModel new];
    englishM.languageName = @"English";//@"英语";
    englishM.languageCode = @"en";
    
    return @[chineseM,englishM];
}

+ (TSLanguageModel *)currLanguageModel{
    //设置选中当前语言
   NSString *currLangStr = [self currLanguageCode];
   NSArray *datas = [self languageDatas];
   for( NSInteger i=0; i<datas.count; i++ ){
       TSLanguageModel *lm = datas[i];
//       if( [lm.languageCode isEqualToString:currLangStr] ){
       if( [currLangStr containsString:lm.languageCode] ){
           return lm;
       }
   }
   return datas[0];
}

+ (NSInteger)currLanguageModelIndex{
    //设置选中当前语言
    NSString *currLangStr = [self currLanguageCode];
    NSArray *datas = [self languageDatas];
    for( NSInteger i=0; i<datas.count; i++ ){
        TSLanguageModel *lm = datas[i];
//        if( [lm.languageCode isEqualToString:currLangStr] ){
        if( [currLangStr containsString:lm.languageCode] ){
            return i;
        }
    }
    
    return 0;
}

+ (void)setLanguageWithModel:(TSLanguageModel *)model{
    if( model.languageCode ==nil ) return;
    
    NSArray *languageCodes = [NSArray arrayWithObjects:model.languageCode,nil];
    [[NSUserDefaults standardUserDefaults] setObject:languageCodes forKey:@"AppleLanguages"];
    [NSBundle setLanguage:model.languageCode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Private

//当前语言的code
+ (NSString*)currLanguageCode{
    //获取当前的语言
    NSMutableArray *userDefaultLanguages = [[NSUserDefaults standardUserDefaults]
    objectForKey:@"AppleLanguages"];
    
    if( userDefaultLanguages.count ){
        return userDefaultLanguages[0];
    }
    
    return @"zh-Hans";
}

@end

// NSBundle+language.m
#import <objc/runtime.h>

static const char _bundle = 0;

@interface BundleEx : NSBundle

@end

@implementation BundleEx

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *bundle = objc_getAssociatedObject(self, &_bundle);
    return bundle ? [bundle localizedStringForKey:key value:value table:tableName] : [super localizedStringForKey:key value:value table:tableName];
}

@end

@implementation NSBundle (Language)

+ (void)setLanguage:(NSString *)language {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [BundleEx class]);
    });
    
    objc_setAssociatedObject([NSBundle mainBundle], &_bundle, language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //Privacy 隐私协议bundle 重置
//    objc_setAssociatedObject([NSBundle mainBundle], &_bundle, language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"html"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
