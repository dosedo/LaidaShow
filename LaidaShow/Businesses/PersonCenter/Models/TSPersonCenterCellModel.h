//
//  TSPersonCenterCellModel.h
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSPersonCenterCellModel : NSObject
@property (nonatomic, strong) NSString *leftText;
@property (nonatomic, strong) NSString *rightText;
@property (nonatomic, assign) NSInteger maxShowRightTextWordCount; //右侧文本最大展示的字数。多于该字数使用... 代替。-1 为不限制
@property (nonatomic, strong) NSString *leftNoteText; //左侧标记文本，默认为nil
@property (nonatomic, strong) NSString *leftImgName; 

@end
