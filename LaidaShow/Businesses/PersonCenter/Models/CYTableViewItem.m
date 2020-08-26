//
//  CYTableViewItem.m
//  zhiying
//
//  Created by DeepAI on 2017/6/26.
//  Copyright © 2017年 DeepAI. All rights reserved.
//

#import "CYTableViewItem.h"

@implementation CYTableViewItem
- (instancetype)initWithImage:(NSString *)image text:(NSString *)text detailText:(NSString *)detailText desVC:(Class)desVc accessoryType:(UITableViewCellAccessoryType)accessoryType{
    if (self = [super init]) {
        self.image = [UIImage imageNamed:image];
        self.text = text;
        self.detailText = detailText;
        self.desVc = desVc;
        self.accessoryType = accessoryType;
        self.height = 50;
    }
    return self;
}
@end
