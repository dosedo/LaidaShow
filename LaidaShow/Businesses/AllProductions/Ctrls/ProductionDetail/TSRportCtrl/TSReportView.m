//
//  TSReportView.m
//  ThreeShow
//
//  Created by wkun on 2019/3/10.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSReportView.h"
#import "XWSheetView.h"
#import "HTProgressHUD.h"

@implementation TSReportView

+ (void)showReportInView:(UIView *)inView{
    TSReportView *reportV = [TSReportView new];
    reportV.backgroundColor = [UIColor clearColor];
    [inView addSubview:reportV];
    
    [reportV showReport];
}

- (void)showReport{
    NSArray *names = @[NSLocalizedString(@"GarbageMarketing", nil),NSLocalizedString(@"Sensitive information", nil),NSLocalizedString(@"Pornographic pornography", nil),NSLocalizedString(@"CHEAT", nil),NSLocalizedString(@"TORT", nil),NSLocalizedString(@"OTHERS", nil)];//@"垃圾营销"@"敏感信息"@"淫秽色情"@"欺诈"@"侵权"@"其他"
    
    __weak typeof(self) weakSelf = self;
    [XWSheetView showWithTitles:names handleIndexBlock:^(NSInteger index) {
        [weakSelf handleSheetIndex:index];
    } handleCancleBlock:^{
        [self removeFromSuperview];
    }];
}

- (void)handleSheetIndex:(NSInteger)index{
    [HTProgressHUD showSuccess:NSLocalizedString(@"ReportInfoSuccess", nil)];
//    [self dismissViewControllerAnimated:NO completion:nil];
    [self removeFromSuperview];
}

@end
