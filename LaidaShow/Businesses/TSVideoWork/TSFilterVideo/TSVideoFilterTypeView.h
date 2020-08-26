//
//  TSVideoFilterTypeView.h
//  ThreeShow
//
//  Created by cgw on 2019/7/17.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

#ifndef TSVIDEOFILTERTYPEVIEW
#define TSVIDEOFILTERTYPEVIEW

//最多支持多少个类型，没有使用复用，所以考虑内存，限制数量
#define TSVIDEOFILTERTYPE_MAX_TYPE_COUNT 30

#endif

@class MHFilterInfo;

@interface TSVideoFilterTypeView : UIView

//是否可以选中
//@property (nonatomic, assign) BOOL isCanSelected;
//点击某item后的回调
@property (nonatomic, copy) void(^selectBlock)(NSInteger index);
@property (nonatomic, strong, readonly) NSArray<MHFilterInfo*> *filters;


- (id)initWithFrame:(CGRect)fr titles:(NSArray<NSString*>*)titles imgNames:(NSArray<NSString*>*)imgName sImgNames:(NSArray<NSString*>*)sImgNames isCanSelected:(BOOL)isCanSelected typeImgHeight:(CGFloat)typeImgHeight;


/**
 滤镜类别选择

 @param dicArr 滤镜类型数据字典集合，key为name,filterClassName,imgName,sImgName
 @return 本实例
 */
- (id)initWithFrame:(CGRect)fr filters:(NSArray<MHFilterInfo*>*)filters typeImgHeight:(CGFloat)typeImgHeight;
@end

NS_ASSUME_NONNULL_END
