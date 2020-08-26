//
//  TSCategoryModel.m
//  ThreeShow
//
//  Created by wkun on 2018/9/25.
//  Copyright © 2018年 deepai. All rights reserved.
//

#import "TSCategoryModel.h"

@implementation TSCategoryModel

+ (TSCategoryModel *)categoryWithCode:(NSString *)code name:(NSString *)name{
    TSCategoryModel *cm = [TSCategoryModel new];
    cm.categoryCode = code;
    cm.categoryName = name;
    return cm;
}

+ (NSArray<NSString *> *)categoryNames{
//    NSArray *titles = @[NSLocalizedString(@"HomeProductionCategoryRecommend", nil),
//                        NSLocalizedString(@"HomeProductionCategory3CNumberal", nil),
//                        NSLocalizedString(@"HomeProductionCategoryJewel", nil),
//                        NSLocalizedString(@"HomeProductionCategoryCurio", nil),
//                        NSLocalizedString(@"HomeProductionCategoryClothing", nil),
//                        NSLocalizedString(@"HomeProductionCategoryOther", nil)];
    NSArray *titles = @[NSLocalizedString(@"推荐", nil),
    NSLocalizedString(@"家居", nil),
    NSLocalizedString(@"鞋服", nil),
    NSLocalizedString(@"箱包", nil),
    NSLocalizedString(@"文创", nil),
    NSLocalizedString(@"动漫", nil),
    NSLocalizedString(@"古玩", nil),
    NSLocalizedString(@"珠宝", nil)];
    
    return titles;
}

+ (NSArray<NSString *> *)categoryCodes{
    //    推荐：100，3C数码：1，珠宝：2，古玩：3，服装：4，其他：99“这样
    NSArray *categorys = @[@"100",@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    return categorys;
}


+(NSArray<TSCategoryModel *> *)categoryModels{
    NSMutableArray *arr = [NSMutableArray new];
    NSArray *titles = [TSCategoryModel categoryNames];
    NSArray *codes = [TSCategoryModel categoryCodes];
    for( NSUInteger i=0; i<titles.count; i++ ){
        if( i>0 ){
            TSCategoryModel *cm = [TSCategoryModel categoryWithCode:codes[i] name:titles[i]];
            [arr addObject:cm];
        }
    }
    
    return arr;
}
@end



