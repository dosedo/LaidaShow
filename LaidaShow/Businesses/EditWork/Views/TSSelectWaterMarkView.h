//
//  TSSelectWaterMarkView.h
//  ThreeShow
//
//  Created by DeepAI on 2019/1/27.
//  Copyright © 2019年 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef TSSELECTWATERMARKVIEW
#define TSSELECTWATERMARKVIEW

typedef void(^SelectWaterMarkBlock)(BOOL isAdd,UIImage *img);
typedef void(^DeleteWaterMarkBlock)(NSInteger index);

#endif

@interface TSSelectWaterMarkView : UIView

@property (nonatomic, strong) UIButton *addBtn;
/**
 集合对象可为NSString图片路径或UIImage图片实例
 */
@property (strong, nonatomic) NSArray<id> *datas;

@property (copy, nonatomic) SelectWaterMarkBlock selectBlock;

@property (nonatomic, copy) DeleteWaterMarkBlock deleteBlock;

/**
 图片的最大数量。默认为5.达到最大数量不展示添加按钮
 */
@property (nonatomic, assign) NSInteger imgMaxCount;


/**
 换底时候，使用该索引，用来判断选择了哪个图片的下标
 */
@property (nonatomic, assign) NSInteger selectedIndex;


/**
 添加新的水印图片至视图

 @param img 新的水印图片
 */
- (void)addWatermarkWithImg:(UIImage*)img;

/**
 重新加载视图数据
 */
- (void)reloadData;

@end

@interface HTScrollView : UIScrollView

@end

@interface TSSelectWaterMarkViewBtn : UIButton

@end

NS_ASSUME_NONNULL_END
