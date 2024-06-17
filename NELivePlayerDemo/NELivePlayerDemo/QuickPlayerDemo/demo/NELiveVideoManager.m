//
//  NELiveVideoManager.m
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/3.
//  Copyright © 2024 netease. All rights reserved.
//

#import "NELiveVideoManager.h"
#import "NELiveVideoCell.h"
#import "NELivePlayerManager.h"

NSString *const NE_DEMO_PLAYER_URL_1 = @"rtmp://ve2618856.live.126.net/live/cdb8aa85e7774185bdb5a9fe5aac322d";
//NSString *const NE_DEMO_PLAYER_URL_1 = @"http://flve2618856.live.126.net/live/4393b9a5f8bc46c591a8faab930366c9.flv?netease=flve2618856.live.126.net";
NSString *const NE_DEMO_PLAYER_URL_2 = @"rtmp://ve2618856.live.126.net/live/4393b9a5f8bc46c591a8faab930366c9";
NSString *const NE_DEMO_PLAYER_URL_3 = @"rtmp://ve2618856.live.126.net/live/cab88138190142c3907610b49f8bdcf3";
NSString *const NE_DEMO_PLAYER_URL_4 = @"rtmp://ve2618856.live.126.net/live/f32b3c1fbfaa4acc8f0302e4ab272059";
NSString *const NE_DEMO_PLAYER_URL_5 = @"rtmp://ve2618856.live.126.net/live/a18bc2ca0df64abd86e78701d1e91557";
NSString *const NE_DEMO_PLAYER_URL_6 = @"rtmp://ve2618856.live.126.net/live/f76c9e0bd38242bca8ca1fc636ceee79";
NSString *const NE_DEMO_PLAYER_URL_7 = @"rtmp://ve2618856.live.126.net/live/d4f9a047911b43d2acc50249ae0939db";
NSString *const NE_DEMO_PLAYER_URL_8 = @"rtmp://ve2618856.live.126.net/live/b8bf628db75641c9ada6e15ebe35ed79";

@interface NELiveVideoManager()<GKVideoScrollViewDataSource, GKVideoScrollViewDelegate, NELivePlayerVideoCellDelegate>

@property (nonatomic, assign) BOOL isScrollViewShowLast;
@property (nonatomic, assign) BOOL isScrollViewShowNext;

@end

@implementation NELiveVideoManager

- (instancetype)initWithDataSource:(NSArray *)array {
    if (self = [super init]) {
        for (NSString *url in array) {
            [self.dataSource addObject:url];
        }
    }
    return self;
}

#pragma mark - Public
- (void)initPlayer {
    // subclass implementation
}

- (void)destoryPlayer {
    // subclass implementation
}

- (void)prepareCell:(NELiveVideoCell *)cell index:(NSInteger)index {
    // subclass implementation
}

- (void)preloadVideoWithCell:(NELiveVideoCell *)cell index:(NSInteger)index {
    // subclass implementation
}

- (void)playVideoWithCell:(NELiveVideoCell *)cell index:(NSInteger)index {
    // subclass implementation
}

- (void)stopVideoWithCell:(NELiveVideoCell *)cell index:(NSInteger)index {
    // subclass implementation
}

- (void)enterFullScreen {
    // subclass implementation
}

- (void)back {
    // subclass implementation
}

- (void)reloadData {
    [self.portraitScrollView reloadData];
    [self performSelector:@selector(reloadCurrentCell) withObject:nil afterDelay:0];
}

- (void)reloadDataWithIndex:(NSInteger)index {
    [self.portraitScrollView reloadDataWithIndex:index];
    //[self.landscapeScrollView reloadDataWithIndex:index];
}

- (void)clearAllPlayers {
    [[NELivePlayerManager sharedInstance] clearAllPlayers];
}

- (void)removeCurrent {
    //[self.portraitScrollView removeCurrentPageAnimated:YES];
}

- (void)reloadDataWithUrl:(NSString *)url {
    [self.portraitScrollView reloadData];
    [self performSelector:@selector(reloadCurrentCell) withObject:nil afterDelay:0];
}

#pragma mark - GKVideoScrollViewDataSource
- (NSInteger)numberOfRowsInScrollView:(GKVideoScrollView *)scrollView {
    return self.dataSource.count;
}

- (GKVideoViewCell *)scrollView:(GKVideoScrollView *)scrollView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = scrollView == self.portraitScrollView ? @"GKVideoPortriatCell" : @"GKVideoLandscapeCell";
    NELiveVideoCell *cell = [scrollView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell loadData:self.dataSource[indexPath.row]];
    [self prepareCell:cell index:indexPath.row];
    return cell;
}

#pragma mark - GKVideoScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.currentCell scrollViewBeginDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.currentCell scrollViewDidEndDragging];
}

// 即将显示
- (void)scrollView:(GKVideoScrollView *)scrollView willDisplayCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.isScrollViewShowNext = indexPath.row > scrollView.currentIndex ? YES : NO;
    self.isScrollViewShowLast = indexPath.row < scrollView.currentIndex ? YES : NO;
    
    //PLAYER_LOG(@"*********[%s] indexPath:%@", __func__, indexPath);
    [self reloadDataLivePlayerManager];
}

// 结束显示
- (void)scrollView:(GKVideoScrollView *)scrollView didEndDisplayingCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //PLAYER_LOG(@"*********[%s] indexPath:%@", __func__, indexPath);
    self.endDisplayingIndex = indexPath.row;
}

// 滑动结束显示
- (void)scrollView:(GKVideoScrollView *)scrollView didEndScrollingCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //PLAYER_LOG(@"*********[%s] didEndScrollingCell indexPath:%@", __func__, indexPath);
    if (scrollView == self.portraitScrollView) {
        self.currentCell = (NELiveVideoCell *)cell;
        self.currentIndex = indexPath.row;
    }
    
    self.isScrollViewShowNext = NO;
    self.isScrollViewShowLast = NO;
    
    [self reloadDataLivePlayerManager];
    
    if (self.currentIndex == self.dataSource.count - 2) {
        [NSNotificationCenter.defaultCenter postNotificationName:@"NELiveVideoManagerRequestMoreNotification" object:self];
    }
}

- (void)scrollView:(GKVideoScrollView *)scrollView didUpdateScrollCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    PLAYER_LOG(@"*********[%s] didUpdateScrollCell indexPath:%@", __func__, indexPath);
//    if (indexPath.row > self.currentIndex+1) {
//        [[NELivePlayerManager sharedInstance] stopLivePlayerIfNeeded];
//    }
}

- (void)scrollView:(GKVideoScrollView *)scrollView didRemoveCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - GKVideoCellDelegate
- (void)cellClickBackBtn {
    [self back];
}

- (void)cellClickLikeBtn:(NELiveVideoCell *)cell {
    
}

- (void)cellClickFullscreenBtn:(NELiveVideoCell *)cell {
    [self enterFullScreen];
}

#pragma mark - Lazy
- (GKVideoScrollView *)portraitScrollView {
    if (!_portraitScrollView) {
        _portraitScrollView = [[GKVideoScrollView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _portraitScrollView.dataSource = self;
        _portraitScrollView.delegate = self;
        [_portraitScrollView registerClass:NELiveVideoCell.class forCellReuseIdentifier:@"GKVideoPortriatCell"];
    }
    return _portraitScrollView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)reloadDataLivePlayerManager {
    NSUInteger currentIndex = self.currentIndex;
    NSString *playingUrl = self.dataSource[currentIndex];
    NSString *nextPlayUrl = @"";
    NSMutableArray *prepareUrlList = [NSMutableArray arrayWithCapacity:0];
    if (currentIndex > 0) {
        NSString *lastPlayUrl = self.dataSource[currentIndex-1];
        [prepareUrlList addObject:lastPlayUrl];
    }
    
    NSUInteger count = self.dataSource.count;
    //向下滑动，还没有滑动结束，则立即播放
    if (self.isScrollViewShowNext) {
        if (currentIndex + 1 < count) {
            nextPlayUrl = self.dataSource[currentIndex + 1];
        }
        
        if (currentIndex + 2 < count) {
            [prepareUrlList addObject:self.dataSource[currentIndex + 2]];
        }
    }
    //向上滑动，还没有滑动结束，则立即播放
    else if (self.isScrollViewShowLast) {
        if (currentIndex - 1 >= 0) {
            nextPlayUrl = self.dataSource[currentIndex - 1];
        }
        
        if (currentIndex + 1 < count) {
            [prepareUrlList addObject:self.dataSource[currentIndex + 1]];
        }
    }
    //滑动结束，nextPlayUrl 为空
    else {
        if (currentIndex + 1 < count) {
            [prepareUrlList addObject:self.dataSource[currentIndex + 1]];
        }
        
        if (currentIndex + 2 < count) {
            [prepareUrlList addObject:self.dataSource[currentIndex + 2]];
        }
    }
        
    BOOL changed = [[NELivePlayerManager sharedInstance] setLivePlayerUrlList:prepareUrlList playingUrl:playingUrl nextPlayUrl:nextPlayUrl];
    //setLivePlayerUrlList 前后两次设置不一样时，才需要去重新添加画布
    if (changed) {
        //当前页面 addSubVuew 播放器的画布
        [self.currentCell loadData:self.dataSource[self.currentIndex]];
        
        //上个页面 addSubVuew 播放器的画布， 向上滑动快速打开
        NSUInteger lastIndex = self.currentIndex - 1;
        if (lastIndex >= 0 && lastIndex < self.dataSource.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastIndex inSection:0];
            NELiveVideoCell *videoCell = [self.portraitScrollView cellForRowAtIndexPath:indexPath];
            if (videoCell) {
                [videoCell loadData:self.dataSource[lastIndex]];
            }
        }
        
        //下个页面 addSubVuew 播放器的画布， 向下滑动快速打开
        NSUInteger nextIndex = self.currentIndex + 1;
        if (nextIndex < self.dataSource.count && nextIndex >= 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nextIndex inSection:0];
            NELiveVideoCell *videoCell = [self.portraitScrollView cellForRowAtIndexPath:indexPath];
            if (videoCell) {
                [videoCell loadData:self.dataSource[nextIndex]];
            }
        }
    }
    
    PLAYER_LOG(@"[%s] didUpdateScrollCell changed:%@ currentIndex:%@ playingUrl:%@ nextPlayUrl:%@ prepareUrlList:%@", __func__, @(changed), @(self.currentIndex), playingUrl, nextPlayUrl, prepareUrlList);

}

- (void)reloadCurrentCell {
    [self.currentCell loadData:self.dataSource[self.currentIndex]];
}

@end
