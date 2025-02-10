//
//  NEDataManager.h
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NELivePlayerVideoProfileType) {
    NELivePlayerVideoProfile180,
    NELivePlayerVideoProfile360,
    NELivePlayerVideoProfile540,
    NELivePlayerVideoProfile720
};

@interface NEPlayerUrlData : NSObject

@property (nonatomic, readonly) NSString *url;
@property (nonatomic, copy) NSString *url180;
@property (nonatomic, copy) NSString *url360;
@property (nonatomic, copy) NSString *url540;
@property (nonatomic, copy) NSString *url720;

- (NSString *)getUrlWithProfileType:(NELivePlayerVideoProfileType)profiletype;

- (NELivePlayerVideoProfileType)getProfileTypeWithUrl:(NSString *)url;

@end

@interface NEDataManager : NSObject

+ (NEDataManager *)sharedInstance;

@property (nonatomic, assign) NELivePlayerVideoProfileType profileType;
@property (nonatomic, assign) BOOL rememberProfileType;

//测试数据
+ (NEPlayerUrlData *)data1;
+ (NEPlayerUrlData *)data2;
+ (NEPlayerUrlData *)data3;
+ (NEPlayerUrlData *)data4;
+ (NEPlayerUrlData *)data5;
+ (NEPlayerUrlData *)data6;
+ (NEPlayerUrlData *)data7;
+ (NEPlayerUrlData *)data8;

@end

NS_ASSUME_NONNULL_END
