//
//  NELivePlayerLoginViewController.m
//  NELivePlayerDemo
//
//  Created by BiWei on 15-10-10.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "NELivePlayerLoginViewController.h"
#import "NELivePlayerVC.h"
#import "NELPDemoScrollVC.h"
#import "UIView+NEPlayer.h"
#import "NELivePlayerListViewController.h"

#define kButtonHeight  43
#define kHorMargin     15
#define kVerMargin     84//64
#define kHorInternal   5
#define kVerInternal   20

@interface NELivePlayerLoginViewController () <NELivePlayerQRScanViewControllerDelegate>
{
    CGRect _preRect;
    NSInteger _selectIndex;
    NSString *mediaType;
    NSString *decodeType;
    NSInteger _inputIndex;
}
@property (nonatomic, strong) UIButton *livestreamBtn;     //选择直播流按钮
@property (nonatomic, strong) UIButton *videoOnDemandBtn;  //选择点播流按钮
@property (nonatomic, strong) UITextField *urlPath;        //网络流地址输入框
@property (nonatomic, strong) UIButton *qrScanBtn;         //二维码扫描

@property (nonatomic, strong) UIView *syncContainerView; //包裹视图
@property (nonatomic, strong) UIButton *syncSwitchBtn;     //多播放器同步
@property (nonatomic, strong) UITextField *syncUrlPath;    //从播放器Url播放器
@property (nonatomic, strong) UIButton *syncQrScanBtn;    //从播放器Url播放器

@property (nonatomic, strong) UIButton *hardware;          //硬件解码按钮
@property (nonatomic, strong) UIButton *software;          //软件解码按钮
@property (nonatomic, strong) UIButton *playBtn;           //播放按钮

@property (nonatomic, strong) UISegmentedControl *media_type;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *imageViewSelected1;

@end

@implementation NELivePlayerLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    
    [self initValues];
    
    //[self rightBtnAction:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)initValues {
    mediaType = @"livestream"; //标识媒体类型，直播流还是点播流或本地文件
    decodeType = @"software";  //标识解码类型，硬件解码或软件解码
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!CGRectEqualToRect(_preRect, self.view.bounds)) {
        CGFloat buttonWidth = self.view.width/2;
        _livestreamBtn.frame = CGRectMake(0, kVerMargin, buttonWidth, kButtonHeight);
        _videoOnDemandBtn.frame = CGRectMake(buttonWidth, kVerMargin, buttonWidth, kButtonHeight);
        _imageView.frame = CGRectMake(0, _livestreamBtn.bottom, self.view.width, 1);
        _imageViewSelected1.frame = CGRectMake(_selectIndex * buttonWidth,
                                                   _imageView.top - 4.0,
                                                   buttonWidth,
                                                   4.0);
        _qrScanBtn.frame = CGRectMake(self.view.width - 38.0 - kHorMargin, _imageView.bottom + 16.0, 38.0, 38.0);
        _urlPath.frame = CGRectMake(kHorMargin,
                                        _qrScanBtn.top,
                                        _qrScanBtn.left - kHorMargin*2,
                                        _qrScanBtn.height);
        _syncContainerView.frame = CGRectMake(kHorMargin,
                                              _urlPath.bottom + 16.0,
                                              self.view.width - kHorMargin*2, 38.0);
        _syncUrlPath.frame = CGRectMake(0, 0, _syncContainerView.width - 38.0 - kHorMargin, _syncContainerView.height);
        _syncQrScanBtn.frame = CGRectMake(_syncUrlPath.right + kHorMargin,
                                          0,
                                          38.0,
                                          _syncContainerView.height);
        if (_syncContainerView.hidden) {
            _software.frame = CGRectMake(0, _urlPath.bottom + 16.0, buttonWidth, 40.0);

        } else {
            _software.frame = CGRectMake(0, _syncContainerView.bottom + 16.0, buttonWidth, 40.0);
        }
        _hardware.frame = CGRectMake(_software.left, _software.bottom, _software.width, _software.height);
        _syncSwitchBtn.frame = CGRectMake(_software.right, _software.top, _software.width, _software.height);
        _playBtn.frame = CGRectMake(32.0, _hardware.bottom+16.0, self.view.width-32.0*2, 40.0);
        _preRect = self.view.bounds;
    }
}

- (void)setupSubviews {

    self.view.backgroundColor = [UIColor whiteColor];
    
    //导航栏:滚动演示
    self.title = @"播放选项";
    UIButton *scrollBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [scrollBtn setTitle:@"滚动演示" forState:UIControlStateNormal];
    scrollBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    scrollBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    scrollBtn.frame = CGRectMake(0, 0, 64, 40);
    [scrollBtn addTarget:self action:@selector(leftBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *scallItem = [[UIBarButtonItem alloc] initWithCustomView:scrollBtn];
    self.navigationItem.leftBarButtonItem = scallItem;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightBtn setTitle:@"播放器秒开演示" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    rightBtn.frame = CGRectMake(0, 0, 64, 40);
    [rightBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //***************************** 媒体类型 ********************************//
    [self.view addSubview:self.livestreamBtn];
    [self.view addSubview:self.videoOnDemandBtn];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.imageViewSelected1];
    [self.view addSubview:self.urlPath];
    [self.view addSubview:self.qrScanBtn];
    [self.view addSubview:self.hardware];
    [self.view addSubview:self.software];
    [self.view addSubview:self.syncSwitchBtn];
    [self.view addSubview:self.syncContainerView];
    [self.syncContainerView addSubview:self.syncUrlPath];
    [self.syncContainerView addSubview:self.syncQrScanBtn];
    [self.view addSubview:self.playBtn];
}

#pragma mark - Actions
- (void) mediaTypeButtonTouched:(id)sender {
    if (sender == _livestreamBtn) {
        self.urlPath.hidden = NO;
        _selectIndex = 0;
        self.urlPath.placeholder = @"请输入直播流地址：URL";
        self.syncUrlPath.placeholder = @"[从播放器]请输入直播流地址：URL";
        [self decodeTypePresent:YES]; //直播解码类型要显示
        mediaType = @"livestream";
    } else if (sender == _videoOnDemandBtn) {
        self.urlPath.hidden = NO;
        _selectIndex = 1;
        self.urlPath.placeholder = @"请输入点播流地址：URL";
        self.syncUrlPath.placeholder = @"[从播放器]请输入点播流地址：URL";
        [self decodeTypePresent:YES]; //点播解码类型要显示
        mediaType = @"videoOnDemand";
    }
    _imageViewSelected1.frame = CGRectMake(_selectIndex * self.view.width/2,
                                           _imageView.top - 4.0,
                                           self.view.width/2,
                                           4.0);
}

- (void)setHardwareButtonStyle:(id)sender {
    NSLog(@"hardware selected!");
    decodeType = @"hardware";
    [self.hardware setSelected:YES];
    [self.software setSelected:NO];
}

- (void)setSoftwareButtonStyle:(id)sender {
    NSLog(@"software selected!");
    decodeType = @"software";
    [self.hardware setSelected:NO];
    [self.software setSelected:YES];
}

- (void)decodeTypePresent:(BOOL) isPresent {
    self.hardware.hidden = !isPresent;
    self.software.hidden = !isPresent;
    self.playBtn.hidden = !isPresent;
}

- (void)playButtonPressed:(id)sender {
    UIAlertView *alert = NULL; //定义一个消息提示框
    NSURL *url = NULL; //待播放的文件路径
    if ([mediaType isEqualToString:@"livestream"] || [mediaType isEqualToString:@"videoOnDemand"]) { //直播流或点播流
        if ([self.urlPath.text length] == 0) {//输入框未输入时提示
            if ([mediaType isEqualToString:@"livestream"]) {
                alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入直播流地址" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            }
            else if([mediaType isEqualToString:@"videoOnDemand"]) {
                alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入点播流地址" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            }
            
            [alert show];
            return;
        }
    
        url = [[NSURL alloc] initWithString:self.urlPath.text];
    }
    
    NSMutableArray *decodeParm = [[NSMutableArray alloc] init];
    [decodeParm addObject:decodeType];
    [decodeParm addObject:mediaType];
    if (_syncSwitchBtn.selected && _syncUrlPath.text.length != 0) {
        NSURL *syncUrl = [NSURL URLWithString:_syncUrlPath.text];
        if (syncUrl) {
            [decodeParm addObject:syncUrl];
        }
    }

    NELivePlayerVC *player = [[NELivePlayerVC alloc] initWithURL:url andDecodeParm:decodeParm];
    [self presentViewController:player animated:YES completion:nil];
}

- (void)onClickQRScan:(id)sender {
    
    if (sender == _qrScanBtn) {
        _inputIndex = 1;
    } else if (sender == _syncQrScanBtn) {
        _inputIndex = 2;
    }
    
    NELivePlayerQRScanViewController *qrScanner = [[NELivePlayerQRScanViewController alloc] init];
    qrScanner.delegate = self;
    [self.navigationController pushViewController:qrScanner animated:YES];
}

- (void)leftBtnAction:(id)sender {
    NELPDemoScrollVC *scrollVC = [[NELPDemoScrollVC alloc] init];
    [self presentViewController:scrollVC animated:YES completion:nil];
}

- (void)rightBtnAction:(id)sender {
    NELivePlayerListViewController *controller = [[NELivePlayerListViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)syncSwitchAction:(UIButton *)sender {
    _syncSwitchBtn.selected = !_syncSwitchBtn.selected;
    [self showSyncControlView:sender.selected];
}

- (void)showSyncControlView:(BOOL)show {
    _syncContainerView.hidden = !show;
    if (show) {
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.software.top = strongSelf.syncContainerView.bottom + 16.0;
            strongSelf.hardware.top = strongSelf.software.bottom;
            strongSelf.syncSwitchBtn.top = strongSelf.software.top;
            strongSelf.playBtn.top = strongSelf.hardware.bottom + 16.0;
        }];
    } else {
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.software.top = strongSelf.urlPath.bottom + 16.0;
            strongSelf.hardware.top = strongSelf.software.bottom;
            strongSelf.syncSwitchBtn.top = strongSelf.software.top;
            strongSelf.playBtn.top = strongSelf.hardware.bottom + 16.0;
        }];
    }
}

#pragma mark - Getter
- (UIButton *)livestreamBtn {
    if (!_livestreamBtn) {
        _livestreamBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_livestreamBtn setBackgroundColor:[UIColor whiteColor]];
        [_livestreamBtn setTitle:@"网络直播" forState:UIControlStateNormal];
        _livestreamBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_livestreamBtn setTitleColor:[[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
        _livestreamBtn.backgroundColor = [UIColor clearColor];
        [_livestreamBtn addTarget:self action:@selector(mediaTypeButtonTouched:) forControlEvents:UIControlEventTouchDown];
    }
    return _livestreamBtn;
}

- (UIButton *)videoOnDemandBtn {
    if (!_videoOnDemandBtn) {
        _videoOnDemandBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoOnDemandBtn setTitle:@"视频点播" forState:UIControlStateNormal];
        _videoOnDemandBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_videoOnDemandBtn setTitleColor:[[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_videoOnDemandBtn setBackgroundColor:[UIColor clearColor]];
        [_videoOnDemandBtn addTarget:self action:@selector(mediaTypeButtonTouched:) forControlEvents:UIControlEventTouchDown];
    }
    return _videoOnDemandBtn;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView= [[UIImageView alloc] init];
        [_imageView setImage:[UIImage imageNamed:@"tab_bottom"]];
    }
    return _imageView;
}

- (UIImageView *)imageViewSelected1 {
    if (!_imageViewSelected1) {
        _imageViewSelected1 = [[UIImageView alloc] init];
        [_imageViewSelected1 setImage:[UIImage imageNamed:@"tab_top"]];
    }
    return _imageViewSelected1;
}

- (UITextField *)urlPath {
    if (!_urlPath) {
        _urlPath = [[UITextField alloc] init];
        [_urlPath setBackgroundColor:[UIColor whiteColor]];
        _urlPath.placeholder = @"请输入直播流地址：URL";
        _urlPath.font = [UIFont boldSystemFontOfSize:12];
        _urlPath.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
        _urlPath.keyboardType = UIKeyboardTypeURL;
        _urlPath.borderStyle = UITextBorderStyleRoundedRect;
        _urlPath.autocorrectionType = UITextAutocorrectionTypeNo; //不自动纠错
        _urlPath.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _urlPath;
}

- (UIButton *)qrScanBtn {
    if (!_qrScanBtn) {
        _qrScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_qrScanBtn setImage:[UIImage imageNamed:@"btn_qr_scan"] forState:UIControlStateNormal];
        [_qrScanBtn addTarget:self action:@selector(onClickQRScan:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qrScanBtn;
}

- (UIButton *)software {
    if (!_software) {
        _software = [self makeSelectBtnWithTitle:@"软件解码"];
        _software.selected = YES;
        [_software addTarget:self action:@selector(setSoftwareButtonStyle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _software;
}

- (UIButton *)hardware {
    if (!_hardware) {
        _hardware = [self makeSelectBtnWithTitle:@"硬件解码"];
        [self.hardware addTarget:self action:@selector(setHardwareButtonStyle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hardware;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"btn_player_start_play"] forState:UIControlStateNormal];
        [_playBtn setTitle:@"播 放" forState:UIControlStateNormal];
        _playBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _playBtn.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [_playBtn addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)makeSelectBtnWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(300, 300, 100, 40);
    btn.contentMode = UIViewContentModeRight;
    
    [btn setImage:[UIImage imageNamed:@"btn_player_selected"] forState:UIControlStateSelected];
    [btn setImage:[UIImage imageNamed:@"btn_player_unselected"] forState:UIControlStateNormal];
    btn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 60);
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(-1, 16, 0, 0);
    btn.titleLabel.numberOfLines = 2;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    return btn;
}

- (UIButton *)syncSwitchBtn {
    if (!_syncSwitchBtn) {
        _syncSwitchBtn = [self makeSelectBtnWithTitle:@"多播放器同步"];
        _syncSwitchBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_syncSwitchBtn addTarget:self action:@selector(syncSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _syncSwitchBtn;
}

- (UIView *)syncContainerView {
    if (!_syncContainerView) {
        _syncContainerView = [[UIView alloc] init];
        _syncContainerView.hidden = YES;
    }
    return _syncContainerView;
}

- (UITextField *)syncUrlPath {
    if (!_syncUrlPath) {
        _syncUrlPath = [[UITextField alloc] init];
        [_syncUrlPath setBackgroundColor:[UIColor whiteColor]];
        _syncUrlPath.placeholder = @"[从播放器]请输入直播流地址：URL";
        _syncUrlPath.font = [UIFont boldSystemFontOfSize:12];
        _syncUrlPath.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
        _syncUrlPath.keyboardType = UIKeyboardTypeURL;
        _syncUrlPath.borderStyle = UITextBorderStyleRoundedRect;
        _syncUrlPath.autocorrectionType = UITextAutocorrectionTypeNo; //不自动纠错
        _syncUrlPath.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _syncUrlPath;
}

- (UIButton *)syncQrScanBtn {
    if (!_syncQrScanBtn) {
        _syncQrScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_syncQrScanBtn setImage:[UIImage imageNamed:@"btn_qr_scan"] forState:UIControlStateNormal];
        [_syncQrScanBtn addTarget:self action:@selector(onClickQRScan:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _syncQrScanBtn;
}

#pragma mark - <NELivePlayerQRScanViewControllerDelegate>
- (void)NELivePlayerQRScanViewController:(NELivePlayerQRScanViewController *)qrScanner
                        didFinishScanner:(NSString *)string {
    
    if (_inputIndex == 1) {
        self.urlPath.text = string;
    } else if (_inputIndex == 2) {
        self.syncUrlPath.text = string;
    }
}

@end
