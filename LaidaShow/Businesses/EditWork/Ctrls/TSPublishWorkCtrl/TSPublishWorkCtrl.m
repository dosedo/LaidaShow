//
//  TSPublishWorkCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 15/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
// metwen

#import "TSPublishWorkCtrl.h"
#import "UIViewController+Ext.h"
#import "UILabel+Ext.h"
#import "UIColor+Ext.h"
#import "KTextView.h"
#import "KKeyBoard.h"
#import "TSWorkModel.h"
#import "PPFileManager.h"
#import "PPLocalFileManager.h"
#import "HTProgressHUD.h"
#import "TSHelper.h"
#import "TSUserModel.h"
#import "NSString+Ext.h"
#import "NSDictionary+Ext.h"
#import "TSWorkReleaseView.h"
#import "TSConstants.h"
#import "XWPickerView.h"
#import "TSCategoryModel.h"
#import "TSLoginCtrl.h"
#import "TSPathManager.h"
#import "TSSelectVideoLenRadioView.h"
#import "XWSheetView.h"
#import "SBPlayer.h"
#import "UIImage+image.h"

@interface TSPublishWorkCtrl ()<KKeyBoardDelegate,UITextFieldDelegate,KTextViewDelegate>
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UIButton *releaseBtn;
@property (nonatomic, strong) KKeyBoard *keyboard;
@property (nonatomic, strong) UITextField *currTf;
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) XWPickerView *pickerView;
@property (nonatomic, strong) NSArray *categoryModels;
@property (nonatomic, assign) NSInteger selectedCategoryIndex;
@property (nonatomic, strong) TSSelectVideoLenRadioView *radioView;
/// 是否公开到广场
@property (nonatomic, strong) TSSelectVideoLenRadioView *publicRadioView;
@property (nonatomic, strong) SBPlayer *player;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation TSPublishWorkCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectedCategoryIndex = -1;
    [self configSelfData];
    self.navigationItem.title = NSLocalizedString(@"ReleasePageTitle", nil);//@"发布作品";
    [self addRightBarItemWithTitle:NSLocalizedString(@"ReleasePageSave", nil) action:@selector(handleSave)];
    
    [self updateTextValueWithModel:self.model];
    self.releaseBtn.hidden = NO;
    
    [self setupPlayerWithModel:self.model];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.keyboard addObserverKeyBoard];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.keyboard removeObserver];
}

#pragma mark - Private

- (UITextField*)getTextFieldWithIndex:(NSUInteger)idx{
    UITextField *tf = [self.inputView viewWithTag:idx+[self getTagBase]];
    if( [tf isKindOfClass:[UITextField class]] ){
        return tf;
    }
    
    if([tf isKindOfClass:[UITextView class]]){
        return tf;
    }
    
    return nil;
}

- (void)updateTextValueWithModel:(TSWorkModel*)wm{
    [self getTextFieldWithIndex:0].text = wm.workName;
   
    NSInteger sidx = 1;
//    if( ![self isVideoWork] ) sidx = 1;
    
    [self getTextFieldWithIndex:2+sidx].text = wm.workPrice;
    [self getTextFieldWithIndex:3+sidx].text = wm.workSaleCount;
    [self getTextFieldWithIndex:4+sidx].text = wm.workBuyUrl;
    [self getTextFieldWithIndex:5+sidx].text = wm.workDes;
    
    NSString *category = wm.workCategory;
    BOOL sucess = [self updateCategoryText:category];
    
    if( wm.workCategoryCode && (!sucess) ){
        for( TSCategoryModel *cm in [TSCategoryModel categoryModels] ){
            if( [cm.categoryCode isEqualToString:wm.workCategoryCode] ){
                category = cm.categoryName;
                [self updateCategoryText:category];
                break;
            }
        }
    }
      
    if( wm.editingImgs.count ){
        UIImage *img = wm.editingImgs[0];
        if( [img isKindOfClass:[UIImage class]] ){
            self.imgView.image = img;
        }
    }
    
    [self getButtonAtRightBarItem].enabled = wm.workName.length;
    self.releaseBtn.enabled = wm.workName.length;
}

/// 更新类别, 成功YES，失败NO
/// @param categoryText 类别文本
- (BOOL)updateCategoryText:(NSString*)categoryText{
    if(categoryText && [self.pickerView.data1 containsObject:categoryText] ){
        _selectedCategoryIndex = [self.pickerView.data1 indexOfObject:categoryText];
        
         [self getTextFieldWithIndex:1].text = categoryText;
        
        return YES;
    }
    return NO;
}

- (void)saveWorkData{
    
    //先清除之前的数据
    [self removeOldWorkModel];

    if( self.model.recordPath ){
        //存在录音文件，则保存录音文件
        PPFileManager *fm = [PPFileManager sharedFileManager];
        [fm moveAuidoFileToNotClearPathWithFileName:self.model.recordPath.lastPathComponent];
        _model.recordPath =
        [fm getAudioFilePathWithFileAllName:_model.recordPath.lastPathComponent isCanClear:NO];
        
        _model.musicName = @"录音文件";
    }
    
    //以时间戳区分的作品名目录。如 workimg1523424324
    TSPathManager *pm = [TSPathManager sharePathManager];
    NSString *workDirName = [pm getNewWorkDirName]; //[TSHelper getlocalNewImgFilePath];
    
    self.model.workDirName = workDirName;
    
    if( [self isVideoWork] ){
        if( self.model.editingVideoUrl ){
            
            self.model.isVideoWork = YES;
            NSFileManager *fm = [NSFileManager defaultManager];
            NSError *err = nil;
            NSString *toVideoPath = [[TSPathManager sharePathManager] getDocPathWithSuffix:workDirName];
            
            self.model.coverPath = [toVideoPath stringByAppendingPathComponent:@"cover.jpg"];
            
            UIImage *cover = [UIImage getVideoFirstViewImage:self.model.editingVideoUrl];//[NSURL fileURLWithPath:self.model.videoPath]];
            [UIImageJPEGRepresentation(cover, 0.5) writeToFile:_model.coverPath atomically:YES];
            
            toVideoPath = [toVideoPath stringByAppendingPathComponent:@"video.mp4"];
            [fm moveItemAtPath:self.model.editingVideoUrl.path toPath:toVideoPath error:&err];
            if( err ){
                NSLog(@"move video fail:%@",err);
            }
            self.model.videoPath = toVideoPath;
        }
    }
    
    NSString *imgPath1 = workDirName;
    
    //将所有图片写入本缓存
//    imgPath1 = [NSString stringWithFormat:@"%@/originImgs",workDirName];
    NSMutableArray *imgPaths = [NSMutableArray new];
    
    //若是本地作品，则从路径取图片。若是拍照的作品，则直接取拍的图片
//    BOOL isLocalWork = self.localWorkModel;
    NSArray *originImgs = [self.model getOriginImgPathsWhenSavework];
    
    for (int i = 0; i<originImgs.count; i++) {
        NSString *imgPath = originImgs[i];
        UIImage *img = (UIImage*)imgPath;
        
        if( [imgPath isKindOfClass:[NSString class]] ){
            NSData *imageData = [NSData dataWithContentsOfFile:imgPath options:NSDataReadingMappedIfSafe error:nil];
            img = [UIImage imageWithData:imageData];
        }
        
        if( [img isKindOfClass:[UIImage class]] ){
            PPFileManager *fm = [PPFileManager sharedFileManager];

            NSString *allName =[NSString stringWithFormat:@"%02d.jpg",i];
            BOOL ret =
            [fm saveSanweishowLocalImgToNotClearPath:img type:0 paths:imgPath1 imgAllName:allName];
            if( ret == NO ){
                NSLog(@"写入图片失败index=%lu",(unsigned long)[_model.imgArr indexOfObject:img]);
            }
            
            NSString *imgPath = [pm getWorkOriginImgPathWithWorkDirName:imgPath1 fileAllName:allName];
            if( imgPath ) [imgPaths addObject:imgPath];
        }
    }
    
    self.model.imgPathArr = imgPaths;
    //将所有中间结果图片写入本缓存
//    imgPath1 = [NSString stringWithFormat:@"%@/maskedImgs",workDirName];
    NSMutableArray *maskImgPaths = [NSMutableArray new];
    for (int i = 0; i<self.model.maskImgPathArr.count; i++) {
        NSString *maskImgPath = self.model.maskImgPathArr[i];
        NSData *imageData = [NSData dataWithContentsOfFile:maskImgPath options:NSDataReadingMappedIfSafe error:nil];
        UIImage *img = [UIImage imageWithData:imageData];
        if( [img isKindOfClass:[UIImage class]] ){
            
            PPFileManager *fm = [PPFileManager sharedFileManager];
            NSString * allName =[NSString stringWithFormat:@"%02d.jpg",i];
            BOOL ret =
            [fm saveSanweishowLocalImgToNotClearPath:img type:1 paths:imgPath1 imgAllName:allName];
        
            if( ret == NO ){
                NSLog(@"写入图片失败index=%lu",(unsigned long)[_model.imgMaskArr indexOfObject:img]);
            }
            
            NSString *imgPath = [pm getWorkMaskImgPathWithWorkDirName:imgPath1 fileAllName:allName];
            if( imgPath ) [maskImgPaths addObject:imgPath];
        }
    }
    self.model.maskImgPathArr = maskImgPaths;
    //将所有退底图片存入本地
    NSMutableArray *clearImgPaths = [NSMutableArray new];

    NSArray *clearPaths = [self.model getClearImgPathsWhenSavework];
    for (int i = 0; i< clearPaths.count; i++) {
        NSString *maskImgPath = clearPaths[i];
        NSData *imageData = [NSData dataWithContentsOfFile:maskImgPath options:NSDataReadingMappedIfSafe error:nil];
        UIImage *img = [UIImage imageWithData:imageData];
        if( [img isKindOfClass:[UIImage class]] ){
            PPFileManager *fm = [PPFileManager sharedFileManager];

            NSString* allName =[NSString stringWithFormat:@"%02d.jpg",i];
            BOOL ret =
            [fm saveSanweishowLocalImgToNotClearPath:img type:2 paths:imgPath1 imgAllName:allName];
            if( ret == NO ){
                NSLog(@"写入图片失败index=%lu",(unsigned long)[_model.clearBgImgArr indexOfObject:img]);
            }
            
            NSString *imgPath = [pm getWorkClearImgPathWithWorkDirName:workDirName fileAllName:allName];
            if( imgPath ) [clearImgPaths addObject:imgPath];
        }
    }
    
    self.model.clearBgImgPathArr = clearImgPaths;
    
    NSArray *tempImgs = self.model.editingImgs;//self.model.imgArr;
    NSArray *tempMaskImgs = self.model.imgMaskArr;
    NSArray *tempClearBgImgArr = self.model.clearBgImgArr;
    self.model.imgArr = nil;
    self.model.clearBgImgArr = nil;
    self.model.imgMaskArr = nil;
    
    //设置若去底了，则设置是否展示去底图片
//    if( _localWorkModel ){
//        self.model.showClearBg = _localWorkModel.showClearBg;
//    }else{
        self.model.showClearBg = (self.model.clearBgImgPathArr.count);
//    }
    
    [[PPLocalFileManager shareLocalFileManager] saveFileToLocal:self.model];
    self.model.imgArr = tempImgs;
    self.model.clearBgImgArr = tempClearBgImgArr;
    self.model.imgMaskArr = tempMaskImgs;
    
    self.model.editingImgs = tempImgs;
}

- (void)removeOldWorkModel{
    //    //已经存在本地，则清除之前的数据
    PPFileManager *fm = [PPFileManager sharedFileManager];
    
    [[PPLocalFileManager shareLocalFileManager] removeFileWithIndex:self.model.imgDataIndex];
    
    return;
    
//    if( self.localWorkModel ){
////        if( _localWorkModel.recordPath ) {
////            //移除录音文件
////            [fm removeFileAtAllPath:_localWorkModel.recordPath];
////        }
//
//        for( NSString *imgPath in _localWorkModel.imgPathArr ){
//            if( [imgPath isKindOfClass:[NSString class]] ){
//                [fm removeFileAtAllPath:imgPath];
//            }
//        }
//
//        for( NSString *imgPath in _localWorkModel.clearBgImgPathArr ){
//            if( [imgPath isKindOfClass:[NSString class]] ){
//                [fm removeFileAtAllPath:imgPath];
//            }
//        }
//        for( NSString *imgPath in _localWorkModel.maskImgPathArr ){
//            if( [imgPath isKindOfClass:[NSString class]] ){
//                [fm removeFileAtAllPath:imgPath];
//            }
//        }
//
//        [[PPLocalFileManager shareLocalFileManager] removeFileWithIndex:self.localWorkModel.imgDataIndex];
//    }
}

- (NSMutableDictionary*)getInfoParameters {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    NSArray *keys = @[@"name",@"category",@"time",@"price",@"saleCount",@"link",@"desc"];
    for( NSUInteger i=0; i<keys.count; i++ ){
        UITextField *tf = [self getTextFieldWithIndex:i];
        if( tf ){
            NSString *str = tf.text;
            if( tf.text.length == 0 ){
                str = @"";
            }
            if( i==1){
                //选择的类别
                TSCategoryModel *cm = self.categoryModels[_selectedCategoryIndex];
                dic[@"category"] = cm.categoryCode;
            }
            else if( i==2 ){
                //视频时长
                dic[keys[i]] = @((_radioView.selectedIndex+1)*10).stringValue;
            }

            else if( i==3 ){
                dic[keys[i]] = @(str.floatValue);
            }else if( i==4 ){
                dic[keys[i]] = @(str.integerValue);
            }
            else{
                dic[keys[i]] = str;
            }
        }
    }
    
    if( dic.allKeys.count ){
        
        dic[@"publicLevel"] = @1;
        dic[@"picTags"] = @{@"0":@"hhhaa"};
        dic[@"audio"] = @"";
        dic[@"audioNum"] = @"1";
        if( self.model.musicUrl && self.model.musicName ){
            dic[@"audio"] = [NSString stringWithFormat:@"%@%@",@"m/",_model.musicName];
        }
        
        return dic;
    }
    
    return nil;
}

//- (NSMutableDictionary*)getVideoInfoParameters {
//    NSMutableDictionary *dic = [NSMutableDictionary new];
//    NSArray *keys = @[@"name",@"category",/*@"time",*/@"price",@"saleCount",@"link",@"desc"];
//    for( NSUInteger i=0; i<keys.count; i++ ){
//        UITextField *tf = [self getTextFieldWithIndex:i];
//        if( tf ){
//            NSString *str = tf.text;
//            if( tf.text.length == 0 ){
//                str = @"";
//            }
//            if( i==1){
//                //选择的类别
//                TSCategoryModel *cm = self.categoryModels[_selectedCategoryIndex];
//                dic[@"category"] = cm.categoryCode;
//            }
//
//            else if( i==2 ){
//                dic[keys[i]] = @(str.floatValue);
//            }else if( i==3 ){
//                dic[keys[i]] = @(str.integerValue);
//            }
////            else if( i==4 ){
////                //视频时长
////                dic[keys[i]] = @((_radioView.selectedIndex+1)*10).stringValue;
////            }
//            else{
//                dic[keys[i]] = str;
//            }
//        }
//    }
//
//    if( dic.allKeys.count ){
//
//        dic[@"publicLevel"] = @1;
//        dic[@"picTags"] = @{@"0":@"hhhaa"};
//        dic[@"audio"] = @"";
//        dic[@"audioNum"] = @"1";
//        if( self.model.musicUrl && self.model.musicName ){
//            dic[@"audio"] = [NSString stringWithFormat:@"%@%@",@"m/",_model.musicName];
//        }
//
//        return dic;
//    }
//
//    return nil;
//}

-(void)startReleaseWorkWithDic:(NSDictionary*)dic isSaveToLocal:(BOOL)saveToLocal{
    _hud = [HTProgressHUD showMessage:NSLocalizedString(@"Releaseing", nil) toView:self.view];//@"发布中"
    [self dispatchAsyncQueueWithName:@"relaseWOrkQ" block:^{
        NSMutableDictionary *recordDic = [NSMutableDictionary dictionaryWithDictionary:dic];

        recordDic[@"recordBase64"] = @"";
        if( self.model.recordPath ){
            NSData *data = [NSData dataWithContentsOfFile:_model.recordPath];
            if( data ){
                NSString *base64 = [NSString stringOfBase64WithData:data];
                if( base64.length ){
                    NSLog(@"存在录音=%@",base64);
                    recordDic[@"recordBase64"] = base64;
                }
            }
        }

        NSString *token = @"";
        if( self.dataProcess.userModel.token ){
            token = self.dataProcess.userModel.token;
        }
        
        recordDic[@"uid"] = self.dataProcess.userModel.userId;
        recordDic[@"username"] = self.dataProcess.userModel.userName;
        recordDic[@"token"] = token;
        recordDic[@"deviceType"] = @"3";
        
        NSURL *videoUrl = nil;
        if( [self isVideoWork] ){
            if( self.model.editingVideoUrl ){
                videoUrl = self.model.editingVideoUrl;
            }
        }
        [self.dataProcess releaseWorkWithImgs:self.model.editingImgs video:videoUrl isVideoWork:[self isVideoWork] recordBase64Data:nil parameters:recordDic completeBlock:^(NSError *err) {
            if( err == nil ){
                //则移除本地作品
//                if( _localWorkModel ){
                if( self.model.isLocalWork && !saveToLocal){
                    [self deleteLocalWorkWithModel:_model];//_localWorkModel];
                }
                
                if( saveToLocal ){
                    
                    //保存之前，先把缓存中 源数据删了，不删除其录音以及其他数据
                    [[PPLocalFileManager shareLocalFileManager] removeFileWithIndex:_model.imgDataIndex];

                    [self saveWorkToLocalWithShowHUD:NO];
                    
                    //发送一个 重新加载本地作品数据的消息
                    [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationDeleteWorkLocal object:nil];
                }
            }
            [self dispatchAsyncMainQueueWithBlock:^{
                [_hud hide];
                if( err ){
//                    NSString *errStt = NSLocalizedString(@"LogonValidity", nil);//登录失效，请重新登录
//                    NSString *msg = [NSString stringWithFormat:@"%@",errStt];
//                    [self showErrMsg:msg];
//                    [self.navigationController pushViewController:[[TSLoginCtrl alloc]init] animated:YES];
                    [self showErrMsgWithError:err];
                }else{
                
                    [HTProgressHUD showSuccess:NSLocalizedString(@"ReleaseSuccess", nil)];//@"发布成功"
                    [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationReloadWorkList object:nil];
  
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }];
    }];
}

- (void)deleteLocalWorkWithModel:(TSWorkModel*)wm{
    PPFileManager *fm = [PPFileManager sharedFileManager];
    if( wm ){
        if( wm.recordPath ) {
            //移除录音文件
            [fm removeFileAtAllPath:wm.recordPath];
        }
        
        for( NSString *imgPath in wm.imgPathArr ){
            if( [imgPath isKindOfClass:[NSString class]] ){
                [fm removeFileAtAllPath:imgPath];
            }
        }
    }
    [[PPLocalFileManager shareLocalFileManager] removeFileWithIndex:wm.imgDataIndex];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationDeleteWorkOnLine object:nil];
}

- (void)saveWorkToLocalWithShowHUD:(BOOL)showHud{
    if( self.model == nil ) {
        
        BOOL noData = [self isVideoWork]==NO && self.model.editingImgs.count ==0;
        if( !noData ){
            noData = ([self isVideoWork] && self.model.editingVideoUrl == nil);
        }

        if( noData ){
            [HTProgressHUD showError:NSLocalizedString(@"ReleaseSaveFaile",nil)];//@"保存失败"
            [[PPLocalFileManager shareLocalFileManager] removeFileWithIndex:_model.imgDataIndex];
            return;
        }
    }
    
    if( showHud ){
        _hud = [HTProgressHUD showMessage:NSLocalizedString(@"ReleaseSave",nil) toView:self.view];//@"努力保存中"
    }
    //    [self dispatchAsyncMainQueueWithBlock:^{
    self.model.workName = [self getTextFieldWithIndex:0].text;
    self.model.workCategory = [self getTextFieldWithIndex:1].text;
    
    //保存作品Code
    if( _selectedCategoryIndex < _categoryModels.count ){
        TSCategoryModel *cm = self.categoryModels[_selectedCategoryIndex];
        self.model.workCategoryCode =  cm.categoryCode;
    }
    
    NSInteger sidx = 1;
//    if( ![self isVideoWork] ) sidx = 1;
    
    self.model.workPrice = [self getTextFieldWithIndex:2+sidx].text;
    self.model.workSaleCount = [self getTextFieldWithIndex:3+sidx].text;
    self.model.workBuyUrl = [self getTextFieldWithIndex:4+sidx].text;
    self.model.workDes = [self getTextFieldWithIndex:5+sidx].text;
    //    }];
    
    if( showHud ){
        [self dispatchAsyncQueueWithName:@"saveWorkQ" block:^{
            [self saveWorkData];
            
            [self dispatchAsyncMainQueueWithBlock:^{
                [_hud hide];
//                _localWorkModel = self.model;
                [HTProgressHUD showSuccess:NSLocalizedString(@"ReleaseSaveSuccess",nil)];//@"保存成功"
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationDeleteWorkOnLine object:nil];
            }];
        }];
    }else{
        [self saveWorkData];
    }
}

- (void)selectCategoryWithIndex:(NSUInteger)index{
    if( self.categoryModels.count > index ){
        TSCategoryModel *cm = _categoryModels[index];
        [self getTextFieldWithIndex:1].text = cm.categoryName;
        
        _selectedCategoryIndex = index;
    }
}

#pragma mark - 验证数据格式是否正确
- (BOOL)validateData{
    
//    NSMutableDictionary *dic = [NSMutableDictionary new];
//    NSArray *keys = @[@"name",@"category",@"price",@"saleCount",@"link",@"desc"];
//    for( NSUInteger i=0; i<keys.count; i++ ){
//
//
//    }
    
//    return NO;
    
    UITextField *tf = [self getTextFieldWithIndex:0];
    if( tf.text == nil || [tf.text isEqualToString:@""] ){
        [HTProgressHUD showError:NSLocalizedString(@"ReleasePagePleaseInputWorkName", nil)];//@"请输入商品名字"];
        return NO;
    }
    
    if( _selectedCategoryIndex < 0 ){
        [HTProgressHUD showError:NSLocalizedString(@"ReleasePageCategoryTextHolder", nil)];//@"请选择商品类别"];
        return NO;
    }
    
    NSInteger sidx = 1;
    
    tf = [self getTextFieldWithIndex:2+sidx];
    if( tf.text.floatValue > 99999.99 ){
        [HTProgressHUD showError:NSLocalizedString(@"价格不能大于99999.99", nil)];
        return NO;
    }
    
    tf = [self getTextFieldWithIndex:3+sidx];
    if( tf.text.integerValue > 99999 ){
        [HTProgressHUD showError:NSLocalizedString(@"数量不能大于99999", nil)];
        return NO;
    }
    
    tf = [self getTextFieldWithIndex:4+sidx];
    if( tf.text.length > 120 ){
        [HTProgressHUD showError:NSLocalizedString(@"链接长度不能大于120个字符", nil)];
        return NO;
    }
    
    tf = [self getTextFieldWithIndex:5+sidx];
    if( tf.text.length > 300 ){
        [HTProgressHUD showError:NSLocalizedString(@"作品描述的长度不能大于300", nil)];
        return NO;
    }
    
    return YES;
}

#pragma mark - TouchEvents
- (void)handleSave{
    [self.view endEditing:YES];
    
    if( [self validateData] ==NO ) return;
    
    [self.view endEditing:YES];
    [self saveWorkToLocalWithShowHUD:YES];
    
//    NSArray *titles = @[@"是否需要保存图片到本地？",@"是"];
//    if( [self isVideoWork] ){
//        titles = @[@"是否需要保存视频到本地？",@"是"];
//    }
//    [XWSheetView showWithTitles:titles cancleTitle:@"否" handleIndexBlock:^(NSInteger index) {
////        [weakSelf handleSheetIndex:index isSelf:isSelf];
//        if( index == 1 ){
//            [self.view endEditing:YES];
//            [self saveWorkToLocalWithShowHUD:YES];
//        }
//    }];
}

- (void)handleRelease{
    [self.view endEditing:YES];
    
    if( ![self isLoginedWithGotoLoginCtrl] ) return;
    
    if( [self validateData] ==NO ) return;
    
    NSMutableDictionary *dic = [self getInfoParameters];
    
    if( dic == nil ){
        [HTProgressHUD showError:NSLocalizedString(@"ReleasePagePleaseInputWorkName", nil)];//@"请输入商品名字"];
        return;
    }
    
    if( _selectedCategoryIndex < 0 ){
        [HTProgressHUD showError:NSLocalizedString(@"ReleasePageCategoryTextHolder", nil)];//@"请选择商品类别"];
        return;
    }
    else{
        TSCategoryModel *cm = self.categoryModels[_selectedCategoryIndex];
        dic[@"category"] = cm.categoryCode;
    }
    
    BOOL isOnlySelfSee = self.publicRadioView.selectedIndex==1;
    if( isOnlySelfSee==NO ){
        dic[@"publicLevel"] = @(1);
    }else{
        dic[@"publicLevel"] = @(0);
    }
    [self startReleaseWorkWithDic:dic isSaveToLocal:YES];
    
//    __weak typeof(self) weakSelf = self;
//    [TSWorkReleaseView showWithHandleIndexBlock:^(NSInteger index, BOOL isSaveToLocal, BOOL isOnlySelfSee) {
//
//        if( isOnlySelfSee==NO ){
//            dic[@"publicLevel"] = @(1);
//        }else{
//            dic[@"publicLevel"] = @(0);
//        }
//        [weakSelf startReleaseWorkWithDic:dic isSaveToLocal:isSaveToLocal];
//    }];
}

- (void)handleSelectCategoryBtn:(UIButton*)selectBtn{
//    selectBtn.hidden =
    [self.view endEditing:YES];
    selectBtn.selected = !selectBtn.isSelected;
    __weak typeof(self) weakSelf = self;
    [self.pickerView showWithCompleteBlock:^(NSUInteger index1, NSUInteger index2, NSUInteger index3) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf selectCategoryWithIndex:index1];
    } dismisBlock:^{
        selectBtn.selected = NO;
    }];
}

#pragma mark - KKeyBoardDelegate

- (void)keyBoardWillShow:(KKeyBoard *)keyBoard keyBoardHeight:(CGFloat)height{
    CGFloat doneH = 0;
    CGFloat iy = self.imgView.bottom+15;
    CGFloat moveDis = _currTf.bottom+self.scrollView.y + iy - (SCREEN_HEIGHT-height)-doneH;
    if( moveDis > 0 ){
        CGRect fr = self.inputView.frame;
        fr.origin.y = (iy- moveDis);
        self.inputView.frame = fr;
    }
}

- (void)keyBoardWillHide:(KKeyBoard *)keyBoard keyBoardHeight:(CGFloat)height{
    CGRect fr = self.inputView.frame;
    fr.origin.y = self.imgView.bottom+15;
    self.inputView.frame = fr;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _currTf = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    UITextField *tf = [self getTextFieldWithIndex:textField.tag-[self getTagBase]+1];
    [tf becomeFirstResponder];
    return YES;
}

- (void)kTextViewShouldEdit:(KTextView *)textView{
    _currTf = (UITextField*)textView;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    BOOL ret = YES;
    if( [string isEqualToString:@""] ){
        //删除
        if( textField.text.length == 1 ){
            ret = NO;
        }
    }
    if( textField.tag == [self getTagBase] ){
        self.releaseBtn.enabled = ret;
        [self getButtonAtRightBarItem].enabled = ret;
    }

    return YES;
}

- (void)kTextViewShouldReturn:(KTextView *)textView{
//    if( [text isEqualToString:@"\n"] ){
        [textView resignFirstResponder];
//    }
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(nonnull NSString *)text{
//    if( [text isEqualToString:@"\n"] ){
//        [textView resignFirstResponder];
//    }
//    return YES;
//}

#pragma mark - Propertys
- (UIImageView *)imgView {
    if( !_imgView ){
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        CGFloat iy = 15;//NAVGATION_VIEW_HEIGHT+15;
        CGFloat iw = 355/2.0,ih = 322/2.0;
        _imgView.frame = CGRectMake((SCREEN_WIDTH-iw)/2, iy, iw, ih);
//        _imgView.backgroundColor = [UIColor whiteColor];
        
        [self.scrollView addSubview:_imgView];
    }
    return _imgView;
}

- (UIView *)inputView {
    if( !_inputView ){
        _inputView = [[UIView alloc] init];
        _inputView.backgroundColor = [UIColor whiteColor];
        CGFloat iy = self.imgView.bottom+15;
        _inputView.frame = CGRectMake(0, iy, SCREEN_WIDTH, 258+42+42+42);
        [self.scrollView addSubview:_inputView];
        
        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _inputView.bottom);
        
//        NSArray *titles = @[@"*名称:",@"价格(元):",@"月销量(件):",@"购买链接:",@"描述:"];
//        NSArray *hoders = @[@"请输入名称",@"请输入价格",@"请输入销量",@"请输入链接",@"请输入描述"];
        NSArray *titles = @[NSLocalizedString(@"ReleasePageNameText", nil),
                            NSLocalizedString(@"ReleasePageCategory", nil),
                            NSLocalizedString(@"ReleasePageVideoLen", nil),
                            NSLocalizedString(@"是否公开到广场", nil),
                            NSLocalizedString(@"ReleasePagePrice", nil),
                            NSLocalizedString(@"ReleasePageSaleCount", nil),
                            NSLocalizedString(@"ReleasePageBuyUrl", nil),
                            NSLocalizedString(@"ReleasePageDes", nil)];
        NSArray *hoders = @[NSLocalizedString(@"ReleasePageNameTextHolder", nil),
                            NSLocalizedString(@"ReleasePageCategoryTextHolder", nil),
                            @"",@"",
                            NSLocalizedString(@"ReleasePagePriceHolder", nil),
                            NSLocalizedString(@"ReleasePageSaleCountHolder", nil),
                            NSLocalizedString(@"ReleasePageBuyUrlHolder", nil),
                            NSLocalizedString(@"ReleasePageDesHolder", nil)];
        for( NSUInteger i=0; i<titles.count; i ++ ){
            UILabel *markL = [UILabel new];
            markL.text = titles[i];
            markL.font = [UIFont systemFontOfSize:14];
            markL.textColor = [UIColor colorWithRgb51];
            CGFloat iw = [markL labelSizeWithMaxWidth:130].width;
            CGFloat ih = 42,iy = ih*i;
            
            //若是视频作品，则隐藏选择视频时长的选项
            if( [self isVideoWork] ){
                if( i> 2 ){
                    iy = ih *(i-1);
                }
                if( i== 2 ){
                    markL.hidden = YES;
                }
            }
            
            markL.frame = CGRectMake(15, iy, iw, ih);
            [_inputView addSubview:markL];
            
            UITextField *tf = nil;
            if( i !=titles.count-1 ){
                  tf = [UITextField new];
                if( i==1 ){
                    //请选择商品
                    tf.userInteractionEnabled = NO;
                }
            }
            else{
                KTextView *textView = [KTextView new];
                textView.placeHolder = hoders[i];
                textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
                textView.scrollEnabled = YES;
                CGRect fr =
                textView.placeHdLbl.frame;
                fr.origin.y = 0;
                fr.origin.x = 5;
                textView.placeHdLbl.frame = fr;
                textView.del = self;
                tf = (UITextField*)textView;
            }
            
            [self addDoneBtnWithView:(UITextView*)tf];
//            tf.tag = [self getTagBase] + i;
            
            //除了第一个，其他的textfield的tag保持之前的值，因为又加了一个 是否公开的按钮。懒得重构了。
            if( i<2 ){
                tf.tag = [self getTagBase] + i;
            }
            else if( i > 2 ){
                tf.tag = [self getTagBase] + i -1;
            }
            
            tf.delegate = self;
            [_inputView addSubview:tf];
            
            tf.textColor = [UIColor colorWithRgb51];
            tf.font = [UIFont systemFontOfSize:14];
            tf.returnKeyType = UIReturnKeyNext;
            if( [tf isKindOfClass:[UITextField class]] ){
                tf.placeholder = hoders[i];
                
            }
            CGFloat ix = markL.right+8;
            iw = SCREEN_WIDTH-ix-10;
            ih = markL.height;
            iy = markL.y;
            if( [tf isKindOfClass:[UITextView class]] ){
                ih = _inputView.height-markL.y - 15;
                iy = markL.y +12;
                tf.returnKeyType = UIReturnKeyDone;
                tf.delegate = tf;
            }
            tf.frame = CGRectMake(ix, iy, iw, ih);
            
            if( i==1+2+1){
                tf.keyboardType = UIKeyboardTypeDecimalPad;
            }else if( i== 2+2+1){
                tf.keyboardType = UIKeyboardTypeNumberPad;
            }else if( i== 3+2+1){
                tf.keyboardType = UIKeyboardTypeURL;
            }
            
            if( i==0 || i==1 ){
                NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:markL.text];
                [as addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 1)];
                markL.attributedText = as;
                
                if( i==1 ){
                    //添加选择的按钮
                    UIButton *selectCategoryBtn = [UIButton new];
                    selectCategoryBtn.frame = tf.frame;
                    [selectCategoryBtn addTarget:self action:@selector(handleSelectCategoryBtn:) forControlEvents:UIControlEventTouchUpInside];
                    [selectCategoryBtn setImage:[UIImage imageNamed:@"category_choose_normal"] forState:UIControlStateNormal];
                    [selectCategoryBtn setImage:[UIImage imageNamed:@"category_choose_selected"] forState:UIControlStateSelected];
                    selectCategoryBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                    [_inputView addSubview:selectCategoryBtn];
                }
            }
            else if( i== 2 ){
                //添加选择视频时长的Radio按钮
                tf.hidden = YES;
                TSSelectVideoLenRadioView *radioView = [[TSSelectVideoLenRadioView alloc] initWithSelectedIndex:0 titles:@[@"10s",@"20s",@"30s"]];
                radioView.frame = tf.frame;
                [_inputView addSubview:radioView];
                
                _radioView = radioView;
                
                if( [self isVideoWork] ){
                    _radioView.hidden = YES;
                }
            }else if( i==3 ){
                //添加选择是否公开到广场的按钮
                tf.hidden = YES;
                TSSelectVideoLenRadioView *radioView = [[TSSelectVideoLenRadioView alloc] initWithSelectedIndex:1 titles:@[@"是",@"否"]];
                radioView.frame = tf.frame;
                [_inputView addSubview:radioView];

                _publicRadioView = radioView;
            }
        }
    }
    return _inputView;
}

- (UIButton *)releaseBtn {
    if( !_releaseBtn ){
        _releaseBtn = [[UIButton alloc] init];
        [_releaseBtn setTitle:NSLocalizedString(@"ReleaseBtnTitle", nil) forState:UIControlStateNormal];
        [_releaseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _releaseBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_releaseBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue"] forState:UIControlStateNormal];
        [_releaseBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue_hi"] forState:UIControlStateHighlighted];
        [_releaseBtn addTarget:self action:@selector(handleRelease) forControlEvents:UIControlEventTouchUpInside];
        CGFloat ih = 44;
        _releaseBtn.frame = CGRectMake(0, SCREEN_HEIGHT-ih-BOTTOM_NOT_SAVE_HEIGHT, SCREEN_WIDTH, ih);
        [self.view addSubview:_releaseBtn];
    }
    return _releaseBtn;
}

- (KKeyBoard *)keyboard{
    if( !_keyboard ){
        _keyboard = [[KKeyBoard alloc] init];
        _keyboard.delegate = self;
    }
    return _keyboard;
}

- (XWPickerView *)pickerView {
    if( !_pickerView ){
        _pickerView = [[XWPickerView alloc] init];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[TSCategoryModel categoryNames]];
        if( arr .count) [arr removeObjectAtIndex:0];
        
        _pickerView.data1 = arr;
    }
    return _pickerView;
}

- (NSArray *)categoryModels{
    if( !_categoryModels ){
        _categoryModels = [TSCategoryModel categoryModels];
    }
    return _categoryModels;
}

@end

@implementation TSPublishWorkCtrl(VideoWork)

- (BOOL)isVideoWork{
    return self.model.isVideoWork;
}

- (void)setupPlayerWithModel:(TSWorkModel*)wm{
    if( [self isVideoWork] ){
        if( wm.editingVideoUrl ){
            self.player.hidden = NO;
            if( self.model.editingVideoUrl == nil ){
                self.model.editingVideoUrl = [NSURL fileURLWithPath:self.model.videoPath];
            }
            [self.player resetLocalVideoUrl:self.model.editingVideoUrl];//[NSURL fileURLWithPath:wm.videoPath]];
            self.player.pauseOrPlayView.hidden = YES;
        }else{
            self.player.hidden = YES;
        }
    }
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
        //        _player.mode = SBLayerVideoGravityResize;
        //添加播放器到视图
        [self.imgView addSubview:_player];
        //约束，也可以使用Frame
//        CGFloat iw = self.view.frame.size.width;
        _player.frame = self.imgView.bounds;//CGRectMake(0, 0, iw, SCREEN_HEIGHT);
    }
    return _player;
}

- (UIScrollView*)scrollView{
    if( !_scrollView ){
        _scrollView = [UIScrollView new];
        _scrollView.frame = CGRectMake(0, NAVGATION_VIEW_HEIGHT, SCREEN_WIDTH, self.releaseBtn.y-NAVGATION_VIEW_HEIGHT);
        
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        _scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:self.scrollView];
    }
    return _scrollView;
}

@end
