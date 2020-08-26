//
//  TSLanguageSetView.m
//  ThreeShow
//
//  Created by wkun on 2020/1/1.
//  Copyright © 2020 deepai. All rights reserved.
//

#import "TSLanguageSetView.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+Ext.h"
#import "TSLanguageModel.h"

@interface TSLanguageSetView()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation TSLanguageSetView
{
    void(^_complete)(void);
    NSArray *_datas;
    
    TSLanguageModel *_selectedModel;
    TSLanguageModel *_startModel;     //最开始的语言
    UITableView *_tableView;
}

+ (void)showWithComplete:(void (^)(void))complete{
    TSLanguageSetView *sv = [TSLanguageSetView new];
    sv->_datas = [TSLanguageModel languageDatas];
    sv->_complete = complete;
    
    sv.frame = [sv frameWithDatas:sv->_datas];
    [sv setupUI];
    
    sv.backgroundColor = [UIColor whiteColor];
    [sv cornerRadius:5];
    [sv bolderWidth:0.5];
    [sv bolderColor:[UIColor colorWithRgb238]];
    
    [sv loadData];
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    bgView.frame = [UIScreen mainScreen].bounds;
    
    [bgView addSubview:sv];
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
}

- (void)loadData{
    [_tableView reloadData];
    
    NSInteger idx = [TSLanguageModel currLanguageModelIndex];
    if( idx >=0 && idx < _datas.count ){
        _startModel = _datas[idx];
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:(UITableViewScrollPositionNone)];
    }
}

#pragma mark - TouchEvents
- (void)handleSureBtn{
    [self handleCancleBtn];
    
    if( _selectedModel == nil || _selectedModel == _startModel ){
        return;
    }
    
    if( _complete ){
        [TSLanguageModel setLanguageWithModel:_selectedModel];
        _complete();
    }
}

- (void)handleCancleBtn{
    [self.superview removeFromSuperview];
}

#pragma mark - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseId = @"reusedCellId";
    TSLanguageSetViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if( !cell ){
        cell = [[TSLanguageSetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.model = _datas[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TSLanguageSetViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    _selectedModel = cell.model;
}

#pragma mark - Private
- (CGRect)frameWithDatas:(NSArray*)datas{
    CGSize size =[UIScreen mainScreen].bounds.size;
    CGFloat iw = 230;
    CGFloat maxH = size.height - 70*2;
    CGFloat minH = 2*35 + 100;
    CGFloat ih = datas.count*35+100;
    if( ih > maxH ) ih = maxH;
    if( ih < minH ) ih = minH;
    
    CGRect fr = CGRectMake(size.width/2-iw/2, size.height/2-ih/2, iw, ih);
    
    return fr;
}

- (void)setupUI{
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    [self addSubview:_tableView];

    if (@available(iOS 11.0, *)) {
       _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
       _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    
    UILabel *titleL = [UILabel new];
    titleL.font = [UIFont systemFontOfSize:16];
    titleL.textColor = [UIColor colorWithRgb51];
    titleL.text = NSLocalizedString(@"PersonLanguageSetTitleKey", nil);
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 50);
    [self addSubview:titleL];

    //取消按钮
    UIButton *cancleBtn = [UIButton new];
    [cancleBtn setTitle:NSLocalizedString(@"SearchCancleText", nil) forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancleBtn addTarget:self action:@selector(handleCancleBtn) forControlEvents:UIControlEventTouchUpInside];
    CGFloat ih = 45, iw = self.frame.size.width/2;
    CGFloat iy = self.frame.size.height-ih;
    cancleBtn.frame = CGRectMake(0, iy, iw, ih);
    [self addSubview:cancleBtn];
    
    //确认按钮
    UIButton *sureBtn = [UIButton new];
    [sureBtn setTitle:NSLocalizedString(@"ClearBgSelectDeviceBtnTitleSure", nil) forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor colorWithRgb_250_100_92] forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [sureBtn addTarget:self action:@selector(handleSureBtn) forControlEvents:UIControlEventTouchUpInside];
    sureBtn.frame = CGRectMake(iw, iy, iw, ih);
    [self addSubview:sureBtn];
    
    [sureBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_disable220"] forState:UIControlStateHighlighted];
    [cancleBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_disable220"] forState:UIControlStateHighlighted];
    
    //顶部线条
    UIView *topLine = [UIView new];
    topLine.frame = CGRectMake(0, iy, iw*2, 0.5);
    topLine.backgroundColor = [UIColor colorWithRgb238];
    [self addSubview:topLine];
    
    //按钮中间线条
    UIView *midLine = [UIView new];
    midLine.frame = CGRectMake(iw, iy+ih/4, 0.5, ih/2);
    midLine.backgroundColor = [UIColor colorWithRgb238];
    [self addSubview:midLine];
    
    _tableView.frame = CGRectMake(0, titleL.bottom, titleL.width, sureBtn.y-titleL.bottom);
}

@end


@implementation TSLanguageSetViewCell{
    UIImageView *_imgView;
    UILabel *_nameL;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self ){
        [self setupUI];
    }
    return self;
}

- (void)setModel:(TSLanguageModel *)model{
    _model = model;
    _nameL.text = model.languageName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    
    _imgView.image = [UIImage imageNamed:selected?@"radiobutton_s":@"radiobutton"];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat ix = 15, iw = 15, ih = 15;
    _imgView.frame = CGRectMake(self.width-ix-iw, self.height/2-ih/2, iw, ih);
    _nameL.frame = CGRectMake(ix, 0, _imgView.x-ix, self.height);
}

#pragma mark - SetupUI
- (void)setupUI{
    _nameL = [UILabel new];
    _nameL.textColor = [UIColor colorWithRgb51];
    _nameL.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_nameL];
    
    _imgView = [UIImageView new];
    [self.contentView addSubview:_imgView];
}

@end
