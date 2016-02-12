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


@interface BMCartoonVC ()
@property(nonatomic, strong)BMTopTabBar* cartoonToolbar;
@end

@implementation BMCartoonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView* customTitleView = [[UIView alloc] initWithFrame:CGRectMake(50, 5, VIEW_DEFAULT_WIDTH-100, 35)];
    UIView* baseView = customTitleView;
    BMTopTabButton* Btn1 = [BMTopTabButton NewWithName:@"动画片"];
    BMTopTabButton* Btn2 = [BMTopTabButton NewWithName:@"最热门"];
    BMTopTabButton* Btn3 = [BMTopTabButton NewWithName:@"学国学"];
    BMTopTabButton* Btn4 = [BMTopTabButton NewWithName:@"学外语"];
    InitViewX(BMTopTabBar, cartoonToolbar, baseView,  0)
    NSDictionary* map = NSDictionaryOfVariableBindings(cartoonToolbar);
    ViewAddCons(baseView, @"H:|-(8)-[cartoonToolbar]-|", nil, map);
    ViewAddCenterY(baseView, cartoonToolbar)
    [cartoonToolbar setItems:@[Btn1, Btn2, Btn3, Btn4] height:35];
    __weak BMCartoonVC* SELF = self;
    cartoonToolbar.blk = ^(int index){
        [SELF topBarButtonClick:index];
    };
    cartoonToolbar.tabTag = 1000;
    cartoonToolbar.userInteractionEnabled = YES;
    self.navigationItem.titleView = customTitleView;
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
    
}

@end
