//
//  TSMyWorkDetailItemList.h
//  ThreeShow
//
//  Created by wkun on 2019/3/10.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HandleItemBlock)(NSInteger idx);

/**
 横向滚动的 按钮item列表，按标题间距 计算布局. 若不能铺满屏幕，则按屏幕均分
 */
@interface TSMyWorkDetailItemList : UIView

@property (nonatomic, strong) NSArray<NSString*> *shareTitles; //分享的标题，如QQ，微博，等

- (id)initWithTitles:(NSArray*)titles imgNames:(NSArray*)imgNames handleItemBlock:(HandleItemBlock)handleItemBlock;

- (void)show;

@end

NS_ASSUME_NONNULL_END
