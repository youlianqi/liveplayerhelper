//
//  NELPDemoPlayerModel.h
//  PlayerDemo
//
//  Created by Netease on 2018/6/26.
//  Copyright © 2018年 Wei942. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NELivePlayerFramework/NELivePlayerFramework.h>

@interface NELPDemoPlayerModel : NSObject

@property (nonatomic, copy) NSString *url;

@property (nonatomic, strong) NELivePlayerController *player;

@property (nonatomic, assign) BOOL isPlaying;

- (instancetype)initWithUrl:(NSString *)url;

- (void)startPlay;

- (void)releasePlayer;

@end
