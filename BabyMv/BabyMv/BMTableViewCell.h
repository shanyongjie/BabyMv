//
//  BMTableViewCell.h
//  BabyMv
//
//  Created by mayzh on 7/22/15.
//  Copyright (c) 2015 happybaby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroDefinition.h"

@protocol BMTableViewCellDelegate <NSObject>
- (void)download:(UIButton *)btn;
- (void)deleteMusic:(UIButton *)btn;
@end

@interface BMTableViewCell : UITableViewCell
@property (strong, nonatomic) UIButton *img;
@property (strong, nonatomic) UILabel *indexLab;
@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UILabel *detailLab;
@property (strong, nonatomic) UIButton *downimg;
@property (strong, nonatomic) UIButton *currentPlayingSign;
@property (weak, nonatomic) id<BMTableViewCellDelegate> cellDelegate;

-(instancetype)initWithCellType:(MyTableViewType)cellType reuseIdentifier:(NSString *)reuseIdentifier;
@end
