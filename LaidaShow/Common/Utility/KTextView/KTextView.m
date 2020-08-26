//
//  KTextView.m
//  RRTY
//
//  Created by 端倪 on 15/6/13.
//  Copyright (c) 2015年 RRTY. All rights reserved.
//

#import "KTextView.h"

@interface KTextView()<UITextViewDelegate>



@end

@implementation KTextView

//-(id)init
//{
//    self = [super init];
//    if( self )
//    {
//        [self initData];
//    }
//    return self;
//}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        [self initData];
    }
    return self;
}

-(void)initData{
    self.scrollEnabled = NO;
    self.font = [UIFont systemFontOfSize:14.0];
    self.delegate = self;
    self.textAlignment = NSTextAlignmentLeft;
    self.showsVerticalScrollIndicator = YES;
    self.aotoresizingContentSizeHeight = NO;
    self.showWordCountMsgAlert = YES;
//    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

-(void)layoutSubviews{
    CGRect fr = self.placeHdLbl.frame;
    fr.size.width = self.frame.size.width-2*fr.origin.x;
    //计算高度
    CGSize size = CGSizeMake(fr.size.width, MAXFLOAT);
    CGFloat ih = [self.placeHdLbl.text boundingRectWithSize:size
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:_placeHdLbl.font} context:nil].size.height;
    fr.size.height = ih;
    self.placeHdLbl.frame = fr;
}

-(void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    if( placeHolder && ![placeHolder isEqualToString:@""] && [self.text isEqualToString:@""] )
    {
        self.placeHdLbl.text = placeHolder;
    }
    else{
        self.placeHdLbl.text = @"请输入...";
    }
    
    if( self.text.length > 0 ){
        self.placeHdLbl.text = @"";
    }
}

-(void)setDel:(id<KTextViewDelegate>)del
{
    _del = del;
}

-(void)setText:(NSString *)text
{
    super.text = text;
    if( text && ![text isEqualToString:@""] )
    {
        self.placeHdLbl.text = @"";
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText{
    [super setAttributedText:attributedText];
    NSAttributedString *text =  attributedText;
    if( text && text.length>0 )
    {
        self.placeHdLbl.text = @"";
    }else{
        self.placeHdLbl.text = _placeHolder;
    }
}

- (void)setFont:(UIFont *)font{
    [super setFont:font];
    self.placeHdLbl.font = font;
}

- (void)setContentInset:(UIEdgeInsets)contentInset{
    [super setContentInset:contentInset];
    CGRect fr = self.placeHdLbl.frame;
    fr.origin = CGPointMake(contentInset.left, contentInset.top);
    fr.size.width = self.frame.size.width-contentInset.left-contentInset.right;
    self.placeHdLbl.frame = fr;
}

-(UILabel*)placeHdLbl
{
    if( !_placeHdLbl )
    {
        _placeHdLbl = [[UILabel alloc] init];
        CGSize size = self.frame.size;
        CGFloat ih = 20;
        if( size.height < 20 )
            ih = size.height;
        
        CGSize size1 = CGSizeMake(size.width, 2000);
        UIEdgeInsets insets = self.textContainerInset;
        CGRect labelRect =  [ @"Test" boundingRectWithSize:size1 options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil];
        ih = labelRect.size.height;
        
//        _placeHdLbl.userInteractionEnabled = NO;
        _placeHdLbl.font = self.font;
        CGFloat iw = 0;
        if( self.frame.size.width > 0 ){
            iw = self.frame.size.width-insets.left-insets.right;
        }
        _placeHdLbl.frame = CGRectMake(insets.left, insets.top, iw, ih);
        _placeHdLbl.textColor = [UIColor colorWithRed:198/255.0 green:198/255.0 blue:204/255.0 alpha:1.0];
        _placeHdLbl.textAlignment = self.textAlignment;
        _placeHdLbl.numberOfLines = 0;
        [self addSubview:self.placeHdLbl];
    }
    return _placeHdLbl;
}

//-(void)settingNotScroll
//{
//    CGSize size = self.frame.size;
//    CGFloat ih = 20;
//    if( size.height < 20 )
//        ih = size.height;
//
//    CGSize size1 = CGSizeMake(size.width, MAXFLOAT);
//
//    CGRect labelRect =  [ self.text boundingRectWithSize:size1 options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil];
//    ih = labelRect.size.height;
//
//    if( self.contentSize.height <= self.frame.size.height )
//    {
//        [self setUserInteractionEnabled:NO];
//    }
//}

//- (void)auotoResizingContentHeight{
//    if( self.aotoresizingContentSizeHeight ){
//        NSString *text = self.text;
//        CGSize size  = [text  boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT)
//                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                       attributes:@{NSFontAttributeName:self.font}
//                                          context:nil].size;
//        self.contentSize = size;
//    }
//}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if( [text isEqualToString:@"\n"] ){//判断输入的字是否是回车，即按下return
        //        [textView resignFirstResponder];
        if( _del && [_del respondsToSelector:@selector(kTextViewShouldReturn:)] ){
            [_del kTextViewShouldReturn:self];
        }
        return NO;
    }
    
    if( _del && [_del respondsToSelector:@selector(kTextView:shouldChangeTextInRange:replacementText:)] ){
        return [_del kTextView:self shouldChangeTextInRange:range replacementText:text];
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ( self.del && [self.del respondsToSelector:@selector(kTextViewShouldEdit:)]) {
        [self.del kTextViewShouldEdit:self];
    }
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
     if( self.del && [self.del respondsToSelector:@selector(kTextViewDidBeginEditing:)] )
     {
         [self.del kTextViewDidBeginEditing:self];
     }
    
    if( self.text==nil || self.text.length == 0 )
        self.placeHdLbl.text = self.placeHolder;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
     if( self.del && [self.del respondsToSelector:@selector(kTextViewDidEndEditing:)] )
     {
         [self.del kTextViewDidEndEditing:self];
     }
}

-(void)textViewDidChange:(UITextView *)textView
{
    if( ![textView.text isEqualToString:@""] )
    {
        self.placeHdLbl.text = @"";
    }
    else
        self.placeHdLbl.text = self.placeHolder;
    
    NSUInteger count = [textView.text length];
    if( self.wordCount > 0 && count > self.wordCount )
    {
        if( !self.showWordCountMsgAlert ){
            return;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"字符个数已达上限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        textView.text = [textView.text substringToIndex:self.wordCount];
        
        return;
    }
    
    if( self.del && [self.del respondsToSelector:@selector(kTextViewDidChange:)] )
    {
        [self.del kTextViewDidChange:self];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
//    NSLog(@"textViewDidChangeSelection=%@",textView.text);
    if( _del && [_del respondsToSelector:@selector(kTextViewDidChangeSelection:)]){
        [_del kTextViewDidChangeSelection:self];
    }
}

@end
