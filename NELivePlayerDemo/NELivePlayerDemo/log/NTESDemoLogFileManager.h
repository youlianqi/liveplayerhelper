//
//  NTESDemoLogFileManager.h
//  NERtcDemo
//
//  Created by Netease on 2020/2/28.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#ifndef PLAYER_LOG
#define PLAYER_LOG(...) DDLogInfo(__VA_ARGS__)
#endif
//#ifdef DEBUG
//#define PLAYER_LOG(...) DDLogInfo(__VA_ARGS__)
//#else
//#define PLAYER_LOG(...)
//#endif


NS_ASSUME_NONNULL_BEGIN

extern DDLogLevel ddLogLevel;

@interface NTESDemoLogFileManager : DDLogFileManagerDefault

@end

NS_ASSUME_NONNULL_END
