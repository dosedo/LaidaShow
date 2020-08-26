//
//  TSWebPageCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 05/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSWebPageCtrl : UIViewController

/**
 http url链接
 */
@property (nonatomic, strong) NSString *pageUrl;

/**
 html的文本
 */
@property (nonatomic, strong) NSString *htmlString;

//html文件的名字。针对于在项目内容的html文件
@property (nonatomic, strong) NSString *fileName;

@end
