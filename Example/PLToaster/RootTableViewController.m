//
//  RootTableViewController.m
//  PLToaster
//
//  Created by zyonpaul on 2018/7/12.
//  Copyright © 2018年 picolustre. All rights reserved.
//

#import "RootTableViewController.h"
#import "PLToaster.h"

@implementation InputButton

- (BOOL)canBecomeFirstResponder {return YES;}
- (void)insertText:(NSString *)text {}
- (void)deleteBackward {}

@end


@interface RootTableViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIWindow *floatWindow;
@property (nonatomic, strong) UILabel *windowLabel;


@property (weak, nonatomic) IBOutlet UISwitch *switchIsInstant;
@property (weak, nonatomic) IBOutlet UIButton *btnUseImg;
@property (weak, nonatomic) IBOutlet UIButton *btnUseTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnUseSubTitle;

@property (weak, nonatomic) IBOutlet UIButton *btnTop;
@property (weak, nonatomic) IBOutlet UIButton *btnCenter;
@property (weak, nonatomic) IBOutlet UIButton *btnBottom;

@end

@implementation RootTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self makeInital];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self makeInital];
    }
    return self;
}
- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self makeInital];
    }
    return self;
}

- (void)makeInital {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableViewOffset:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)updateTableViewOffset:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect statusBarRect = [UIApplication sharedApplication].statusBarFrame;
        [self.tableView setContentInset:UIEdgeInsetsMake(CGRectGetHeight(statusBarRect), 0, 0, 0)];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect statusBarRect = [UIApplication sharedApplication].statusBarFrame;
    [self.tableView setContentInset:UIEdgeInsetsMake(CGRectGetHeight(statusBarRect), 0, 0, 0)];
    self.tableView.delaysContentTouches = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleInstantAction:(UISwitch *)sender {
    sender.on = !sender.isOn;
}

- (IBAction)toggleUseImgAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)toggleUseTitleAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)toggleUseSubtitleAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)toggleKeyboardAction:(id)sender {
    if ([sender isFirstResponder]) {
        [sender resignFirstResponder];
    } else {
        [sender becomeFirstResponder];
    }
}

- (IBAction)positionAction:(UIButton *)sender {
    NSArray *btns = @[self.btnTop, self.btnCenter, self.btnBottom];
    for (UIButton *button in btns) {
        button.selected = NO;
    }
    sender.selected = YES;
}


- (IBAction)makeToastAction:(id)sender {
    BOOL isInstant = self.switchIsInstant.on;
    BOOL useTitle = self.btnUseTitle.selected;
    BOOL useSubTitle = self.btnUseSubTitle.selected;
    BOOL useIcon = self.btnUseImg.selected;
    
    PLToastPosition position = ({
        PLToastPosition result = PLToastPositionBottom;
        if (self.btnTop.selected) {
            result = PLToastPositionTop;
        } else if(self.btnCenter.selected) {
            result = PLToastPositionCenter;
        } else if(self.btnBottom.selected) {
            result = PLToastPositionBottom;
        }
        result;
    });
    
    PLToastObj *toastObj = [[PLToastObj alloc] init];
    toastObj.iconImg = useIcon ? [UIImage imageNamed:@"toast_icon"] : nil;
    toastObj.toastTitle = useTitle ? [NSString stringWithFormat:@"Toast:%d", arc4random()%100] : nil;
    toastObj.toastDesc = useSubTitle ? [NSString stringWithFormat:@"Toast Description Must Be Long Long Long Long Long Long Long :%d", arc4random()%100] : nil;
    toastObj.position = position;
    if (isInstant) {
        [PLToaster instantToastWithToastObj:toastObj];
    } else {
        [PLToaster queueToastWithToastObj:toastObj];
    }
}
- (IBAction)randomToastAction:(id)sender {
    BOOL isInstant = self.switchIsInstant.on;
    
    BOOL useTitle = arc4random()%2;
    BOOL useSubTitle = arc4random()%2;
    BOOL useIcon = arc4random()%2;
    
    PLToastPosition position = arc4random()%3;
    
    PLToastObj *toastObj = [[PLToastObj alloc] init];
    toastObj.iconImg = useIcon ? [UIImage imageNamed:@"toast_icon"] : nil;
    toastObj.toastTitle = useTitle ? [NSString stringWithFormat:@"Toast:%d", arc4random()%100] : nil;
    toastObj.toastDesc = useSubTitle ? [NSString stringWithFormat:@"Toast Description Must Be Long Long Long Long Long Long Long :%d", arc4random()%100] : nil;
    toastObj.position = position;
    if (isInstant) {
        [PLToaster instantToastWithToastObj:toastObj];
    } else {
        [PLToaster queueToastWithToastObj:toastObj];
    }
}

- (IBAction)toggleFloatWindowAction:(id)sender {
    self.floatWindow.hidden = !self.floatWindow.hidden;
}

#pragma mark - getter
- (UIWindow *)floatWindow {
    if (!_floatWindow) {
        CGRect windowRect = CGRectMake(0, 0, 200, 100);
        UIWindow *floatWindow = [[UIWindow alloc] initWithFrame:windowRect];
        floatWindow.layer.borderWidth = 5.0f;
        floatWindow.layer.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:.5f].CGColor;
        floatWindow.layer.borderColor = [UIColor magentaColor].CGColor;
        floatWindow.windowLevel = 10000000;
        
        self.windowLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 200, 100}];
        self.windowLabel.textAlignment = NSTextAlignmentCenter;
        self.windowLabel.font = [UIFont systemFontOfSize:20.0f];
        self.windowLabel.textColor = [UIColor blackColor];
        self.windowLabel.text = @"Window";
        [floatWindow addSubview:self.windowLabel];
        
        self.windowLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [floatWindow addConstraint:[NSLayoutConstraint constraintWithItem:floatWindow attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.windowLabel attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:CGFLOAT_MIN]];
        [floatWindow addConstraint:[NSLayoutConstraint constraintWithItem:floatWindow attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.windowLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:CGFLOAT_MIN]];
        
        /**
         在屏幕旋转时, Application 会对 Screen 上的所有 UIWindow 进行缩放旋转操作.
         
         旋转中心为 window 中心, 而非 screen 中心
         缩放长宽比例按照 screen 的 width 和 height 缩放而缩放
         
         */
        UIViewController *rootViewCtl = [[UIViewController alloc] init];
        rootViewCtl.view.backgroundColor = [UIColor clearColor];
        floatWindow.rootViewController = rootViewCtl;
        
        _floatWindow = floatWindow;
    }
    return _floatWindow;
}

@end
