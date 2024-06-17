//
//  NELPDemoScrollVC.m
//  PlayerDemo
//
//  Created by Wei942 on 2018/5/30.
//  Copyright © 2018年 Wei942. All rights reserved.
//

#import "NELPDemoScrollVC.h"
#import "NELPDisplayScrollView.h"
#import "NELPDemoPlayerModel.h"

@interface NELPDemoScrollVC ()

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) NELPDisplayScrollView *scrollView;
@property (nonatomic, strong) NSArray<NSString *> *douyinVideoStrings;
@property (nonatomic, strong) NSMutableArray <NELPDemoPlayerModel *>*playerItems;
@property (nonatomic, readonly) NSArray *images;
@end

@implementation NELPDemoScrollVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self doProload];
    [self configOwnViews];
    [self doInitPlayers];
}

#pragma mark - 播放器SDK功能
- (void)doProload {
    [NELivePlayerController addPreloadUrls:self.douyinVideoStrings];
}

- (void)doInitPlayers {
    NSArray *urls = self.douyinVideoStrings;
    NSMutableArray *proUrls = [NSMutableArray array];
    if (urls.count > 2) {
        [proUrls addObject:urls.lastObject];
        [proUrls addObject:urls[0]];
        [proUrls addObject:urls[1]];
    } else if (urls.count == 2){
        [proUrls addObject:urls.lastObject];
        [proUrls addObject:urls.firstObject];
        [proUrls addObject:urls.lastObject];
    } else if (urls.count == 1) {
        [proUrls addObject:urls.firstObject];
        [proUrls addObject:urls.firstObject];
        [proUrls addObject:urls.firstObject];
    } else {}

    __weak typeof(self) weakSelf = self;
    [proUrls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NELPDemoPlayerModel *playerItem = [[NELPDemoPlayerModel alloc] initWithUrl:obj];
        if (idx == 0) {
            playerItem.player.view.frame = weakSelf.scrollView.topView.bounds;
            [weakSelf.scrollView.topView addSubview:playerItem.player.view];
        } else if (idx == 1) {
            playerItem.player.view.frame = weakSelf.scrollView.centerView.bounds;
            [weakSelf.scrollView.centerView addSubview:playerItem.player.view];
            playerItem.isPlaying = YES;
        } else if (idx == 2) {
            playerItem.player.view.frame = weakSelf.scrollView.bottomView.bounds;
            [weakSelf.scrollView.bottomView addSubview:playerItem.player.view];
        }

        if (!weakSelf.playerItems) {
            weakSelf.playerItems = [NSMutableArray array];
        }
        [weakSelf.playerItems addObject:playerItem];
    }];
    
    NSLog(@"添加播放器， 播放器总个数:%zi", _playerItems.count);
}

- (void)doRefreshDisplayView {
    __weak typeof(self) weakSelf = self;
    [_playerItems enumerateObjectsUsingBlock:^(NELPDemoPlayerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.player.view removeFromSuperview];
        if (idx == 0) {
            obj.player.view.frame = weakSelf.scrollView.topView.bounds;
            [weakSelf.scrollView.topView addSubview:obj.player.view];
        } else if (idx == 1) {
            obj.player.view.frame = weakSelf.scrollView.centerView.bounds;
            [weakSelf.scrollView.centerView addSubview:obj.player.view];
        } else if (idx == 2) {
            obj.player.view.frame = weakSelf.scrollView.bottomView.bounds;
            [weakSelf.scrollView.bottomView addSubview:obj.player.view];
        }
    }];
}

- (void)doAddUrlPlayerWithIndex:(NSInteger)index isNext:(BOOL)isNext {
    NSArray *urls = self.douyinVideoStrings;
    
    //播放当前的
    [_playerItems enumerateObjectsUsingBlock:^(NELPDemoPlayerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isPlaying) {
            obj.isPlaying = NO;
        }
    }];
    
    if (isNext) {
        //释放旧的
        if (_playerItems.count > 0) {
            NELPDemoPlayerModel *item = [_playerItems firstObject];
            [_playerItems removeObject:item];
            [item releasePlayer];
            NSLog(@"释放第一个播放器");
        } else {
            NSLog(@"数组空了");
        }

        //增加新的
        NSInteger nextIndex = ((index + 1 > urls.count - 1) ? 0 : (index + 1));
        NSString *nextUrl   = urls[nextIndex];
        NELPDemoPlayerModel *newItem = [[NELPDemoPlayerModel alloc] initWithUrl:nextUrl];
        [_playerItems addObject:newItem];
        NSLog(@"添加播放器， 播放器总个数:%zi", _playerItems.count);
    } else {
        //释放旧的
        if (_playerItems.count > 0) {
            NELPDemoPlayerModel *item = [_playerItems lastObject];
            [_playerItems removeObject:item];
            [item releasePlayer];
            NSLog(@"释放最后一个播放器");
        } else {
            NSLog(@"数组空了");
        }

        //增加新的
        NSInteger lastIndex = ((index - 1 < 0) ? urls.count - 1 : (index - 1));
        NSString *lastUrl   = urls[lastIndex];
        NELPDemoPlayerModel *newItem = [[NELPDemoPlayerModel alloc] initWithUrl:lastUrl];
        if (_playerItems.count == 0) {
            [_playerItems addObject:newItem];
        } else {
            [_playerItems insertObject:newItem atIndex:0];
        }
        NSLog(@"插入播放器， 播放器总个数:%zi", _playerItems.count);
    }
    
    //更换页面
    [self doRefreshDisplayView];
    
    if (_playerItems.count > 1) {
        _playerItems[1].isPlaying = YES;
    }
}

- (void)configOwnViews {
    
    _scrollView = [[NELPDisplayScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.lives = [NSMutableArray arrayWithArray:self.images];
    __weak typeof(self) weakSelf = self;
    _scrollView.pageIndex = ^(NSInteger index, BOOL isNext) {
        NSLog(@"index = %zi, isNext = %@", index, isNext ? @"Y" : @"N");
        [weakSelf doAddUrlPlayerWithIndex:index isNext:isNext];
    };
    [self.view addSubview:_scrollView];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
    _backBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    _backBtn.frame = CGRectMake(8, 8, 60, 40);
    [_backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
}

- (void)backAction:(UIButton *)sender {
    
    [_playerItems enumerateObjectsUsingBlock:^(NELPDemoPlayerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj releasePlayer];
    }];
    [_playerItems removeAllObjects];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray<NSString *> *)douyinVideoStrings {
    if(!_douyinVideoStrings){
        _douyinVideoStrings = @[
            @"http://jdvodzopqjhvv.vod.126.net/jdvodzopqjhvv/a5977679-4bd6-4c32-a32d-b444fc2c3283.mp4",
            @"http://jdvodzopqjhvv.vod.126.net/jdvodzopqjhvv/2f65ddc9-c46a-43fb-a8ef-41e9bc5fa688.mp4",
            @"https://vodegkofxdv.vod.126.net/vodegkofxdv/pquGvpyd_1677633965_shd.mp4",];
    }
    return _douyinVideoStrings;
}

- (NSArray *)images {
    return @[@"timg",
             @"timg",
             @"timg",
             @"timg"
             ];
}

@end
