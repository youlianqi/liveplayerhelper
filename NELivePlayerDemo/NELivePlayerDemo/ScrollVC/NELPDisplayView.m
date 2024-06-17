//
//  NELPDisplayView.m
//  NELivePlayerDemo
//
//  Created by Netease on 2018/7/20.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NELPDisplayView.h"

@interface NELPDisplayView ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation NELPDisplayView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageView.image = image;
}

@end
