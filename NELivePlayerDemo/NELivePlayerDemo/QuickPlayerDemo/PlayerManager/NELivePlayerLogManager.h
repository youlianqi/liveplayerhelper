//
//  NELivePlayerLogManager.h
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/14.
//

#import <Foundation/Foundation.h>
#import <NMCBasicModuleFramework/NMCCocoaLumberjack.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG
#define LIVE_PLAYER_LOG(...) NSLog(__VA_ARGS__)
#else
#ifndef LIVE_PLAYER_LOG
#define LIVE_PLAYER_LOG(frmt, ...)    NMC_LOG_MAYBE(NMC_LOG_ASYNC_ENABLED, NMC_LOG_LEVEL_DEF, NMCDDLogFlagInfo,    0, @"LivePlayer", __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#endif
#endif


@interface NELivePlayerLogManager : NSObject

+ (instancetype)shareInstance;

- (void)setLogLevel:(NMCDDLogLevel)logLevel;

@end

NS_ASSUME_NONNULL_END
