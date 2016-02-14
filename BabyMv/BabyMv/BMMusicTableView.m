//
//  BMMusicTableView.m
//  BabyMv
//
//  Created by ma on 2/7/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMMusicTableView.h"
#import "BMTableViewCell.h"
#import "BMDataModel.h"
#import "BMDataBaseManager.h"
#import "BMDataCacheManager.h"
#import "Toast+UIView.h"

#import <AFHTTPRequestOperation.h>
#import <UIButton+WebCache.h>


@interface BMMusicTableView ()<UITableViewDelegate, UITableViewDataSource, BMTableViewCellDelegate>
@property(nonatomic, strong)NSMutableArray* items;
@end

@implementation BMMusicTableView

-(instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.items = [NSMutableArray new];
        self.myType = MyTableViewTypeMusic;
    }
    return self;
}

-(void)setItems:(NSMutableArray *)items {
    if (_items != items) {
        _items = items;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.items.count) {
        return self.items.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellReuseId = @"Cell";
    switch (self.myType) {
        case MyTableViewTypeMusic:
            cellReuseId = @"musicCell";
            break;
        case MyTableViewTypeCartoon:
            cellReuseId = @"cartoonCell";
            break;
        case MyTableViewTypeMusicDown:
            cellReuseId = @"musicDownload";
            break;
        case MyTableViewTypeCartoonDown:
            cellReuseId = @"cartoonDownload";
            break;
        case MyTableViewTypeFavorite:
            cellReuseId = @"favoriteDownload";
            break;
        case MyTableViewTypeHistory:
            cellReuseId = @"historyDownload";
            break;
        default:
            break;
    }
    BMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    if (!cell) {
        cell = [[BMTableViewCell alloc] initWithCellType:self.myType reuseIdentifier:cellReuseId];
        cell.cellDelegate = self;
    }
    
    switch (self.myType) {
        case MyTableViewTypeMusic: {
            BMListDataModel* cur_video = [self.items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            cell.downimg.tag = 3000+indexPath.row;
            [cell.downimg setImage:[UIImage imageNamed:@"download_cell"] forState:UIControlStateNormal];
            if ([cur_video.IsDowned intValue]) {
                [cell.downimg setImage:[UIImage imageNamed:@"downloadsuccess"] forState:UIControlStateNormal];
            }
            break;
        }
        case MyTableViewTypeMusicDown: {
            BMListDataModel* cur_video = [self.items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            cell.downimg.tag = 3000+indexPath.row;
            break;
        }
        case MyTableViewTypeCartoon: {
            BMCartoonListDataModel* cur_video = [self.items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            [cell.img sd_setImageWithURL:[NSURL URLWithString:cur_video.PicUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default"]];
            cell.downimg.tag = 3000+indexPath.row;
            [cell.downimg setImage:[UIImage imageNamed:@"download_cell"] forState:UIControlStateNormal];
            if ([cur_video.IsDowned intValue]) {
                [cell.downimg setImage:[UIImage imageNamed:@"downloadsuccess"] forState:UIControlStateNormal];
            }
            break;
        }
        case MyTableViewTypeCartoonDown: {
            BMCartoonListDataModel* cur_video = [self.items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            [cell.img sd_setImageWithURL:[NSURL URLWithString:cur_video.PicUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default"]];
            cell.downimg.tag = 3000+indexPath.row;
            break;
        }
        case MyTableViewTypeFavorite: {
            BMCollectionDataModel* cur_video = [self.items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            cell.downimg.tag = 3000+indexPath.row;
            break;
        }
        case MyTableViewTypeHistory: {
            BMListDataModel* cur_video = [self.items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            cell.downimg.tag = 3000+indexPath.row;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (self.myType) {
        case MyTableViewTypeMusic:
            return 30;
            break;
        case MyTableViewTypeCartoon:
            return 30;
            break;
        case MyTableViewTypeMusicDown:
            return 30;
            break;
        case MyTableViewTypeCartoonDown:
            return 30;
            break;
        case MyTableViewTypeFavorite:
            return 30;
            break;
        case MyTableViewTypeHistory:
            return 30;
            break;
        default:
            break;
            return 0.01;
    }
    return 0.01;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0;
//}
//
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 30)];
    //    view.backgroundColor = [UIColor darkGrayColor];
    UIView *segview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 5)];
    segview.backgroundColor = RGB(0xeeeeee, 1.0);
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, MAIN_WIDTH, 25)];
    titleLab.font = [UIFont systemFontOfSize:11.5];
    titleLab.backgroundColor = [UIColor whiteColor];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 29.5, MAIN_WIDTH, 0.5)];
    lineView.backgroundColor = RGB(0xe4e4e4, 1.0);
    [view addSubview:segview];
    [view addSubview:titleLab];
    [view addSubview:lineView];
    switch (self.myType) {
        case MyTableViewTypeMusic:
        case MyTableViewTypeCartoon:
            titleLab.text = @"最近更新";
            break;
        case MyTableViewTypeMusicDown:
            titleLab.text = @"我下载的儿歌";
            break;
        case MyTableViewTypeCartoonDown:
            titleLab.text = @"我下载的动画";
            break;
        case MyTableViewTypeFavorite:
            titleLab.frame = CGRectMake(XGAP, 5, MAIN_WIDTH-XGAP, 25);
            titleLab.text = @"收藏";
            break;
        case MyTableViewTypeHistory:
            titleLab.text = @"历史";
            break;
        default:
            break;
            return nil;
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    BMVideoInfo* video_info = [_listArray objectAtIndex:indexPath.row];
//    
//    if([BMVideoPlayList sharedInstance].listID != video_info.mvId){
//        [BMVideoPlayList sharedInstance].listID = video_info.mvId;
//        [[BMVideoPlayList sharedInstance] setPlayList:_listArray];
//    }
//    
//    [[BMVideoPlayList sharedInstance] setCurIndex:indexPath.row];
//    
//    BMVlcVideoPlayViewController* _video_play_view = [[BMVlcVideoPlayViewController alloc] initWithVideoInfo:video_info];
//    
//    [[BMAppDelegate sharedAppDelegate].mainViewController presentViewController:_video_play_view animated:NO completion:^{
//        NSLog(@"view did load");
//    }];
    
    switch (self.myType) {
        case MyTableViewTypeMusic:
            break;
        case MyTableViewTypeCartoon:
            break;
        case MyTableViewTypeMusicDown:
            break;
        case MyTableViewTypeCartoonDown:
            break;
        case MyTableViewTypeFavorite:
            break;
        case MyTableViewTypeHistory:
            break;
        default:
            break;
    }
}

#pragma mark cell delegate

- (void)download:(UIButton *)btn {
    NSUInteger index = btn.tag-3000;
    __block BMListDataModel* audio_info = self.items[index];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString*documentsDirectory = DOWNLOAD_DIR;
        NSString *name = [NSString stringWithFormat:@"%@.%@", audio_info.Rid, [audio_info.Url pathExtension]];
        NSString *musicPath =[documentsDirectory stringByAppendingPathComponent:name];
        NSLog(@"musicPath--------%@", musicPath);
        AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:audio_info.Url]]];
        operation1.outputStream = [NSOutputStream outputStreamToFileAtPath:musicPath append:NO];
        [operation1 start];
        [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            time_t now;
            time(&now);
            audio_info.IsDowned      = @(YES);
            audio_info.DownloadTime  = @([[NSDate date] timeIntervalSince1970]);
            
            if (self.myType == MyTableViewTypeMusic && [audio_info isKindOfClass:[BMListDataModel class]]) {
                [[BMDataBaseManager sharedInstance] downLoadMusicList:audio_info];
            }
            if (self.myType == MyTableViewTypeCartoon && [audio_info isKindOfClass:[BMCartoonListDataModel class]]) {
                BMCartoonListDataModel* cartoonListData = (BMCartoonListDataModel *)audio_info;
                [[BMDataBaseManager sharedInstance] downLoadCartoonList:cartoonListData];
            }

            [btn setImage:[UIImage imageNamed:@"downloadsuccess"] forState:UIControlStateNormal];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    });
}

-(void)deleteMusic:(UIButton *)btn {
    NSUInteger index = btn.tag-3000;
    switch (self.myType) {
        case MyTableViewTypeMusic:
            break;
        case MyTableViewTypeCartoon:
            break;
        case MyTableViewTypeMusicDown: {
            BMListDataModel* audio_info = self.items[index];
            audio_info.IsDowned = @(0);
            [BMDataCacheManager updateMusicListDataDownLoadStatus:audio_info];
            [self.items removeObject:audio_info];
            [self reloadData];
        }
            break;
        case MyTableViewTypeCartoonDown: {
            BMCartoonListDataModel* cartoonListData = self.items[index];
            cartoonListData.IsDowned = @(0);
            [BMDataCacheManager updateCartoonListDataDownLoadStatus:cartoonListData];
            [self.items removeObject:cartoonListData];
            [self reloadData];
            break;
        }
        case MyTableViewTypeFavorite:
            break;
        case MyTableViewTypeHistory:
            break;
        default:
            break;
    }
}

- (void)cancelFav:(UIButton *)btn {
    
}

- (void)deleteHistory:(UIButton *)btn {
    
}

@end


