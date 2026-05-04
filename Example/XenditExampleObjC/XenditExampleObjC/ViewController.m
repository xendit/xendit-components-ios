#import "ViewController.h"
@import XenditComponents;

@interface ViewController ()

@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIStackView   *contentStack;
@property (nonatomic, strong) UILabel       *instructionLabel;
@property (nonatomic, strong) UITextView    *keyTextView;
@property (nonatomic, strong) UIButton      *checkoutButton;
@property (nonatomic, strong) UILabel       *resultLabel;

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

    [self.contentStack addArrangedSubview:self.instructionLabel];
    [self.contentStack addArrangedSubview:self.keyTextView];
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

#pragma mark - Actions

- (void)checkoutTapped {
    NSString *key = [self.keyTextView.text
                     stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (key.length == 0) { return; }

    self.resultLabel.hidden = YES;

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
