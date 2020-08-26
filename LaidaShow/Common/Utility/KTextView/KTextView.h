//
//  KTextView.h
//  RRTY
//
//  Created by 端倪 on 15/6/13.
//  Copyright (c) 2015年 RRTY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KTextViewDelegate;
@interface KTextView : UITextView

@property (nonatomic, strong) UILabel *placeHdLbl;

@property (nonatomic, strong) NSString *placeHolder;
@property (nonatomic, assign) BOOL showWordCountMsgAlert; //是否展示字数限制提示信息，默认为YES

@property (nonatomic, assign) NSUInteger wordCount;             //字数。0为不限制。默认为0
/**
 *  自动改变contentsize 的高度。默认为NO.
 */
@property (nonatomic, assign) BOOL aotoresizingContentSizeHeight;
@property (nonatomic, weak) id<KTextViewDelegate> del;

@end

@protocol KTextViewDelegate <NSObject>

@optional
-(void)kTextViewShouldEdit:(KTextView*)textView;
-(void)kTextViewDidChange:(KTextView*)textView;
-(void)kTextViewDidBeginEditing:(KTextView *)textView;
-(void)kTextViewDidEndEditing:(KTextView *)textView;
-(void)kTextViewShouldReturn:(KTextView*)textView;
- (BOOL)kTextView:(KTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)kTextViewDidChangeSelection:(KTextView*)textView;
@end
