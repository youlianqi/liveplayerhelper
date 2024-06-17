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

- (void)initUI;

- (void)loadData:(NSString *)playerModel;

- (void)scrollViewBeginDragging;

- (void)scrollViewDidEndDragging;


@end

NS_ASSUME_NONNULL_END
