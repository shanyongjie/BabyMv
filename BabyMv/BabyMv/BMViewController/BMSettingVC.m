//
//  BMSettingVC.m
//  
//
//  Created by ma on 2/5/16.
//
//

#import "BMSettingVC.h"
#import "MacroDefinition.h"
#import "BMTopTabBar.h"

@interface BMSettingView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView* settingListView;
@property (nonatomic, assign)BOOL         bShowFeedback;

@end

@interface BMSettingVC ()
@property(nonatomic, strong)BMSettingView* tableView;
@end

@implementation BMSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"设置";
    UIView* baseView = self.view;
    InitViewX(BMSettingView, tableView, baseView, 0);
    NSDictionary* map = NSDictionaryOfVariableBindings(tableView);
    ViewAddCons(baseView, @"H:|[tableView]|", nil, map)
    ViewAddCons(baseView, @"V:|[tableView]|", nil, map)
    [self setExtraCellLineHidden:tableView];
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
- (void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}

@end



@implementation BMSettingView

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.dataSource = self;
//        std::string str_update_version = "";
//        RTLocalConfig::GetConfigureInstance()->GetConfigStringValue(APP_CUR_VERSION_GROUP, APP_UPDATE_VERSION, str_update_version);
        NSString *current_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
//        if (NSOrderedAscending == [current_version compare:[NSString stringWithUTF8String:str_update_version.c_str()]]) {
            _bShowFeedback = YES;
//        }else {
//            _bShowFeedback = NO;
//        }
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (0 == section) {
        return 0;
    }else {
        return 25;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (0 == section) {
        return @"";
    }else {
        return @"";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return 1;
    }else {
        if (_bShowFeedback) {
            return 3;
        }else {
            return 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section) {
        return 230;
    }
    return 36;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if (0 == indexPath.section) {
        float f_left = (tableView.frame.size.width - 190) / 2.0;
        UIImageView* image_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_about"]];
        [image_icon setFrame:CGRectMake(f_left, 5, 60, 60)];
        [cell.contentView addSubview:image_icon];
        
        UILabel* label_version = [[UILabel alloc] initWithFrame:CGRectMake(f_left + 70, 12, 120, 20)];
        [label_version setBackgroundColor:[UIColor clearColor]];
        [label_version setFont:[UIFont systemFontOfSize:15]];
        [label_version setTextAlignment:NSTextAlignmentLeft];
        [label_version setTextColor:[UIColor grayColor]];
        [label_version setText:[NSString stringWithFormat:@"版本号: V%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        [cell.contentView addSubview:label_version];
        
        UILabel* label_title = [[UILabel alloc] initWithFrame:CGRectMake(f_left + 70, 37, 120, 20)];
        [label_title setBackgroundColor:[UIColor clearColor]];
        [label_title setFont:[UIFont systemFontOfSize:18]];
        [label_title setTextAlignment:NSTextAlignmentLeft];
        [label_title setTextColor:[UIColor blackColor]];
        [label_title setText:@"亲宝动画片"];
        [cell.contentView addSubview:label_title];
        
        UIView* view_gap = [[UIView alloc] initWithFrame:CGRectMake(40, 68, tableView.frame.size.width - 80, 1)];
        [view_gap setBackgroundColor:RGB(0xc8c8cb, 1.0)];
        [cell.contentView addSubview:view_gap];
        
        UILabel* label_introduction = [[UILabel alloc] initWithFrame:CGRectMake(10, 73, tableView.frame.size.width - 20, 10)];
        label_introduction.textColor = RGB(0x555555, 1.0);
        label_introduction.font = [UIFont systemFontOfSize:13];
        label_introduction.textAlignment = NSTextAlignmentLeft;
        label_introduction.numberOfLines = 0;
        [label_introduction setBackgroundColor:[UIColor clearColor]];
        [label_introduction setText:@"       亲宝动画片是一款针对儿童早期教育和智力开发的软件，是每个妈妈和宝宝的必备神器。亲宝动画拥有海量童话、儿歌、故事、古典文学、数字、英语等各种类型资源，适合0到10岁的宝宝及妈妈使用。亲宝动画片为免费软件，使用过程中产生的流量费用，由运营商收取，使用中遇到的问题可加QQ群：2321362339，或发邮件到qinbaodonghua@126.com。亲宝动画片中所有动画资源均来自网友上传，如有侵权请及时联系我们，并出示版权证明，我们将删除相关资源。"];
        label_introduction.lineBreakMode = NSLineBreakByWordWrapping;
        [label_introduction sizeToFit];
        [cell.contentView addSubview:label_introduction];
    }else {
        switch (indexPath.row) {
            case 0:
            {
                UIImageView* image_clean = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clean"]];
                image_clean.frame = CGRectMake(10, 6, 24, 24);
                [cell.contentView addSubview:image_clean];
                
                UILabel* label_clean = [[UILabel alloc] initWithFrame:CGRectMake(40, 8, tableView.frame.size.width - 20, 20)];
                label_clean.textColor = [UIColor blackColor];
                label_clean.font = [UIFont systemFontOfSize:17];
                label_clean.textAlignment = NSTextAlignmentLeft;
                [label_clean setBackgroundColor:[UIColor clearColor]];
                [label_clean setText:@"清空缓存"];
                [cell.contentView addSubview:label_clean];
                break;
            }
            case 1:
            {
                UIImageView* image_feedback = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feedback"]];
                image_feedback.frame = CGRectMake(10, 6, 24, 24);
                [cell.contentView addSubview:image_feedback];
                
                UILabel* label_feedback = [[UILabel alloc] initWithFrame:CGRectMake(40, 8, tableView.frame.size.width - 20, 20)];
                label_feedback.textColor = [UIColor blackColor];
                label_feedback.font = [UIFont systemFontOfSize:17];
                label_feedback.textAlignment = NSTextAlignmentLeft;
                [label_feedback setBackgroundColor:[UIColor clearColor]];
                [label_feedback setText:@"用户反馈"];
                [cell.contentView addSubview:label_feedback];
                break;
            }
            case 2:
            {
                UIImageView* image_comment = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment"]];
                image_comment.frame = CGRectMake(10, 6, 24, 24);
                [cell.contentView addSubview:image_comment];
                
                UILabel* label_comment = [[UILabel alloc] initWithFrame:CGRectMake(40, 8, tableView.frame.size.width - 20, 20)];
                label_comment.textColor = [UIColor blackColor];
                label_comment.font = [UIFont systemFontOfSize:17];
                label_comment.textAlignment = NSTextAlignmentLeft;
                [label_comment setBackgroundColor:[UIColor clearColor]];
                [label_comment setText:@"求五星好评"];
                [cell.contentView addSubview:label_comment];
                break;
            }
                
            default:
            {
                
                break;
            }
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (0 == indexPath.section) {
        return;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            NSLog(@"清空缓存");
            break;
        }
        case 1:
        {
            NSLog(@"用户反馈");
            break;
        }
        case 2:
        {
            if (NSOrderedAscending == [[UIDevice currentDevice].systemVersion compare:@"7.0"]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=961102267"]];
            }else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id961102267"]];
            }
            break;
        }
            
        default:
        {
            
            break;
        }
    }
}

@end

