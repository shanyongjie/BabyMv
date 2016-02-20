//
//  BMVlcVideoPlayViewController.m
//  BabyMv
//
//  Created by 单永杰 on 15/6/19.
//  Copyright (c) 2015年 happybaby. All rights reserved.
//

#import "BMVlcVideoPlayViewController.h"
#import "BMDataModel.h"
#import "MacroDefinition.h"


#define USE_VLC_LIB 0

#if USE_VLC_LIB
#import <MobileVLCKit/MobileVLCKit.h>
#endif

#define TAG_LABEL_TITLE               300
#define TAG_BTN_RETURN                301
#define TAG_LABEL_CURRENT             302
#define TAG_LABEL_DURATION            303
#define TAG_BTN_PLAY                  304
#define TAG_SLIDER                    305
#define TAG_BTN_PREV                  306
#define TAG_BTN_NEXT                  307


#if USE_VLC_LIB
@interface BMVlcVideoPlayViewController ()<VLCMediaPlayerDelegate>
@property (nonatomic, strong) VLCMediaPlayer* moviePlayer;
@property (nonatomic, strong) VLCMedia* videoMedia;
@end
#endif


@implementation BMVlcVideoPlayViewController

- (id) initWith {
    self = [super init];
    if (self) {
        bScreenLock = false;
    }
    
    return self;
}

-(void)setVideoInfo:(BMCartoonListDataModel *)videoInfo index:(NSInteger)index videoList:(NSArray *)currentPlayingList{
    _videoInfo = videoInfo;
    _currentPlayingIndex = index;
    _currentPlayingList = [NSArray arrayWithArray:currentPlayingList];
}

#pragma mark -- loading status
- (void)showLoadingPage:(BOOL)bShow descript:(NSString*)strDescript
{
    if (bShow) {
        if (!_waitingView) {
        }
        _waitingView.hidden=NO;
        [self.view bringSubviewToFront:_waitingView];
    } else {
        [_waitingView removeFromSuperview];
        _waitingView=nil;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    int n_screen_width = [[UIScreen mainScreen] bounds].size.height;
    int n_screen_height = [[UIScreen mainScreen] bounds].size.width;
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    _playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, n_screen_width, n_screen_height)];
    [_playerView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_playerView];
    
    
    _topBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, n_screen_width, 44)];
    [_topBackgroundView setBackgroundColor:RGB(0xfecd3f, 1.0)];
    
    _bottomBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, n_screen_height - 50, n_screen_width, 50)];
    [_bottomBackgroundView setBackgroundColor:RGB(0x363636, 1.0)];
    
    UIButton* btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnReturn setBackgroundColor:[UIColor clearColor]];
    [btnReturn setImage:[UIImage imageNamed:@"returnNormal"] forState:(UIControlStateNormal)];
    [btnReturn setImage:[UIImage imageNamed:@"returnClicked"] forState:(UIControlStateHighlighted)];
    [btnReturn addTarget:self action:@selector(onBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    //    btnReturn.frame = CGRectMake(0, 9, 30, 25.5);
    btnReturn.frame = CGRectMake(0, 0, 60, 44);
    btnReturn.imageEdgeInsets = UIEdgeInsetsMake(4.5, 8, 4.5, 8);
    [btnReturn setTag:TAG_BTN_RETURN];
    [_topBackgroundView addSubview:btnReturn];
    
    UILabel* label_title = [[UILabel alloc] initWithFrame:CGRectMake((n_screen_width - 240) / 2, 10, 240, 22)];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:NSTextAlignmentCenter];
    [label_title setTextColor:RGB(0x7b4802, 1.0)];
    [label_title setTag:TAG_LABEL_TITLE];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [label_title setText: _videoInfo.Name];
    [_topBackgroundView addSubview:label_title];
    
    UIButton* btnPlay = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [btnPlay setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
    
    btnPlay.frame = CGRectMake(20, 10, 48, 30);
    btnPlay.imageEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 9);
    [btnPlay setBackgroundColor:[UIColor clearColor]];
    [btnPlay setTag:TAG_BTN_PLAY];
    [btnPlay addTarget:self action:@selector(onBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    [_bottomBackgroundView addSubview:btnPlay];
    
    UIButton* btnNext = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [btnNext setImage:[UIImage imageNamed:@"btnNextNormal"] forState:UIControlStateNormal];
    [btnNext setImage:[UIImage imageNamed:@"btnNextClicked"] forState:UIControlStateHighlighted];
    btnNext.frame = CGRectMake(77, 10, 48, 30);
    btnNext.imageEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 9);
    [btnNext setBackgroundColor:[UIColor clearColor]];
    [btnNext setTag:TAG_BTN_NEXT];
    [btnNext addTarget:self action:@selector(onBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    [_bottomBackgroundView addSubview:btnNext];
    
    UILabel* label_current_time = [[UILabel alloc] initWithFrame:CGRectMake(135, 15, 35, 20)];
    [label_current_time setBackgroundColor:[UIColor clearColor]];
    [label_current_time setFont:[UIFont systemFontOfSize:12]];
    [label_current_time setTextAlignment:NSTextAlignmentRight];
    [label_current_time setTextColor:[UIColor whiteColor]];
    [label_current_time setTag:TAG_LABEL_CURRENT];
    [label_current_time setText:@"00:00"];
    [_bottomBackgroundView addSubview:label_current_time];
    
    UILabel* label_duration = [[UILabel alloc] initWithFrame:CGRectMake(170, 15, 40, 20)];
    [label_duration setBackgroundColor:[UIColor clearColor]];
    [label_duration setFont:[UIFont systemFontOfSize:12]];
    [label_duration setTextAlignment:NSTextAlignmentLeft];
    [label_duration setTextColor:RGB(0x9a9a9a, 1.0)];
    [label_duration setTag:TAG_LABEL_DURATION];
    [label_duration setText:@"/00:00"];
    [_bottomBackgroundView addSubview:label_duration];
    
    UISlider* slider = [[UISlider alloc] initWithFrame:CGRectMake(225, 15, n_screen_width - 300, 20)];
    [slider setBackgroundColor:[UIColor clearColor]];
    [slider setTag:TAG_SLIDER];
    [slider addTarget:self action:@selector(onSeekClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    [slider setThumbImage:[UIImage imageNamed:@"seekThumb"] forState:(UIControlStateNormal)];
    [slider setThumbImage:[UIImage imageNamed:@"seekThumbHighlighted"] forState:(UIControlStateHighlighted)];
    [slider setMinimumTrackTintColor:RGB(0x41acdd, 1.0)];
    [slider setMaximumTrackTintColor:RGB(0x515151, 1.0)];
    [_bottomBackgroundView addSubview:slider];
    
    [self.view addSubview:_topBackgroundView];
    [self.view addSubview:_bottomBackgroundView];
    
    _btnScreenLock = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnScreenLock.frame = CGRectMake(n_screen_width - 55, n_screen_height - 40, 30, 30);
    [_btnScreenLock setBackgroundColor:[UIColor clearColor]];
    if (bScreenLock) {
        [_btnScreenLock setImage:[UIImage imageNamed:@"btnLocked"] forState:(UIControlStateNormal)];
    }else{
        [_btnScreenLock setImage:[UIImage imageNamed:@"btnUnLocked"] forState:(UIControlStateNormal)];
    }
    [_btnScreenLock addTarget:self action:@selector(onScreenLockClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_btnScreenLock];
    
    _gestureResponseView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, n_screen_width, n_screen_height - 88)];
    [_gestureResponseView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_gestureResponseView];
    
    _tipsRect = _gestureResponseView.frame;
    
    UITapGestureRecognizer *tapGestureRecognize=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapErrorViewGestureRecognizer:)];
    tapGestureRecognize.numberOfTapsRequired=1;
    [_gestureResponseView addGestureRecognizer:tapGestureRecognize];
    
#if USE_VLC_LIB
    _moviePlayer = [[VLCMediaPlayer alloc] init];
    _moviePlayer.delegate = self;
    _moviePlayer.drawable = _playerView;
    [self play];
#endif
}

#if USE_VLC_LIB
- (void)play{
    _tipsRect = _gestureResponseView.frame;
    
    BMCartoonListDataModel* song_item = self.videoInfo;
    NSString*documentsDirectory = DOWNLOAD_DIR;
    NSString *name = [NSString stringWithFormat:@"%@.%@", song_item.Rid, [song_item.Url pathExtension]];
    NSString *str_file_path =[documentsDirectory stringByAppendingPathComponent:name];
    
    if ((song_item && [song_item.IsDowned intValue]) && [[NSFileManager defaultManager] fileExistsAtPath:str_file_path]) {
        if (_moviePlayer) {
            [_moviePlayer stop];
        }
        
        int n_screen_width = [[UIScreen mainScreen] bounds].size.height;
        int n_screen_height = [[UIScreen mainScreen] bounds].size.width;
        int temp = n_screen_height + n_screen_width;
        n_screen_width = (n_screen_width > n_screen_height) ? n_screen_width : n_screen_height;
        n_screen_height = temp - n_screen_width;
        
        [self.view bringSubviewToFront:_bottomBackgroundView];
        [self.view bringSubviewToFront:_topBackgroundView];
        [self.view bringSubviewToFront:_gestureResponseView];
        [self.view bringSubviewToFront:_btnScreenLock];
        
        _moviePlayer.media = [VLCMedia mediaWithPath:str_file_path];
        [_moviePlayer play];
        
    }else{
        _moviePlayer.media = [VLCMedia mediaWithURL:[NSURL URLWithString:song_item.Url]];
        [_moviePlayer play];
        
        [self.view bringSubviewToFront:_bottomBackgroundView];
        [self.view bringSubviewToFront:_topBackgroundView];
        [self.view bringSubviewToFront:_gestureResponseView];
        [self.view bringSubviewToFront:_btnScreenLock];
        [self showLoadingPage:YES descript:@"正在缓冲"];
    }
}
#endif

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----- button response

- (void)onBtnClicked : (id)sender{
    UIButton* btn_control = (UIButton*)sender;
    if (btn_control) {
        switch (btn_control.tag) {
            case TAG_BTN_RETURN:
            {
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
                
                [self dismissViewControllerAnimated:YES completion:^{
#if USE_VLC_LIB
                    _moviePlayer.delegate = nil;
                    [_moviePlayer stop];
                    NSLog(@"view did unload");
#endif
                }];
                break;
            }
#if USE_VLC_LIB
            case TAG_BTN_PLAY:
            {
                if (_moviePlayer.isPlaying)
                    [_moviePlayer pause];
                else{
                    [_moviePlayer play];
                }
                
                break;
            }
            case TAG_BTN_PREV:
            {
                break;
            }
            case TAG_BTN_NEXT:
            {
                if (self.currentPlayingList.count) {
                    BMCartoonListDataModel* next_item = self.currentPlayingList[++self.currentPlayingIndex];
                    _videoInfo = next_item;
                }else {
                    return;
                }
                
                [self play];
                break;
            }
#endif
            default:
                break;
        }
    }
}

- (void)onScreenLockClick{
    bScreenLock = !bScreenLock;
    if (bScreenLock) {
        [_btnScreenLock setImage:[UIImage imageNamed:@"btnLocked"] forState:(UIControlStateNormal)];
        if (!_bottomBackgroundView.hidden){
            _bottomBackgroundView.alpha = 1.0;
            _topBackgroundView.alpha = 1.0;
            [UIView animateWithDuration:0.3 animations:^{
                _bottomBackgroundView.alpha = 0.0;
                _topBackgroundView.alpha = 0.0;
                
            } completion:^(BOOL finished) {
                _bottomBackgroundView.hidden = YES;
                _topBackgroundView.hidden = YES;
            }];
        }
    }else {
        [_btnScreenLock setImage:[UIImage imageNamed:@"btnUnLocked"] forState:(UIControlStateNormal)];
    }
}

#pragma mark ----- slider seek clicked
- (void) onSeekClicked:(id)sender{
#if USE_VLC_LIB
    UISlider* slider = (UISlider*)sender;
//    _moviePlayer.time = slider.value *
    NSLog(@"current time is %d", [_moviePlayer.time intValue]);
    [_moviePlayer setTime:[VLCTime timeWithInt:((int)(slider.value * [_moviePlayer.media.length intValue]))]];
#endif
}

#pragma mark ----- hide status bar & view scape left delegate
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);;
}

- (BOOL) shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark ----- single tap response
- (void)singleTapErrorViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (bScreenLock) {
        return;
    }
    
    if (_bottomBackgroundView.hidden) {
        _bottomBackgroundView.alpha = 0.0;
        _topBackgroundView.alpha = 0.0;
        _bottomBackgroundView.hidden = NO;
        _topBackgroundView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _bottomBackgroundView.alpha = 1.0;
            _topBackgroundView.alpha = 1.0;
        }];
    }else {
        _bottomBackgroundView.alpha = 1.0;
        _topBackgroundView.alpha = 1.0;
        [UIView animateWithDuration:0.3 animations:^{
            _bottomBackgroundView.alpha = 0.0;
            _topBackgroundView.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            _bottomBackgroundView.hidden = YES;
            _topBackgroundView.hidden = YES;
        }];
    }
}

#pragma mark ----- vlc play state delegate
#if USE_VLC_LIB
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification{
    if (_moviePlayer.isPlaying) {
        UIButton* btnPlay = (UIButton*)[_bottomBackgroundView viewWithTag:TAG_BTN_PLAY];
        if (btnPlay) {
            btnPlay.imageEdgeInsets = UIEdgeInsetsMake(3, 9, 3, 9);
            [btnPlay setImage:[UIImage imageNamed:@"btnPaused"] forState:UIControlStateNormal];
        }
        
        [self showLoadingPage:NO descript:@"正在缓冲..."];
    }else {
        switch (_moviePlayer.state) {
            case VLCMediaPlayerStateBuffering:
            {
                UIButton* btnPlay = (UIButton*)[_bottomBackgroundView viewWithTag:TAG_BTN_PLAY];
                if (btnPlay) {
                    btnPlay.imageEdgeInsets = UIEdgeInsetsMake(3, 9, 3, 9);
                    [btnPlay setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
                }
                
                [self showLoadingPage:YES descript:@"正在缓冲..."];
                break;
            }
            case VLCMediaPlayerStatePaused:
            {
                UIButton* btnPlay = (UIButton*)[_bottomBackgroundView viewWithTag:TAG_BTN_PLAY];
                if (btnPlay) {
                    btnPlay.imageEdgeInsets = UIEdgeInsetsMake(3, 9, 3, 9);
                    [btnPlay setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
                }
                break;
            }
            case VLCMediaPlayerStateStopped:
            {
//                BMCartoonListDataModel* next_item = [[BMVideoPlayList sharedInstance] nextItem];
//                if (next_item) {
//                    _videoInfo = next_item;
//                }else {
//                    return;
//                }
//                
//                [self play];
                BMCartoonListDataModel* next_item = self.currentPlayingList[++self.currentPlayingIndex];
                _videoInfo = next_item;
                [self play];
                break;
            }
            case VLCMediaPlayerStateEnded:
            {
                UIButton* btnPlay = (UIButton*)[_bottomBackgroundView viewWithTag:TAG_BTN_PLAY];
                if (btnPlay) {
                    btnPlay.imageEdgeInsets = UIEdgeInsetsMake(3, 9, 3, 9);
                    [btnPlay setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
                }
                
                break;
            }
            default:
                break;
        }
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification{
    
    UILabel* label_title = (UILabel*)[_topBackgroundView viewWithTag:TAG_LABEL_TITLE];
    [label_title setText:_videoInfo.Name];
    
    float f_current_time = [_moviePlayer.time intValue] / 1000.f;
    float f_duration = [_moviePlayer.media.length intValue] / 1000.f;
    UILabel* label_duration = (UILabel*)[_bottomBackgroundView viewWithTag:TAG_LABEL_DURATION];
    if (label_duration) {
        [label_duration setText:[NSString stringWithFormat:@"/%02d:%02d", ((int)f_duration) / 60, ((int)f_duration) % 60]];
    }
    
    UILabel* label_current_time = (UILabel*)[_bottomBackgroundView viewWithTag:TAG_LABEL_CURRENT];
    if (label_current_time) {
        [label_current_time setText:[NSString stringWithFormat:@"%02d:%02d", ((int)f_current_time) / 60, ((int)f_current_time) % 60]];
    }
    
    UISlider* slider = (UISlider*) [_bottomBackgroundView viewWithTag:TAG_SLIDER];
    if (slider) {
        [slider setValue:f_current_time / f_duration animated:YES];
    }
}
#endif
@end
