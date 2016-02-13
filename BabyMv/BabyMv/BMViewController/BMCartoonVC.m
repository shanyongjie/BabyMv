//
//  BMCartoonVC.m
//  BabyMv
//
//  Created by ma on 2/5/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMCartoonVC.h"
#import "MacroDefinition.h"
#import "BMTopTabBar.h"
#import "MYFocusScrollView.h"
#import "BMMusicTableView.h"
#import "BMMusicListVC.h"
#import "BMDataModel.h"
#import "BMDataCacheManager.h"
#import "BMRequestManager.h"
#import <UIButton+WebCache.h>



@interface BMCartoonVC ()<MYFocusViewDelegate>
@property(nonatomic, strong)BMTopTabBar* cartoonToolbar;
@property(nonatomic, strong)BMMusicTableView* tableView;
@property(nonatomic, strong)MYFocusView* focusView;
@property(nonatomic, strong)NSMutableArray* datalist;
@property(nonatomic, strong)BMTopTabButton* Btn1;
@property(nonatomic, strong)BMTopTabButton* Btn2;
@property(nonatomic, strong)BMTopTabButton* Btn3;
@property(nonatomic, strong)BMTopTabButton* Btn4;

@property(nonatomic, strong)NSMutableArray* cartoonCateArr;
@property(nonatomic, strong)NSMutableArray* cartoonCollectionArr;
@property(nonatomic, strong)NSMutableArray* cartoonListArr;
@property(nonatomic, strong)NSNumber* selectedCategoryId;
@property(nonatomic, strong)NSNumber* selectedCollectionId;
@property(nonatomic, strong)UIView* waitingView;
@property(nonatomic, strong)BMMusicListVC* musicListVC;
@end

@implementation BMCartoonVC

-(instancetype)init {
    self = [super init];
    if (self) {
        _cartoonCateArr = [NSMutableArray new];
        _cartoonCollectionArr = [NSMutableArray new];
        _cartoonListArr = [NSMutableArray new];
        _selectedCategoryId = @(-1);
        _selectedCollectionId = @(-1);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _musicListVC = [BMMusicListVC new];
    {
        UIView* customTitleView = [[UIView alloc] initWithFrame:CGRectMake(50, 5, VIEW_DEFAULT_WIDTH-100, 35)];
        UIView* baseView = customTitleView;
        _Btn1 = [BMTopTabButton NewWithName:@""];
        _Btn2 = [BMTopTabButton NewWithName:@""];
        _Btn3 = [BMTopTabButton NewWithName:@""];
        _Btn4 = [BMTopTabButton NewWithName:@""];
        InitViewX(BMTopTabBar, cartoonToolbar, baseView,  0)
        NSDictionary* map = NSDictionaryOfVariableBindings(cartoonToolbar);
        ViewAddCons(baseView, @"H:|-(8)-[cartoonToolbar]-|", nil, map);
        ViewAddCenterY(baseView, cartoonToolbar)
        [cartoonToolbar setItems:@[_Btn1, _Btn2, _Btn3, _Btn4] height:35];
        __weak BMCartoonVC* SELF = self;
        cartoonToolbar.blk = ^(int index){
            [SELF topBarButtonClick:index];
        };
        cartoonToolbar.tabTag = 1000;
        self.navigationItem.titleView = customTitleView;
    }
    {
        UIView* baseView = self.view;
        InitViewX(BMMusicTableView, tableView, baseView, 0);
        NSDictionary* map = NSDictionaryOfVariableBindings(tableView);
        
        ViewAddCons(baseView, @"H:|[tableView]|", nil, map);
        ViewAddCons(baseView, @"V:|[tableView]|", nil, map);
        
        _focusView = [[MYFocusView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 152) itemCounts:8];
        [_focusView loadScrollView];
        tableView.tableHeaderView = _focusView;
    }
    
    {
        _cartoonCateArr = [NSMutableArray arrayWithArray:[BMDataCacheManager cartoonCate]];
        if (_cartoonCateArr.count>=4) {
            if ([self.selectedCategoryId isEqualToNumber:@(-1)]) {
                self.selectedCategoryId = ((BMDataModel *)_cartoonCateArr[0]).Rid;
            }
            for (int index = 0; index < _cartoonCateArr.count; ++index) {
                BMDataModel* cate = _cartoonCateArr[index];
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
                    default:
                        break;
                }
            }
            [self LoadCollectionAndListData];
        }
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCategoryDataFinish:) name:LOAD_CARTOON_CATEGORY_DATA_FINISHED object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCollectionDataFinish:) name:LOAD_CARTOON_COLLECTION_DATA_FINISHED object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadListDataFinish:) name:LOAD_CARTOON_LIST_DATA_FINISHED object:nil];
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

-(void)LoadCollectionAndListData {
    _cartoonCollectionArr = [NSMutableArray arrayWithArray:[BMDataCacheManager cartoonCollectionWithCateId:self.selectedCategoryId]];
    if (_cartoonCollectionArr.count) {
        [_focusView removeFromSuperview];
        _focusView = [[MYFocusView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 152) itemCounts:_cartoonCollectionArr.count];
        [_focusView setClickDelegate:self];
        [_focusView loadScrollView];
        _tableView.tableHeaderView = _focusView;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSUInteger index = 0; index < _cartoonCollectionArr.count; index++) {
                BMCollectionDataModel* cur_mv = [_cartoonCollectionArr objectAtIndex:index];
                UIButton *btn = (UIButton *)[_focusView viewWithTag:(1000 + index)];
                [btn sd_setImageWithURL:[NSURL URLWithString:cur_mv.Url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default"]];
                UILabel *label = (UILabel *)[_focusView viewWithTag:(2000 + index)];
                label.text = cur_mv.Name;
                CGSize textSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width+30, 11) lineBreakMode:NSLineBreakByTruncatingTail];
                CGRect frame = CGRectMake(label.frame.origin.x - (textSize.width-label.frame.size.width)/2, label.frame.origin.y, textSize.width, label.frame.size.height);
                label.frame = frame;
            }
        });
        
        self.selectedCollectionId = ((BMCollectionDataModel *)_cartoonCollectionArr[0]).Rid;
        _cartoonListArr = [NSMutableArray arrayWithArray:[BMDataCacheManager cartoonListWithCollectionId:self.selectedCollectionId]];
        if (_cartoonListArr.count) {
            [self.tableView setItems:[NSMutableArray arrayWithArray:_cartoonListArr]];
            [self.tableView reloadData];
        } else {
            [[BMRequestManager sharedInstance] loadListDataWithCollectionId:self.selectedCollectionId requestType:MyRequestTypeCartoon];
        }
    } else{
        [[BMRequestManager sharedInstance] loadCollectionDataWithCategoryId:self.selectedCategoryId requestType:MyRequestTypeCartoon];
        [self showLoadingPage:YES descript:nil];
    }
}

- (void)loadCategoryDataFinish:(NSNotification *) notify {
    _cartoonCateArr = [NSMutableArray arrayWithArray:[BMDataCacheManager cartoonCate]];
    if (_cartoonCateArr.count>=4) {
        if ([self.selectedCategoryId isEqualToNumber:@(-1)]) {
            self.selectedCategoryId = ((BMDataModel *)_cartoonCateArr[0]).Rid;
        }
        for (int index = 0; index < _cartoonCateArr.count; ++index) {
            BMDataModel* cate = _cartoonCateArr[index];
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
                default:
                    break;
            }
        }
        [self LoadCollectionAndListData];
    }
}

-(void)loadCollectionDataFinish:(NSNotification *)notify {
    [self showLoadingPage:NO descript:nil];
    NSDictionary* userInfo = notify.object;
    NSArray* cartoonList = userInfo[@"cartoonList"];
    NSString* currCateId = userInfo[@"cartoonCateId"];
//    if (cartoonList.count) {
//        [self.tableView setItems:[NSMutableArray arrayWithArray:musicList]];
//        [self.tableView reloadData];
//    }
    if ([currCateId integerValue] == [self.selectedCategoryId integerValue]) {
        _cartoonCollectionArr = [NSMutableArray arrayWithArray:[BMDataCacheManager cartoonCollectionWithCateId:self.selectedCategoryId]];
        [_focusView removeFromSuperview];
        _focusView = [[MYFocusView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 152) itemCounts:_cartoonCollectionArr.count];
        [_focusView setClickDelegate:self];
        [_focusView loadScrollView];
        _tableView.tableHeaderView = _focusView;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSUInteger index = 0; index < _cartoonCollectionArr.count; index++) {
                BMCartoonCollectionDataModel* cur_mv = [_cartoonCollectionArr objectAtIndex:index];
                UIButton *btn = (UIButton *)[_focusView viewWithTag:(1000 + index)];
                [btn sd_setImageWithURL:[NSURL URLWithString:cur_mv.Url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default"]];
                UILabel *label = (UILabel *)[_focusView viewWithTag:(2000 + index)];
                label.text = cur_mv.Name;
                CGSize textSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width+30, 11) lineBreakMode:NSLineBreakByTruncatingTail];
                CGRect frame = CGRectMake(label.frame.origin.x - (textSize.width-label.frame.size.width)/2, label.frame.origin.y, textSize.width, label.frame.size.height);
                label.frame = frame;
            }
        });
        self.selectedCollectionId = ((BMCollectionDataModel *)_cartoonCollectionArr[0]).Rid;
        _cartoonListArr = [NSMutableArray arrayWithArray:[BMDataCacheManager cartoonListWithCollectionId:self.selectedCollectionId]];
        if (_cartoonListArr.count) {
            [self.tableView setItems:[NSMutableArray arrayWithArray:_cartoonListArr]];
            [self.tableView reloadData];
        } else {
            [[BMRequestManager sharedInstance] loadListDataWithCollectionId:self.selectedCollectionId requestType:MyRequestTypeCartoon];
        }
    }
}

-(void)loadListDataFinish:(NSNotification *)notify {
    NSDictionary* userInfo = notify.object;
    NSString* collectionId = userInfo[@"collectionId"];
    self.selectedCollectionId = @([collectionId intValue]);
    _cartoonListArr = [NSMutableArray arrayWithArray:[BMDataCacheManager cartoonListWithCollectionId:self.selectedCollectionId]];
    if (_cartoonListArr.count) {
        [self.tableView setItems:[NSMutableArray arrayWithArray:_cartoonListArr]];
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

-(void)topBarButtonClick:(int)index {
    if (index>1003 || _cartoonCateArr.count<4) {
        return;
    }
    BMDataModel* cate = _cartoonCateArr[index-1000];
    self.selectedCategoryId = cate.Rid;
    [self LoadCollectionAndListData];
}

@end
