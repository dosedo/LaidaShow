//
//  TSEditAddImgCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSEditAddImgCtrl.h"
#import "UIView+LayoutMethods.h"
#import "UIViewController+Ext.h"
#import "TSEditNaviView.h"
#import "UIColor+Ext.h"
#import "HTProgressHUD.h"
#import "TSGestureImageView.h"
#import "UIImage+Extras.h"
#import "WXWPhotoPicker.h"
#import "HTProgressHUD.h"
#import "CYEditStickerView.h"
#import "TSHttpRequest.h"
#import "TSDataProcess.h"
#import "TSUserModel.h"
#import "TZImagePickerController.h"
#import "TSSelectWaterMarkView.h"
#import "TSWaterMarkCell.h"
#import "TSWatermarkImgModel.h"
#import "SBPlayer.h"
#import "DSVideoEditManager.h"
#import <AVFoundation/AVFoundation.h>

#define Start_X          10.0f      // 第一个按钮的X坐标
#define Start_Y          50.0f     // 第一个按钮的Y坐标
#define Width_Space      5.0f      // 2个按钮之间的横间距
#define Height_Space     20.0f     // 竖间距
#define Button_Height   122.0f    // 高
#define Button_Width    75.0f    // 宽
#define COL_NUM 5
//定义cell的标识符

NSString static *reuseIdentifier =@"cell";

@interface TSEditAddImgCtrl ()<TZImagePickerControllerDelegate>

@property (nonatomic, strong) UIImage *selectImg; //相册选择的img

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) TSEditNaviView *naviView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UISlider *whiteBalanceSlider;  //透明度
@property (nonatomic, strong) dispatch_queue_t alphaImgQ;
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) UIImage *modifyResultImg; //添加的贴图调整（透明度或缩放旋转）之后生成的图片
@property (nonatomic, strong) UIButton *changeImgBtn;

@property (nonatomic,strong) CYEditStickerView* stickerView;  //贴图视图

@property (nonatomic, strong) UIImage *pastedImage;

//@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) UIView *waterBgView;

@property (nonatomic,strong) UIImageView *materImageView;


@property (nonatomic,strong) UIButton *bottomWaterBtn;
//定义本地中的数组用于存放获取后的数据。

@property (nonatomic,strong)NSArray *getDataArray;


////开始使用二维数组进行数据结构设计；
//@property (nonatomic, strong)NSArray *defaultArray;//有defaultArray()方法；
//@property (nonatomic, strong)NSMutableArray *dataArray;//有一个方法的名称也是dataArray();
@property (nonatomic, strong) TSSelectWaterMarkView *selectWaterMarkView;
@property (nonatomic, strong) NSArray<TSWatermarkImgModel*> *waterMarkModels;

//视频水印部分
@property (nonatomic, strong) SBPlayer *player;

@end

@implementation TSEditAddImgCtrl{
    UIImageView *_createImgViewBgView;
    UIImageView *_createImgViewAddView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRgb_240_239_244];
//    self.imgView.image = _imgs[0];
    self.index = 0;

    self.alphaImgQ = dispatch_queue_create("alphaImgQ", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    
    [self resetDatas];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.player pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetDatas{
    
    //判断是视频作品还是图片作品
    if( self.videoUrl ){
        self.imgView.hidden = YES;
        self.player.hidden = NO;
        self.bottomView.hidden = NO;
        [self.view sendSubviewToBack:self.player];
        
        [self.player resetLocalVideoUrl:self.videoUrl];
        
        [self setPlayerFrame];
        
        [self.view bringSubviewToFront:self.bottomView];
    }else{
        self.imgView.hidden = NO;
        self.player.hidden = YES;
    }
    
    if( _imgs && _imgs.count )
        [self updateNewBgImg:_imgs[0]];
    
    UILabel *lbl = (UILabel*)[self.bottomView viewWithTag:100];
    lbl.text = @"100";// [NSString stringWithFormat:@"%d%%", (int)slider.value];
    self.whiteBalanceSlider.enabled = YES;
    self.whiteBalanceSlider.value = 100;
    
    //从相册获取图片，添加到addImgView上
    _selectImg = [self getLocalSelectImgWithImg:_selectImg];

    [self.view bringSubviewToFront:self.bottomView];
    
    [_selectWaterMarkView removeFromSuperview];
    _selectWaterMarkView = nil;
    [self.selectWaterMarkView reloadData];
    
    [self requestWatermarkImgs];
    
    [_stickerView removeFromSuperview];
    _stickerView = nil;
}

#pragma mark - Private

- (void)setSelectImg:(UIImage *)selectImg{
    _selectImg = selectImg;
    
    if (self.stickerView) {
        [self.stickerView removeFromSuperview];
        self.stickerView = nil;
    }
    
    self.stickerView = [[CYEditStickerView alloc] initWithBgView:/*self.imgView*/self.view image:selectImg withCenterPoint:/*self.imgView.center*/CGPointMake(SCREEN_WIDTH/2, self.imgView.center.y)];
    self.stickerView.image = selectImg;
    
    [self.view bringSubviewToFront:self.bottomView];
}

- (UISlider*)getSlider{
    UISlider *sli = [[UISlider alloc] init];
    sli.value = 50;
    sli.maximumValue = 100;
    sli.minimumTrackTintColor = [UIColor colorWithRgb_0_151_216];
    sli.thumbTintColor = [UIColor colorWithRgb_0_151_216];
    [sli addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateNormal];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateHighlighted];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateSelected];
    return sli;
}

- (UILabel*)getLabelWithTextAlignt:(NSTextAlignment)align text:(NSString*)text inView:(UIView*)inView{
    UILabel *lbl = [UILabel new];
    [inView addSubview:lbl];
    
    lbl.textAlignment = align;
    lbl.text = text;
    lbl.textColor = [UIColor colorWithRgb51];
    lbl.font = [UIFont systemFontOfSize:14];
    
    return lbl;
}

//修改图片透明度
- (void)modifyimg{
    
    _changeImgBtn.enabled = NO;
    self.naviView.sureBtn.enabled = NO;
    CGFloat alpha = self.whiteBalanceSlider.value/100;
    dispatch_async(self.alphaImgQ, ^{
        
        UIImage *img = _selectImg;
        if( [img isKindOfClass:[UIImage class]] ){
            UIImage *newImg = [UIImage imageByApplyingAlpha:alpha image:img];
            
            [self dispatchAsyncMainQueueWithBlock:^{
//                self.addImgView.imgView.image = newImg;
                self.stickerView.contentView.image = newImg;
                self.stickerView.image = newImg;
                self.naviView.sureBtn.enabled = YES;
                _changeImgBtn.enabled = YES;
            }];
        }
    });
}
    
- (UIImage*)getLocalResultImg{
    if( _modifyResultImg ){
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"editAddImg99999.jpg"];
        NSLog(@"保存路径 -- %@",path);
        NSFileManager *fm = [NSFileManager defaultManager];
        if( [fm fileExistsAtPath:path] ){
            [fm removeItemAtPath:path error:nil];
        }
        
        @autoreleasepool{
            [UIImagePNGRepresentation(_modifyResultImg) writeToFile:path atomically:YES];
            NSLog(@"保存路径 -- %@",path);
            _modifyResultImg = nil;
        }
        
        NSData *imageData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
        _modifyResultImg = [UIImage imageWithData:imageData];
        imageData = nil;
        
        return _modifyResultImg;
    }
    
    return nil;
}

- (NSArray*)composeAllImgs{
    
    NSMutableArray *arr = [NSMutableArray new];
    NSUInteger i=0;
    for( UIImage *img in _imgs ){
        
        @autoreleasepool{
            UIImage *newImg = [self composeNewImgWithOriImg:img];
            newImg = [self regetModifyImg:newImg atIndex:i];
            if( newImg ){
                //保存至
                [arr addObject:newImg];
            }
            
            i++;
        }
    }
    
    _modifyResultImg = nil;
    return arr;
}
    
- (UIImage*)composeNewImgWithOriImg:(UIImage*)originImg{
    
    @autoreleasepool{
    
        UIImage *newImg = _modifyResultImg;
        UIImage* img = originImg;//self.bgImgView.image;
        CGSize size = img.size;
        UIGraphicsBeginImageContext(size);
        [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
        if( newImg ){
            
            CGRect rect = [self.stickerView convertRect:self.stickerView.contentView.frame toView:self.imgView];
            
            CGSize originalSize = img.size;
            CGSize newSize = self.imgView.frame.size;
            CGFloat ratio =originalSize.width/newSize.width;//图片的显示尺寸和绘制到图形上下文中的实际尺寸的比例
            
            rect.origin.x =rect.origin.x*ratio;
            rect.origin.y =rect.origin.y*ratio;
            rect.size.width = rect.size.width*ratio;
            rect.size.height = rect.size.height*ratio;
            
            [newImg drawInRect:rect];//[self getDrawAddImgRect]];
        }
        UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return togetherImage;
    }
    
    return nil;
}

- (CGRect)getDrawAddImgRect{
    CGRect rect = [self.view convertRect:self.stickerView.contentView.frame toView:self.imgView];
    
//    CGFloat scale = self.imgView.image.size.width/self.imgView.width;
//    rect.origin.x *= scale;
//    rect.origin.y *= scale;
//    rect.size.width  *= scale;
//    rect.size.height *= scale;
    
    return rect;
}
    
    
- (UIImage*)regetModifyImg:(UIImage*)myImage atIndex:(NSUInteger)idx{
    
    @autoreleasepool{
    if( myImage ){
        NSString *tempImgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"editAddImgTemp%ld.jpg",idx]];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isExist = [fm fileExistsAtPath:tempImgPath];
        if( isExist ){
            [fm removeItemAtPath:tempImgPath error:nil];
        }
        
        //        NSData *data = [myImage initWithData:nil];
        [UIImageJPEGRepresentation(myImage, 1) writeToFile:tempImgPath atomically:YES];
        
        myImage = nil;
        
        NSData *imageData = [NSData dataWithContentsOfFile:tempImgPath options:NSDataReadingMappedIfSafe error:nil];
        UIImage * img = [UIImage imageWithData:imageData];
        
        return img;
    }
    }
    return nil;
}

- (UIImage*)convertImg:(UIImage*)image1 img2:(UIImage*)image2 size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, size.height)];
    [image2 drawInRect:CGRectMake(image1.size.width, 0, image2.size.width, size.height)];
    UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    return togetherImage;
}
    
- (void)updateNewBgImg:(UIImage*)img{
    if( img ==nil ) return;
    
    self.imgView.image = img;
    CGRect fr = CGRectMake(0, 0, SCREEN_WIDTH, self.bottomView.y);
    self.imgView.frame = fr;
    CGSize size = _imgView.size;
    if( size.width/img.size.width > size.height/img.size.height ){
        size.width = size.height*(img.size.width/img.size.height);
        fr.origin.x = (self.imgView.width-size.width)/2;
    }else{
        size.height = size.width *(img.size.height/img.size.width);
        fr.origin.y = (self.imgView.height-size.height)/2;
    }
    fr.size = size;
    self.imgView.frame = fr;
}

- (UIImage*)getLocalSelectImgWithImg:(UIImage*)img{
    if( img ){
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"editAddImgForSelectedImg88888.jpg"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if( [fm fileExistsAtPath:path] ){
            [fm removeItemAtPath:path error:nil];
        }
        
        [UIImagePNGRepresentation(img) writeToFile:path atomically:YES];
        
        img = nil;
        NSData *imageData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
        UIImage* newimg = [UIImage imageWithData:imageData];
        
        return newimg;
    }
    
    return nil;
}

- (void)deleteWatermarkSuccessAtIndex:(NSInteger)idx{
    NSMutableArray *newModels = nil;
    NSMutableArray *newUrls = nil;
    //至少有两个数据时，需要清除已有的数据，否则直接清空
    if( self.waterMarkModels.count >1 ){
        //确保数据一致性
        if( self.waterMarkModels.count == self.selectWaterMarkView.datas.count ){
            if( self.waterMarkModels.count > idx ){
                newModels = [NSMutableArray arrayWithArray:self.waterMarkModels];
                newUrls = [NSMutableArray arrayWithArray:self.selectWaterMarkView.datas];
                
                [newModels removeObjectAtIndex:idx];
                [newUrls removeObjectAtIndex:idx];
            }
        }
    }
    
    self.waterMarkModels = newModels;
    self.selectWaterMarkView.datas = newUrls;
    [self.selectWaterMarkView reloadData];
}

- (void)addWatermarkSuccessWithImg:(UIImage*)img{
    [HTProgressHUD showSuccess:NSLocalizedString(@"水印上传完成", nil)];
    
    self.selectImg = [self getLocalSelectImgWithImg:img];
//    [self.addImgView resetViews];
    self.whiteBalanceSlider.value = 100;
    [self sliderValueChanged:self.whiteBalanceSlider];
    [self.selectWaterMarkView addWatermarkWithImg:img];
    
    //更新水印数据
    TSWatermarkImgModel *wm = [TSWatermarkImgModel new];
    wm.url = nil;
#warning 水印id本应该在上传水印完成后，从服务器返回，但现在服务器没有返回，所以置空
    wm.watermarkImgId = nil;
    NSMutableArray *wmDatas = [NSMutableArray new];
    [wmDatas addObject:wm];
    if( self.waterMarkModels.count ){
        [wmDatas addObjectsFromArray:self.waterMarkModels];
    }
    _waterMarkModels = wmDatas;
}

- (void)showConfirmAddWatermarkAlertWithCompleteBlock:(void(^)(void))completeBlock{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"确定上传水印？", nil) message:NSLocalizedString(@"水印上传后会变为默认水印需要自己切换选择，确定上传吗？", nil) preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:(UIAlertActionStyleCancel) handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ShareOK",nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if( completeBlock ){
            completeBlock();
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 视频添加水印
- (void)addVideoWaterMark{
 
    //视频水印
    UIImage *img = [self.stickerView getChangedImage];
    _hud = [HTProgressHUD showMessage:NSLocalizedString(@"制作中...", nil) toView:self.view];
    [[DSVideoEditManager shareVideoEditManager] addWaterMarkWithImg:img frame:[self getWaterMarkInVideoFrame] inputVideoPath:self.videoUrl.path complteBlock:^(NSString * _Nonnull outputPath) {
        [_hud hide];
        if( outputPath ==nil ){
            [HTProgressHUD showError:NSLocalizedString(@"添加水印失败", nil)];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
            if( _completeBlock ){
                _completeBlock(([NSURL fileURLWithPath:outputPath]));
            }
        }
    }];
}

//按视频比例缩放播放器的frame
- (void)setPlayerFrame{
    CGRect fr = CGRectMake(0, 0, SCREEN_WIDTH, self.bottomView.y);
    CGSize size = fr.size;
    
    AVAssetTrack *videoAssetTrack = [[self.player.anAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize naturalSize = videoAssetTrack.naturalSize;
    size.width = (naturalSize.width/naturalSize.height)*size.height;
    fr.size = size;
    fr.origin.x = (SCREEN_WIDTH-size.width)/2;
    self.player.frame = fr;
}

- (CGRect)getWaterMarkInVideoFrame{
    CGRect rect = [self.stickerView convertRect:self.stickerView.contentView.frame toView:self.player];
    
    AVAssetTrack *videoAssetTrack = [[self.player.anAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize naturalSize = videoAssetTrack.naturalSize;
    
    CGFloat scale = naturalSize.width/self.player.width;
    rect.origin.x *= scale;
    rect.origin.y *= scale;
    rect.size.width  *= scale;
    rect.size.height *= scale;
    
    rect.origin.y = (naturalSize.height-rect.size.height-rect.origin.y);
    
    return rect;
}

#pragma mark - HttpRequest
- (void)requestWatermarkImgs{
    [self dispatchAsyncQueueWithName:@"loadWatermarkImgs" block:^{
        [self.dataProcess waterMarkImgsWithCompleteBlock:^(NSArray *urls, NSArray*models, NSError *err) {
            [self dispatchAsyncMainQueueWithBlock:^{
                if( err == nil ){
                    _waterMarkModels = models;
                    self.selectWaterMarkView.datas = urls;
                    [self.selectWaterMarkView reloadData];
                }
            }];
        }];
    }];
}

- (void)requestDeleteWatermarkImgWithIndex:(NSInteger)idx{
    if( !(idx >=0 && idx <= self.waterMarkModels.count) ) return;
    
    TSWatermarkImgModel *im = self.waterMarkModels[idx];
    if( im.watermarkImgId == nil ) return;
    
    [self dispatchAsyncQueueWithName:@"deleteWatermarkImgs" block:^{
        [self.dataProcess deleteWatermarkImgWithId:im.watermarkImgId completeBlock:^(NSError *err){
            [self dispatchAsyncMainQueueWithBlock:^{
                if( err == nil ){
                    [self deleteWatermarkSuccessAtIndex:idx];
                }else{
                    [self showErrMsgWithError:err];
                }
            }];
        }];
    }];
}

- (void)requestAddWatermarkImgWithImage:(UIImage*)img{
    
    [self dispatchAsyncQueueWithName:@"addWatermarkImgs" block:^{
        [self.dataProcess addWatermarkWithImg:img completeBlock:^(id waterModel, NSError *err) {
            //上传完成后，拉取一遍数据，为了获取刚刚上传的图片的水印ID
            if( err == nil ){
                [self requestWatermarkImgs];
            }
            [self dispatchAsyncMainQueueWithBlock:^{
                if( err == nil ){
                    [self addWatermarkSuccessWithImg:img];
                    
                    
                }else{
                    [self showErrMsgWithError:err];
                }
            }];
        }];
    }];
}


#pragma mark - TouchEvents
- (void)handleClose{
    NSLog(@"%@",[_stickerView superview]);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSave{
    
    //不存在贴图，点击保存，则直接返回
    if( [_stickerView superview] == nil ){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    //若是视频，则去给视频添加水印
    if( self.videoUrl ){
        
        [self addVideoWaterMark];
        return;
    }

    if( _createImgViewAddView == nil ){
        _createImgViewAddView = [UIImageView new];
    }
    
    if( _createImgViewBgView == nil ){
        _createImgViewBgView = [UIImageView new];
    }
    
    _modifyResultImg = nil;
    _hud = [HTProgressHUD showMessage:NSLocalizedString(@"WorkEditSaveingImgs", nil) toView:self.view];
    
    [self getResultImgWithCompleteBlock:^{
        
        [self dispatchAsyncQueueWithName:@"saveAllImgQ" block:^{
            
            NSArray *arr = [self composeAllImgs];
            
            [self dispatchAsyncMainQueueWithBlock:^{
                [_hud hide];
                
                if( arr.count ){
                    if( self.completeBlock ){
                        self.completeBlock(arr);
                    }
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }];
}
    
- (void)getResultImgWithCompleteBlock:(void(^)(void))completeBlock{
    [self dispatchAsyncQueueWithName:@"resultImgq" block:^{
        _modifyResultImg = nil;
        @autoreleasepool{
            _modifyResultImg = [self.stickerView getChangedImage];
            
            UIImageWriteToSavedPhotosAlbum(_modifyResultImg, nil, nil, nil);
        }

        [self dispatchAsyncMainQueueWithBlock:^{
            if( completeBlock ){
                completeBlock();
            }
        }];
    }];
}

//更换图片
- (void)handleResetBtn{
   __block TZImagePickerController *tz = [[TZImagePickerController alloc] initWithMaxImagesCount:2 delegate:self];
//    __weak TZImagePickerController *weakTz = tz;

    __weak typeof(self) weakSelf = self;
    [tz setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        __strong typeof(self) strongSelf = weakSelf;
//        [weakTz dismissViewControllerAnimated:YES completion:^{
            [strongSelf showConfirmAddWatermarkAlertWithCompleteBlock:^{
                [weakSelf requestAddWatermarkImgWithImage:photos[0]];
            }];
//        }];
//        TSEditAddImgCtrl* wk = self;
        
//        [self presentViewController:alert animated:YES completion:nil];
//        [weakTz showViewController:alert sender:nil];
//        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil]];
//        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
//
//            NSDictionary *para = @{
//                                   @"uid":self.dataProcess.userModel.userId,
//                                   @"deviceType":@"3",
//                                   @"token":self.dataProcess.userModel.token,
//                                   };
//            NSLog(@"水印时token -- %@",self.dataProcess.userModel.token);
//            [self.dataProcess.httpRequest uploadWaterMarkImg:photos[0] url:@"http://www.aipp3d.com/services/Member/uploadAddWaterMark" parameters:para completeBlock:^(NSDictionary *dic, NSError *err) {
//                if (err ==nil) {
//                    NSLog(@"水印上传完成");
//                    [HTProgressHUD showSuccess:@"水印上传完成"];
//                    [wk.addImgView resetViews];
//                    wk.selectImg = [wk getLocalSelectImgWithImg:photos[0]];
//                    [wk.addImgView resetViews];
//                    wk.whiteBalanceSlider.value = 100;
//                    [wk sliderValueChanged:wk.whiteBalanceSlider];
//                    [self.selectWaterMarkView addWatermarkWithImg:wk.selectImg];
//
//                }
//
//            }];
//
//        }]];
        
    }];
    tz.modalPresentationStyle = 0; //适配iOS13,设置全屏
    [self presentViewController:tz animated:YES completion:nil];
    
}

- (void)deleteWatermarkWithIndex:(NSInteger)idx{
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:NSLocalizedString(@"确定删除水印？", nil)
                                        message:NSLocalizedString(@"删除后需重新上传新水印", nil)
                                 preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ShareOK",nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self.stickerView removeFromSuperview];
        [self requestDeleteWatermarkImgWithIndex:idx];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    UILabel *lbl = (UILabel*)[self.bottomView viewWithTag:100];
    lbl.text = [NSString stringWithFormat:@"%d%%", (int)slider.value];
    
    @autoreleasepool{
        [self modifyimg];
    }
}

#pragma mark - Propertys
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
        UILabel *markL = [self getLabelWithTextAlignt:NSTextAlignmentLeft text:NSLocalizedString(@"WorkEditAddImgAlphaText", nil) inView:_bottomView];
        markL.frame = CGRectMake(ix, iy, iw, ih);
        
        UILabel *valueL = [self getLabelWithTextAlignt:NSTextAlignmentRight text:@"100%" inView:_bottomView];
        iw = 50;
        ix = _bottomView.width-iw-ix;
        valueL.frame = CGRectMake(ix, markL.y, iw, markL.height);
        valueL.tag = 100;
        
        UISlider* slider = self.whiteBalanceSlider;
        iw = valueL.x - markL.right;
        ih = 20;
        slider.frame = CGRectMake(markL.right, markL.center.y-ih/2, iw, ih);
        [_bottomView addSubview:slider];
        
        iw = 60;ih  = 60;
        ix = 20;//(_bottomView.width-iw)/5;
        CGFloat topH = 45;

        self.waterBgView = [[UIView alloc] initWithFrame:CGRectMake(20,(self.naviView.y-topH-ih)/2+topH , [UIScreen mainScreen].bounds.size.width, ih)];
//        self.waterBgView.backgroundColor = [UIColor redColor];
        [_bottomView addSubview:self.waterBgView];
        
        /********底部水印列表*********/

        [self.view addSubview:_bottomView];
        
        //阴影
        _bottomView.layer.shadowOffset = CGSizeMake(0, -3);
        _bottomView.layer.shadowOpacity = 0.08;
        _bottomView.layer.shadowColor = [UIColor blackColor].CGColor;

    }
    return _bottomView;
}

- (UIImageView *)imgView {
    if( !_imgView ){
        _imgView = [[UIImageView alloc] init];
        _imgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.bottomView.y);
        _imgView.userInteractionEnabled = YES;
        _imgView.clipsToBounds = NO;
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imgView];
    }
    return _imgView;
}

- (TSEditNaviView *)naviView {
    if( !_naviView ){
        _naviView = [[TSEditNaviView alloc] initWithTitle:NSLocalizedString(@"WorkEditBottomWaterMark", nil) target:self cancleSel:@selector(handleClose) sureSel:@selector(handleSave)];
        CGFloat ih = BOTTOM_NOT_SAVE_HEIGHT+45+15;
        _naviView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
    }
    return _naviView;
}

- (UISlider *)whiteBalanceSlider {
    if( !_whiteBalanceSlider ){
        _whiteBalanceSlider = [self getSlider];
        _whiteBalanceSlider.value = 100;
    }
    return _whiteBalanceSlider;
}

- (TSSelectWaterMarkView *)selectWaterMarkView{
    if( !_selectWaterMarkView ){
        _selectWaterMarkView = [TSSelectWaterMarkView new];
        _selectWaterMarkView.frame = self.waterBgView.bounds;
        
        __weak typeof(self) ws = self;
        _selectWaterMarkView.selectBlock = ^(BOOL isAdd, UIImage * _Nonnull img) {
   
            if( isAdd == NO ){
                [ws setSelectImg:img];
//                ws.addImgView.imgView.image = img;
            }else{
                [ws handleResetBtn];
            }
        };
        
        _selectWaterMarkView.deleteBlock = ^(NSInteger index) {
            [ws deleteWatermarkWithIndex:(index)];
        };
        
        [self.waterBgView addSubview:_selectWaterMarkView];
    }
    
    return _selectWaterMarkView;
}


- (SBPlayer *)player {
    if( !_player ){
        _player = [[SBPlayer alloc]initWithUrl:[NSURL URLWithString:@""]];
        _player.largerBtn.enabled = NO;
        _player.isShowControlView = NO;
        //        _player.allowsRotateScreen = NO;
        //设置标题
        //设置播放器背景颜色
        _player.backgroundColor = [UIColor clearColor];
        //设置播放器填充模式 默认SBLayerVideoGravityResizeAspectFill，可以不添加此语句
        
        _player.mode = SBLayerVideoGravityResizeAspect;
        //添加播放器到视图
        [self.view addSubview:_player];
        //约束，也可以使用Frame
        CGFloat iw = self.view.frame.size.width;
        _player.frame = CGRectMake(0, 0, iw, self.bottomView.y);
    }
    return _player;
}

@end
