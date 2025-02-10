#import "LabelSwitchView.h"

@interface LabelSwitchView ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UISwitch *switcher;

@end

@implementation LabelSwitchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        if (@available(iOS 13.0, *)) {
            label.textColor = UIColor.labelColor;
        }
        
        [self addSubview:label];
        _textLabel = label;
        
        UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
        switcher.tintColor = [UIColor lightGrayColor];
        [self addSubview:switcher];
        _switcher = switcher;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = CGRectInset(self.bounds, 4, 0);

    [self.switcher sizeToFit];
    
    self.switcher.center = CGPointMake(CGRectGetMaxX(bounds) - CGRectGetWidth(self.switcher.frame) / 2 - 8, CGRectGetMidY(bounds));
    
    CGFloat labelMaxX = CGRectGetMinX(self.switcher.frame) - 4;
    self.textLabel.frame = CGRectMake(0, 0, labelMaxX, CGRectGetHeight(bounds));
}

@end
