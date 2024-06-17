//
//  NELivePlayerLogManager.m
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/14.
//

#import "NELivePlayerLogManager.h"



@interface NELivePlayerLogHelper : NSObject

//NSDate -> yyyy-MM-dd HH:mm:ss
+ (NSString *)timeStringToDate:(NSDate *)date;

//deault log directory
+ (NSString *)defaultLogDirectory;

//default log temp directory
+ (NSString *)defaultLogTempDirectory;

@end

@implementation NELivePlayerLogHelper

//NSDate -> yyyy-MM-dd HH:mm:ss
+ (NSString *)timeStringToDate:(NSDate *)date {
    NSString *dateFormat = @"yyyy-MM-dd-HH-mm-ss-SSS";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSString *time = [dateFormatter stringFromDate:date];
    return (time ? time : @"none");
}

//deault log directory
+ (NSString *)defaultLogDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *logDirectory = [baseDir stringByAppendingPathComponent:@"NMCLogs"];
    NSString *logsDirectory = [logDirectory stringByAppendingPathComponent:@"NELivePlayer"];
    return logsDirectory;
}

//default log zip directory
+ (NSString *)defaultLogTempDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *logDirectory = [baseDir stringByAppendingPathComponent:@"NMCLogs"];
    return logDirectory;
}

@end

@interface NELivePlayerLogFormat : NSObject<NMCDDLogFormatter>

@end

@implementation NELivePlayerLogFormat

+ (NSDateFormatter *)logDateFormatter
{
    static NSDateFormatter *nelpLogDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nelpLogDateFormatter = [[NSDateFormatter alloc] init];
        nelpLogDateFormatter.dateFormat = @"MM-dd HH:mm:ss.SSS";
    });
    return nelpLogDateFormatter;
}

- (NSString *)formatLogMessage:(NMCDDLogMessage *)logMessage {
    NSString *logLevel = nil;
    switch (logMessage.flag) {
        case NMCDDLogFlagError:
            logLevel = @"ERROR";
            break;
        case NMCDDLogFlagWarning:
            logLevel = @"WARN";
            break;
        case NMCDDLogFlagDebug:
            logLevel = @"DEBUG";
            break;
        case NMCDDLogFlagInfo:
            logLevel = @"INFO";
            break;
        default:
            logLevel = @"VERBOSE";
            break;
    }
    NSDate *date = logMessage.timestamp;
    NSDateFormatter *dateFmt = [NELivePlayerLogFormat logDateFormatter];
    NSString *dateStr = [dateFmt stringFromDate:date];
    NSString *threadName = @"";
    if (logMessage.threadName.length != 0) {
        threadName = [NSString stringWithFormat:@"-%@", logMessage.threadName];
    }
    NSString *formatLogString = [NSString stringWithFormat:@"[%@][%@][%@%@]: %@", logLevel, dateStr, logMessage.threadID, threadName, logMessage.message];
    return formatLogString;
}

@end

@interface NELivePlayerLogManager ()
@property (nonatomic, readonly) NMCDDTTYLogger *ttyLogger; //终端日志
@property (nonatomic, strong) NMCDDFileLogger *fileLogger; //文件日志
@end

@implementation NELivePlayerLogManager

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NELivePlayerLogManager alloc] init];
    });
    return instance;
}


- (instancetype)init {
    if (self = [super init]) {
        [self setupLoggers];
    }
    return self;
}

- (void)setLogLevel:(NMCDDLogLevel)logLevel {
    [NMCDDLog changeLogger:self.fileLogger withLevel:logLevel];
}

- (NMCDDFileLogger *)fileLogger {
    if (!_fileLogger) {
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *dir = [[docPath stringByAppendingPathComponent:@"NMCLogs"] copy];
        NSString *loggerFilePath = [dir stringByAppendingString:@"/LivePlayer"];
        NMCDDLogFileManagerDefault *loggerFileManager = [[NMCDDLogFileManagerDefault alloc] initWithLogsDirectory:loggerFilePath];
        loggerFileManager.maximumNumberOfLogFiles = 7;
        _fileLogger = [[NMCDDFileLogger alloc] initWithLogFileManager:loggerFileManager];
        _fileLogger.sdkName = @"LivePlayer";
        _fileLogger.maximumFileSize = 5*1024*1024;
        _fileLogger.rollingFrequency = 24*60*60;
        _fileLogger.automaticallyAppendNewlineForCustomFormatters = YES;
    }
    return _fileLogger;
}


- (NMCDDTTYLogger *)ttyLogger {
    return [NMCDDTTYLogger sharedInstance];
}

- (void)setupLoggers {
    
    NMCDDLogLevel ttyLoggerLevel = NMCDDLogLevelInfo;
    NMCDDLogLevel fileLoggerLevel = NMCDDLogLevelInfo;
    
    //Add
    [NMCDDLog addLogger:self.ttyLogger withLevel:ttyLoggerLevel];//终端日志
    [NMCDDLog addLogger:self.fileLogger withLevel:fileLoggerLevel]; //文件日志
    
    //Format
    NELivePlayerLogFormat *loggerFormat = [[NELivePlayerLogFormat alloc] init];
    [self.ttyLogger setLogFormatter:loggerFormat];
    [self.fileLogger setLogFormatter:loggerFormat];
}

@end
