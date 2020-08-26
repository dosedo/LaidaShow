//
//  XWSheetView.h
//  ThreeShow
//
//  Created by hitomedia on 16/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef XWSHEETVIEW
#define XWSHEETVIEW

#define XWSheetViewCancleBtnTag (987654321)

#endif

@interface XWSheetView : UIView

@property (nonatomic, strong) NSArray *titles;

+ (XWSheetView*)shareSheetView;

+ (void)showWithTitles:(NSArray*)titles handleIndexBlock:(void(^)(NSInteger index))handleIndexBlock;

+ (void)showWithTitles:(NSArray*)titles cancleTitle:(NSString*)cancleTitle handleIndexBlock:(void(^)(NSInteger index))handleIndexBlock;

+ (void)showWithTitles:(NSArray*)titles handleIndexBlock:(void(^)(NSInteger index))handleIndexBlock  handleCancleBlock:(void(^)(void))handleCancleBlock;

@end
