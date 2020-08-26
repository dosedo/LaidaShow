//
//  KTimer.h
//  RRTY
//
//  Created by 端倪 on 15/5/21.
//  Copyright (c) 2015年 RRTY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KTimer : NSObject

@property (nonatomic, assign) BOOL isTiming;        //是否正在计时


-(id)initWithButton:(UIButton*)btn;

-(void)startTimer;

-(void)endTimer;

@end
