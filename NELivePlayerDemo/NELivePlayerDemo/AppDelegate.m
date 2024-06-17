//
//  AppDelegate.m
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/5.
//

#import "AppDelegate.h"
#import "NELivePlayerLoginViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)initDemoLog
{
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dir = [[docPath stringByAppendingPathComponent:@"Netease"] copy];
    dir = [dir stringByAppendingString:@"/demo"];
    NTESDemoLogFileManager *fileLogManager = [[NTESDemoLogFileManager alloc] initWithLogsDirectory:dir];
    fileLogManager.maximumNumberOfLogFiles = 7;
    fileLogManager.logFilesDiskQuota = 40*1024*1024;
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileLogManager];
    fileLogger.maximumFileSize = 5*1024*1024;
    fileLogger.rollingFrequency = 24*60*60;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    DDLogFileFormatterDefault *timeFormat =  [[DDLogFileFormatterDefault alloc] initWithDateFormatter:dateFormatter];
    [fileLogger setLogFormatter:timeFormat];
    [DDLog addLogger:fileLogger withLevel:DDLogLevelInfo];
    
  #ifdef DEBUG
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
  #endif
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initDemoLog];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NELivePlayerLoginViewController *viewController = [[NELivePlayerLoginViewController alloc] init];
    UINavigationController *neLivePlayerLoginController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = neLivePlayerLoginController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
