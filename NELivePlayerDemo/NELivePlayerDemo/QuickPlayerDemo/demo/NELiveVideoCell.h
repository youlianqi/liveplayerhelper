//
//  NELiveVideoCell.h
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/3.
//  Copyright © 2024 netease. All rights reserved.
//

#import "GKVideoViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class NELiveVideoCell;
@class NELivePlayer;
@class NELivePlayerModel;
@class NEPlayerUrlData;

@protocol NELivePlayerVideoCellDelegate <NSObject>

@optional
- (void)cellClickBackBtn;
- (void)cellClickLikeBtn:(NELiveVideoCell *)cell;
- (void)cellClickFullscreenBtn:(NELiveVideoCell *)cell;

@end

@interface NELiveVideoCell : GKVideoViewCell

@property (nonatomic, weak) id<NELivePlayerVideoCellDelegate> delegate;

@property (nonatomic, readonly) NELivePlayer *player;

@property (nonatomic, strong) NSString *playerModel;
@property (nonatomic, strong) NEPlayerUrlData *playerData;

- (void)initUI;

- (void)loadData:(NSString *)playerModel;

- (void)scrollViewBeginDragging;

- (void)scrollViewDidEndDragging;

- (void)resetSegmentControl;

- (void)videoProfileDidChanged;

@end

NS_ASSUME_NONNULL_END
