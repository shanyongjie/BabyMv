//
//  BMPlayingVC.m
//  
//
//  Created by ma on 2/5/16.
//
//

#import "BMPlayingVC.h"
#import "MacroDefinition.h"
#import "BMTopTabBar.h"
#import "BMMusicTableView.h"
#import "BSPlayList.h"

@interface BMPlayingVC ()
@property(nonatomic, strong)BMMusicTableView* tableView;
@property(nonatomic, strong)BMBottomPlayingTabBar* playingTabBar;
@end

@implementation BMPlayingVC

-(void)viewWillAppear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationItem setHidesBackButton:YES];
    [_playingTabBar beginUpdates];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:NO];
    self.midButton.hidden = NO;
    [_playingTabBar endUpdates];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    {
        UIView* baseView = self.view;
        InitViewX(BMMusicTableView, tableView, baseView, 0);
        InitViewX(BMBottomPlayingTabBar, playingTabBar, baseView, 0);
        NSDictionary* map = NSDictionaryOfVariableBindings(tableView, playingTabBar);
        
        ViewAddCons(baseView, @"H:|[tableView]|", nil, map);
        ViewAddCons(baseView, @"H:|[playingTabBar]|", nil, map);
        ViewAddCons(baseView, @"V:|[tableView][playingTabBar(50)]|", nil, map);
        __weak BMPlayingVC* SELF = self;
        playingTabBar.blk = ^(int index){
            [SELF playingToolBarButtonClick:index];
        };
    }
    
    
    _tableView.myType = MyTableVIewTypePlayList;
    [_tableView setSongItems:[BSPlayList sharedInstance].arryPlayList];
    self.navigationItem.title = @"播放列表";
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftItemsSupplementBackButton = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewData) name:kCNotificationPlayItemStarted object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 简单reloadData数据
-(void)reloadTableViewData {
    [self.tableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)playingToolBarButtonClick:(int)index {
    switch (index) {
        case 1000: {
            // mode button
            
            break;
        }
        case 1001: {
            // return
//            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1002: {
            // play
            break;
        }
        case 1003: {
            // next
            break;
        }
        case 1004: {
            // time
            break;
        }
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
