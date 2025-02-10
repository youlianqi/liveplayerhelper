//
//  NELivePlayerManager.m
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/3.
//  Copyright © 2024 netease. All rights reserved.
//

#import "NELivePlayerManager.h"
#import <UIKit/UIKit.h>
#import "NELivePlayerManager.h"
#import "NELivePlayerLogManager.h"

#define kKeepPrepareLoadTimerDuration 20
#define kKeepPlayingTimerDuration 3
#define kPlayingErroRetryLimit 10

NSString *const NELivePlayerPlayViewNotAddSubviewNotification = @"NELivePlayerPlayViewNotAddSubviewNotification";

@interface NELivePlayer ()

@property (nonatomic, strong, nullable) NSString *url;

@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isHardware;
@property (nonatomic, assign) NELPBufferStrategy bufferStrategy;
@property (nonatomic, assign) BOOL pauseInBackground;
@property (nonatomic, assign) BOOL isInRestarting;;
@property (nonatomic, assign) BOOL isPlayingBeforeBackground;
@property (nonatomic, assign) BOOL isMarkPlay;
@property (nonatomic, assign) NSUInteger retryCount;

- (instancetype)initWithUrl:(NSString *)url;

- (void)resetWithUrl:(NSString *)url;

- (void)restartPlay;

- (void)recreatePlay;

- (void)prepareToPlay;

- (void)startPlay;

- (void)createPlayer;

- (void)stopPlay;

- (void)releasePlayer;

@end

@implementation NELivePlayer

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public method

- (instancetype)initWithUrl:(NSString *)url {
    if (self = [super init]) {
        [self initPlayerNotication];
        _url = url;
        _isHardware = YES;
        _pauseInBackground = YES;
        _bufferStrategy = NELPDelayPullUp;

        if (_url.length > 0) {
            [self createPlayer];
        }
        else {
            _player = nil;
        }
        
        _isReady = NO;
    }
    return self;
}

- (void)resetWithUrl:(NSString *)url {
    LIVE_PLAYER_LOG(@"resetWithUrl old url:%@ url:%@", _url, url);
    _url = url;
    self.retryCount = 0;
    if (self.isPlaying) {
        self.isPlaying = NO;
    }
    else {
        [self stopPlay];
        [self releasePlayer];
        [self createPlayer];
    }
}

- (void)prepareToPlay {
    if (![_player isPreparedToPlay]) {
        [_player prepareToPlay];
        LIVE_PLAYER_LOG(@"[%@] prepareToPlay", _url);
    }
}

#pragma mark - Private method

- (void)createPlayer {
    LIVE_PLAYER_LOG(@"[%@] createPlayer", _url);
    [NELivePlayerController setLogLevel:NELP_LOG_SILENT];
    NSError *error = nil;
    _player = [[NELivePlayerController alloc] initWithContentURL:[NSURL URLWithString:_url]
                                                           error:&error];
    if (_player == nil) {
        LIVE_PLAYER_LOG(@"player initilize failed, please tay again.error = [%@]!", error);
    }
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [_player setBufferStrategy:_bufferStrategy];
    [_player setScalingMode:NELPMovieScalingModeAspectFit]; // 设置画面显示模式，默认原始大小
    [_player setShouldAutoplay:NO]; // 设置prepareToPlay完成后是否自动播放
    //[_player setShouldAutoplay:YES]; // 设置prepareToPlay完成后是否自动播放
    [_player setHardwareDecoder:_isHardware]; // 设置解码模式，是否开启硬件解码
    [_player setPauseInBackground:_pauseInBackground]; // 设置切入后台时的状态，暂停还是继续播放
    [_player setPlaybackTimeout:15 *1000]; // 设置拉流超时时间
    [_player setLoopPlayCount:-1]; //无限循环
    [self prepareToPlay];
}

- (void)initPlayerNotication {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotifyPlayerDidPrepared:)
                                                 name:NELivePlayerDidPreparedToPlayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotifyPlayerDisplayFirstVideo:)
                                                 name:NELivePlayerFirstVideoDisplayedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotifyPlayerPlaybackDidFinishError:)
                                                 name:NELivePlayerPlaybackDidFinishErrorKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotifyPlayerPlaybackDidFinish:)
                                                 name:NELivePlayerPlaybackFinishedNotification
                                               object:nil];
}

- (void)startPlay {
    if (_isReady) {
        [self.player play];
        self.isInRestarting = NO;
        //_isMarkPlay = YES;
        LIVE_PLAYER_LOG(@"[%@] 开始播放", _url);
    } else {
        //_isMarkPlay = YES;
        LIVE_PLAYER_LOG(@"[%@] 标记播放", _url);
    }
    _isPlaying = YES;
}

- (void)stopPlay {
    _isMarkPlay = NO;
    _isReady = NO;
    _isPlaying = NO;
    [self.player pause];
    LIVE_PLAYER_LOG(@"[%@] 停止播放", _url);
}

- (void)restartPlay {
    self.isInRestarting = YES;
    [self stopPlay];
    [self releasePlayer];
    [self createPlayer];
    [self startPlay];
}

- (void)recreatePlay {
    [self stopPlay];
    [self releasePlayer];
    [self createPlayer];
}

- (void)releasePlayer {
    [self.player.view removeFromSuperview];
    [self.player shutdown];
    self.player = nil;
    LIVE_PLAYER_LOG(@"[%@] releasePlayer", _url);
}

- (void)onNotifyPlayerDidPrepared:(NSNotification *)notification {
    if (notification.object == _player) {
        LIVE_PLAYER_LOG(@"[%@] onNotifyPlayerDidPrepared object:%@", _url, notification.object);
        _isReady = YES;
        self.retryCount = 0;
        self.isInRestarting = NO;
        
        if (self.isPlaying && !self.player.isPlaying) {
            UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
            if (applicationState == UIApplicationStateActive) {
                LIVE_PLAYER_LOG(@"[%@] 开始播放", _url);
                [self.player play];
                self.isMarkPlay = NO;
            }
            else {
                self.isMarkPlay = YES;
            }
        }
        else {
            self.isMarkPlay = NO;
        }
    }
}

- (void)onNotifyPlayerDisplayFirstVideo:(NSNotification *)notification {
    if (notification.object == _player) {
        LIVE_PLAYER_LOG(@"[%@] onNotifyPlayerDisplayFirstVideo", _url);
        if (_player.view.superview == nil) {
            LIVE_PLAYER_LOG(@"[%@] onNotifyPlayerDisplayFirstVideo 没有 addSubView", _url);
            [[NSNotificationCenter defaultCenter] postNotificationName:NELivePlayerPlayViewNotAddSubviewNotification object:_url];
        }
    }
}

- (void)onNotifyPlayerPlaybackDidFinishError:(NSNotification *)notification {
    if (notification.object == _player) {
        LIVE_PLAYER_LOG(@"[%@] onNotifyPlayerPlaybackDidFinishError retryCount:%@", _url, @(self.retryCount));
        if (self.retryCount < kPlayingErroRetryLimit) {
            BOOL isPlaying = self.isPlaying;
            [self recreatePlay];
            if (isPlaying) {
                [self startPlay];
            }
        }
    }
}

- (void)onNotifyPlayerPlaybackDidFinish:(NSNotification *)notification {
    if (notification.object == _player) {
        LIVE_PLAYER_LOG(@"[%@] onNotifyPlayerPlaybackDidFinish userInfo:%@ retryCount:%@", _url, notification.userInfo, @(self.retryCount));
        NSDictionary *userInfo = notification.userInfo;
        if (self.retryCount < kPlayingErroRetryLimit && [userInfo objectForKey:NELivePlayerPlaybackDidFinishErrorKey]) {
            BOOL isPlaying = self.isPlaying;
            [self recreatePlay];
            self.retryCount++;
            if (isPlaying) {
                [self startPlay];
            }
        }
    }
}

- (void)setIsPlaying:(BOOL)isPlaying {
    if (isPlaying != _isPlaying) {
        if (isPlaying) {
            LIVE_PLAYER_LOG(@"%@[%@] isPlaying YES", self, _url);
            [self startPlay];
        } else {
            LIVE_PLAYER_LOG(@"%@[%@] isPlaying NO", self, _url);
            [self stopPlay];
            [self releasePlayer];
            [self createPlayer];
        }
        _isPlaying = isPlaying;
    }
}

@end

@interface NELivePlayerManager ()

@property (nonatomic, assign) BOOL hasInited;
@property (nonatomic, strong) NSMutableArray<NELivePlayer *> *playerList;

@property (nonatomic, strong) NSString *playingUrl;
@property (nonatomic, strong) NSString *lastPlayUrl;
@property (nonatomic, strong) NSString *nextPlayUrl;

@property (nonatomic, strong) NSTimer *prepareLoadtimer;
@property (nonatomic, strong) NSTimer *playerTimer;

@property (nonatomic, strong) NSArray *cachePrepareUrlList;
@property (nonatomic, strong) NSString *cachePlayingUrl;
@property (nonatomic, strong) NSString *cacheNextPlayUrl;

@end

@implementation NELivePlayerManager

+ (NELivePlayerManager *)sharedInstance {
    static NELivePlayerManager *g_live_player_manager_Instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_live_player_manager_Instance = [[self alloc] init];
    });
    
    return g_live_player_manager_Instance;
}

- (void)dealloc {
    
}

- (void)clearAllPlayers {
    for (NELivePlayer *player in self.playerList) {
        [player stopPlay];
        [player releasePlayer];
        player.url = nil;
    }
    [_playerList removeAllObjects];
    
    self.playingUrl = @"";
    self.lastPlayUrl = @"";
    self.nextPlayUrl = @"";
    self.cachePlayingUrl = @"";
    self.cacheNextPlayUrl = @"";
    [self stopTimer];
    _hasInited = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _hasInited = NO;
        [self initDataIfNeeded];
        [NELivePlayerLogManager shareInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(appDidBecomeActive:)
                                                             name:UIApplicationDidBecomeActiveNotification
                                                           object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)initDataIfNeeded {
    if (!_hasInited) {
        _playerList = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSUInteger i = 0; i < 6; ++i) {
            NELivePlayer *playerModel= [[NELivePlayer alloc] initWithUrl:@""];
            [_playerList addObject:playerModel];
        }
    }
    
    _hasInited = YES;
}

- (BOOL)isPlayerUrlListChanged:(NSArray *)prepareUrlList playingUrl:(NSString *)playingUrl nextPlayUrl:(NSString *)nextPlayUrl {
    if (prepareUrlList.count != self.cachePrepareUrlList.count) {
        return YES;
    }
    
    if (![playingUrl isEqualToString:self.cachePlayingUrl]) {
        return YES;
    }
    
    if (![nextPlayUrl isEqualToString:self.cacheNextPlayUrl]) {
        return YES;
    }
    
    for (NSUInteger i = 0; i < prepareUrlList.count; i++) {
        if (![prepareUrlList[i] isEqualToString:self.cachePrepareUrlList[i]]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isInPrepareUrlList:(NSArray *)prepareUrlList player:(NELivePlayer *)player {
    for (NSString *url in prepareUrlList) {
        if ([player.url isEqualToString:url]) {
            return YES;
        }
    }
    
    return NO;
}

- (NELivePlayer *)findExpireLivePlayer:(NSArray *)prepareUrlList {
    for (NELivePlayer *player in self.playerList) {
        if (![self isInPrepareUrlList:prepareUrlList player:player]) {
            return player;
        }
    }
    
    return nil;
}

- (NSMutableArray *)findExpireLivePlayers:(NSArray *)prepareUrlList playingUrl:(NSString *)playingUrl nextPlayUrl:(NSString *)nextPlayUrl {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    
    for (NELivePlayer *player in self.playerList) {
        if (player.url.length == 0) {
            [array addObject:player];
            continue;
        }
        
        if (![self isLivePlayerInPlaying:player playingUrl:playingUrl nextPlayUrl:nextPlayUrl] &&
            ![self isUrlInPrepareUrlList:player.url urlList:prepareUrlList]) {
            [array addObject:player];
        }
    }
    
    return array;
}

- (BOOL)isPrepareUrlListChanged:(NSArray *)prepareUrlList {
    if (prepareUrlList.count != self.cachePrepareUrlList.count) {
        return YES;
    }
    
    for (NSUInteger i = 0; i < self.cachePrepareUrlList.count; ++i) {
        if (![self.cachePrepareUrlList[i] isEqualToString:prepareUrlList[i]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setLivePlayerUrlListOnlyPreload:(NSArray *)prepareUrlList {
    LIVE_PLAYER_LOG(@"%s prepareUrlList[%@]", __func__, prepareUrlList);
    [self initDataIfNeeded];
    
    if (![self isPrepareUrlListChanged:prepareUrlList]) {
        return;
    }
    
    [self stopPrepareLoadTimer];
 
    for (NSString *url in prepareUrlList) {
        NELivePlayer *livePlayer = [self getPlayerWithUrl:url];
        if (!livePlayer) {
            livePlayer = [self findExpireLivePlayer:prepareUrlList];
            
            if (livePlayer) {
                [livePlayer resetWithUrl:url];
            }
        }
    }
    
    self.cachePrepareUrlList = [NSArray arrayWithArray:prepareUrlList];
    [self startPrepareLoadTimer];
}

- (BOOL)isUrlInPrepareUrlList:(NSString *)url urlList:(NSArray *)urlList {
    for (NSString *prepareUrl in urlList) {
        if (prepareUrl.length > 0 &&  [prepareUrl isEqualToString:url]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)releaseUnusedPlayers {
    for (NELivePlayer *player in self.playerList) {
        if (player.url.length > 0 &&
            ![player.url isEqualToString:self.playingUrl] &&
            ![player.url isEqualToString:self.nextPlayUrl] &&
            ![player.url isEqualToString:self.lastPlayUrl] &&
            ![self isUrlInPrepareUrlList:player.url urlList:self.cachePrepareUrlList]) {
            LIVE_PLAYER_LOG(@"releaseUnusedPlayers player url:%@", player.url);
            [player stopPlay];
            [player releasePlayer];
            player.url = nil;
        }
    }
}

- (BOOL)stopLivePlayerIfNeeded {
#if 0
    for (NELivePlayer *player in self.playerList) {
        if (player.isPlaying ) {
            LIVE_PLAYER_LOG(@"[%s] playingUrl:%@, isPlaying to NO", __func__, player.url);
            player.isPlaying = NO;
        }
    }
#endif
    return YES;
}

- (BOOL)switchPlayingUrl:(NSString *)playingUrl {
    LIVE_PLAYER_LOG(@"%s switchPlayingUrl lastPlayingUrl:%@ to:%@", __func__, self.playingUrl, playingUrl);

    if ([self.playingUrl isEqualToString:playingUrl]) {
        return NO;
    }
    
    NELivePlayer *livePlayer = [self getPlayerWithUrl:self.playingUrl];
    livePlayer.url = playingUrl;
    [livePlayer.player switchContentUrl: [NSURL URLWithString:playingUrl]];
    self.playingUrl = playingUrl;
    self.cachePlayingUrl = playingUrl;
    
    [self stopPlayerTimer];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(startPlayerTimer) withObject:nil afterDelay:8];
    return YES;
}

- (BOOL)setLivePlayerUrlList:(NSArray *)prepareUrlListA playingUrl:(NSString *)playingUrl nextPlayUrl:(NSString *)nextPlayUrl {
    [self initDataIfNeeded];
    
    if (![self isPlayerUrlListChanged:prepareUrlListA playingUrl:playingUrl nextPlayUrl:nextPlayUrl]) {
        LIVE_PLAYER_LOG(@"%s is not changed. prepareUrlList:%@ playingUrl:%@, nextPlayUrl:%@", __func__, prepareUrlListA, playingUrl, nextPlayUrl);
        return NO;
    }
    [self stopTimer];
    
    LIVE_PLAYER_LOG(@"%s prepareUrlList:%@ playingUrl:%@, nextPlayUrl:%@", __func__, prepareUrlListA, playingUrl, nextPlayUrl);
    
    NSMutableArray *prepareUrlList = [NSMutableArray arrayWithCapacity:0];
    for (NSString *str in prepareUrlListA) {
        if (str.length > 0 && ![str isEqualToString:playingUrl] && ![str isEqualToString:nextPlayUrl]) {
            [prepareUrlList addObject:str];
        }
    }
    
    NSMutableArray *freeLivePlayer = [self findExpireLivePlayers:prepareUrlList playingUrl:playingUrl nextPlayUrl:nextPlayUrl];
    LIVE_PLAYER_LOG(@"%s freeLivePlayer:%@", __func__, freeLivePlayer);

    BOOL playingPlayerChanged = NO;
    if (![_playingUrl isEqualToString:playingUrl]) {
        playingPlayerChanged = YES;
    }
    self.playingUrl = playingUrl;
    
    if (nextPlayUrl.length > 0) {
        self.nextPlayUrl = nextPlayUrl;
    }
    else {
        self.nextPlayUrl = @"";
    }
    
    if (playingPlayerChanged) {
        NELivePlayer *lastPlayerModel = [self getPlayerWithUrl:self.lastPlayUrl];
        if (lastPlayerModel) {
            if (![self isLivePlayerInPlaying:lastPlayerModel playingUrl:playingUrl nextPlayUrl:nextPlayUrl]) {
                LIVE_PLAYER_LOG(@"setLivePlayerUrlList playingPlayerChanged lastPlayerModel:%@", lastPlayerModel.url);
                lastPlayerModel.isPlaying = NO;
            }
        }
        
        NELivePlayer *playingModel = [self getPlayerWithUrl:playingUrl];
        if (!playingModel) {
            if (freeLivePlayer.count > 0) {
                playingModel = freeLivePlayer[0];
                [freeLivePlayer removeObjectAtIndex:0];
                [playingModel resetWithUrl:playingUrl];
                LIVE_PLAYER_LOG(@"setLivePlayerUrlList playingPlayerChanged playingModel:%@", playingModel.url);
            }
        }
        [playingModel.player setMute:NO];
        playingModel.isPlaying = YES;
    }
    
    if (nextPlayUrl.length > 0) {
        NELivePlayer *nextPlayerModel = [self getPlayerWithUrl:nextPlayUrl];
        if (!nextPlayerModel) {
            if (freeLivePlayer.count > 0) {
                nextPlayerModel = freeLivePlayer[0];
                [freeLivePlayer removeObjectAtIndex:0];
                LIVE_PLAYER_LOG(@"setLivePlayerUrlList nextPlayUrl length > 0,  nextPlayerModel:%@", nextPlayerModel.url);
                [nextPlayerModel resetWithUrl:nextPlayUrl];
            }
        }
        
        if (nextPlayerModel) {
            //滑动到一半，直接开始拉流，但声音设置为 mute
            [nextPlayerModel.player setMute:YES];
            nextPlayerModel.isPlaying = YES;
        }
    }
    
    if (prepareUrlList.count >= 3) {
        NSString *url = prepareUrlList[2];
        NELivePlayer *playerModel = [self getPlayerWithUrl:url];
        if (playerModel) {
            if (playerModel.isPlaying && ![url isEqualToString:self.lastPlayUrl]) {
                playerModel.isPlaying = NO;
            }
        }
        else {
            if (freeLivePlayer.count > 0) {
                playerModel = freeLivePlayer[0];
                [freeLivePlayer removeObjectAtIndex:0];
            }
            
            if (playerModel) {
                //防止 preloadList 里又有 playingUrl，playingUrl 又被 stop
                if (![self isLivePlayerInPlaying:playerModel playingUrl:playingUrl nextPlayUrl:nextPlayUrl]) {
                    LIVE_PLAYER_LOG(@"setLivePlayerUrlList repareUrlList.count >= 3 playerModel:%@", playerModel.url);
                    [playerModel resetWithUrl:url];
                }
            }
        }
    }
    
    if (prepareUrlList.count >= 2) {
        NSString *url = prepareUrlList[1];
        NELivePlayer *playerModel = [self getPlayerWithUrl:url];
        if (playerModel) {
            if (playerModel.isPlaying && ![url isEqualToString:self.lastPlayUrl]) {
                playerModel.isPlaying = NO;
            }
        }
        else {
            if (freeLivePlayer.count > 0) {
                playerModel = freeLivePlayer[0];
                [freeLivePlayer removeObjectAtIndex:0];
            }
            
            if (playerModel) {
                //防止 preloadList 里又有 playingUrl，playingUrl 又被 stop
                if (![self isLivePlayerInPlaying:playerModel playingUrl:playingUrl nextPlayUrl:nextPlayUrl]) {
                    LIVE_PLAYER_LOG(@"setLivePlayerUrlList prepareUrlList.count >= 2 playerModel:%@", playerModel.url);
                    [playerModel resetWithUrl:url];
                }
            }
        }
    }
    
    if (prepareUrlList.count >= 1) {
        NSString *url = prepareUrlList[0];
        NELivePlayer *playerModel = [self getPlayerWithUrl:url];
        if (playerModel) {
            if (playerModel.isPlaying && ![url isEqualToString:self.lastPlayUrl]) {
                playerModel.isPlaying = NO;
            }
        }
        else {
            if (freeLivePlayer.count > 0) {
                playerModel = freeLivePlayer[0];
                [freeLivePlayer removeObjectAtIndex:0];
            }
            if (playerModel) {
                //防止 preloadList 里又有 playingUrl，playingUrl 又被 stop
                if (![self isLivePlayerInPlaying:playerModel playingUrl:playingUrl nextPlayUrl:nextPlayUrl]) {
                    LIVE_PLAYER_LOG(@"setLivePlayerUrlList prepareUrlList.count >= 1 playerModel:%@", playerModel.url);
                    [playerModel resetWithUrl:url];
                }
            }
        }
    }
       
    self.cachePrepareUrlList = [NSArray arrayWithArray:prepareUrlListA];
    self.cachePlayingUrl = playingUrl;
    self.cacheNextPlayUrl = nextPlayUrl;
    if (playingPlayerChanged) {
        self.lastPlayUrl = playingUrl;
    }
    [self releaseUnusedPlayers];
    [self startTimer];
    
    return YES;
}

- (NELivePlayer *)getPlayerWithUrl:(NSString *)url {
    for (NELivePlayer *player in self.playerList) {
        if ([player.url isEqualToString:url]) {
            return player;
        }
    }
    
    return nil;
}

- (BOOL)isLivePlayerInPlaying:(NELivePlayer *)livePlayer playingUrl:(NSString *)playingUrl nextPlayUrl:(NSString *)nextPlayUrl {
    if (livePlayer.url.length > 0 && 
        ([livePlayer.url isEqualToString:playingUrl] || ([livePlayer.url isEqualToString:nextPlayUrl]))) {
        return YES;
    }
    
    return NO;
}

- (void)startTimer {
    [self startPrepareLoadTimer];
    [self startPlayerTimer];
}

- (void)stopTimer {
    [self stopPrepareLoadTimer];
    [self stopPlayerTimer];
}

- (void)startPrepareLoadTimer {
    [self stopPrepareLoadTimer];
    _prepareLoadtimer = [NSTimer scheduledTimerWithTimeInterval:kKeepPrepareLoadTimerDuration target:self selector:@selector(onPrepareLoad:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_prepareLoadtimer forMode:NSRunLoopCommonModes];
}

- (void)stopPrepareLoadTimer {
    if (_prepareLoadtimer) {
        [_prepareLoadtimer invalidate];
        _prepareLoadtimer = nil;
    }
}

- (void)onPrepareLoad:(id)sender {
    for (NELivePlayer *player in self.playerList) {
        if (!player.isPlaying && player.url.length > 0) {
            [player recreatePlay];
        }
    }
}

- (void)startPlayerTimer {
    [self stopPlayerTimer];
    _playerTimer = [NSTimer scheduledTimerWithTimeInterval:kKeepPlayingTimerDuration target:self selector:@selector(onPlayerTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_playerTimer forMode:NSRunLoopCommonModes];
}

- (void)stopPlayerTimer {
    if (_playerTimer) {
        [_playerTimer invalidate];
        _playerTimer = nil;
    }
}

- (void)onPlayerTimer:(id)sender  {
    for (NSUInteger i = 0; i < self.playerList.count; ++i) {
        NELivePlayer *model = self.playerList[i];
        //LIVE_PLAYER_LOG(@"onPlayerTimer [%@][%@] isPlaying:%@ player.isPlaying:%@ playbackState:%@", @(i), model.url, @(model.isPlaying), @(model.player.isPlaying), @(model.player.playbackState));
        if (model.url.length > 0 && model.isPlaying) {
            UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
            LIVE_PLAYER_LOG(@"onPlayerTimer [%@][%@] isPlaying:%@ player.isPlaying:%@ playbackState:%@ applicationState:%@", @(i), model.url, @(model.isPlaying), @(model.player.isPlaying), @(model.player.playbackState), @(applicationState));
            BOOL isLivePlayerPlaying = model.player.isPlaying;
            if (!model.isInRestarting && !isLivePlayerPlaying) {
                [model restartPlay];
            }
            else if (isLivePlayerPlaying && !model.player.view.superview) {
                LIVE_PLAYER_LOG(@"[%@] onPlayerTimer model 没有 addSubView", model.url);
                [[NSNotificationCenter defaultCenter] postNotificationName:NELivePlayerPlayViewNotAddSubviewNotification object:model.url];
            }
        }
    }
}

// 当应用程序返回前台时，会调用此方法
- (void)appDidBecomeActive:(NSNotification *)notification {
    LIVE_PLAYER_LOG(@"%s", __FUNCTION__);
    [self performSelector:@selector(resumePlayerIfNeeded) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(startPlayerTimer) withObject:nil afterDelay:2.0];
}

- (void)resumePlayerIfNeeded {
    for (NSUInteger i = 0; i < self.playerList.count; ++i) {
        NELivePlayer *model = self.playerList[i];
        if (model.url.length > 0 && model.isPlaying && !model.player.isPlaying) {
            if (model.isMarkPlay) {
                LIVE_PLAYER_LOG(@"%s  [%@][%@] 恢复播放", __FUNCTION__, @(i), model.url);
                [model.player play];
            }
            else {
                LIVE_PLAYER_LOG(@"%s  [%@][%@] 重启播放", __FUNCTION__, @(i), model.url);
                [model restartPlay];
            }
        }
    }
}

// 当应用程序进入后台时，会调用此方法
- (void)appDidEnterBackground:(NSNotification *)notification {
    LIVE_PLAYER_LOG(@"%s", __FUNCTION__);
    [self stopPlayerTimer];
}

@end
