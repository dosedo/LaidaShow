//
//  TSPersonCenterCellModel.m
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSPersonCenterCellModel.h"

@implementation TSPersonCenterCellModel
- (instancetype)init{
    self = [super init ];
    if( self ){
        self.maxShowRightTextWordCount = -1;
        self.leftNoteText = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    TSPersonCenterCellModel *cm = [[self class] allocWithZone:zone];
    cm.rightText = [self.rightText copy];
    cm.leftText = [self.leftText copy];
    cm.maxShowRightTextWordCount = self.maxShowRightTextWordCount;
    cm.leftNoteText = [self.leftNoteText copy];
    return cm;
}
@end
