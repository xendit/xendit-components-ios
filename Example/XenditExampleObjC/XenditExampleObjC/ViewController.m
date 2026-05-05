#import "ViewController.h"
#import "OpenSansFont.h"
#import "SpaceMonoFont.h"
#import "NotoSerifFont.h"
@import XenditComponents;

// Theme indices matching the segmented control order
typedef NS_ENUM(NSInteger, AppThemeIndex) {
    AppThemeIndexDefault    = 0,
    AppThemeIndexDailyBrew  = 1,
    AppThemeIndexFintechBlue = 2,
    AppThemeIndexArcade     = 3,
    AppThemeIndexBoutique   = 4,
};

@interface ViewController ()

@property (nonatomic, strong) UIScrollView          *scrollView;
@property (nonatomic, strong) UIStackView           *contentStack;
@property (nonatomic, strong) UILabel               *instructionLabel;
@property (nonatomic, strong) UITextView            *keyTextView;
@property (nonatomic, strong) UISegmentedControl    *themeControl;
@property (nonatomic, strong) UIButton              *checkoutButton;
@property (nonatomic, strong) UILabel               *resultLabel;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Xendit SDK Example";
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;

    [self setupLayout];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Layout

- (void)setupLayout {
    self.scrollView = [UIScrollView new];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];

    self.contentStack = [UIStackView new];
    self.contentStack.axis = UILayoutConstraintAxisVertical;
    self.contentStack.spacing = 16;
    self.contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentStack];

    UILabel *themeLabel = [UILabel new];
    themeLabel.text = @"Theme";
    themeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    themeLabel.textColor = UIColor.secondaryLabelColor;

    [self.contentStack addArrangedSubview:self.instructionLabel];
    [self.contentStack addArrangedSubview:self.keyTextView];
    [self.contentStack addArrangedSubview:themeLabel];
    [self.contentStack addArrangedSubview:self.themeControl];
    [self.contentStack addArrangedSubview:self.checkoutButton];
    [self.contentStack addArrangedSubview:self.resultLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.contentStack.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:24],
        [self.contentStack.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:20],
        [self.contentStack.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-20],
        [self.contentStack.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-24],
        [self.contentStack.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-40],

        [self.keyTextView.heightAnchor constraintEqualToConstant:140],
    ]];
}

#pragma mark - Subview factories

- (UILabel *)instructionLabel {
    if (!_instructionLabel) {
        _instructionLabel = [UILabel new];
        _instructionLabel.text = @"Paste your components_sdk_key from the Create Session response.";
        _instructionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _instructionLabel.textColor = UIColor.secondaryLabelColor;
        _instructionLabel.numberOfLines = 0;
    }
    return _instructionLabel;
}

- (UITextView *)keyTextView {
    if (!_keyTextView) {
        _keyTextView = [UITextView new];
        _keyTextView.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
        _keyTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        _keyTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _keyTextView.layer.borderColor = UIColor.separatorColor.CGColor;
        _keyTextView.layer.borderWidth = 1;
        _keyTextView.layer.cornerRadius = 8;
        _keyTextView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
        _keyTextView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _keyTextView;
}

- (UISegmentedControl *)themeControl {
    if (!_themeControl) {
        _themeControl = [[UISegmentedControl alloc] initWithItems:@[
            @"Default", @"Daily Brew", @"Fintech Blue", @"Arcade", @"Boutique"
        ]];
        _themeControl.selectedSegmentIndex = 0;
        [_themeControl addTarget:self action:@selector(themeTapped) forControlEvents:UIControlEventValueChanged];
    }
    return _themeControl;
}

- (UIButton *)checkoutButton {
    if (!_checkoutButton) {
        UIButtonConfiguration *config = [UIButtonConfiguration filledButtonConfiguration];
        config.title = @"Checkout with Xendit";
        config.cornerStyle = UIButtonConfigurationCornerStyleMedium;
        _checkoutButton = [UIButton buttonWithConfiguration:config primaryAction:nil];
        [_checkoutButton addTarget:self
                            action:@selector(checkoutTapped)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkoutButton;
}

- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [UILabel new];
        _resultLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _resultLabel.textColor = UIColor.labelColor;
        _resultLabel.numberOfLines = 0;
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.hidden = YES;
    }
    return _resultLabel;
}

#pragma mark - Theme helpers

- (UIColor *)colorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

- (XDTAppearance *)appearanceForThemeIndex:(NSInteger)index {
    XDTAppearance *appearance = [XDTAppearance new];

    switch ((AppThemeIndex)index) {
        case AppThemeIndexDefault:
            break;

        case AppThemeIndexDailyBrew: {
            XDTFontFamily *fonts = [XDTFontFamily new];
            fonts.regular  = [OpenSansFont regular];
            fonts.medium   = [OpenSansFont medium];
            fonts.semiBold = [OpenSansFont semiBold];
            fonts.bold     = [OpenSansFont bold];
            appearance.fontFamily         = fonts;
            appearance.colorPrimary       = [self colorWithRed:141 green:110 blue:99];
            appearance.colorText          = [self colorWithRed:62  green:39  blue:35];
            appearance.colorTextSecondary = [self colorWithRed:121 green:85  blue:72];
            appearance.colorTextPlaceholder = [self colorWithRed:161 green:136 blue:127];
            appearance.colorDanger        = [self colorWithRed:211 green:47  blue:47];
            appearance.colorBorder        = [self colorWithRed:215 green:204 blue:200];
            appearance.colorBackground    = [self colorWithRed:255 green:251 blue:240];
            appearance.borderRadius       = 12;
            break;
        }

        case AppThemeIndexFintechBlue: {
            XDTFontFamily *fonts = [XDTFontFamily new];
            fonts.regular  = [OpenSansFont regular];
            fonts.medium   = [OpenSansFont medium];
            fonts.semiBold = [OpenSansFont semiBold];
            fonts.bold     = [OpenSansFont bold];
            appearance.fontFamily         = fonts;
            appearance.colorPrimary       = [self colorWithRed:0   green:82  blue:255];
            appearance.colorText          = [self colorWithRed:17  green:24  blue:39];
            appearance.colorTextSecondary = [self colorWithRed:107 green:114 blue:128];
            appearance.colorTextPlaceholder = [self colorWithRed:156 green:163 blue:175];
            appearance.colorDanger        = [self colorWithRed:220 green:38  blue:38];
            appearance.colorBorder        = [self colorWithRed:229 green:231 blue:235];
            appearance.colorBackground    = [UIColor whiteColor];
            appearance.borderRadius       = 6;
            break;
        }

        case AppThemeIndexArcade: {
            XDTFontFamily *fonts = [XDTFontFamily new];
            fonts.regular  = [SpaceMonoFont regular];
            fonts.medium   = [SpaceMonoFont regular];
            fonts.semiBold = [SpaceMonoFont bold];
            fonts.bold     = [SpaceMonoFont bold];
            appearance.fontFamily         = fonts;
            appearance.colorPrimary       = [self colorWithRed:0   green:255 blue:209];
            appearance.colorText          = [UIColor whiteColor];
            appearance.colorTextSecondary = [self colorWithRed:136 green:136 blue:136];
            appearance.colorTextPlaceholder = [self colorWithRed:51 green:51 blue:51];
            appearance.colorDisabled      = [self colorWithRed:26  green:26  blue:26];
            appearance.colorDanger        = [self colorWithRed:255 green:0   blue:85];
            appearance.colorBorder        = [self colorWithRed:0   green:255 blue:209];
            appearance.colorBackground    = [UIColor blackColor];
            appearance.qrForegroundColor  = [UIColor blackColor];
            appearance.qrBackgroundColor  = [self colorWithRed:0   green:255 blue:209];
            appearance.borderRadius       = 4;
            break;
        }

        case AppThemeIndexBoutique: {
            XDTFontFamily *fonts = [XDTFontFamily new];
            fonts.regular  = [NotoSerifFont regular];
            fonts.medium   = [NotoSerifFont medium];
            fonts.semiBold = [NotoSerifFont semiBold];
            fonts.bold     = [NotoSerifFont bold];
            appearance.fontFamily         = fonts;
            appearance.colorPrimary       = [self colorWithRed:44  green:44  blue:44];
            appearance.colorText          = [self colorWithRed:44  green:44  blue:44];
            appearance.colorTextSecondary = [self colorWithRed:90  green:90  blue:90];
            appearance.colorTextPlaceholder = [self colorWithRed:170 green:170 blue:170];
            appearance.colorDanger        = [self colorWithRed:148 green:27  blue:27];
            appearance.colorBorder        = [self colorWithRed:44  green:44  blue:44];
            appearance.colorBackground    = [self colorWithRed:244 green:241 blue:234];
            appearance.qrForegroundColor  = [self colorWithRed:44  green:44  blue:44];
            appearance.qrBackgroundColor  = [self colorWithRed:244 green:241 blue:234];
            appearance.borderRadius       = 0;
            break;
        }
    }

    return appearance;
}

#pragma mark - Actions

- (void)themeTapped {
    // Selection is read at checkout time
}

- (void)checkoutTapped {
    NSString *key = [self.keyTextView.text
                     stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (key.length == 0) { return; }

    self.resultLabel.hidden = YES;

    XDTAppearance *appearance = [self appearanceForThemeIndex:self.themeControl.selectedSegmentIndex];
    [XDTComponents initializeWithAppearance:appearance];

    [XDTComponents presentFromViewController:self
                           componentsSdkKey:key
                                   onResult:^(XDTPaymentResult *result) {
        [self handleResult:result];
    }];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Result handling

- (void)handleResult:(XDTPaymentResult *)result {
    NSString *message;

    switch (result.status) {
        case XDTPaymentStatusSuccess:
            message = [NSString stringWithFormat:@"✓ Success\nID: %@\nChannel: %@",
                       result.paymentRequestId, result.channelCode];
            self.resultLabel.textColor = UIColor.systemGreenColor;
            break;
        case XDTPaymentStatusFailed:
            message = [NSString stringWithFormat:@"✗ Failed\n%@ (%@)",
                       result.error.message, result.error.xenditCode];
            self.resultLabel.textColor = UIColor.systemRedColor;
            break;
        case XDTPaymentStatusCanceled:
            message = @"Canceled: The session was terminated.";
            self.resultLabel.textColor = UIColor.secondaryLabelColor;
            break;
        case XDTPaymentStatusExpired:
            message = @"Expired: The session timed out.";
            self.resultLabel.textColor = UIColor.secondaryLabelColor;
            break;
        case XDTPaymentStatusDismissed:
            message = @"Dismissed: User closed the sheet.";
            self.resultLabel.textColor = UIColor.secondaryLabelColor;
            break;
    }

    self.resultLabel.text = message;
    self.resultLabel.hidden = NO;
}

@end
