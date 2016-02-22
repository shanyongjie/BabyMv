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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithCellType:(MyTableViewType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    switch (cellType) {
        case MyTableViewTypeMusic:
        case MyTableViewTypeMusicDown:
        case MyTableViewTypeFavorite:
        case MyTableViewTypeHistory:
        case MyTableVIewTypePlayList:
            return [self initMusicCellWithStyle:UITableViewCellStyleDefault cellType:cellType reuseIdentifier:reuseIdentifier];
            break;
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
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(42, 10, MAIN_BOUNDS_WIDTH - 42 -10-10-31.5, 15)];
//        _titleLab.text = @"数鸭子";
        _titleLab.font = [UIFont systemFontOfSize:15];
        _detailLab = [[UILabel alloc] initWithFrame:CGRectMake(42, 35, 100, 12)];
//        _detailLab = @"合集  播放25万";
        _detailLab.font = [UIFont systemFontOfSize:12];
        _downimg = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BOUNDS_WIDTH-10-31.5, 11.5, 31.5, 31.5)];
        if (MyTableViewTypeMusic == cellType) {
            [_downimg setImage:[UIImage imageNamed:@"download_cell"] forState:UIControlStateNormal];
            [_downimg addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
        }else if (MyTableVIewTypePlayList == cellType) {
            [_downimg setImage:[UIImage imageNamed:@"download_cell"] forState:UIControlStateNormal];
            [_downimg addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
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
        
        _currentPlayingSign = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 4, self.frame.size.height)];
        _currentPlayingSign.backgroundColor = RGB(0xf4ad00, 1.0);
        _currentPlayingSign.enabled = NO;
        _currentPlayingSign.hidden = YES;
        [self.contentView addSubview:_indexLab];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_detailLab];
        [self.contentView addSubview:_downimg];
        [self.contentView addSubview:_currentPlayingSign];
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        [self.selectedBackgroundView setBackgroundColor:RGB(0xfff8e1, 1.0)];
    }
    return self;
}

- (instancetype)initCartoonCellWithStyle:(UITableViewCellStyle)style cellType:(MyTableViewType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _img = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 90, 50)];
        _img.layer.borderWidth = 1;
        _img.layer.borderColor = [UIColor blackColor].CGColor;

        _indexLab = [[UILabel alloc] initWithFrame:CGRectMake(90+20, 12, 32, 15)];
//        _indexLab.text = [NSString stringWithFormat:@"112"];
        _indexLab.font = [UIFont systemFontOfSize:15];
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(90+42, 12,  MAIN_BOUNDS_WIDTH - 90 - 42 -20-10-31.5, 15)];
//        _titleLab.text = @"数鸭子";
        _titleLab.font = [UIFont systemFontOfSize:15];
        _detailLab = [[UILabel alloc] initWithFrame:CGRectMake(90+42, 35, 100, 12)];
//        _detailLab.text = @"合集  播放25万";
        _detailLab.font = [UIFont systemFontOfSize:12];
        _downimg = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BOUNDS_WIDTH-10-31.5, 11, 38, 38)];
        if (MyTableViewTypeCartoon == cellType) {
            [_downimg setImage:[UIImage imageNamed:@"download_cell"] forState:UIControlStateNormal];
            [_downimg addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
        } else if (MyTableViewTypeCartoonDown == cellType) {
            [_downimg setImage:[UIImage imageNamed:@"delete_cell"] forState:UIControlStateNormal];
            [_downimg addTarget:self action:@selector(deleteMusic:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.contentView addSubview:_img];
        [self.contentView addSubview:_indexLab];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_detailLab];
        [self.contentView addSubview:_downimg];
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





