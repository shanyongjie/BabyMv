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

@interface BMMusicListVC ()
@property(nonatomic, strong)BMMusicTableView* tableView;
@property(nonatomic, strong)NSMutableArray* listData;
@property(nonatomic, strong)UIView* waitingView;
@property(nonatomic, strong)UIBarButtonItem* favBarBtn;
@property(nonatomic, strong)UIButton* favBtn;
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
    }
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listDataLoadFinished:) name:LOAD_MUSIC_LIST_DATA_FINISHED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listDataLoadFinished:) name:LOAD_CARTOON_LIST_DATA_FINISHED object:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated {
#warning some data from cache, other form DB, that's a question
    _favBtn.selected = NO;
    self.navigationItem.rightBarButtonItem = nil;
    if (self.vcType == MyListVCTypeMusic) {
        self.navigationItem.rightBarButtonItem = self.favBarBtn;
        self.navigationItem.title = self.currentCollectionData.Name;
        _listData = [NSMutableArray arrayWithArray:[BMDataCacheManager musicListWithCollectionId:self.currentCollectionData.Rid]];
        if (_listData.count) {
            [self.tableView setItems:[NSMutableArray arrayWithArray:_listData]];
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
        self.navigationItem.title = self.currentCartoonCollectionData.Name;
        _listData = [NSMutableArray arrayWithArray:[BMDataCacheManager cartoonListWithCollectionId:self.currentCartoonCollectionData.Rid]];
        if (_listData.count) {
            [self.tableView setItems:[NSMutableArray arrayWithArray:_listData]];
            [self.tableView reloadData];
        } else{
            [[BMRequestManager sharedInstance] loadListDataWithCollectionId:self.currentCartoonCollectionData.Rid requestType:MyRequestTypeCartoon];
            [self showLoadingPage:YES descript:nil];
        }
        _favBtn.selected = [[BMDataBaseManager sharedInstance] IsCartoonCollectionFaved:self.currentCartoonCollectionData.Rid];
        return;
    }

    if (self.vcType == MyListVCTypeMusicDownload) {
        self.navigationItem.title = @"我下载的儿歌";
        _listData = [NSMutableArray arrayWithArray:[[BMDataBaseManager sharedInstance] getDownloadedMusicList]];
        if (_listData.count) {
            [self.tableView setItems:[NSMutableArray arrayWithArray:_listData]];
            [self.tableView reloadData];
        }
    }
    if (self.vcType == MyListVCTypeCartoonDownload) {
        self.navigationItem.title = @"我下载的动画";
        _listData = [NSMutableArray arrayWithArray:[[BMDataBaseManager sharedInstance] getDownloadedCartoonList]];
        if (_listData.count) {
            [self.tableView setItems:[NSMutableArray arrayWithArray:_listData]];
            [self.tableView reloadData];
        }
    }
    if (self.vcType == MyListVCTypeHistory) {
        self.navigationItem.title = @"收听历史";
        _listData = [NSMutableArray arrayWithArray:[[BMDataBaseManager sharedInstance] getListenMusicList]];
        if (_listData.count) {
            [self.tableView setItems:[NSMutableArray arrayWithArray:_listData]];
            [self.tableView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            [self.tableView setItems:[NSMutableArray arrayWithArray:_listData]];
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

- (void)showLoadingPage:(BOOL)bShow descript:(NSString*)strDescript
{
    if (bShow) {
        if (!_waitingView) {
            _waitingView=[[UIView alloc] initWithFrame:self.view.frame];
            [self.view addSubview:_waitingView];
            
            CGRect rc=CGRectMake(0, 0, 86, 86);
            UIView* pBlackFrameView=[[UIView alloc] initWithFrame:rc];
            pBlackFrameView.center = self.view.center;
            [pBlackFrameView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
            pBlackFrameView.layer.cornerRadius=10;
            pBlackFrameView.layer.masksToBounds=YES;
            [_waitingView addSubview:pBlackFrameView];
            
            UIActivityIndicatorView* pActIndView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(26, 16, 34, 34)];
            [pActIndView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [pBlackFrameView addSubview:pActIndView];
            [pActIndView startAnimating];
            
            UILabel* text=[[UILabel alloc] initWithFrame:CGRectMake(0, 50, 86, 30)];
            [text setBackgroundColor:[UIColor clearColor]];
            [text setTextAlignment:NSTextAlignmentCenter];
            [text setText:strDescript?strDescript:@"正在加载"];
            [text setTextColor:[UIColor whiteColor]];
            [text setFont: [UIFont systemFontOfSize:13]];
            [pBlackFrameView addSubview:text];
        }
        _waitingView.hidden=NO;
    } else {
        [_waitingView removeFromSuperview];
        _waitingView=nil;
    }
}

#pragma mark - Orientation
- (BOOL) shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end
