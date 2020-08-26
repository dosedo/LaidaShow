//
//  KSegmentView.h
//  HopeHelpClient
//
//  Created by 端倪 on 16/2/16.
//  Copyright © 2016年 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KSegmentViewDelegate;
/**
 仅仅支持两个Item的UISegmentCtrl
 
 - returns:
 */
@interface KSegmentView : UIView

@property (nonatomic, weak) id<KSegmentViewDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger seletedItemIndex;
@property (nonatomic, assign) NSInteger defalutSelctIndex;              //默认选择的Index：初始为0

-(id)initWithFrame:(CGRect)frame titles:(NSArray*)titles;

@end


@protocol KSegmentViewDelegate <NSObject>

-(void)segmentView:(KSegmentView*)segmentView didSelectItemAtIndex:(NSUInteger)index;

@end



