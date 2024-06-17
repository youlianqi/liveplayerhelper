//
//  NELPDisplayScrollView.m
//  LinkusApp
//
//  Created by Wei942 on 2018/5/29.
//  Copyright © 2018年 Wei942. All rights reserved.
//

#import "NELPDisplayScrollView.h"

@interface NELPDisplayScrollView () <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation NELPDisplayScrollView


- (void)setLives:(NSMutableArray *)lives {
    _lives = lives;
    if (_lives.count == 0) {
        _topView.image = nil;
        _centerView.image = nil;
        _bottomView.image = nil;
    } else if (_lives.count == 1) {
        _topView.image = [UIImage imageNamed:_lives[0]];
        _centerView.image = [UIImage imageNamed:_lives[0]];
        _bottomView.image = [UIImage imageNamed:_lives[0]];
    } else if (_lives.count == 2) {
        _topView.image = [UIImage imageNamed:_lives[1]];
        _centerView.image = [UIImage imageNamed:_lives[0]];
        _bottomView.image = [UIImage imageNamed:_lives[1]];
    } else {
        _centerView.image = [UIImage imageNamed:_lives[0]];
        _topView.image = [UIImage imageNamed:_lives[_lives.count - 1]];
        _bottomView.image = [UIImage imageNamed:_lives[1]];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.contentSize = CGSizeMake(0, frame.size.height * 3);
        self.contentOffset = CGPointMake(0, frame.size.height);
        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.delegate = self;
        
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    _topView = [[NELPDisplayView alloc] initWithFrame:CGRectMake(0, 0 * height, width, height)];
    _topView.backgroundColor = [UIColor redColor];
    _centerView = [[NELPDisplayView alloc] initWithFrame:CGRectMake(0, 1 * height, width, height)];
    _centerView.backgroundColor = [UIColor yellowColor];
    _bottomView = [[NELPDisplayView alloc] initWithFrame:CGRectMake(0, 2 * height, width, height)];
    _bottomView.backgroundColor = [UIColor greenColor];
    [self addSubview:_topView];
    [self addSubview:_centerView];
    [self addSubview:_bottomView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    _topView.frame = CGRectMake(0, 0 * height, width, height);
    _centerView.frame = CGRectMake(0, 1 * height, width, height);
    _bottomView.frame = CGRectMake(0, 2 * height, width, height);
    self.contentSize = CGSizeMake(0, 3 * height);
}

- (void)switchPlayer:(UIScrollView*)scrollView
{
    NSInteger totalCount = self.lives.count;
    CGFloat offset = scrollView.contentOffset.y;
    
    if (self.lives.count != 0) {
        if (offset >= 2*self.frame.size.height)
        {
            // slides to the down player
            if (++_currentIndex == totalCount) {
                _currentIndex = 0;
            }
            
            //更新显示
            scrollView.contentOffset = CGPointMake(0, self.frame.size.height);
            
            //更新图片
            _topView.image = _centerView.image;
            _centerView.image = _bottomView.image;
            NSInteger nextIndex = _currentIndex + 1;
            if (nextIndex == totalCount) {
                nextIndex = 0;
            }
            NSString *imageName = _lives[nextIndex];
            _bottomView.image = [UIImage imageNamed:imageName];
            
            //回调出去释放播放器，并加新的
            _pageIndex(_currentIndex, YES);
        }
        else if (offset <= 0)
        {
            if (--_currentIndex < 0) {
                _currentIndex = (totalCount - 1);
            }
            
            // slides to the upper player
            scrollView.contentOffset = CGPointMake(0, self.frame.size.height);
            
            //更新图片
            _centerView.image = _topView.image;
            _bottomView.image = _centerView.image;
            NSInteger lastIndex = _currentIndex - 1;
            if (lastIndex < 0) {
                lastIndex = totalCount - 1;
            }
            NSString *imageName = _lives[lastIndex];
            _topView.image = [UIImage imageNamed:imageName];
            
            //回调
            _pageIndex(_currentIndex, NO);
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self switchPlayer:scrollView];
}

@end


