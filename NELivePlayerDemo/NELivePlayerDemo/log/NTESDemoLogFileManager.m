//
//  NTESDemoLogFileManager.m
//  NERtcDemo
//
//  Created by Netease on 2020/2/28.
//

#import "NTESDemoLogFileManager.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.

DDLogLevel ddLogLevel = DDLogLevelAll;

@implementation NTESDemoLogFileManager

-(NSString *)newLogFileName {
    NSString *appName = @"Demo";
    NSString *timeStamp = [self getTimestamp];

    return [NSString stringWithFormat:@"%@_%@.log", appName, timeStamp];
}

-(BOOL)isLogFile:(NSString *)fileName {
    if ([fileName hasPrefix:@"Demo_"]) {
        return YES;
    }
    return NO;
}

-(NSString *)getTimestamp {
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"YYYY.MM.dd-HH.mm.ss"];
    });

    return [dateFormatter stringFromDate:NSDate.date];
}

@end
