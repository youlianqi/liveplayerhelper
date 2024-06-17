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
 
        [self.dataSource addObject:NE_DEMO_PLAYER_URL_1];
        [self.dataSource addObject:NE_DEMO_PLAYER_URL_2];
        [self.dataSource addObject:NE_DEMO_PLAYER_URL_3];
        [self.dataSource addObject:NE_DEMO_PLAYER_URL_4];
        [self.dataSource addObject:NE_DEMO_PLAYER_URL_5];
        [self.dataSource addObject:NE_DEMO_PLAYER_URL_6];
        [self.dataSource addObject:NE_DEMO_PLAYER_URL_7];
        [self.dataSource addObject:NE_DEMO_PLAYER_URL_8];
        
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
    [self resetPreloadPlayerIfNeeded];
}

- (UICollectionView *)collectionView
{
    if( !_collectionView ) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        //layout.itemSize = CGSizeMake(100, 150);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[NELivePlayerCollectionViewCell class] forCellWithReuseIdentifier:@"PlayerListCellIdentifier"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"PlayerListCellIdentifier";
    NELivePlayerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.dataSource.count) {
        cell.url = self.dataSource[indexPath.row];
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
    [self.dataSource addObject:NE_DEMO_PLAYER_URL_1];
    [self.dataSource addObject:NE_DEMO_PLAYER_URL_2];
    [self.dataSource addObject:NE_DEMO_PLAYER_URL_3];
    [self.dataSource addObject:NE_DEMO_PLAYER_URL_4];
    [self.dataSource addObject:NE_DEMO_PLAYER_URL_5];
    [self.dataSource addObject:NE_DEMO_PLAYER_URL_6];
    [self.dataSource addObject:NE_DEMO_PLAYER_URL_7];
    [self.dataSource addObject:NE_DEMO_PLAYER_URL_8];
    [self.collectionView reloadData];
    [self resetPreloadPlayerIfNeeded];
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
            [preloadList addObject:self.dataSource[i]];
        }
    }
    
    [[NELivePlayerManager sharedInstance] setLivePlayerUrlListOnlyPreload:preloadList];
}

@end
