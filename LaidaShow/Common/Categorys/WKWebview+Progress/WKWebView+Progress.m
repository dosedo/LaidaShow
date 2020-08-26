//
//  WKWebView+Progress.m
//  AProject
//
//  Created by cgw on 2018/11/28.
//  Copyright © 2018 cgw. All rights reserved.
//

#import "WKWebView+Progress.h"

@implementation WKWebView (Progress)

- (void)addProgress{
//    estimatedProgress
    [self addObserver:self forKeyPath:@"estimatedProgress" options:(NSKeyValueObservingOptionNew) context:nil];
    NSInteger tag = [self progressTag];
    UIProgressView *progress = [self viewWithTag:tag];
    if( progress == nil ){
        progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1)];
        progress.tintColor = [UIColor greenColor];
        progress.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [self addSubview:progress];
        progress.tag = tag;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSInteger tag = [self progressTag];
    UIProgressView *progress = [self viewWithTag:tag];
    if( progress ){
        [progress setProgress:self.estimatedProgress];
        if( self.estimatedProgress > 0.99 ){
//            [progress removeFromSuperview];
            progress.hidden = YES;
//            progress = nil;
        }
        else if( self.estimatedProgress > 0.1 ){
            if( progress.hidden ){
                progress.hidden = NO;
            }
        }
    }
}

- (void)dealloc{
    UIView *progressView = [self viewWithTag:[self progressTag]];
    if( progressView ){
        [self removeObserver:self forKeyPath:@"estimatedProgress"];
        [progressView removeFromSuperview];
        progressView = nil;
    }
}

- (NSInteger)progressTag{
    return 19990;
}

@end
