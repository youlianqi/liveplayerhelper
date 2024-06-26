//
//  NELivePlayerViewController.m
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/3.
//  Copyright © 2024 netease. All rights reserved.
//

#import "NELivePlayerViewController.h"
#import "NELiveVideoManager.h"
#import <MJRefresh/MJRefresh.h>
#import "NEDataManager.h"

@interface NELivePlayerViewController ()

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, strong) NELiveVideoManager *manager;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger pageSize;

@property (nonatomic, assign) BOOL isInsertFront;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end

@implementation NELivePlayerViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithDataSource:(NSArray *)array {
    if (self = [super init]) {
        _manager = [[NELiveVideoManager alloc] initWithDataSource:array];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
        backItem.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = backItem;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onNotifyLiveVideoManagerRequestMore:)
                                                     name:@"NELiveVideoManagerRequestMoreNotification"
                                                   object:nil];
    }
    return self;
}

- (void)onBack:(id)sender {
    [self.manager clearAllPlayers];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    [self setupRefresh];
}

- (void)initUI {
    self.view.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.manager.portraitScrollView];
    self.manager.portraitScrollView.frame = self.view.bounds;
    [self.manager reloadData];
    
    if ([NEDataManager sharedInstance].rememberProfileType) {
        [self.view addSubview:self.segmentedControl];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self hideNavBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self showNavBar];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
    return self.statusBarStyle;
}

- (void)showNavBar {
    NSDictionary *dic = @{NSForegroundColorAttributeName: UIColor.grayColor, NSFontAttributeName: [UIFont boldSystemFontOfSize:18]};
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = UIColor.whiteColor;
        appearance.shadowColor = UIColor.whiteColor;
        appearance.titleTextAttributes = dic;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = appearance;
        //self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setTitleTextAttributes:dic];
    }
    self.statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)hideNavBar {
    NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    if (@available(iOS 15.0, *)) {
        //navigation标题文字颜色
        UINavigationBarAppearance *barApp = [UINavigationBarAppearance new];
        barApp.backgroundColor = UIColor.clearColor;
        barApp.shadowColor = nil;
        barApp.backgroundEffect = nil;
        barApp.titleTextAttributes = dic;
        self.navigationController.navigationBar.scrollEdgeAppearance = nil;
        self.navigationController.navigationBar.standardAppearance = barApp;
        //self.navigationController.navigationBar.translucent = YES;
    }else{
        //背景色
//        UIImage *image = [TCTools imageWithColor:UIColorBaseRGBA(0xffffff, 0)];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        
        // 导航条title 字体 颜色
        [self.navigationController.navigationBar setTitleTextAttributes:dic];
    }
    self.statusBarStyle = UIStatusBarStyleDefault;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"180", @"360", @"540", @"720"]];
        _segmentedControl.selectedSegmentIndex = [NEDataManager sharedInstance].profileType;
        [_segmentedControl setApportionsSegmentWidthsByContent:YES];
        _segmentedControl.backgroundColor = [UIColor grayColor];
        [_segmentedControl addTarget:self action:@selector(segmentControlChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _segmentedControl;
}

- (void)segmentControlChangeValue:(UISegmentedControl *)control {
    [NEDataManager sharedInstance].profileType = control.selectedSegmentIndex;
    [self.manager reloadDataDidProfileChanged];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (_segmentedControl) {
        _segmentedControl.frame = CGRectMake(20, self.view.frame.size.height-60, self.view.frame.size.width-40, 33);
    }
}

#pragma mark - Navigation

- (void)setupRefresh {
     self.page = 1;
     self.total = 10;
     self.pageSize = 5;
     
     __weak __typeof(self) weakSelf = self;
     self.manager.portraitScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
         __strong __typeof(weakSelf) strongSelf = weakSelf;
         [strongSelf reRequestNewData];
     }];
     
     MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
         __strong __typeof(weakSelf) strongSelf = weakSelf;
         [strongSelf requestMoreData];
     }];
     footer.automaticallyRefresh = YES;
     self.manager.portraitScrollView.mj_footer = footer;
}

- (void)reRequestNewData {
    [self.manager.dataSource removeAllObjects];
    [self.manager.dataSource addObject:[NEDataManager data1]];
    [self.manager.dataSource addObject:[NEDataManager data2]];
    [self.manager.dataSource addObject:[NEDataManager data3]];
    [self.manager.dataSource addObject:[NEDataManager data4]];
    [self.manager.dataSource addObject:[NEDataManager data5]];
    [self.manager.dataSource addObject:[NEDataManager data6]];
    [self.manager.dataSource addObject:[NEDataManager data7]];
    [self.manager.dataSource addObject:[NEDataManager data8]];
    [self.manager.portraitScrollView.mj_header endRefreshing];
    [self.manager.portraitScrollView.mj_footer endRefreshing];
    [self.manager.portraitScrollView reloadData];
}

- (void)requestMoreData {
    [self doAddDataSource];
    [self.manager.portraitScrollView.mj_header endRefreshing];
    [self.manager.portraitScrollView.mj_footer endRefreshing];
    [self.manager.portraitScrollView reloadData];
}

- (void)onNotifyLiveVideoManagerRequestMore:(NSNotification *)notification {
    [self doAddDataSource];
    [self.manager.portraitScrollView reloadData];
}

- (NSUInteger)findIndexOfLastDataSource {
    NEPlayerUrlData *lastData = self.manager.dataSource.lastObject;
    if ([lastData.url540 containsString:NE_DEMO_PLAYER_URL_1]) {
        return 1;
    }
    else  if ([lastData.url540 containsString:NE_DEMO_PLAYER_URL_2]) {
        return 2;
    }
    else  if ([lastData.url540 containsString:NE_DEMO_PLAYER_URL_3]) {
        return 3;
    }
    else  if ([lastData.url540 containsString:NE_DEMO_PLAYER_URL_4]) {
        return 4;
    }
    else  if ([lastData.url540 containsString:NE_DEMO_PLAYER_URL_5]) {
        return 5;
    }
    else  if ([lastData.url540 containsString:NE_DEMO_PLAYER_URL_6]) {
        return 6;
    }
    else  if ([lastData.url540 containsString:NE_DEMO_PLAYER_URL_7]) {
        return 7;
    }
    else  if ([lastData.url540 containsString:NE_DEMO_PLAYER_URL_8]) {
        return 8;
    }
    
    return 1;
}

- (void)addPlayUrlWithIndex:(NSUInteger)index {
    if (index == 1) {
        [self.manager.dataSource addObject:[NEDataManager data1]];
    }
    else if (index == 2) {
        [self.manager.dataSource addObject:[NEDataManager data2]];
    }
    else if (index == 3) {
        [self.manager.dataSource addObject:[NEDataManager data3]];
    }
    else if (index == 4) {
        [self.manager.dataSource addObject:[NEDataManager data4]];
    }
    else if (index == 5) {
        [self.manager.dataSource addObject:[NEDataManager data5]];
    }
    else if (index == 6) {
        [self.manager.dataSource addObject:[NEDataManager data6]];
    }
    else if (index == 7) {
        [self.manager.dataSource addObject:[NEDataManager data7]];
    }
    else if (index == 8) {
        [self.manager.dataSource addObject:[NEDataManager data8]];
    }
}

- (void)doAddDataSource {
    NSUInteger lastIndex = [self findIndexOfLastDataSource];
    for (NSUInteger i = 0; i < 8; ++i) {
        lastIndex++;
        lastIndex = lastIndex > 8 ? 1 : lastIndex;
        [self addPlayUrlWithIndex:lastIndex];
    }
}

- (void)requestData {
    [self.manager.dataSource removeAllObjects];
    [self.manager.dataSource addObject:[NEDataManager data1]];
    [self.manager.dataSource addObject:[NEDataManager data2]];
    [self.manager.dataSource addObject:[NEDataManager data3]];
    [self.manager.dataSource addObject:[NEDataManager data4]];
    [self.manager.dataSource addObject:[NEDataManager data5]];
    [self.manager.dataSource addObject:[NEDataManager data6]];
    [self.manager.dataSource addObject:[NEDataManager data7]];
    [self.manager.dataSource addObject:[NEDataManager data8]];
    [self.manager.portraitScrollView reloadData];
}

@end
