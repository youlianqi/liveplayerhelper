//
//  NELivePlayerManager.h
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/3.
//  Copyright © 2024 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NELivePlayerFramework/NELivePlayerFramework.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * addSubview 播放器的画布时，播放器可能还没预加载完成，还没有画布。
 * 收到播放器第一帧视频显示时的消息通知时，如果发现播放器画布没有superView，则发出这个通知， 通知的object 为播放器的url。
 */
extern NSString *const NELivePlayerPlayViewNotAddSubviewNotification;


/**
 * 单个播放器
 */
@interface NELivePlayer : NSObject

/**
 * 播放器核心功能类
 * 播放器预加载完成，可以通过 player 的 view 获取画布
 */
@property (nonatomic, strong, nullable) NELivePlayerController *player;

/**
 * 用户接口层是否设置播放器为播放模式
 */
@property (nonatomic, assign) BOOL isPlaying;

@end

/**
 * 播放器管理
 */
@interface NELivePlayerManager : NSObject

+ (NELivePlayerManager *)sharedInstance;

/**
 * 停止并释放所有播放器。
 * 此接口会清理预加载的播放列表。
 */
- (void)clearAllPlayers;
/**
 * 还未播放，在播放列表页面，预加载所有的 prepareUrlList。
 * 在播放列表页面先调了该接口，等几秒后，再跳转到直播页面（直播页面的地址在 prepareUrlList 中），直播页面能快速出图
 * prepareUrlList 传递 6个将要播放的url
 */
- (void)setLivePlayerUrlListOnlyPreload:(NSArray<NSString *> *)prepareUrlList;

/**
*  播放器url预建连。 会自动播放 playingUrl 和 nextPlayUrl， 其中 playingUrl 声音为 unmute，nextPlayUrl 声音为 mute
*  prepareUrlList 需要播放器提前准备的url列表 滑动过程中 nextPlayUrl  不为空时。 传递 1个将要播放的url和上一个播放的url。滑动结束，nextPlayUrl 为空，传递 2个将要播放的url和上一个播放的url。
*  playingUrl 当前需要播放的url。
*  nextPlayUrl 下一个需要播放的url。 滑动过程中，nextPlayUrl 设置滑动下一个播放的url，能直接播放这个url，并且mute。 滑动结束，将 nextPlayUrl 设置为空字符串
*/
- (BOOL)setLivePlayerUrlList:(NSArray<NSString *> *)prepareUrlList playingUrl:(NSString *)playingUrl nextPlayUrl:(NSString *)nextPlayUrl;

/**
 * 切换当前页面播放器的url
 */
- (BOOL)switchPlayingUrl:(NSString *)playingUrl;
/**
 * 根据播放器地址获取 NELivePlayer
 */
- (NELivePlayer *)getPlayerWithUrl:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
