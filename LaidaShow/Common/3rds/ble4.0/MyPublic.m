//
//  MyPublic.m
//  MyBleDemo
//
//  Created by Allen Ning on 15/7/14.
//  Copyright (c) 2015年 my. All rights reserved.
//

#import "MyPublic.h"
#import "MyBleClass.h"

@implementation MyPublic



static MyBleClass *myThisMyBleClass;

+(MyBleClass *)getMyBleClass
{
    @synchronized ([MyBleClass class]){
        if (myThisMyBleClass == nil)
        {
            myThisMyBleClass = [[MyBleClass alloc] init];
        }
    }
    return myThisMyBleClass;
    
    
}

+ (MyBleClass *)shareMyBleClass{
    
    static MyBleClass *myBleClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myBleClass = [[MyBleClass alloc] init];
    });
    return myBleClass;
}
@end
