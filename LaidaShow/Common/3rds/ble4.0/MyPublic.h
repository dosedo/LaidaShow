//
//  MyPublic.h
//  MyBleDemo
//
//  Created by Allen Ning on 15/7/14.
//  Copyright (c) 2015年 my. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyBleClass;
@interface MyPublic : NSObject
//+(MyBleClass *)getMyBleClass;

/**获取我的设备*/
+ (MyBleClass *)shareMyBleClass;
@end
