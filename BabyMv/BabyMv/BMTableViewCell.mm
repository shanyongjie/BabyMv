//
//  BMTableViewCell.m
//  BabyMv
//
//  Created by mayzh on 7/22/15.
//  Copyright (c) 2015 happybaby. All rights reserved.
//

#import "BMTableViewCell.h"


@interface BMTableViewCell ()
@end

@implementation BMTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//    self.currentPlayingSign.hidden = YES;
////    self.selectedBGView.hidden = YES;
//    if (selected) {
//        self.currentPlayingSign.hidden = NO;
////        self.selectedBGView.hidden = NO;
//    }
//}

-(instancetype)initWithCellType:(MyTableViewType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    switch (cellType) {
        case MyTableViewTypeMusic:
        case MyTableViewTypeMusicDown:
        case MyTableViewTypeHistory:
        case MyTableVIewTypePlayList:
            return [self initMusicCellWithStyle:UITableViewCellStyleDefault cellType:cellType reuseIdentifier:reuseIdentifier];
            break;
        case MyTableViewTypeFavorite:
        case MyTableViewTypeCartoon:
        case MyTableViewTypeCartoonDown:
            return [self initCartoonCellWithStyle:UITableViewCellStyleDefault cellType:cellType reuseIdentifier:reuseIdentifier];
            break;
        default:
            return nil;
            break;
    }
}

- (instancetype)initMusicCellWithStyle:(UITableViewCellStyle)style cellType:(MyTableViewType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _indexLab = [[UILabel alloc] initWithFrame:CGRectMake(10, (54-15)/2, 32, 15)];
//        _indexLab.text = [NSString stringWithFormat:@"112"];
        _indexLab.font = [UIFont systemFontOfSize:15];
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(42, 10, MAIN_BOUNDS_WIDTH - 42 -10-10-38, 15)];
        _titleLab.textColor = RGB(0x1b1b1b, 1.0);
        _titleLab.font = [UIFont systemFontOfSize:15];
        _detailLab = [[UILabel alloc] initWithFrame:CGRectMake(42, 35, 100, 12)];
        _detailLab.textColor = RGB(0xababab, 1.0);
        _detailLab.font = [UIFont systemFontOfSize:12];
        _downimg = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BOUNDS_WIDTH-10-38, 11.5, 38, 38)];
        [_downimg.titleLabel setFont:[UIFont systemFontOfSize:13]];
        _cellLineView = [[UIView alloc] initWithFrame:CGRectMake(42, 54.5, MAIN_BOUNDS_WIDTH-42, 0.5)];
        _cellLineView.backgroundColor = CellLineColor;
        
        if (MyTableViewTypeMusic == cellType) {
            [_downimg setImage:[UIImage imageNamed:@"download_cell"] forState:UIControlStateNormal];
            [_downimg addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
        }else if (MyTableVIewTypePlayList == cellType) {
            [_downimg setImage:[UIImage imageNamed:@"download_cell"] forState:UIControlStateNormal];
            [_downimg addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
//            [_downimg addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
        } else if (MyTableViewTypeMusicDown == cellType) {
            [_downimg setImage:[UIImage imageNamed:@"delete_cell"] forState:UIControlStateNormal];
            [_downimg addTarget:self action:@selector(deleteMusic:) forControlEvents:UIControlEventTouchUpInside];
        } else if (MyTableViewTypeFavorite == cellType) {
            [_downimg setImage:[UIImage imageNamed:@"delete_cell"] forState:UIControlStateNormal];
            [_downimg addTarget:self action:@selector(cancelFav:) forControlEvents:UIControlEventTouchUpInside];
        } else if (MyTableViewTypeHistory == cellType) {
            [_downimg setImage:[UIImage imageNamed:@"delete_cell"] forState:UIControlStateNormal];
            [_downimg addTarget:self action:@selector(deleteHistory:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        _currentPlayingSign = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 4, 54.5)];
        _currentPlayingSign.backgroundColor = RGB(0xf4ad00, 1.0);
        _currentPlayingSign.enabled = NO;
        _currentPlayingSign.hidden = YES;
        _selectedBGView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, VIEW_DEFAULT_WIDTH-5, 54.5)];
        [_selectedBGView setBackgroundColor:RGB(0xfff8e1, 1.0)];
        _selectedBGView.hidden = YES;
        [self.contentView addSubview:_selectedBGView];
        [self.contentView addSubview:_indexLab];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_detailLab];
        [self.contentView addSubview:_downimg];
        [self.contentView addSubview:_currentPlayingSign];
        [self.contentView addSubview:_cellLineView];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, VIEW_DEFAULT_WIDTH-5, self.frame.size.height)];
        [self.selectedBackgroundView setBackgroundColor:RGB(0xfff8e1, 1.0)];
    }
    return self;
}

- (instancetype)initCartoonCellWithStyle:(UITableViewCellStyle)style cellType:(MyTableViewType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _img = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 90, 50)];
        _img.layer.borderWidth = 1;
        _img.layer.cornerRadius = 3;
        _img.layer.borderColor = RGB(0xe8e8e8, 1.0).CGColor;

        _indexLab = [[UILabel alloc] initWithFrame:CGRectMake(90+20, 12, 32, 15)];
//        _indexLab.text = [NSString stringWithFormat:@"112"];
        _indexLab.font = [UIFont systemFontOfSize:15];
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(90+40, 12,  MAIN_BOUNDS_WIDTH - 90 - 40 -20-10-38, 15)];
        _titleLab.textColor = RGB(0x1b1b1b, 1.0);
        _titleLab.font = [UIFont systemFontOfSize:15];
        _detailLab = [[UILabel alloc] initWithFrame:CGRectMake(90+20, 35, 100, 12)];
        _detailLab.textColor = RGB(0xababab, 1.0);
        _detailLab.font = [UIFont systemFontOfSize:12];
        _downimg = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BOUNDS_WIDTH-10-38, 11, 38, 38)];
        _cellLineView = [[UIView alloc] initWithFrame:CGRectMake(90+20, 59.5, MAIN_BOUNDS_WIDTH-90-20, 0.5)];
        _cellLineView.backgroundColor = CellLineColor;

        _downimg.hidden = NO;
        _indexLab.hidden = NO;
        if (MyTableViewTypeCartoon == cellType) {
            [_downimg setImage:[UIImage imageNamed:@"download_cell"] forState:UIControlStateNormal];
//            [_downimg addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
        } else if (MyTableViewTypeCartoonDown == cellType) {
            [_downimg setImage:[UIImage imageNamed:@"delete_cell"] forState:UIControlStateNormal];
            [_downimg addTarget:self action:@selector(deleteMusic:) forControlEvents:UIControlEventTouchUpInside];
        } else if (MyTableViewTypeFavorite == cellType) {
            _downimg.hidden = YES;
            _indexLab.hidden = YES;
        }
        
        [self.contentView addSubview:_img];
        [self.contentView addSubview:_indexLab];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_detailLab];
        [self.contentView addSubview:_downimg];
        [self.contentView addSubview:_cellLineView];
    }
    return self;
}

- (void)download:(UIButton *)btn {
    if ([_cellDelegate respondsToSelector:@selector(download:)]) {
        [_cellDelegate download:btn];
    }
}

- (void)deleteMusic:(UIButton *)btn {
    if ([_cellDelegate respondsToSelector:@selector(deleteMusic:)]) {
        [_cellDelegate deleteMusic:btn];
    }
}

- (void)cancelFav:(UIButton *)btn {
    if ([_cellDelegate respondsToSelector:@selector(cancelFav:)]) {
        [_cellDelegate cancelFav:btn];
    }
}

- (void)deleteHistory:(UIButton *)btn {
    if ([_cellDelegate respondsToSelector:@selector(deleteHistory:)]) {
        [_cellDelegate deleteHistory:btn];
    }
}


@end





