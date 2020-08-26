//
//  TSTakePhotoCompleteCtrl.m
//  ThreeShow
//
//  Created by wkun on 2019/6/23.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSTakePhotoCompleteCtrl.h"
#import "UILabel+Ext.h"
#import "UIViewController+Ext.h"
#import "TSEditWorkCtrl.h"
#import "TSHelper.h"
#import "TSProductionShowView.h"
#import "TSWorkModel.h"
#import "TSPublishWorkCtrl.h"

@interface TSTakePhotoCompleteCtrl ()
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) TSProductionShowView *showView;

@end

@implementation TSTakePhotoCompleteCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    self.showView.imgs = self.imgs;
    [self.showView reloadData];
}

#pragma mark - TouchEvents
- (void)handleBottomBtn:(UIButton*)btn{
    if( btn.tag == 100 ){
        
        NSLog(@"=====返回=====");
//        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }else if( btn.tag == 101 ){
        
        //编辑
        TSEditWorkCtrl *wc = [TSHelper shareEditWorkCtrl];
        wc.model = [TSWorkModel workModelForTakePhotoWithImgs:self.imgs];
        [wc resetDatas];
        wc.isNeedBackToWorkListCtrl = NO;
        [self pushViewCtrl:wc];
        
    }else if( btn.tag == 102 ){
        TSPublishWorkCtrl *wc = [TSPublishWorkCtrl new];
        wc.model = [TSWorkModel workModelForTakePhotoWithImgs:self.imgs];;
        wc.model.editingImgs = self.imgs;
        [self pushViewCtrl:wc];
    }
}

#pragma mark - Getters
- (TSProductionShowView *)showView {
    if( !_showView ){
        _showView = [[TSProductionShowView alloc] init];
        _showView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _showView.clipsToBounds = YES;
        [self.view addSubview:_showView];
        
        [self.view addSubview:self.bottomView];
    }
    return _showView;
}

- (UIView *)bottomView {
    if( !_bottomView ){
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        CGFloat baseH = 120 - 30;
        CGFloat ih = baseH + BOTTOM_NOT_SAVE_HEIGHT;
        _bottomView.frame = CGRectMake(0, (SCREEN_HEIGHT-ih), SCREEN_WIDTH, ih);
        
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithRgb221];
        line.frame = CGRectMake(0, 0, _bottomView.width, 0.5);
        [_bottomView addSubview:line];
        
//        NSArray *titles = @[NSLocalizedString(@"ClearBgBackTitle", nil),
//                            NSLocalizedString(@"ClearBgStartClearTitle", nil),
//                            NSLocalizedString(@"ClearBgEditTitle", nil)];
//        NSArray *imgs = @[@"preview_back",@"preview_remove_normal",@"preview_editor"];
        NSArray *imgs = @[@"complete_back",@"complete_editor",@"complete_next"];
        for( NSUInteger i=0; i<imgs.count; i++ ){
            UIButton *btn = [UIButton new];
            [_bottomView addSubview:btn];
//            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:imgs[i]] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(handleBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat btnH = 77,btnW = _bottomView.width/imgs.count;
            btn.frame = CGRectMake(i*btnW, (baseH-btnH)/2, btnW, btnH);
            
//            CGFloat maxImgWH = 50,titleH = 20;
//            CGSize imgSize = btn.currentImage.size;
//            CGFloat titleLen = [btn.titleLabel labelSizeWithMaxWidth:btnW].width;
//            CGFloat toLeft = (btnW-titleLen)/2;
//            btn.titleEdgeInsets = UIEdgeInsetsMake(btnH-titleH, toLeft-imgSize.width, 0, toLeft);
//
//            toLeft = (btnW-imgSize.width)/2;
//            CGFloat toTop =  (maxImgWH-imgSize.height)/2;
//            btn.imageEdgeInsets = UIEdgeInsetsMake(toTop, toLeft, btnH-(toTop+imgSize.height), toLeft-titleLen);
            btn.tag = 100+i;
        }
    }
    return _bottomView;
}

@end
