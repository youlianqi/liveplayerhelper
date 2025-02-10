//
//  NEDataManager.m
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/27.
//

#import "NEDataManager.h"

@implementation NEPlayerUrlData

- (NSString *)url {
    NELivePlayerVideoProfileType profileType = [NEDataManager sharedInstance].profileType;
    switch (profileType) {
        case NELivePlayerVideoProfile180:
            return _url180;
        case NELivePlayerVideoProfile360:
            return _url360;
        case NELivePlayerVideoProfile540:
            return _url540;
        case NELivePlayerVideoProfile720:
            return _url720;
        default:
            break;
    }

    return _url720;
}  

- (NSString *)getUrlWithProfileType:(NELivePlayerVideoProfileType)profileType {
    switch (profileType) {
        case NELivePlayerVideoProfile180:
            return _url180;
        case NELivePlayerVideoProfile360:
            return _url360;
        case NELivePlayerVideoProfile540:
            return _url540;
        case NELivePlayerVideoProfile720:
            return _url720;
        default:
            break;
    }
    
    return _url720;
}

- (NELivePlayerVideoProfileType)getProfileTypeWithUrl:(NSString *)url {
    if ([url isEqualToString:_url180]) {
        return NELivePlayerVideoProfile180;
    }
    else if ([url isEqualToString:_url360]) {
        return NELivePlayerVideoProfile360;
    }
    else if ([url isEqualToString:_url540]) {
        return NELivePlayerVideoProfile540;
    }
    else if ([url isEqualToString:_url720]) {
        return NELivePlayerVideoProfile720;
    }
    
    return NELivePlayerVideoProfile720;
}

@end

@implementation NEDataManager

+ (NEDataManager *)sharedInstance {
    static NEDataManager *g_datar_manager_Instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_datar_manager_Instance = [[self alloc] init];
    });
    
    return g_datar_manager_Instance;
}

- (void)dealloc {
    
}

- (instancetype)init{
    if (self = [super init]) {
        self.profileType = NELivePlayerVideoProfile720;
    }
    return self;
}

+ (NEPlayerUrlData *)data1 {
    NEPlayerUrlData *data = [[NEPlayerUrlData alloc] init];
    data.url540 = @"rtmp://ve2618856.live.126.net/live/cdb8aa85e7774185bdb5a9fe5aac322d_S1";
    data.url720 = @"rtmp://ve2618856.live.126.net/live/cdb8aa85e7774185bdb5a9fe5aac322d";
    data.url180 = @"rtmp://ve2618856.live.126.net/live/cdb8aa85e7774185bdb5a9fe5aac322d_S3";
    data.url360 = @"rtmp://ve2618856.live.126.net/live/cdb8aa85e7774185bdb5a9fe5aac322d_S2";
    return data;
}

+ (NEPlayerUrlData *)data2 {
    NEPlayerUrlData *data = [[NEPlayerUrlData alloc] init];
    data.url540 = @"rtmp://ve2618856.live.126.net/live/4393b9a5f8bc46c591a8faab930366c9_S1";
    data.url720 = @"rtmp://ve2618856.live.126.net/live/4393b9a5f8bc46c591a8faab930366c9";
    data.url180 = @"rtmp://ve2618856.live.126.net/live/4393b9a5f8bc46c591a8faab930366c9_S3";
    data.url360 = @"rtmp://ve2618856.live.126.net/live/4393b9a5f8bc46c591a8faab930366c9_S2";
    return data;
}

+ (NEPlayerUrlData *)data3 {
    NEPlayerUrlData *data = [[NEPlayerUrlData alloc] init];
    data.url540 = @"rtmp://ve2618856.live.126.net/live/cab88138190142c3907610b49f8bdcf3_S1";
    data.url720 = @"rtmp://ve2618856.live.126.net/live/cab88138190142c3907610b49f8bdcf3";
    data.url180 = @"rtmp://ve2618856.live.126.net/live/cab88138190142c3907610b49f8bdcf3_S3";
    data.url360 = @"rtmp://ve2618856.live.126.net/live/cab88138190142c3907610b49f8bdcf3_S2";
    return data;
}

+ (NEPlayerUrlData *)data4 {
    NEPlayerUrlData *data = [[NEPlayerUrlData alloc] init];
    data.url540 = @"rtmp://ve2618856.live.126.net/live/f32b3c1fbfaa4acc8f0302e4ab272059_S1";
    data.url720 = @"rtmp://ve2618856.live.126.net/live/f32b3c1fbfaa4acc8f0302e4ab272059";
    data.url180 = @"rtmp://ve2618856.live.126.net/live/f32b3c1fbfaa4acc8f0302e4ab272059_S3";
    data.url360 = @"rtmp://ve2618856.live.126.net/live/f32b3c1fbfaa4acc8f0302e4ab272059_S2";
    return data;
}

+ (NEPlayerUrlData *)data5 {
    NEPlayerUrlData *data = [[NEPlayerUrlData alloc] init];
    data.url540 = @"rtmp://ve2618856.live.126.net/live/a18bc2ca0df64abd86e78701d1e91557_S1";
    data.url720 = @"rtmp://ve2618856.live.126.net/live/a18bc2ca0df64abd86e78701d1e91557";
    data.url180 = @"rtmp://ve2618856.live.126.net/live/a18bc2ca0df64abd86e78701d1e91557_S3";
    data.url360 = @"rtmp://ve2618856.live.126.net/live/a18bc2ca0df64abd86e78701d1e91557_S2";
    return data;
}

+ (NEPlayerUrlData *)data6 {
    NEPlayerUrlData *data = [[NEPlayerUrlData alloc] init];
    data.url540 = @"rtmp://ve2618856.live.126.net/live/f76c9e0bd38242bca8ca1fc636ceee79_S1";
    data.url720 = @"rtmp://ve2618856.live.126.net/live/f76c9e0bd38242bca8ca1fc636ceee79";
    data.url180 = @"rtmp://ve2618856.live.126.net/live/f76c9e0bd38242bca8ca1fc636ceee79_S3";
    data.url360 = @"rtmp://ve2618856.live.126.net/live/f76c9e0bd38242bca8ca1fc636ceee79_S2";
    return data;
}

+ (NEPlayerUrlData *)data7 {
    NEPlayerUrlData *data = [[NEPlayerUrlData alloc] init];
    data.url540 = @"rtmp://ve2618856.live.126.net/live/d4f9a047911b43d2acc50249ae0939db_S1";
    data.url720 = @"rtmp://ve2618856.live.126.net/live/d4f9a047911b43d2acc50249ae0939db";
    data.url180 = @"rtmp://ve2618856.live.126.net/live/d4f9a047911b43d2acc50249ae0939db_S3";
    data.url360 = @"rtmp://ve2618856.live.126.net/live/d4f9a047911b43d2acc50249ae0939db_S2";
    return data;
}

+ (NEPlayerUrlData *)data8 {
    NEPlayerUrlData *data = [[NEPlayerUrlData alloc] init];
    data.url540 = @"rtmp://ve2618856.live.126.net/live/b8bf628db75641c9ada6e15ebe35ed79_S1";
    data.url720 = @"rtmp://ve2618856.live.126.net/live/b8bf628db75641c9ada6e15ebe35ed79";
    data.url180 = @"rtmp://ve2618856.live.126.net/live/b8bf628db75641c9ada6e15ebe35ed79_S3";
    data.url360 = @"rtmp://ve2618856.live.126.net/live/b8bf628db75641c9ada6e15ebe35ed79_S2";
    return data;
}

@end
