//
//  NSString+PathExtension.m
//  PaiPai
//
//  Created by wkun on 12/22/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import "NSString+PathExtension.h"

@implementation NSString(PathExtension)

-(NSString*)pathLastName{
    if( self && self.length ){
        NSString *lastPath = [self lastPathComponent];
        NSString *ext = [self pathExtension];
        NSInteger index = lastPath.length-ext.length-1;
        if( index < 0 )
            index = 0;
        NSString *name = [lastPath substringToIndex:index];
        
        return name;
    }
    return nil;
}

@end
