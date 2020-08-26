//
//  HTModifyNickNameCtrl.h
//  Hitu
//
//  Created by hitomedia on 16/7/18.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "HTViewCtrl.h"
@interface HTModifyNickNameCtrl : UIViewController

@property (nonatomic, strong) NSString *itemTitle;
@property (nonatomic ,strong) NSString *nickName;  //当前展示的文本
@property (nonatomic, strong) NSString *placeHolder; 
@property (nonatomic, assign) NSInteger maxWordCount; //-1 为不限制字数

//0 修改昵称 1修改个性签名 2修改名片姓名 3修改名片手机号 4修改名片职位 5修改名片邮箱 6修改名片公司 7修改名片地址
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, copy) void(^completeBlock)(NSString *text,NSUInteger type);

@end
