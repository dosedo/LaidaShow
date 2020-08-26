//
//  CYTableViewItem.h
//  zhiying
//
//  Created by DeepAI on 2017/6/26.
//  Copyright © 2017年 DeepAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYTableViewItem : NSObject
//内容相关
@property (nonatomic,strong) UIImage* image;
@property (nonatomic,copy) NSString* text;
@property (nonatomic,copy) NSString* detailText;
@property (nonatomic,assign) UITableViewCellAccessoryType accessoryType;
@property (nonatomic,assign) Class desVc;

//高度  default is 50
@property (nonatomic,assign) CGFloat height;

- (instancetype)initWithImage:(NSString *)image text:(NSString *)text detailText:(NSString *)detailText desVC:(Class)desVc accessoryType:(UITableViewCellAccessoryType)accessoryType;
@end
