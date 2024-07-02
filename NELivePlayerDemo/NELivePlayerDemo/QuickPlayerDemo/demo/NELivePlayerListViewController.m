//
//  NELivePlayerListViewController.m
//  NELivePlayerDemo
//
//  Created by 游联启 on 2024/6/6.
//

#import "NELivePlayerListViewController.h"
#import "NELiveVideoManager.h"
#import "NELivePlayerViewController.h"
#import "NELivePlayerManager.h"
#import "NEDataManager.h"
#import "LabelSwitchView.h"

@interface NELivePlayerCollectionViewCell()

@property (nonatomic, strong) UIImageView *backgroudImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSString *url;

@end

@implementation NELivePlayerCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _backgroudImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"show_room_cover"]];
        [self.contentView addSubview:_backgroudImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
    }
    
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _backgroudImageView.frame = self.contentView.bounds;
    
    _titleLabel.frame = CGRectMake(10, 10, self.contentView.bounds.size.width-20, self.contentView.bounds.size.height-20);
}
    
@end
    
@interface NELivePlayerListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSUInteger preloadIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) LabelSwitchView *rememberSwitchView;
@end

@implementation NELivePlayerListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (instancetype)init {
    if (self = [super init]) {
        UIBarButtonItem *segmentedBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
        UIBarButtonItem *rememberBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rememberSwitchView];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:segmentedBarButtonItem, rememberBarButtonItem, nil];
        
        [self.dataSource addObject:[NEDataManager data1]];
        [self.dataSource addObject:[NEDataManager data2]];
        [self.dataSource addObject:[NEDataManager data3]];
        [self.dataSource addObject:[NEDataManager data4]];
        [self.dataSource addObject:[NEDataManager data5]];
        [self.dataSource addObject:[NEDataManager data6]];
        [self.dataSource addObject:[NEDataManager data7]];
        [self.dataSource addObject:[NEDataManager data8]];
        
        _preloadIndex = 0;
        [self setLivePlayerUrlListInInit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    self.collectionView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_segmentedControl) {
        if (_segmentedControl.selectedSegmentIndex != [NEDataManager sharedInstance].profileType) {
            _segmentedControl.selectedSegmentIndex = [NEDataManager sharedInstance].profileType;
            [self segmentControlChangeValue:_segmentedControl];
        }
    }
    [self resetPreloadPlayerIfNeeded];
}

- (UICollectionView *)collectionView
{
    if( !_collectionView ) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[NELivePlayerCollectionViewCell class] forCellWithReuseIdentifier:@"PlayerListCellIdentifier"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"180", @"360", @"540", @"720"]];
        _segmentedControl.selectedSegmentIndex = [NEDataManager sharedInstance].profileType;
        [_segmentedControl addTarget:self action:@selector(segmentControlChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _segmentedControl;
}

- (void)segmentControlChangeValue:(UISegmentedControl *)control {
    [NEDataManager sharedInstance].profileType = control.selectedSegmentIndex;
    [self.collectionView reloadData];
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf resetPreloadPlayerIfNeeded];
    });
}

- (LabelSwitchView *)rememberSwitchView {
    if (!_rememberSwitchView) {
        LabelSwitchView *view = [[LabelSwitchView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        view.textLabel.text = @"记住分辨率";
        view.textLabel.font = [UIFont systemFontOfSize:14];
        view.switcher.on = NO;
        [view.switcher addTarget:self action:@selector(rememberSwitchAction:) forControlEvents:UIControlEventValueChanged];
        _rememberSwitchView = view;
    }
    return _rememberSwitchView;
}

- (void)rememberSwitchAction:(UISwitch *)switcher {
    [NEDataManager sharedInstance].rememberProfileType = switcher.isOn;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"PlayerListCellIdentifier";
    NELivePlayerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.dataSource.count) {
        NEPlayerUrlData *data = self.dataSource[indexPath.row];
        cell.url = data.url;
        cell.titleLabel.text = cell.url;
    }
    
    cell.backgroundColor = [UIColor yellowColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<NSIndexPath *> *selectedIndexPaths = [collectionView indexPathsForSelectedItems];
    if (selectedIndexPaths.count > 0) {
        NSIndexPath *indexPath = selectedIndexPaths[0];
        NSMutableArray *preloadList = [[NSMutableArray alloc] init];
        NSUInteger index = indexPath.row;
        for (NSUInteger i = 0; i < 4; ++i) {
            if (index < self.dataSource.count) {
                [preloadList addObject:self.dataSource[index]];
                index++;
            }
        }
        NELivePlayerViewController *playViewController = [[NELivePlayerViewController alloc] initWithDataSource:preloadList];
        [self.navigationController pushViewController:playViewController animated:YES];
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.view.frame.size.width;
    CGFloat space = 5;
    CGFloat cellWidth = (width-4*space)/2;
    CGFloat cellHeight = cellWidth * 5 / 4;
    return CGSizeMake(cellWidth, cellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0)) {
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self requestMoreDataIfNeeded:scrollView];
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf resetPreloadPlayerIfNeeded];
    });
}

- (void)requestMoreDataIfNeeded:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat height = scrollView.frame.size.height;
    if (offsetY > (contentHeight - height)) {
        [self requestMoreData];
    }
}

- (void)requestMoreData {
    [self.dataSource addObject:[NEDataManager data1]];
    [self.dataSource addObject:[NEDataManager data2]];
    [self.dataSource addObject:[NEDataManager data3]];
    [self.dataSource addObject:[NEDataManager data4]];
    [self.dataSource addObject:[NEDataManager data5]];
    [self.dataSource addObject:[NEDataManager data6]];
    [self.dataSource addObject:[NEDataManager data7]];
    [self.dataSource addObject:[NEDataManager data8]];
    [self.collectionView reloadData];
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf resetPreloadPlayerIfNeeded];
    });
}

- (void)resetPreloadPlayerIfNeeded {
    NSMutableArray *preloadList = [[NSMutableArray alloc] init];
    NSUInteger index = 0;
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        NELivePlayerCollectionViewCell *cell = (NELivePlayerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        CGRect cellRect = [self.collectionView convertRect:cell.frame toView:self.collectionView.superview];
        if (CGRectContainsRect(self.collectionView.frame, cellRect)) {
            //PLAYER_LOG(@"[%s]indexPath row:%@ url:%@", __func__, @(indexPath.row), cell.url);
            [preloadList addObject:cell.url];
            index = MAX(index, indexPath.row);
            //PLAYER_LOG(@"[%s]visiable indexPath row:%@ url:%@", __func__, @(indexPath.row), cell.url);
        }
    }
    
    //滑动到只有 4 个 cell 显示完整
    if (preloadList.count == 4) {
        if (index+1 < self.dataSource.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+1 inSection:0];
            NELivePlayerCollectionViewCell *cell = (NELivePlayerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            //PLAYER_LOG(@"[%s]indexPath row:%@ url:%@ index:%@", __func__, @(indexPath.row), cell.url, @(index+1));
            [preloadList addObject:cell.url];
        }
        
        if (index+2 < self.dataSource.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+2 inSection:0];
            NELivePlayerCollectionViewCell *cell = (NELivePlayerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            //PLAYER_LOG(@"[%s]indexPath row:%@ url:%@ index:%@", __func__, @(indexPath.row), cell.url , @(index+2));
            [preloadList addObject:cell.url];
        }
    }
    
    [[NELivePlayerManager sharedInstance] setLivePlayerUrlListOnlyPreload:preloadList];
}

- (void)setLivePlayerUrlListInInit{
    NSMutableArray *preloadList = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 6; ++i) {
        if (i < self.dataSource.count) {
            NEPlayerUrlData *data = self.dataSource[i];
            [preloadList addObject:data.url];
        }
    }
    
    [[NELivePlayerManager sharedInstance] setLivePlayerUrlListOnlyPreload:preloadList];
}

@end
