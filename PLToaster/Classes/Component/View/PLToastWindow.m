//
//  PLToastWindow.m
//  PLToaster
//
//  Created by sungrow on 2019/4/28.
//

#import "PLToastWindow.h"
#import "PLToastViewProtocol.h"

#define __SHOW_WINDOW_BORDER__ 0

const UIWindowLevel UIWindowLevelToast = 100000000;

@interface PLToastWindow()

@end

@implementation PLToastWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self makeInitialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self makeInitialization];
    }
    return self;
}

- (void)makeInitialization {
    UIViewController *rootViewCtl = [UIViewController new];
    [self setRootViewController:rootViewCtl];
    [self setWindowLevel:UIWindowLevelToast];
#pragma mark - window border for debuging
#if __SHOW_WINDOW_BORDER__
    self.layer.borderColor = [UIColor orangeColor].CGColor;
    self.layer.borderWidth = 5.0f;
#endif
    
}

- (UIEdgeInsets)layoutEdgeInsets {
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
    }
    return UIEdgeInsetsMake(MAX(CGRectGetHeight(statusBarFrame), safeAreaInsets.top), safeAreaInsets.left, safeAreaInsets.bottom, safeAreaInsets.right);
}

- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    if (self.toastDelegate && [self.toastDelegate respondsToSelector:@selector(toastWindow:safeAreaInsetsDidChanged:)]) {
        [self.toastDelegate toastWindow:self safeAreaInsetsDidChanged:[self layoutEdgeInsets]];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha < 0.01) {
        return nil;
    }
    if ([self pointInside:point withEvent:event]) {
        for (UIView *subView in [self.subviews reverseObjectEnumerator]) {
            if ([subView isEqual:self.rootViewController.view]) {
                continue;
            }
            if (![subView conformsToProtocol:@protocol(PLToastViewProtocol)]) {
                continue;
            }
            UIView<PLToastViewProtocol> *view = (UIView<PLToastViewProtocol> *)subView;
            if (![view shouldRespond2Touch]) {
                continue;
            }
            CGPoint convertedPoint = [self convertPoint:point toView:subView];
            UIView *hitTestView = [subView hitTest:convertedPoint withEvent:event];
            if (hitTestView) {
                return  hitTestView;
            }
        }
    }
    return nil;
}

#pragma mark - getter
- (UIWindowLevel)windowLevel {
    /// 实验发现, 对 UIWindow 类设置 WindowLevel 时, 系统会将最大值压制在 10,000,000. 但模拟器的键盘的 WindowLevel 却是 10,000,001
    if (TARGET_OS_SIMULATOR) {
        return UIWindowLevelToast;
    } else {
        return [super windowLevel];
    }
}

@end
