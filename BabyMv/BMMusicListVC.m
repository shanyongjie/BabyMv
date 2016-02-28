//
//  BMMusicListVC.m
//  BabyMv
//
//  Created by ma on 2/12/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMMusicListVC.h"
#import "BMMusicTableView.h"
#import "BMDataModel.h"
#import "BMDataBaseManager.h"
#import "BMDataCacheManager.h"
#import "BMRequestManager.h"
#import "AppDelegate.h"

@interface BMMusicListVC ()
@property(nonatomic, strong)BMMusicTableView* tableView;
@property(nonatomic, strong)NSMutableArray* listData;
@property(nonatomic, strong)UIBarButtonItem* favBarBtn;
@property(nonatomic, strong)UIButton* favBtn;
@property(nonatomic, strong)UIButton* delHistoryBtn;
@property(nonatomic, strong)UIBarButtonItem* delHistoryBarBtn;
@end

@implementation BMMusicListVC

-(instancetype)init {
    self = [super init];
    if (self) {
        _vcType = MyListVCTypeMusic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    {
        UIView* baseView = self.view;
        InitViewX(BMMusicTableView, tableView, baseView, 0);
        switch (self.vcType) {
            case MyListVCTypeMusic:
                tableView.myType = MyTableViewTypeMusic;
                break;
            case MyListVCTypeMusicDownload:
                tableView.myType = MyTableViewTypeMusicDown;
                break;
            case MyListVCTypeCartoon:
                tableView.myType = MyTableViewTypeCartoon;
                break;
            case MyListVCTypeCartoonDownload:
                tableView.myType = MyTableViewTypeCartoonDown;
                break;
            case MyListVCTypeHistory:
                tableView.myType = MyTableViewTypeHistory;
                break;
            default:
                break;
        }
        NSDictionary* map = NSDictionaryOfVariableBindings(tableView);
        
        ViewAddCons(baseView, @"H:|[tableView]|", nil, map);
        ViewAddCons(baseView, @"V:|[tableView]|", nil, map);
    }
    {
        _favBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_favBtn addTarget:self action:@selector(favCollection:) forControlEvents:UIControlEventTouchUpInside];
        [_favBtn setImage:[UIImage imageNamed:@"shoucang"] forState:UIControlStateNormal];
        [_favBtn setImage:[UIImage imageNamed:@"shoucang-down"] forState:UIControlStateSelected];
        _favBtn.frame = CGRectMake(0, 0, 32, 32);
        _favBarBtn = [[UIBarButtonItem alloc] initWithCustomView:_favBtn];
        
        
        _delHistoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delHistoryBtn addTarget:self action:@selector(deleteAllHistory:) forControlEvents:UIControlEventTouchUpInside];
        [_delHistoryBtn setImage:[UIImage imageNamed:@"delete_all"] forState:UIControlStateNormal];
        [_delHistoryBtn setImage:[UIImage imageNamed:@"delete_all"] forState:UIControlStateSelected];
        _delHistoryBtn.frame = CGRectMake(0, 0, 32, 32);
        _delHistoryBarBtn = [[UIBarButtonItem alloc] initWithCustomView:_delHistoryBtn];
    }
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listDataLoadFinished:) name:LOAD_MUSIC_LIST_DATA_FINISHED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listDataLoadFinished:) name:LOAD_CARTOON_LIST_DATA_FINISHED object:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated {
#warning some data from cache, other form DB, that's a question
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewData) name:kCNotificationPlayItemStarted object:nil];
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationItem setHidesBackButton:YES];
    [[AppDelegate sharedAppDelegate].mainTabBarController setGlobalReturnBtnHidden:NO];
    _favBtn.selected = NO;
    self.navigationItem.rightBarButtonItem = nil;
    if (self.vcType == MyListVCTypeMusic) {
        self.navigationItem.rightBarButtonItem = self.favBarBtn;
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, VIEW_DEFAULT_WIDTH-160, 35)];
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        titleLabel.textColor = RGB(0x7b4703, 1.0);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = self.currentCollectionData.Name;
        self.navigationItem.titleView = titleLabel;
        _listData = [NSMutableArray arrayWithArray:[BMDataCacheManager musicListWithCollectionId:self.currentCollectionData.Rid]];
        if (_listData.count) {
            [self.tableView setSongItems:_listData];
            [self.tableView reloadData];
        } else{
            [[BMRequestManager sharedInstance] loadListDataWithCollectionId:self.currentCollectionData.Rid requestType:MyRequestTypeMusic];
            [self showLoadingPage:YES descript:nil];
        }
        _favBtn.selected = [[BMDataBaseManager sharedInstance] IsMusicCollectionFaved:self.currentCollectionData.Rid];
        return;
    }

    if (self.vcType == MyListVCTypeCartoon) {
        self.navigationItem.rightBarButtonItem = self.favBarBtn;
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, VIEW_DEFAULT_WIDTH-160, 35)];
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        titleLabel.textColor = RGB(0x7b4703, 1.0);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = self.currentCartoonCollectionData.Name;
        self.navigationItem.titleView = titleLabel;
        _listData = [NSMutableArray arrayWithArray:[BMDataCacheManager cartoonListWithCollectionId:self.currentCartoonCollectionData.Rid]];
        if (_listData.count) {
            [self.tableView setSongItems:_listData];
            [self.tableView reloadData];
        } else{
            [[BMRequestManager sharedInstance] loadListDataWithCollectionId:self.currentCartoonCollectionData.Rid requestType:MyRequestTypeCartoon];
            [self showLoadingPage:YES descript:nil];
        }
        _favBtn.selected = [[BMDataBaseManager sharedInstance] IsCartoonCollectionFaved:self.currentCartoonCollectionData.Rid];
        return;
    }

    if (self.vcType == MyListVCTypeMusicDownload) {
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, VIEW_DEFAULT_WIDTH-160, 35)];
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        titleLabel.textColor = RGB(0x7b4703, 1.0);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"我下载的儿歌";
        self.navigationItem.titleView = titleLabel;
        _listData = [NSMutableArray arrayWithArray:[[BMDataBaseManager sharedInstance] getDownloadedMusicList]];
        if (_listData.count) {
            [self.tableView setSongItems:_listData];
            [self.tableView reloadData];
        }
    }
    if (self.vcType == MyListVCTypeCartoonDownload) {
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, VIEW_DEFAULT_WIDTH-160, 35)];
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        titleLabel.textColor = RGB(0x7b4703, 1.0);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"我下载的动画";
        self.navigationItem.titleView = titleLabel;
        _listData = [NSMutableArray arrayWithArray:[[BMDataBaseManager sharedInstance] getDownloadedCartoonList]];
        if (_listData.count) {
            [self.tableView setSongItems:_listData];
            [self.tableView reloadData];
        }
    }
    if (self.vcType == MyListVCTypeHistory) {
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, VIEW_DEFAULT_WIDTH-160, 35)];
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        titleLabel.textColor = RGB(0x7b4703, 1.0);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"收听历史";
        self.navigationItem.titleView = titleLabel;
        self.navigationItem.rightBarButtonItem = self.delHistoryBarBtn;
        _listData = [NSMutableArray arrayWithArray:[[BMDataBaseManager sharedInstance] getListenMusicList]];
        if (_listData.count) {
            [self.tableView setSongItems:_listData];
            [self.tableView reloadData];
        }
    }
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCNotificationPlayItemStarted object:nil];
    [self.tabBarController.tabBar setHidden:NO];
    [[AppDelegate sharedAppDelegate].mainTabBarController setGlobalReturnBtnHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 简单reloadData数据
-(void)reloadTableViewData {
    switch (self.vcType) {
        case MyListVCTypeMusic:
        case MyListVCTypeMusicDownload:
        case MyListVCTypeHistory:
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)listDataLoadFinished:(NSNotification *)notify {
    [self showLoadingPage:NO descript:nil];
    NSDictionary* userInfo = notify.object;
    NSString* collectionId = userInfo[@"collectionId"];
    
    int currentCollectionId = 0;
    if (self.vcType == MyListVCTypeMusic) {
        currentCollectionId = [self.currentCollectionData.Rid intValue];
    }
    if (self.vcType == MyListVCTypeCartoon) {
        currentCollectionId = [self.currentCartoonCollectionData.Rid intValue];
    }
    if ([collectionId intValue] == currentCollectionId) {
        if (self.vcType == MyListVCTypeMusic) {
            _listData = [NSMutableArray arrayWithArray:[BMDataCacheManager musicListWithCollectionId:self.currentCollectionData.Rid]];
        }
        if (self.vcType == MyListVCTypeCartoon) {
            _listData = [NSMutableArray arrayWithArray:[BMDataCacheManager cartoonListWithCollectionId:self.currentCartoonCollectionData.Rid]];
        }
        if (_listData.count) {
            [self.tableView setSongItems:_listData];
            [self.tableView reloadData];
        }
    }
}

-(void)favCollection:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (self.vcType == MyListVCTypeMusic) {
        self.currentCollectionData.IsFaved = [NSNumber numberWithBool:btn.selected];
        [[BMDataBaseManager sharedInstance] favMusicCollection:self.currentCollectionData];
    }
    if (self.vcType == MyListVCTypeCartoon) {
        self.currentCartoonCollectionData.IsFaved = [NSNumber numberWithBool:btn.selected];
        [[BMDataBaseManager sharedInstance] favCartoonCollection:self.currentCartoonCollectionData];
    }
}

-(void)deleteAllHistory:(UIButton *)btn {
    if (!self.listData) {
        return;
    }
    __weak __typeof(self)weafSekf = self;
    UIBlockAlertView* blockView = [[UIBlockAlertView alloc]initWithTitle:@"确定要删除全部历史纪录？" cancelButtonTitle:@"取消" otherButtons:[NSArray arrayWithObjects:@"确定", nil] andDeal:^(UIBlockAlertView *alert, NSInteger clickIndex) {
        if (clickIndex == 1) {
            for (BMListDataModel* cur_video in self.listData) {
                cur_video.LastListeningTime = [NSNumber numberWithInt:NSTimeIntervalSince1970];
            }
            [[BMDataBaseManager sharedInstance] listenMusicListArr:self.listData];
            [self.tableView setSongItems:nil];
            [weafSekf.tableView reloadData];

        }
    }];
    [blockView show];
}

@end
