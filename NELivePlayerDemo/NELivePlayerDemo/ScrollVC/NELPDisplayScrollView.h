//
//  NELPDisplayScrollView.h
//  LinkusApp
//
//  Created by Wei942 on 2018/5/29.
//  Copyright © 2018年 Wei942. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NELPDisplayView.h"

@protocol NELPDisplayScrollViewProtocol;

@interface NELPDisplayScrollView : UIScrollView

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSMutableArray * lives;

@property (nonatomic, weak) id <NELPDisplayScrollViewProtocol> adaptor;

@property (nonatomic,copy) void(^pageIndex)(NSInteger index, BOOL isNext);

@property (nonatomic, strong) NELPDisplayView *topView;

@property (nonatomic, strong) NELPDisplayView *centerView;

@property (nonatomic, strong) NELPDisplayView *bottomView;

@end
