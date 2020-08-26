//
//  TSSelectMusicCell.m
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSSelectMusicCell.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSSelectMusicModel.h"

@interface TSSelectMusicCell()
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel  *nameL;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) UIView *line;
@end

@implementation TSSelectMusicCell

- (id)initReportCellWithReuseID:(NSString *)rid{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rid];
    if( self ){
        self.isReportCell = YES;
    }
    return self;
}

- (void)setModel:(TSSelectMusicModel *)model{
    _model = model;
    self.nameL.text = model.name;
    self.playBtn.selected = model.isPlaying;
    self.selectBtn.selected = model.isPlaying;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.selectBtn.selected = selected;
    self.playBtn.selected = selected;
}

- (void)layoutSubviews{
    CGSize size = self.size;
    
    CGFloat ix = 5,iw= 38;
    self.playBtn.frame = CGRectMake(ix, 0, iw, size.height);
    self.selectBtn.frame = CGRectMake(size.width-iw-ix, 0, iw, size.height);
    
    ix = _playBtn.right;
    if( _isReportCell ){
        ix = 15;
        _playBtn.frame = CGRectZero;
    }
    self.nameL.frame = CGRectMake(ix, 0, _selectBtn.x-ix, size.height);
    ix = 15;
    self.line.frame = CGRectMake(ix, 0, size.width-2*ix, 0.5);
}

#pragma mark - TouchEvents
- (void)handlePlayBtn:(UIButton*)btn{
    
}

- (void)handleSelectBtn:(UIButton*)btn{
    
}

#pragma mark - Properts
- (UIButton *)playBtn {
    if( !_playBtn ){
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"edit_music_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"edit_music_pause"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(handlePlayBtn:) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_playBtn];
    }
    return _playBtn;
}

- (UIButton *)selectBtn {
    if( !_selectBtn ){
        _selectBtn = [[UIButton alloc] init];
        [_selectBtn setImage:[UIImage imageNamed:@"edit_music_check_n"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"edit_music_check_s"] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(handleSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
        _selectBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_selectBtn];
    }
    return _selectBtn;
}

- (UILabel *)nameL {
    if( !_nameL ){
        _nameL = [[UILabel alloc] init];
        _nameL.textColor = [UIColor colorWithRgb51];
        _nameL.font = [UIFont systemFontOfSize:15];
        
        [self.contentView addSubview:_nameL];
    }
    return _nameL;
}

- (UIView *)line {
    if( !_line ){
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor colorWithRgb221];
        
        [self.contentView addSubview:_line];
    }
    return _line;
}

@end
