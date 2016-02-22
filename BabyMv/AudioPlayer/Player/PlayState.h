//
//  PlayState.h
//  KWPlayer
//
//  Created by YeeLion on 11-1-24.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

typedef enum _PlayState {
    PLayStateUndefined = 0,
    PlayStateBuffering,
    //PlayStatePrepareing,
    PlayStatePlaying,
    PlayStatePaused,
    PlayStateStopped,
    PlayStateBufferingFailed,
    //PlayStateDecodeError,
    //PlayStatePlayError,
    PlayStateFailed,
} PlayState;

