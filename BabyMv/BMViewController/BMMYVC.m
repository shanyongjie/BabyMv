//
//  BMMYVC.m
//  
//
//  Created by ma on 2/5/16.
//
//

#import "BMMYVC.h"
#import "BMMusicListVC.h"
#import "MacroDefinition.h"
#import "BMTopTabBar.h"
#import "BMMusicTableView.h"
#import "BMDataBaseManager.h"



@interface UIButton()

@end

@interface BMMYVC ()
@property(strong, nonatomic) UIButton* historyBtn;
@property(strong, nonatomic) UIButton* downloadMusicBtn;
@property(strong, nonatomic) UIButton* downloadmovieBtn;
@property(strong, nonatomic) BMMusicTableView* tableView;
@property(strong, nonatomic) NSMutableArray* items;
@property(strong, nonatomic) BMMusicListVC* historyVC;
@property(strong, nonatomic) BMMusicListVC* downloadMusicVC;
@property(strong, nonatomic) BMMusicListVC* downloadCartoonVC;
@end

@implementation BMMYVC

-(instancetype)init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的";
    {
        _historyVC = [BMMusicListVC new];
        _historyVC.vcType = MyListVCTypeHistory;
        _downloadMusicVC = [BMMusicListVC new];
        _downloadMusicVC.vcType = MyListVCTypeMusicDownload;
        _downloadCartoonVC = [BMMusicListVC new];
        _downloadCartoonVC.vcType = MyListVCTypeCartoonDownload;
    }
    {
        UIView* baseView = self.view;
        INITBUTTONX(historyBtn, baseView, 1001)
        [historyBtn setImage:[UIImage imageNamed:@"shoutinglishi"] forState:UIControlStateNormal];
        [historyBtn addTarget:self action:@selector(openVC:) forControlEvents:UIControlEventTouchUpInside];
        INITBUTTONX(downloadMusicBtn, baseView, 1002)
        [downloadMusicBtn setImage:[UIImage imageNamed:@"ergexiazai"] forState:UIControlStateNormal];
        [downloadMusicBtn addTarget:self action:@selector(openVC:) forControlEvents:UIControlEventTouchUpInside];
        INITBUTTONX(downloadmovieBtn, baseView, 1003)
        [downloadmovieBtn setImage:[UIImage imageNamed:@"donghuaxiazai"] forState:UIControlStateNormal];
        [downloadmovieBtn addTarget:self action:@selector(openVC:) forControlEvents:UIControlEventTouchUpInside];
        InitViewX(BMMusicTableView, tableView, baseView, 0)
        tableView.myType = MyTableViewTypeFavorite;
        
        NSDictionary* map = NSDictionaryOfVariableBindings(historyBtn, downloadMusicBtn, downloadmovieBtn, tableView);
        NSDictionary* metrics = @{@"btnW":@(MYBTNWIDTH), @"btnH":@(MWBTNHEIGHT), @"gap":@(XGAP)};
        ViewAddConsAlign(baseView, @"H:|-(gap)-[historyBtn(btnW)]-(gap)-[downloadMusicBtn(historyBtn)]-(gap)-[downloadmovieBtn(historyBtn)]-(gap)-|", 0, metrics, map)
        ViewAddCons(baseView, @"H:|[tableView]|", metrics, map)
        ViewAddCons(baseView, @"V:|-(8)-[historyBtn(btnH)]-[tableView]-|", metrics, map)
        ViewAddCons(baseView, @"V:|-(8)-[downloadMusicBtn(btnH)]-[tableView]-|", metrics, map)
        ViewAddCons(baseView, @"V:|-(8)-[downloadmovieBtn(btnH)]-[tableView]-|", metrics, map)
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadFavoriteData];
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

-(void)loadFavoriteData {
    [self.items removeAllObjects];
    [self.items addObjectsFromArray:[[BMDataBaseManager sharedInstance] getFavoriteMusicCollections]];
    [self.items addObjectsFromArray:[[BMDataBaseManager sharedInstance] getFavoriteCartoonCollections]];
    if (self.items.count) {
        [self.tableView setItems:self.items];
        [self.tableView reloadData];
    }
}

-(void)openVC:(UIButton *)btn {
    switch (btn.tag) {
        case 1001:
            [self.navigationController pushViewController:self.historyVC animated:YES];
            break;
        case 1002:
            [self.navigationController pushViewController:self.downloadMusicVC animated:YES];
            break;
        case 1003:
            [self.navigationController pushViewController:self.downloadCartoonVC animated:YES];
            break;
        default:
            break;
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
