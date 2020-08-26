//
//  XWPickerView.m
//  Hitu
//
//  Created by hitomedia on 2017/3/21.
//  Copyright © 2017年 hitomedia. All rights reserved.
//

#import "XWPickerView.h"

#define XW_APV_PROVINCE_COMPONENT  0
#define XW_APV_CITY_COMPONENT      1
#define XW_APV_DISTRICT_COMPONENT  2
#define XW_APV_SURE_BTN_TAG        100
#define XW_APV_CANCLE_BTN_TAG      101

static CGFloat const gAnimateTime = 0.4;

@interface XWPickerView(LastSelectedArea)

- (void)updateSelectedAreaWithProvinceIndex:(NSUInteger)pIndex
                                  cityIndex:(NSUInteger)cIndex
                              districtIndex:(NSUInteger)dIndex;

- (NSUInteger)lastSelectedProvinceIndex;
- (NSUInteger)lastSelectedCityIndex;
- (NSUInteger)lastSelectedDistrictIndex;

@end

@interface XWPickerView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) UIView       *bgView;
@property (nonatomic, strong) UIButton     *sureBtn;
@property (nonatomic, strong) UIButton     *cancleBtn;
@property (nonatomic, strong) UILabel      *titleL;

@end

@implementation XWPickerView{
    NSArray      *_sortedProvincesKeys;
    NSDictionary *_cityDic;
    NSUInteger   _selectedProvinceIndex;
    CompleteBlock _completeBlock;
    void(^_dismisBlock)(void);
}

#pragma mark - Public

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleL.text = title;
}

- (void)showWithCompleteBlock:(CompleteBlock)completeBlock{
    
    _completeBlock = completeBlock;
    
    [self loadSelectedComponent];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:gAnimateTime animations:^{
        CGRect fr = self.bgView.frame;
        fr.origin.y = CGRectGetHeight(self.frame)-CGRectGetHeight(_bgView.frame);
        self.bgView.frame = fr;
        self.alpha = 1.0;
    }];
}

- (void)showWithCompleteBlock:(CompleteBlock)completeBlock dismisBlock:(void (^)(void))dismisBlock{
    _dismisBlock = dismisBlock;
    
    [self showWithCompleteBlock:completeBlock];
}

- (void)hide{
    
    [UIView animateWithDuration:gAnimateTime animations:^{
        CGRect fr = self.bgView.frame;
        fr.origin.y = CGRectGetHeight(self.frame);
        self.bgView.frame = fr;
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        _completeBlock = nil;
        
        if( _dismisBlock ){
            _dismisBlock();
        }
    }];
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData{
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, 0, size.width, size.height);
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.alpha = 0.0;
    
    UILabel *titleL = [[UILabel alloc] init];
    CGFloat ix = CGRectGetMaxX(self.cancleBtn.frame);
    titleL.frame = CGRectMake(ix, 0, (size.width-2*ix), _cancleBtn.frame.size.height);
    titleL.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    titleL.font = [UIFont systemFontOfSize:15];
    titleL.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:titleL];
    _titleL = titleL;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBgView:)];
    [self addGestureRecognizer:tap];
}

#pragma mark - Private
- (void)loadSelectedComponent{
    NSUInteger pIdx = [self lastSelectedProvinceIndex];
    NSUInteger cIdx = [self lastSelectedCityIndex];
    NSUInteger dIdx = [self lastSelectedDistrictIndex];

    [self.pickerView reloadAllComponents];
    if( pIdx < self.data1.count )
        [self.pickerView selectRow:pIdx inComponent:XW_APV_PROVINCE_COMPONENT animated:YES];
    if( cIdx <self.data2.count )
        [self.pickerView selectRow:cIdx inComponent:XW_APV_CITY_COMPONENT animated:YES];
    if( dIdx <self.data3.count )
        [self.pickerView selectRow:dIdx inComponent:XW_APV_DISTRICT_COMPONENT animated:YES];
}

- (void)configBtn:(UIButton*)btn{
    if( btn ){
        [btn setTitleColor:[UIColor colorWithRed:238/255.0 green:134/255.0 blue:53/255.0 alpha:1.0]
                  forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateHighlighted];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - TouchEvent

- (void)handleBgView:(UITapGestureRecognizer*)ges{
    [self hide];
}

- (void)handleBtn:(UIButton*)btn{
    if( btn.tag == XW_APV_SURE_BTN_TAG ){
        //sure
        if( _completeBlock ){
            
            NSUInteger pIdx = 0;
            NSUInteger cIdx = 0;
            NSUInteger dIdx = 0;
            NSInteger  num = [self numberOfComponentsInPickerView:self.pickerView];
            
            NSString *province = nil;
            NSUInteger idx = [self.pickerView selectedRowInComponent:XW_APV_PROVINCE_COMPONENT];
            pIdx = idx;
            if( self.data1.count > idx){
                province = self.data1[idx];
            }

            NSString *city = nil;
            if( num > XW_APV_CITY_COMPONENT )
                idx = [self.pickerView selectedRowInComponent:XW_APV_CITY_COMPONENT];
            cIdx = idx;
            if( self.data2.count > idx){
                city = self.data2[idx];
            }
            
            NSString *district = nil;
            if( num > XW_APV_DISTRICT_COMPONENT )
                idx = [self.pickerView selectedRowInComponent:XW_APV_DISTRICT_COMPONENT];
            dIdx = idx;
            if( self.data3.count > idx ){
                district = self.data3[idx];
            }
            
            [self updateSelectedAreaWithProvinceIndex:pIdx cityIndex:cIdx districtIndex:dIdx];
            if( _completeBlock )
                _completeBlock(pIdx, cIdx, dIdx);
        }
    }
    
    [self hide];
}

#pragma mark- PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSUInteger num = 0;
    if( self.data1 ) num++;
    if( self.data2 ) num ++;
    if( self.data3) num++;
    return num;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == XW_APV_PROVINCE_COMPONENT) {
        return [self.data1 count];
    }
    else if (component == XW_APV_CITY_COMPONENT) {
        return [self.data2 count];
    }
    else {
        return [self.data3 count];
    }
}


#pragma mark- PickerView Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == XW_APV_PROVINCE_COMPONENT) {
        return [self.data1 objectAtIndex: row];
    }
    else if (component == XW_APV_CITY_COMPONENT) {
        return [self.data2 objectAtIndex: row];
    }
    else {
        return [self.data3 objectAtIndex: row];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    NSInteger  num = [self numberOfComponentsInPickerView:pickerView];
    if( num ==0 ) return 0;
    
    
    CGFloat iw = [UIScreen mainScreen].bounds.size.width/num;
    if( num == 1 ) return iw;
    
    if (component == XW_APV_CITY_COMPONENT) {
        return iw;
    }
    else {
        return iw-40;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *lbl = nil;
    CGFloat iw = [UIScreen mainScreen].bounds.size.width/3;
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, iw, 30)];
    if (component == XW_APV_PROVINCE_COMPONENT) {
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.text = [self.data1 objectAtIndex:row];
    }
    else if (component == XW_APV_CITY_COMPONENT) {
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = [self.data2 objectAtIndex:row];
    }
    else {
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.text = [self.data3 objectAtIndex:row];
    }
    
    NSInteger  num = [self numberOfComponentsInPickerView:pickerView];
    if( num ==1 ) lbl.textAlignment = NSTextAlignmentCenter;
    
    lbl.font = [UIFont systemFontOfSize:15];
    lbl.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    lbl.backgroundColor = [UIColor clearColor];
    
    return lbl;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}

#pragma mark - Propertys

- (UIPickerView *)pickerView{
    if( !_pickerView ){
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.frame = CGRectMake(0, CGRectGetMaxY(self.sureBtn.frame), CGRectGetWidth(self.frame), 190);
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.showsSelectionIndicator = YES;
        _pickerView.userInteractionEnabled = YES;
        _pickerView.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
        line.frame = CGRectMake(0, 0, _pickerView.frame.size.width, 0.5);
        [_pickerView addSubview:line];
        
        [self.bgView addSubview:_pickerView];
    }
    return _pickerView;
}

- (UIButton *)cancleBtn {
    if( !_cancleBtn ){
        _cancleBtn = [[UIButton alloc] init];
        [_cancleBtn setTitle:NSLocalizedString(@"ReleaseCancel", nil) forState:UIControlStateNormal];//@"取消"
        _cancleBtn.tag = XW_APV_CANCLE_BTN_TAG;
        _cancleBtn.frame = CGRectMake(0, 0, 70, 40);
        [self configBtn:_cancleBtn];
        [self.bgView addSubview:_cancleBtn];
        [_cancleBtn setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    return _cancleBtn;
}

- (UIButton *)sureBtn {
    if( !_sureBtn ){
        _sureBtn = [[UIButton alloc] init];
        [_sureBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];//@"确定"
        _sureBtn.tag = XW_APV_SURE_BTN_TAG;
        CGFloat iw = self.cancleBtn.frame.size.width;
        _sureBtn.frame = CGRectMake(CGRectGetWidth(self.frame)-iw, CGRectGetMinY(self.cancleBtn.frame), iw, self.cancleBtn.frame.size.height);
        [self configBtn:_sureBtn];
        
        [self.bgView addSubview:_sureBtn];
    }
    return _sureBtn;
}

- (UIView*)bgView {
    if( !_bgView ){
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
//        [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        _bgView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 190+40);
        
        [self addSubview:_bgView];
    }
    return _bgView;
}

@end


@implementation XWPickerView(LastSelectedArea)

- (NSString*)lastSelectedAreaIndexesKey{
    return @"xwlastSelectedAreaIndexesKeyForPickerView";
}

- (void)updateSelectedAreaWithProvinceIndex:(NSUInteger)pIndex
                                  cityIndex:(NSUInteger)cIndex
                              districtIndex:(NSUInteger)dIndex{
    
    NSArray *indexes = @[@(pIndex), @(cIndex), @(dIndex)];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:indexes];
    [[NSUserDefaults standardUserDefaults] setObject:data
                                              forKey:[self lastSelectedAreaIndexesKey]];
}

- (NSUInteger)lastSelectedProvinceIndex{
    return [self lastIndexWithType:0];
}

- (NSUInteger)lastSelectedCityIndex{
    return [self lastIndexWithType:1];
}

- (NSUInteger)lastSelectedDistrictIndex{
    return [self lastIndexWithType:2];
}


#pragma mark - LastSelectedArea Private
- (NSArray*)lastSelectedAreaIndexes{
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[self lastSelectedAreaIndexesKey]];
    
    NSArray *indexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if( [indexes isKindOfClass:[NSArray class]] ){
        return indexes;
    }
    
    return nil;
}

/**
 *  type 0:省 1：城市 2：区
 *
 *  @param type
 *
 *  @return 索引
 */
- (NSUInteger)lastIndexWithType:(NSUInteger)type{
    NSArray *indexes = [self lastSelectedAreaIndexes];
    if( indexes.count> type)
    {
        if( [indexes[type] isKindOfClass:[NSNumber class]] ){
            return ((NSNumber*)(indexes[type])).integerValue;
        }
    }
    
    return 0;
}

@end










