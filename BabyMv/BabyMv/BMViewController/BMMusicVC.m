//
//  BMMusicVC.m
//  BabyMv
//
//  Created by ma on 2/5/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMMusicVC.h"
#import "MacroDefinition.h"
#import "BMTopTabBar.h"
#import "BMMusicTableView.h"
#import "MYFocusScrollView.h"

#import "BMDataModel.h"
#import "BMDataBaseManager.h"
#import "BMDataCacheManager.h"
#import "BMRequestManager.h"

#import <UIButton+WebCache.h>

@interface BMMusicVC ()
@property(nonatomic, strong)BMTopTabBar* musicToolbar;
@property(nonatomic, strong)BMMusicTableView* tableView;
@property(nonatomic, strong)MYFocusView* focusView;
@property(nonatomic, strong)NSMutableArray* datalist;
@property(nonatomic, strong)BMTopTabButton* Btn1;
@property(nonatomic, strong)BMTopTabButton* Btn2;
@property(nonatomic, strong)BMTopTabButton* Btn3;
@property(nonatomic, strong)BMTopTabButton* Btn4;
@property(nonatomic, strong)BMTopTabButton* Btn5;

@property(nonatomic, strong)NSMutableArray* musicCateArr;
@property(nonatomic, strong)NSMutableArray* collectionArr;
@property(nonatomic, strong)NSMutableArray* musicListArr;
@property(nonatomic, strong)NSNumber* selectedCategoryId;
@property(nonatomic, strong)UIView* waitingView;
@end

@implementation BMMusicVC

-(instancetype)init {
    self = [super init];
    if (self) {
        _musicCateArr = [NSMutableArray new];
        _collectionArr = [NSMutableArray new];
        _musicListArr = [NSMutableArray new];
        _selectedCategoryId = @(-1);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    {
        UIView* customTitleView = [[UIView alloc] initWithFrame:CGRectMake(50, 5, VIEW_DEFAULT_WIDTH-100, 35)];
        UIView* baseView = customTitleView;
        _Btn1 = [BMTopTabButton NewWithName:@""];
        _Btn2 = [BMTopTabButton NewWithName:@""];
        _Btn3 = [BMTopTabButton NewWithName:@""];
        _Btn4 = [BMTopTabButton NewWithName:@""];
        _Btn5 = [BMTopTabButton NewWithName:@""];
        InitViewX(BMTopTabBar, musicToolbar, baseView,  0)
        NSDictionary* map = NSDictionaryOfVariableBindings(musicToolbar);
        ViewAddCons(baseView, @"H:|-(8)-[musicToolbar]-|", nil, map);
        ViewAddCenterY(baseView, musicToolbar)
        [musicToolbar setItems:@[_Btn1, _Btn2, _Btn3, _Btn4, _Btn5] height:35];
        __weak BMMusicVC* SELF = self;
        musicToolbar.blk = ^(int index){
            [SELF topBarButtonClick:index];
        };
        musicToolbar.tabTag = 1000;
        self.navigationItem.titleView = customTitleView;
    }
    {
        UIView* baseView = self.view;
        InitViewX(BMMusicTableView, tableView, baseView, 0);
        NSDictionary* map = NSDictionaryOfVariableBindings(tableView);
        
        ViewAddCons(baseView, @"H:|[tableView]|", nil, map);
        ViewAddCons(baseView, @"V:|[tableView]|", nil, map);
        
        _focusView = [[MYFocusView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 152) itemCounts:8];
//        [_focusView setClickDelegate:self];
        [_focusView loadScrollView];
        tableView.tableHeaderView = _focusView;
    }
    
    {
        _musicCateArr = [NSMutableArray arrayWithArray:[BMDataCacheManager musicCate]];
        if (_musicCateArr.count>=5) {
            if ([self.selectedCategoryId isEqualToNumber:@(-1)]) {
                self.selectedCategoryId = ((BMDataModel *)_musicCateArr[0]).Rid;
            }
            for (int index = 0; index < _musicCateArr.count; ++index) {
                BMDataModel* cate = _musicCateArr[index];
                switch (index) {
                    case 0:
                        [_Btn1 setTitle:cate.Name];
                        break;
                    case 1:
                        [_Btn2 setTitle:cate.Name];
                        break;
                    case 2:
                        [_Btn3 setTitle:cate.Name];
                        break;
                    case 3:
                        [_Btn4 setTitle:cate.Name];
                        break;
                    case 4:
                        [_Btn5 setTitle:cate.Name];
                        break;
                    default:
                        break;
                }
            }
            _collectionArr = [NSMutableArray arrayWithArray:[BMDataCacheManager musicCollectionWithCateId:self.selectedCategoryId]];
            if (_collectionArr.count) {
                [_focusView removeFromSuperview];
                _focusView = [[MYFocusView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 152) itemCounts:_collectionArr.count];
                [_focusView loadScrollView];
                _tableView.tableHeaderView = _focusView;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (NSUInteger index = 0; index < _collectionArr.count; index++) {
                        BMCollectionDataModel* cur_mv = [_collectionArr objectAtIndex:index];
                        UIButton *btn = (UIButton *)[_focusView viewWithTag:(1000 + index)];
                        [btn sd_setImageWithURL:[NSURL URLWithString:cur_mv.Url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default"]];
                        UILabel *label = (UILabel *)[_focusView viewWithTag:(2000 + index)];
                        label.text = cur_mv.Name;
                        CGSize textSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width+30, 11) lineBreakMode:NSLineBreakByTruncatingTail];
                        CGRect frame = CGRectMake(label.frame.origin.x - (textSize.width-label.frame.size.width)/2, label.frame.origin.y, textSize.width, label.frame.size.height);
                        label.frame = frame;
                    }
                });

            } else{
                [[BMRequestManager sharedInstance] loadCollectionDataWithCategoryId:self.selectedCategoryId];
                [self showLoadingPage:YES descript:nil];
            }
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCategoryDataFinish:) name:LOAD_CATEGORY_DATA_FINISHED object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCollectionDataFinish:) name:LOAD_COLLECTION_DATA_FINISHED object:nil];
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

-(void)topBarButtonClick:(int)index {
    if (index>1004 || _musicCateArr.count<5) {
        return;
    }
    BMDataModel* cate = _musicCateArr[index-1000];
    self.selectedCategoryId = cate.Rid;
    _collectionArr = [NSMutableArray arrayWithArray:[BMDataCacheManager musicCollectionWithCateId:self.selectedCategoryId]];
    if (_collectionArr.count) {
        [_focusView removeFromSuperview];
        _focusView = [[MYFocusView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 152) itemCounts:_collectionArr.count];
        [_focusView loadScrollView];
        _tableView.tableHeaderView = _focusView;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSUInteger index = 0; index < _collectionArr.count; index++) {
                BMCollectionDataModel* cur_mv = [_collectionArr objectAtIndex:index];
                UIButton *btn = (UIButton *)[_focusView viewWithTag:(1000 + index)];
                [btn sd_setImageWithURL:[NSURL URLWithString:cur_mv.Url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default"]];
                UILabel *label = (UILabel *)[_focusView viewWithTag:(2000 + index)];
                label.text = cur_mv.Name;
                CGSize textSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width+30, 11) lineBreakMode:NSLineBreakByTruncatingTail];
                CGRect frame = CGRectMake(label.frame.origin.x - (textSize.width-label.frame.size.width)/2, label.frame.origin.y, textSize.width, label.frame.size.height);
                label.frame = frame;
            }
        });
        
    } else{
        [[BMRequestManager sharedInstance] loadCollectionDataWithCategoryId:self.selectedCategoryId];
        [self showLoadingPage:YES descript:nil];
    }

}

- (void)loadCategoryDataFinish:(NSNotification *) notify {
    _musicCateArr = [NSMutableArray arrayWithArray:[BMDataCacheManager musicCate]];
    if (_musicCateArr.count>=5) {
        if ([self.selectedCategoryId isEqualToNumber:@(-1)]) {
            self.selectedCategoryId = ((BMDataModel *)_musicCateArr[0]).Rid;
        }
        for (int index = 0; index < _musicCateArr.count; ++index) {
            BMDataModel* cate = _musicCateArr[index];
            switch (index) {
                case 0:
                    [_Btn1 setTitle:cate.Name];
                    break;
                case 1:
                    [_Btn2 setTitle:cate.Name];
                    break;
                case 2:
                    [_Btn3 setTitle:cate.Name];
                    break;
                case 3:
                    [_Btn4 setTitle:cate.Name];
                    break;
                case 4:
                    [_Btn5 setTitle:cate.Name];
                    break;
                default:
                    break;
            }
        }
        [[BMRequestManager sharedInstance] loadCollectionDataWithCategoryId:self.selectedCategoryId];
    }
}

-(void)loadCollectionDataFinish:(NSNotification *)notify {
    [self showLoadingPage:NO descript:nil];
    NSDictionary* userInfo = notify.object;
    NSArray* musicList = userInfo[@"SongList"];
    NSString* currCateId = userInfo[@"musicCateId"];
    if (musicList.count) {
        [self.tableView setItems:[NSMutableArray arrayWithArray:musicList]];
        [self.tableView reloadData];
    }
    if ([currCateId integerValue] == [self.selectedCategoryId integerValue]) {
        _collectionArr = [NSMutableArray arrayWithArray:[BMDataCacheManager musicCollectionWithCateId:self.selectedCategoryId]];
        [_focusView removeFromSuperview];
        _focusView = [[MYFocusView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 152) itemCounts:_collectionArr.count];
//        [_focusView setClickDelegate:self];
        [_focusView loadScrollView];
        _tableView.tableHeaderView = _focusView;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSUInteger index = 0; index < _collectionArr.count; index++) {
                BMCollectionDataModel* cur_mv = [_collectionArr objectAtIndex:index];
                UIButton *btn = (UIButton *)[_focusView viewWithTag:(1000 + index)];
                [btn sd_setImageWithURL:[NSURL URLWithString:cur_mv.Url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default"]];
                UILabel *label = (UILabel *)[_focusView viewWithTag:(2000 + index)];
                label.text = cur_mv.Name;
                CGSize textSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width+30, 11) lineBreakMode:NSLineBreakByTruncatingTail];
                CGRect frame = CGRectMake(label.frame.origin.x - (textSize.width-label.frame.size.width)/2, label.frame.origin.y, textSize.width, label.frame.size.height);
                label.frame = frame;
            }
        });

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
