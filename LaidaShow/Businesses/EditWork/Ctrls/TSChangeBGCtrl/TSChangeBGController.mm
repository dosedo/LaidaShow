//
//  ViewController.m
//  ThreeShow
//
//  Created by DeepAI on 2019/1/26.
//  Copyright © 2019年 deepai. All rights reserved.
//

#import "TSChangeBGController.h"
#import "TSProductionShowView.h"
#import "TZImagePickerController.h"
#import "UIColor+Ext.h"
#import "TSWorkModel.h"
#import "UIView+LayoutMethods.h"
#import "TSEditNaviView.h"
#import "PPFileManager.h"
#import "TSHelper.h"
#import "post_process.h"
#import "TSSelectWaterMarkView.h"
#import "TSWaterMarkCell.h"
#import "HTProgressHUD.h"
#import "UIViewController+Ext.h"
#import "WXWPhotoPicker.h"
#import "UIView+LayoutMethods.h"
#import "TSEditWorkCtrl.h"
#import "PPLocalFileManager.h"
#import "TSPathManager.h"

//定义cell的标识符
NSString static *reuseIdentifier =@"cell";
@class TSWorkModel;
@interface TSChangeBGController ()<UICollectionViewDelegate,UICollectionViewDataSource,TZImagePickerControllerDelegate>
@property (nonatomic, strong) TSProductionShowView *showView;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) TSEditNaviView *naviView;
@property (nonatomic,strong) UIView *changeBgView;
@property (nonatomic,strong) TSWaterMarkCell *cell;
//开始使用二维数组进行数据结构设计；
@property (nonatomic, strong)NSArray *defaultArray;//有defaultArray()方法；
@property (nonatomic, strong)NSMutableArray *dataArray;//有一个方法的名称也是dataArray();
@property (nonatomic, strong) TSSelectWaterMarkView *selectBgView;
@property (nonatomic, strong) HTProgressHUD *hud;

@end

@implementation  TSChangeBGController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRgb_240_239_244];
//    [self.view addSubview:self.showView];
    [self.showView addSubview:self.bottomView];
    self.navigationItem.hidesBackButton = YES;
}

-(void)resetDatas{
    self.showView.imgs = self.model.editingImgs;//self.imgs;
    [self.showView reloadData];
    [self.selectBgView reloadData];
}

#pragma mark - Propertys

- (TSSelectWaterMarkView *)selectBgView{
    if( !_selectBgView ){
        _selectBgView = [TSSelectWaterMarkView new];
        _selectBgView.imgMaxCount = 30;
        
        __weak typeof(self) wk = self;
        _selectBgView.selectBlock = ^(BOOL isAdd, UIImage * _Nonnull img) {
            
            UIImage *bgImg = nil;
            if( !isAdd ){
                NSString *changeBgImgName = [NSString stringWithFormat:@"bg_%02ld",(long)wk.selectBgView.selectedIndex];
                bgImg = [UIImage imageNamed:changeBgImgName];
            }
            [wk handleAddOrImg:isAdd img:bgImg];
        };
        
        NSMutableArray *imgs = [NSMutableArray new];
        for(  int i=0; i<20; i++ ){

            char zimu = 'a'+i;
            NSString *name = [NSString stringWithFormat:@"refoot_%c",zimu];
            [imgs addObject:[UIImage imageNamed:name]];
        }
        _selectBgView.datas = imgs;
    }
    return _selectBgView;
}

- (TSProductionShowView *)showView {
    if( !_showView ){
        _showView = [[TSProductionShowView alloc] init];
        _showView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _showView.clipsToBounds = YES;
        [self.view addSubview:_showView];
    }
    return _showView;
}

- (UIView *)bottomView {
    if( !_bottomView ){
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        CGFloat ih = self.naviView.height + 90;
        _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
        CGRect fr = self.naviView.frame;
        fr.origin.y = _bottomView.height-fr.size.height;
        self.naviView.frame = fr;
        [_bottomView addSubview:self.naviView];
        
        CGFloat ix = 20,iw = 80;ih = 30;
        CGFloat iy = 0;
        
        iw = 50;
        ix = _bottomView.width-iw-ix;
        
        ih = 20;
        
        
        iw = 60;ih  = 60;
        ix = 20;//(_bottomView.width-iw)/5;
        CGFloat topH = 45;
        
        self.changeBgView = [[UIView alloc] initWithFrame:CGRectMake(15,(self.naviView.y-topH-ih)/2 +topH/2+10, SCREEN_WIDTH-15 , ih)];
//        self.changeBgView.backgroundColor = [UIColor redColor];
        [_bottomView addSubview:self.changeBgView];
        
//        /********底部水印列表*********/
//        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
//        [layout setScrollDirection:(UICollectionViewScrollDirectionHorizontal)];
//        layout.itemSize = CGSizeMake(60, 60);
//        layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
//        layout.minimumInteritemSpacing = 2;
//        self.collectionView =[[UICollectionView alloc]initWithFrame:_changeBgView.bounds collectionViewLayout:layout];
//        self.collectionView.backgroundColor = [UIColor whiteColor];
//        [self.collectionView registerClass:[TSWaterMarkCell class] forCellWithReuseIdentifier:@"cellId"];
//        self.collectionView.delegate = self;
//        self.collectionView.dataSource = self;
//        [_changeBgView addSubview:self.collectionView];
        [self.showView addSubview:_bottomView];
        
        self.selectBgView.frame = _changeBgView.bounds;
        [self.changeBgView addSubview:self.selectBgView];
        [_selectBgView reloadData];
        
        //阴影
        _bottomView.layer.shadowOffset = CGSizeMake(0, -3);
        _bottomView.layer.shadowOpacity = 0.08;
        _bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    }
    return _bottomView;
}

- (TSEditNaviView *)naviView {
    if( !_naviView ){
        _naviView = [[TSEditNaviView alloc] initWithTitle:NSLocalizedString(@"WorkEditBottomChangeBg", nil) target:self cancleSel:@selector(handleClose) sureSel:@selector(handleSave)];
        CGFloat ih = BOTTOM_NOT_SAVE_HEIGHT+45+15;
        _naviView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
    }
    return _naviView;
}

#pragma mark - Private
- (NSString*)getClearBgPathWithFileAllPath:(NSString*)fileAllPath{
    NSString *lastPathComponent = [fileAllPath lastPathComponent];
    return [fileAllPath substringToIndex:[fileAllPath rangeOfString:lastPathComponent].location];
}

#pragma mark - 换底
- (void)startChangeImgWithOriginImgPaths:(NSString*)originImgPaths maskImgPaths:(NSString*)maskImgPath  bgImgPaths:(NSString*)bgImgPaths resultImgPaths:(NSString *)resultImgPaths count:(NSInteger)count {
    
    getMaxCC((char*)[originImgPaths UTF8String], (char*)[maskImgPath UTF8String], (char*)[resultImgPaths UTF8String],(char*)[bgImgPaths UTF8String],(int)count);
    NSLog(@"换底");
}

- (NSArray*)startChangeBgWithNewBgImg:(UIImage*)bgImg{

    if( self.model.imgPathArr.count ==0 || _model.maskImgPathArr.count==0 || _model.clearBgImgPathArr.count ==0 || bgImg ==nil ){
        NSLog(@"换底失败,路径图片为nil");
        return nil;
    }
    
    //将背景图写入临时目录
    NSString *bgImgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"changetemp"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( ![fm fileExistsAtPath:bgImgPath] ){
        [fm createDirectoryAtPath:bgImgPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filePath = [bgImgPath stringByAppendingPathComponent:@"temp.jpg"];

    BOOL ret =
    [UIImageJPEGRepresentation(bgImg, 1) writeToFile:filePath atomically:YES];
    if( ret ==NO ) return nil;
    
    TSPathManager *pm = [TSPathManager sharePathManager];
    NSString *oiPath = [pm getWorkOriginImgPathWithWorkDirName:_model.workDirName];
    //[self getClearBgPathWithFileAllPath:self.oriImgs[0]];
    
    NSString *maskPath = [pm getWorkMaskImgPathWithWorkDirName:_model.workDirName];
    //[self getClearBgPathWithFileAllPath:self.maskClearImgs[0]];
    NSString *clearPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempClearImgs"];
    clearPath = [clearPath stringByAppendingString:@"/"];
    
    if( ![fm fileExistsAtPath:clearPath] ){
        [fm createDirectoryAtPath:clearPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //[pm getWorkClearImgPathWithWorkDirName:_model.workDirName];
    //[self getClearBgPathWithFileAllPath:self.resultImgs[0]];
    
    //换底完成
    [self startChangeImgWithOriginImgPaths:oiPath maskImgPaths:maskPath bgImgPaths:filePath resultImgPaths:clearPath count:_model.imgPathArr.count];
    
    //重新加载数据
    NSMutableArray *arr = [NSMutableArray new];
    NSMutableArray *clearPaths = [NSMutableArray new];
    for( NSInteger i =0; i<_model.imgPathArr.count; i++ ){
        NSString *originImgPath = _model.imgPathArr[i];
        NSString *clearImgPath = [clearPath stringByAppendingPathComponent:originImgPath.lastPathComponent];
        
        NSData *imageData = [NSData dataWithContentsOfFile:clearImgPath options:NSDataReadingMappedIfSafe error:nil];
        UIImage *img = [UIImage imageWithData:imageData];
        
        if( img ){
            [arr addObject:img];
        }
        
        if( clearImgPath ){
            [clearPaths addObject:clearImgPath];
        }
    }
    
    //退底成功后，设置model的临时退底结果图片路径
    self.model.tempEditClearImgPaths = clearPaths;
//    self.model.editingImgs = arr;
//    self.model.editingObject = TSWorkEditObjectClearedBgWork;
    
    return arr;
}

- (void)startChangeBgWithImg:(UIImage*)img{
    _hud = [HTProgressHUD showMessage:NSLocalizedString(@"WorkChangeBgChanging", nil) toView:self.view];
    [self dispatchAsyncQueueWithName:@"clearBgQ" block:^{
        
        NSArray<UIImage*> *rets = [self startChangeBgWithNewBgImg:img];
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( rets.count ){
//                self.model.editingObject = TSWorkEditObjectClearedBgWork;
//                self.model.editingImgs = rets;
                self.showView.imgs = rets;
                [self.showView reloadData];
            }
        }];
    }];
}

#pragma mark - TouchEvents

- (void)handleSave{
    TSWorkModel *wm = self.model;//self.editWorkCtrl.model;
    if ( wm ){
//        [[PPLocalFileManager shareLocalFileManager] updateModel:wm atIndex:wm.imgDataIndex];
//        self.editWorkCtrl.imgs = self.showView.imgs;
//        [self.editWorkCtrl resetDatas];
        
        self.model.editingImgs = self.showView.imgs;
        self.model.editingObject = TSWorkEditObjectClearedBgWork;
        [self.editWorkCtrl clipImgComplete:self.showView.imgs];
        [self.editWorkCtrl resetDatas];
        
        [self handleClose];
    }
}

- (void)handleClose{
    [self.navigationController popViewControllerAnimated:YES];
}
/*
 *
 * parm fileName *image 图片文件
 * 将图片命名为XXX保存包项目沙盒类
 */

-(NSString *)saveImage:(UIImage*)image ToDocmentWithFileName:(NSString*)fileName{
    //2.保存到对应的沙盒目录中，具体代码如下：
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    // 保存文件的名称
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    //图片大小
    CGSize size = CGSizeMake(320, 480);
    
    //调用图片大小截取方法
    // UIImage* img = [ scaleToSize:image size:size];
    
    // 保存成功会返回YES
    BOOL result = [UIImagePNGRepresentation(image) writeToFile: filePath atomically:YES];
    NSLog(@"filePath -- %@",filePath);
    if (result) {
        return filePath;
    }else{
        return NULL;
    }
}


//更换图片
- (void)handleSelectPhotoBtn{
    
    [[WXWPhotoPicker sharedPhotoPicker] showImagePickerViewInCtrl:self];
    [WXWPhotoPicker sharedPhotoPicker].completion = ^(NSArray *images) {
        if( images.count )
            [self startChangeBgWithImg:images[0]];
    };
    
//    __block TZImagePickerController *tz = [[TZImagePickerController alloc] initWithMaxImagesCount:2 delegate:self];
//    __weak TZImagePickerController *weakTz = tz;
//
//    [tz setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
////        TSChangeBGController * wk = self;
//        if( photos.count )
//            [self startChangeBgWithImg:photos[0]];
//    }];
//
//    [self presentViewController:tz animated:YES completion:nil];
    
}

- (void)handleAddOrImg:(BOOL)isAdd img:(UIImage*)img{
    if( isAdd ){
        //选择退底背景
        [self handleSelectPhotoBtn];
    }else{
        [self startChangeBgWithImg:img];
    }
}

@end
