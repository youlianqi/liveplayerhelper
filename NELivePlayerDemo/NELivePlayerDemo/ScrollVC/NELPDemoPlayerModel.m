//
//  NELPDemoPlayerModel.m
//  PlayerDemo
//
//  Created by Netease on 2018/6/26.
//  Copyright © 2018年 Wei942. All rights reserved.
//

#import "NELPDemoPlayerModel.h"

@interface NELPDemoPlayerModel ()
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isMarkPlay;
@end

@implementation NELPDemoPlayerModel

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithUrl:(NSString *)url {
    if (self = [super init]) {
        [self initPlayerNotication];
        _url = url;
        _player = [self createPlayer];
        _isReady = NO;
    }
    return self;
}

- (NELivePlayerController *)createPlayer {
    [NELivePlayerController setLogLevel:NELP_LOG_SILENT];
    NSError *error = nil;
    NELivePlayerController *player = [[NELivePlayerController alloc] initWithContentURL:[NSURL URLWithString:_url]
                                                               error:&error];
    if (player == nil) {
        NSLog(@"player initilize failed, please tay again.error = [%@]!", error);
    }
    player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [player setBufferStrategy:NELPAntiJitter];
    [player setScalingMode:NELPMovieScalingModeAspectFit]; // 设置画面显示模式，默认原始大小
    [player setShouldAutoplay:YES]; // 设置prepareToPlay完成后是否自动播放
    [player setHardwareDecoder:YES]; // 设置解码模式，是否开启硬件解码
    [player setPauseInBackground:NO]; // 设置切入后台时的状态，暂停还是继续播放
    [player setPlaybackTimeout:15 *1000]; // 设置拉流超时时间
    [player setLoopPlayCount:-1]; //无限循环
    [player setMute:YES];
    [player prepareToPlay];
    return player;
}

- (void)initPlayerNotication {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(PlayerDidPrepared:)
                                                 name:NELivePlayerDidPreparedToPlayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(PlayerDisplayFirstVideo:)
                                                 name:NELivePlayerFirstVideoDisplayedNotification
                                               object:nil];
}

- (void)startPlay {
    if (_isReady) {
        [self.player setMute:NO];
        [self.player play];
        NSLog(@"[%@] 开始播放", _url);
    } else {
        _isMarkPlay = YES;
        NSLog(@"[%@] 标记播放", _url);
    }
}

- (void)stopPlay {
    _isMarkPlay = NO;
    [self.player setMute:YES];
    [self.player setCurrentPlaybackTime:0];
    [self.player pause];
}

- (void)releasePlayer {
    [self.player.view removeFromSuperview];
    [self.player shutdown];
    self.player = nil;
}

- (void)PlayerDidPrepared:(NSNotification *)note {
    if (note.object == _player) {
        _isReady = YES;
    }
}

- (void)PlayerDisplayFirstVideo:(NSNotification *)note {
    if (note.object == _player) {
        if (!_isMarkPlay) {
            [self.player setMute:YES];
            [self.player pause];
            NSLog(@"[%@] 暂停播放", _url);
        } else {
            [self.player setMute:NO];
            NSLog(@"[%@] 开始播放", _url);
        }
    }
}

- (void)setIsPlaying:(BOOL)isPlaying {
    if (isPlaying != _isPlaying) {
        if (isPlaying) {
            [self startPlay];
        } else {
            [self stopPlay];
        }
        _isPlaying = isPlaying;
    }
}

@end
