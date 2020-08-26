//
//  TSWorkModel.m
//  ThreeShow
//
//  Created by hitomedia on 15/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
// metwen

#import "TSWorkModel.h"
#import "MJExtension.h"

#import "TSHelper.h"
#import "TSPathManager.h"

@implementation TSWorkModel

MJCodingImplementation

- (instancetype)init {
    self = [super init];
    
    if( self ){
        self.isCanClearBg = YES;
        self.clearState = TSWorkClearBgStateNotBegin;
    }
    return self;
}

- (BOOL)isCleared{
    return (self.imgPathArr.count == self.maskImgPathArr.count &&
            self.maskImgPathArr.count == self.clearBgImgPathArr.count &&
            self.imgPathArr.count );
}

//保存时，得到需要保存的原图路径
- (NSArray*)getOriginImgPathsWhenSavework{
    NSFileManager *fm = [NSFileManager defaultManager];
    for( NSString *editImgPath in self.tempEditOriginImgPaths ){
        
        if( [fm fileExistsAtPath:editImgPath] ){
            return self.tempEditOriginImgPaths;
        }
    }
    
    return self.imgPathArr;
}

//保存时，得到需要保存的去底图路径
- (NSArray*)getClearImgPathsWhenSavework{
    NSFileManager *fm = [NSFileManager defaultManager];
    for( NSString *editImgPath in self.tempEditClearImgPaths ){
        
        if( [fm fileExistsAtPath:editImgPath] ){
            return self.tempEditClearImgPaths;
        }
    }
    
    return self.clearBgImgPathArr;
}

+ (TSWorkModel *)workModelForTakePhotoWithImgs:(NSArray *)imgs{
    if( imgs.count ==0 ) return nil;
    
    TSWorkModel *wm = [TSWorkModel new];
    wm.isLocalWork = NO;
    wm.editingImgs = imgs;
    wm.editingObject = TSWorkEditObjectOriginWork;
    wm.imgDataIndex = -1;
    
    TSPathManager *pm = [TSPathManager sharePathManager];
    NSString *imgDir = [pm getWorkOriginImgPathWithWorkDirName:[pm takePhotoWorkImgDirName]];//[TSHelper takePhotoImgPath];
    NSMutableArray *arr = [NSMutableArray new];
    for( NSInteger i=0; i<imgs.count; i++ ){
        NSString *imgFilePath = [imgDir stringByAppendingPathComponent:[TSHelper getSaveWorkImgNameAtIndex:i]];
        [arr addObject:imgFilePath];
    }
    wm.imgPathArr = arr;
    wm.workDirName = [pm takePhotoWorkImgDirName];
    
    return wm;
}

#pragma mark - Private

- (id)copyWithZone:(NSZone *)zone{
    
    TSWorkModel *dm = [[self class] allocWithZone:zone];
    dm.imgMaskArr = [self.imgMaskArr copy];
    dm.imgPathArr = [self.imgPathArr copy];
    dm.imgArr = [self.imgArr copy];
    dm.recordPath = [self.recordPath copy];
    dm.musicName = [self.musicName copy];
    dm.musicUrl = [self.musicUrl copy];
    dm.musicUrl =
    dm.workName = [self.workName copy];
    dm.workPrice = [self.workPrice copy];
    dm.workSaleCount = [self.workSaleCount copy];
    dm.workBuyUrl = [self.workBuyUrl copy];
    dm.workDes = [self.workDes copy];
    dm.imgDataIndex = self.imgDataIndex;
    
    dm.isCanClearBg = self.isCanClearBg;
    dm.clearState = self.clearState;
    dm.clearBgImgPathArr = [self.clearBgImgPathArr copy];
    dm.clearBgImgArr = [self.clearBgImgArr copy];
    dm.clearBgWorkId = [self.clearBgWorkId copy];
    dm.maskImgPathArr = [self.maskImgPathArr copy];
    dm.workCategory = [self.workCategory copy];
    dm.showClearBg = self.showClearBg;
    return dm;
}

#pragma mark - Propertys
- (NSArray<UIImage *> *)imgArr{
    return _editingImgs;
}

@end
