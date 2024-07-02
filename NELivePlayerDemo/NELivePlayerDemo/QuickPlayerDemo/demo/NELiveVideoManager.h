//
//  NELiveVideoManager.h
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/3.
//  Copyright © 2024 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKVideoScrollView.h"
#import "NELiveVideoCell.h"


NS_ASSUME_NONNULL_BEGIN

extern NSString *const NE_DEMO_PLAYER_URL_1;
extern NSString *const NE_DEMO_PLAYER_URL_2;
extern NSString *const NE_DEMO_PLAYER_URL_3;
extern NSString *const NE_DEMO_PLAYER_URL_4;
extern NSString *const NE_DEMO_PLAYER_URL_5;
extern NSString *const NE_DEMO_PLAYER_URL_6;
extern NSString *const NE_DEMO_PLAYER_URL_7;
extern NSString *const NE_DEMO_PLAYER_URL_8;

@class NELivePlayer;
@class NELiveVideoCell;
@class NELivePlayerViewController;

@interface NELiveVideoManager : NSObject

@property (nonatomic, strong) GKVideoScrollView *portraitScrollView;

@property (nonatomic, weak) NELiveVideoCell *currentCell;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) NSInteger endDisplayingIndex;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, weak) NELivePlayerViewController *viewController;

@property (nonatomic, strong, nullable) NELivePlayer *player;

- (instancetype)initWithDataSource:(NSArray *)array;

/// 准备cell
- (void)prepareCell:(NELiveVideoCell *)cell index:(NSInteger)index;

/// 预加载视频
- (void)preloadVideoWithCell:(NELiveVideoCell *)cell index:(NSInteger)index;

/// 播放视频
- (void)playVideoWithCell:(NELiveVideoCell *)cell index:(NSInteger)index;

/// 停止播放
- (void)stopVideoWithCell:(NELiveVideoCell *)cell index:(NSInteger)index;

- (void)reloadData;
- (void)reloadDataWithIndex:(NSInteger)index;
- (void)reloadDataDidProfileChanged;

- (void)clearAllPlayers;

@end

NS_ASSUME_NONNULL_END
