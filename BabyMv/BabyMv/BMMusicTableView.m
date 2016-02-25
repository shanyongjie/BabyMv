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
#import "BMMusicListVC.h"
#import "BMMusicVC.h"
#import "BMCartoonVC.h"
#import "BMVlcVideoPlayViewController.h"

#import "Toast+UIView.h"
#import "UIView+UIViewController.h"
#import <AFHTTPRequestOperation.h>
#import <UIButton+WebCache.h>

#import "AudioPlayer/AudioPlayerAdapter.h"
#import "BSPlayList.h"
#import "iToast.h"

#define LIST_ID_DOWNLOAD           39999991
#define LIST_ID_HISTORY            39999992


@interface BMMusicTableView ()<UITableViewDelegate, UITableViewDataSource, BMTableViewCellDelegate>
@property(nonatomic, strong)NSMutableArray* items;
@property(nonatomic, strong)BMMusicListVC* musicListVC;
@property(nonatomic, strong)BMMusicListVC* cartoonListVC;
@property(nonatomic, strong)BMVlcVideoPlayViewController* vlcPlayer;
@property(nonatomic, strong)NSMutableSet* downloadingItems;
@end

@implementation BMMusicTableView

-(instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;

        _items = [NSMutableArray new];
        _myType = MyTableViewTypeMusic;
        _downloadingItems = [NSMutableSet new];
    }
    return self;
}

-(void)setSongItems:(NSArray *)items {
    [_items removeAllObjects];
    [_items addObjectsFromArray:items];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_items.count) {
        return _items.count;
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
        case MyTableVIewTypePlayList:
            cellReuseId = @"musicPlayListCell";
            break;
        default:
            break;
    }
    BMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    if (!cell) {
        cell = [[BMTableViewCell alloc] initWithCellType:_myType reuseIdentifier:cellReuseId];
        cell.cellDelegate = self;
    }
    
    switch (_myType) {
        case MyTableViewTypeMusic: {
            BMListDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            cell.downimg.tag = 3000+indexPath.row;
            [cell.downimg setImage:[UIImage imageNamed:@"download_cell"] forState:UIControlStateNormal];
            [cell.downimg addTarget:cell action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
            cell.downimg.enabled = YES;
            if ([cur_video.IsDowned intValue]) {
                [cell.downimg removeTarget:cell action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
                [cell.downimg setImage:[UIImage imageNamed:@"downloadsuccess"] forState:UIControlStateNormal];
                cell.downimg.enabled = NO;
            }
            BMListDataModel* currentPlayingMusic =  [BSPlayList sharedInstance].currentItem;
            cell.currentPlayingSign.hidden = YES;
            cell.selectedBGView.hidden = YES;
            if (currentPlayingMusic && [currentPlayingMusic.Rid isEqualToNumber:cur_video.Rid]) {
                cell.currentPlayingSign.hidden = NO;
                cell.selectedBGView.hidden = NO;
            }
            break;
        }
        case MyTableViewTypeMusicDown: {
            BMListDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            cell.downimg.tag = 3000+indexPath.row;
            BMListDataModel* currentPlayingMusic =  [BSPlayList sharedInstance].currentItem;
            cell.currentPlayingSign.hidden = YES;
            cell.selectedBGView.hidden = YES;
            if (currentPlayingMusic && [currentPlayingMusic.Rid isEqualToNumber:cur_video.Rid]) {
                cell.currentPlayingSign.hidden = NO;
                cell.selectedBGView.hidden = NO;
            }
            break;
        }
        case MyTableViewTypeCartoon: {
            BMCartoonListDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            [cell.img sd_setBackgroundImageWithURL:[NSURL URLWithString:cur_video.PicUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default"]];
            cell.downimg.tag = 3000+indexPath.row;
            [cell.downimg setImage:[UIImage imageNamed:@"download_cell"] forState:UIControlStateNormal];
            [cell.downimg addTarget:cell action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
            cell.downimg.enabled = YES;
            if ([cur_video.IsDowned intValue]) {
                [cell.downimg removeTarget:cell action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
                [cell.downimg setImage:[UIImage imageNamed:@"downloadsuccess"] forState:UIControlStateNormal];
                cell.downimg.enabled = NO;
            }
            
            break;
        }
        case MyTableViewTypeCartoonDown: {
            BMCartoonListDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            [cell.img sd_setBackgroundImageWithURL:[NSURL URLWithString:cur_video.PicUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default"]];
            cell.downimg.tag = 3000+indexPath.row;
            break;
        }
        case MyTableViewTypeFavorite: {
            BMCollectionDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            cell.downimg.tag = 3000+indexPath.row;
            break;
        }
        case MyTableViewTypeHistory: {
            BMListDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            cell.downimg.tag = 3000+indexPath.row;
            BMListDataModel* currentPlayingMusic =  [BSPlayList sharedInstance].currentItem;
            cell.currentPlayingSign.hidden = YES;
            cell.selectedBGView.hidden = YES;
            if (currentPlayingMusic && [currentPlayingMusic.Rid isEqualToNumber:cur_video.Rid]) {
                cell.currentPlayingSign.hidden = NO;
                cell.selectedBGView.hidden = NO;
            }
            break;
        }
        case MyTableVIewTypePlayList: {
            BMListDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            cell.titleLab.text = cur_video.Name;
            cell.detailLab.text = cur_video.Artist;
            cell.downimg.tag = 3000+indexPath.row;
            [cell.downimg setImage:[UIImage imageNamed:@"download_cell"] forState:UIControlStateNormal];
            if ([cur_video.IsDowned intValue]) {
                [cell.downimg setImage:[UIImage imageNamed:@"downloadsuccess"] forState:UIControlStateNormal];
            }
            BMListDataModel* currentPlayingMusic =  [BSPlayList sharedInstance].currentItem;
            cell.currentPlayingSign.hidden = YES;
            cell.selectedBGView.hidden = YES;
            if (currentPlayingMusic && [currentPlayingMusic.Rid isEqualToNumber:cur_video.Rid]) {
                cell.currentPlayingSign.hidden = NO;
                cell.selectedBGView.hidden = NO;
            }
            break;
        }
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            return 0;
            break;
        case MyTableVIewTypePlayList:
            return 0;
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
        case MyTableVIewTypePlayList:
            return nil;
        default:
            break;
            return nil;
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.myType) {
        case MyTableViewTypeMusic:
        {
            BMListDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            
            if (cur_video.CollectionId != [BSPlayList sharedInstance].listID) {
                [[BSPlayList sharedInstance] setPlayList:_items];
                [[BSPlayList sharedInstance] setListID:[cur_video.CollectionId intValue]];
                [[BSPlayList sharedInstance] savePlaylist];
            }
            
            [[BSPlayList sharedInstance] setCurIndex:indexPath.row];
            [[AudioPlayerAdapter sharedPlayerAdapter] playRingtoneItem:cur_video inList:[cur_video.CollectionId intValue] delegate:nil];
            
            break;
        }
        case MyTableViewTypeMusicDown:
        {
            if (LIST_ID_DOWNLOAD != [BSPlayList sharedInstance].listID) {
                [[BSPlayList sharedInstance] setPlayList:_items];
                [[BSPlayList sharedInstance] setListID:LIST_ID_DOWNLOAD];
                [[BSPlayList sharedInstance] savePlaylist];
            }
            
            BMListDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            [[BSPlayList sharedInstance] setCurIndex:indexPath.row];
            [[AudioPlayerAdapter sharedPlayerAdapter] playRingtoneItem:cur_video inList:LIST_ID_DOWNLOAD delegate:nil];
            break;
        }
        case MyTableVIewTypePlayList:
        {
            BMListDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            [[BSPlayList sharedInstance] setCurIndex:indexPath.row];
            [[AudioPlayerAdapter sharedPlayerAdapter] playRingtoneItem:cur_video inList:[BSPlayList sharedInstance].listID delegate:nil];
            break;
        }
        case MyTableViewTypeHistory: {
//            [BMDataCacheManager setCurrentPlayingList:[NSArray arrayWithArray:self.items]];
            if (LIST_ID_HISTORY != [BSPlayList sharedInstance].listID) {
                [[BSPlayList sharedInstance] setPlayList:_items];
                [[BSPlayList sharedInstance] setListID:LIST_ID_HISTORY];
                [[BSPlayList sharedInstance] savePlaylist];
            }
            
            BMListDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            [[BSPlayList sharedInstance] setCurIndex:indexPath.row];
            [[AudioPlayerAdapter sharedPlayerAdapter] playRingtoneItem:cur_video inList:LIST_ID_HISTORY delegate:nil];
            break;
        }
        case MyTableViewTypeCartoon:
        case MyTableViewTypeCartoonDown: {
            [[AudioPlayerAdapter sharedPlayerAdapter] pause];
            [BMDataCacheManager setCurrentPlayingList:[NSArray arrayWithArray:_items]];
            BMCartoonListDataModel* cur_video = [_items objectAtIndex:indexPath.row];
            _vlcPlayer = [[BMVlcVideoPlayViewController alloc] init];
            [_vlcPlayer setVideoInfo:cur_video index:indexPath.row videoList:[BMDataCacheManager currentPlayingList]];
#warning Oriention!!!
            //only use presentViewController: animated: completion: method can generate new VC to control it's own Oriention!!!
            [self.viewController.navigationController presentViewController:_vlcPlayer animated:YES completion:nil];
            break;
        }
        case MyTableViewTypeFavorite: {
            BMDataModel* collection = [_items objectAtIndex:indexPath.row];
            if ([collection isKindOfClass:[BMCartoonCollectionDataModel class]]) {
                BMCartoonCollectionDataModel *collectModel = (BMCartoonCollectionDataModel *)collection;
                _cartoonListVC = [BMMusicListVC new];
                _cartoonListVC.vcType = MyListVCTypeCartoon;
                _cartoonListVC.currentCartoonCollectionData = collectModel;
                [self.viewController.navigationController pushViewController:_cartoonListVC animated:YES];
                return;
            }
            if ([collection isKindOfClass:[BMCollectionDataModel class]]) {
                BMCollectionDataModel *collectModel = (BMCollectionDataModel *)collection;
                _musicListVC = [BMMusicListVC new];
                _musicListVC.vcType = MyListVCTypeMusic;
                _musicListVC.currentCollectionData = collectModel;
                [self.viewController.navigationController pushViewController:_musicListVC animated:YES];
                return;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark cell delegate

- (void)download:(UIButton *)btn {
    NSUInteger index = btn.tag-3000;

    __block BMListDataModel* audio_info = _items[index];
    
    if ([self.downloadingItems containsObject:audio_info]) {
        [iToast defaultShow:@"已经加入下载队列"];
        return;
    }
    
    [self.downloadingItems addObject:audio_info];
    __weak BMMusicTableView* SELF = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString*documentsDirectory = DOWNLOAD_DIR;
        NSString *name = [NSString stringWithFormat:@"%@.%@", audio_info.Rid, [audio_info.Url pathExtension]];
        NSString *musicPath =[documentsDirectory stringByAppendingPathComponent:name];
        NSLog(@"musicPath--------%@", musicPath);
        AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:audio_info.Url]]];
        operation1.outputStream = [NSOutputStream outputStreamToFileAtPath:musicPath append:NO];
        [operation1 start];
        [operation1 setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            [btn setImage:nil forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            NSUInteger percent = 100.0*totalBytesRead/totalBytesExpectedToRead;
            NSLog(@"percent::%lu%", (unsigned long)percent);
            switch (percent) {
                case 0:
                case 10:
                case 20:
                case 30:
                case 40:
                case 50:
                case 60:
                case 70:
                case 80:
                case 90:
                case 100: {
                    NSString* str = [[NSString stringWithFormat:@"%lu", (unsigned long)percent] stringByAppendingString:@"%"];
                    [btn setTitle:str forState:UIControlStateNormal];
                    break;
                }
                default:
                    break;
            }
        }];
        [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            time_t now;
            time(&now);
            audio_info.IsDowned      = [NSNumber numberWithBool:YES];
            audio_info.DownloadTime  = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
            
            if (self.myType == MyTableViewTypeMusic && [audio_info isKindOfClass:[BMListDataModel class]]) {
                [[BMDataBaseManager sharedInstance] downLoadMusicList:audio_info];
            }
            if (self.myType == MyTableViewTypeCartoon && [audio_info isKindOfClass:[BMCartoonListDataModel class]]) {
                BMCartoonListDataModel* cartoonListData = (BMCartoonListDataModel *)audio_info;
                [[BMDataBaseManager sharedInstance] downLoadCartoonList:cartoonListData];
            }

            [btn setImage:[UIImage imageNamed:@"downloadsuccess"] forState:UIControlStateNormal];
            btn.enabled = NO;
            [SELF.downloadingItems removeObject:audio_info];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [iToast defaultShow:@"下载失败"];
            [SELF.downloadingItems removeObject:audio_info];
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
            BMListDataModel* audio_info = _items[index];
            audio_info.IsDowned = [NSNumber numberWithInt:0];
            [BMDataCacheManager updateMusicListDataDownLoadStatus:audio_info];
            NSString*documentsDirectory = DOWNLOAD_DIR;
            NSString *name = [NSString stringWithFormat:@"%@.%@", audio_info.Rid, [audio_info.Url pathExtension]];
            NSString *musicPath =[documentsDirectory stringByAppendingPathComponent:name];
            [[NSFileManager defaultManager] removeItemAtPath:musicPath error:nil];
            [_items removeObject:audio_info];
            [self reloadData];
            NSDictionary* dic = @{@"collectionId":audio_info.CollectionId};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABLEVIEW_OF_MUSICVC object:dic];
        }
            break;
        case MyTableViewTypeCartoonDown: {
            BMCartoonListDataModel* cartoonListData = _items[index];
            cartoonListData.IsDowned = [NSNumber numberWithInt:0];
            [BMDataCacheManager updateCartoonListDataDownLoadStatus:cartoonListData];
            NSString*documentsDirectory = DOWNLOAD_DIR;
            NSString *name = [NSString stringWithFormat:@"%@.%@", cartoonListData.Rid, [cartoonListData.Url pathExtension]];
            NSString *musicPath =[documentsDirectory stringByAppendingPathComponent:name];
            [[NSFileManager defaultManager] removeItemAtPath:musicPath error:nil];
            [_items removeObject:cartoonListData];
            [self reloadData];
            NSDictionary* dic = @{@"collectionId":cartoonListData.CollectionId};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABLEVIEW_OF_CARTOONVC object:dic];
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
    NSUInteger index = btn.tag-3000;
    switch (self.myType) {
        case MyTableViewTypeMusic:
            break;
        case MyTableViewTypeCartoon:
            break;
        case MyTableViewTypeMusicDown: {
            BMCollectionDataModel* collection_info = _items[index];
            collection_info.IsFaved = [NSNumber numberWithInt:0];
            [[BMDataBaseManager sharedInstance] favMusicCollection:collection_info];
            [_items removeObject:collection_info];
            [self reloadData];
        }
            break;
        case MyTableViewTypeCartoonDown: {
            BMCartoonCollectionDataModel* collection_info = _items[index];
            collection_info.IsFaved = [NSNumber numberWithInt:0];
            [[BMDataBaseManager sharedInstance] favCartoonCollection:collection_info];
            [_items removeObject:collection_info];
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

- (void)deleteHistory:(UIButton *)btn {
    NSUInteger index = btn.tag-3000;
    switch (self.myType) {
        case MyTableViewTypeMusic:
        case MyTableViewTypeMusicDown:
        case MyTableViewTypeHistory: {
            BMListDataModel* cur_video = [_items objectAtIndex:index];
            cur_video.LastListeningTime = [NSNumber numberWithInt:NSTimeIntervalSince1970];
            [[BMDataBaseManager sharedInstance] listenMusicList:cur_video];
            [_items removeObject:cur_video];
            [self reloadData];
            break;
        }
        case MyTableViewTypeCartoon:
        case MyTableViewTypeCartoonDown: {
            break;
        }
        case MyTableViewTypeFavorite:
            break;
        default:
            break;
    }
}

@end


