//
//  BMBaseVC.m
//  BabyMv
//
//  Created by ma on 2/27/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMBaseVC.h"
#import "Reachability.h"
#import "iToast.h"

@interface BMBaseVC()

@property(nonatomic, strong)UIView* waitingView;

@end

@implementation BMBaseVC

-(void)viewWillAppear:(BOOL)animated {
    if([Reachability reachabilityForLocalWiFi].currentReachabilityStatus==NotReachable&&[[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        [iToast defaultShow:@"请检查您的网络连接。" duration:2000];
    }
}

#pragma mark ----- hide status bar & view scape left delegate
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation) == UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (BOOL) shouldAutorotate{
    return NO;
}

#pragma mark - 显示加载菊花
- (void)showLoadingPage:(BOOL)bShow descript:(NSString*)strDescript
{
    if (bShow) {
        if([Reachability reachabilityForLocalWiFi].currentReachabilityStatus==NotReachable&&[[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
            return;
        }

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
