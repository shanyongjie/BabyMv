//
//  BMMusicListVC.m
//  BabyMv
//
//  Created by ma on 2/12/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMMusicListVC.h"
#import "BMMusicTableView.h"
#import "MacroDefinition.h"
#import "BMDataModel.h"
#import "BMDataCacheManager.h"
#import "BMRequestManager.h"


@interface BMMusicListVC ()
@property(nonatomic, strong)BMMusicTableView* tableView;
@property(nonatomic, strong)NSMutableArray* musicListData;
@property(nonatomic, strong)UIView* waitingView;
@end

@implementation BMMusicListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    {
        UIView* baseView = self.view;
        InitViewX(BMMusicTableView, tableView, baseView, 0);
        NSDictionary* map = NSDictionaryOfVariableBindings(tableView);
        
        ViewAddCons(baseView, @"H:|[tableView]|", nil, map);
        ViewAddCons(baseView, @"V:|[tableView]|", nil, map);
    }
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listDataLoadFinished:) name:LOAD_LIST_DATA_FINISHED object:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = self.currentCollectionData.Name;
    _musicListData = [NSMutableArray arrayWithArray:[BMDataCacheManager musicListWithCollectionId:self.currentCollectionData.Rid]];
    if (_musicListData.count) {
        [self.tableView setItems:[NSMutableArray arrayWithArray:_musicListData]];
        [self.tableView reloadData];
    } else{
        [[BMRequestManager sharedInstance] loadListDataWithCollectionId:self.currentCollectionData.Rid];
        [self showLoadingPage:YES descript:nil];
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
    _musicListData = [NSMutableArray arrayWithArray:[BMDataCacheManager musicListWithCollectionId:self.currentCollectionData.Rid]];
    if (_musicListData.count) {
        [self.tableView setItems:[NSMutableArray arrayWithArray:_musicListData]];
        [self.tableView reloadData];
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

@end
