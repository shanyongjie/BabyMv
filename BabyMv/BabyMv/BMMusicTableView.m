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
#import "Toast+UIView.h"

#import <AFHTTPRequestOperation.h>

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
    BMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[BMTableViewCell alloc] initMusicCellWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.cellDelegate = self;
    }
    BMListDataModel* cur_video = [self.items objectAtIndex:indexPath.row];
//    [cell.img sd_setImageWithURL:[NSURL URLWithString:cur_video.picUrl] placeholderImage:[UIImage imageNamed:@"default"]];
    cell.indexLab.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
    cell.titleLab.text = cur_video.Name;
    cell.detailLab.text = cur_video.Artist;
    cell.downimg.tag = 3000+indexPath.row;
    if (cur_video.IsDowned) {
        [cell.downimg setImage:[UIImage imageNamed:@"downloadsuccess"] forState:UIControlStateNormal];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
//
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0;
//}
//
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 30)];
//    //    view.backgroundColor = [UIColor darkGrayColor];
//    UIView *segview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 5)];
//    segview.backgroundColor = RGB(0xeeeeee, 1.0);
//    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, MAIN_WIDTH, 25)];
//    titleLab.font = [UIFont systemFontOfSize:11.5];
//    titleLab.text = @"最近更新";
//    titleLab.backgroundColor = [UIColor whiteColor];
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 29.5, MAIN_WIDTH, 0.5)];
//    lineView.backgroundColor = RGB(0xe4e4e4, 1.0);
//    [view addSubview:segview];
//    [view addSubview:titleLab];
//    [view addSubview:lineView];
//    return view;
    return nil;
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
}

#pragma mark cell delegate

- (void)download:(UIButton *)btn {
    NSUInteger index = btn.tag-3000;
    __block BMListDataModel* audio_info = self.items[index];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString*documentsDirectory =[paths objectAtIndex:0];
        NSString *name = [NSString stringWithFormat:@"%@.mp3", audio_info.Rid];
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
            [[BMDataBaseManager sharedInstance] downLoadMusicList:audio_info];
            [btn setImage:[UIImage imageNamed:@"downloadsuccess"] forState:UIControlStateNormal];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    });
}

@end
