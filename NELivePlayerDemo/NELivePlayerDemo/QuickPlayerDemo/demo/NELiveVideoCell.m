//
//  NELiveVideoCell.m
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/3.
//  Copyright © 2024 netease. All rights reserved.
//

#import "NELiveVideoCell.h"
#import <NELivePlayerFramework/NELivePlayerFramework.h>
#import "NELivePlayerManager.h"
#import "NEDataManager.h"
#import "NELiveVideoManager.h"

@interface NELiveVideoCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *playerContentview;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end


@implementation NELiveVideoCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:UIScreen.mainScreen.bounds]) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"show_room_default_bg"]];
        _backgroundImageView.frame = self.bounds;
        [self addSubview:_backgroundImageView];

        self.playerContentview = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.playerContentview];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width-20, self.bounds.size.height-20)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        
        if (![NEDataManager sharedInstance].rememberProfileType) {
            [self addSubview:self.segmentedControl];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onNotifyPlayerPlayViewNotAddSubview:)
                                                     name:NELivePlayerPlayViewNotAddSubviewNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"180", @"360", @"540", @"720"]];
        _segmentedControl.selectedSegmentIndex = [NEDataManager sharedInstance].profileType;
        [_segmentedControl setApportionsSegmentWidthsByContent:YES];
        [_segmentedControl addTarget:self action:@selector(segmentControlChangeValue:) forControlEvents:UIControlEventValueChanged];
        _segmentedControl.backgroundColor = [UIColor grayColor];
    }
    
    return _segmentedControl;
}

- (void)segmentControlChangeValue:(UISegmentedControl *)control {
    self.playerModel = [self.playerData getUrlWithProfileType:control.selectedSegmentIndex];
    [self videoProfileDidChanged];
}

- (void)videoProfileDidChanged {
    [[NELivePlayerManager sharedInstance] switchPlayingUrl:self.playerModel];
    self.titleLabel.text = self.playerModel;
    [self doLoadData:self.playerModel];
}

- (void)resetSegmentControl {
    if (_segmentedControl) {
        NELivePlayerVideoProfileType profileType = [self.playerData getProfileTypeWithUrl:self.playerModel];
       _segmentedControl.selectedSegmentIndex = profileType;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_segmentedControl) {
        _segmentedControl.frame = CGRectMake(20, self.frame.size.height-60, self.frame.size.width-40, 33);
    }
}

- (void)removeLastPlayerViewIfNeeded {
    for (UIView *subview in [self.playerContentview subviews]) {
        [subview removeFromSuperview];
    }
}

- (void)onNotifyPlayerPlayViewNotAddSubview:(NSNotification *)notification {
    NSString *url = notification.object;
    if (url && self.playerModel.length > 0 && [self.playerModel isEqualToString:url] && self.playerContentview.subviews.count == 0) {
        PLAYER_LOG(@"[%s][%@]", __func__, url);
        [self loadData:self.playerModel];
    }
}

- (void)loadData:(NSString *)playerModel {
    [self doLoadData:playerModel];
    [self resetSegmentControl];
}

- (BOOL)doLoadData:(NSString *)playerModel {
    NELivePlayer *player = [[NELivePlayerManager sharedInstance] getPlayerWithUrl:playerModel];
    for (UIView *subview in [self.playerContentview subviews]) {
        if (subview == player.player.view) {
            return NO;
        }
    }
    self.playerModel = playerModel;

    self.titleLabel.text = self.playerModel;
    
    if (player.player.view.superview) {
        [player.player.view removeFromSuperview];
    }
    
    [self removeLastPlayerViewIfNeeded];
    
    if (player.player.view) {
        [self.playerContentview addSubview:player.player.view];
        return NO;
    }
    
    BOOL retry = player.isPlaying && !player.player.view;
    return retry;
}

- (void)initUI {
    
}

- (void)scrollViewBeginDragging {
    
}

- (void)scrollViewDidEndDragging {
    
}

@end
