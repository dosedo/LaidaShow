//
//  AppDelegate+Orientation.m
//  ThreeShow
//
//  Created by cgw on 2018/9/18.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "AppDelegate+Orientation.h"

@implementation AppDelegate (Orientation)

- (void)setAppIsForcePortrait:(BOOL)isForcePortrait{
    if( isForcePortrait ){
        self.isForcePortrait = 1;
    }else{
        self.isForcePortrait = 2;
    }
    
    [self application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.window];
}



@end
