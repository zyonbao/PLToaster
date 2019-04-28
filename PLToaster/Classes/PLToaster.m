//
//  PLToaster.m
//  PLToaster
//
//  Created by zyonpaul on 2018/7/9.
//  Copyright © 2018年 picolustre. All rights reserved.
//

#import "PLToaster.h"
#import "PLToastWindow.h"
#import "PLToastOperation.h"
#import <objc/runtime.h>

#define __SHOW_LAYOUT_BORDER__ 0

#pragma mark - shortcut functions in C
void PLMakeInstantToast(NSString *toastMsg) {
    PLMakeToast(toastMsg, YES, PLToastPositionBottom);
}

void PLMakeToast(NSString *toastMsg, BOOL isInstant, PLToastPosition position) {
    PLToastObj *toastObject = [PLToastObj toastObjWithTitle:toastMsg];
    toastObject.position = position;
    if (isInstant) {
        [PLToaster instantToastWithToastObj:toastObject];
    } else {
        [PLToaster queueToastWithToastObj:toastObject];
    }
}

/**
 PLToaster
 */
@interface PLToaster ()<PLToastOperationDelegate, PLToastWindowDelegate>

@property (nonatomic, strong) PLToastWindow *toastWindow;
@property (nonatomic, strong) NSOperationQueue *toastQueue;

@property (nonatomic, strong) UIView<PLToastViewProtocol> *toastView;
@property (nonatomic, assign) NSUInteger maxTaskCount;

@property (nonatomic, assign) Class<PLToastViewProtocol> viewClass;
/// the operation currently in handling
@property (nonatomic, weak) PLToastOperation *handlingOperation;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) UIView *layoutRectView;

@end

@implementation PLToaster

static id _sharedToaster = nil;

+ (void)configToastViewClass:(Class<PLToastViewProtocol>)viewClass {
    PLToaster *toaster = [PLToaster toaster];
    if (![toaster.viewClass isEqual:viewClass]) {
        toaster.viewClass = viewClass;
    }
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    @synchronized(self) {
        if (!_sharedToaster) {
            _sharedToaster = [super allocWithZone:zone];
        }
    }
    return _sharedToaster;
}

- (id)copyWithZone:(NSZone *)zone {
    return _sharedToaster;
}

+ (instancetype)toaster {
    @synchronized(self) {
        if (!_sharedToaster) {
            _sharedToaster = [[[self class] alloc] init];
        }
    }
    return _sharedToaster;
}

- (instancetype)init {
    if (self = [super init]) {
        [self makeInitialization];
    }
    return self;
}

- (void)dealloc {
    [self removeNotificationObservers];
}

- (void)makeInitialization {
    CGRect toastWindowFrame = [[UIScreen mainScreen] bounds];
    self.toastWindow = [[PLToastWindow alloc] initWithFrame:toastWindowFrame];
    self.toastWindow.toastDelegate = self;
    self.toastWindow.backgroundColor = [UIColor clearColor];
#if __SHOW_LAYOUT_BORDER__
    UIView *redView = [[UIView alloc] init];
    redView.backgroundColor = [UIColor clearColor];
    redView.layer.borderColor = [UIColor redColor].CGColor;
    redView.layer.borderWidth = 5.0f;
    [self.toastWindow addSubview:redView];
    self.layoutRectView = redView;
#endif
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTappedOnToastView:)];
    
    NSOperationQueue *toastQueue = [[NSOperationQueue alloc] init];
    toastQueue.maxConcurrentOperationCount = 1;
    self.toastQueue = toastQueue;
    self.maxTaskCount = 10;
    self.viewClass = [PLToastView class];
    [self setupNotificationObserver];
}

#pragma mark - TapRecognizer Action
- (void)didTappedOnToastView:(id)sender {
    if (self.handlingOperation && self.handlingOperation.toastObj) {
        BOOL remove = self.handlingOperation.toastObj.clickHandler(self.handlingOperation.toastObj);
        if (remove) {
            [self.handlingOperation finishOperation];
        }
    }
}

- (void)setupNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toastWindowRefresh:) name:UIWindowDidBecomeVisibleNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameChanged:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeVisibleNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

#pragma mark - Notification Events
/**
 由于在键盘弹起的时候, 系统的 RemoteKeyboardWindow 的 windowLevel 同样是最高的 windowLevel.
 而相同 windowLevel 的展示层级与设置 hidden 的顺序呈正相关. 因此这里设置一下 hidden. 让当前 window 展示在键盘之前
 */
- (void)toastWindowRefresh:(NSNotification *)notification {
    id object = notification.object;
    if (object && object == self.toastWindow) {
        return;
    }
    if ([(UIWindow *)object windowLevel] <= UIWindowLevelStatusBar) {
        return;
    }
    if (self.toastQueue && [self.toastQueue operationCount] > 0) {
        if (self.toastWindow && !self.toastWindow.hidden) {
            self.toastWindow.hidden = YES;
            self.toastWindow.hidden = NO;
        }
    }
}

- (void)statusBarDidChange:(NSNotification *)notification {
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self handleRotate:currentOrientation];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self handleRotate:currentOrientation];
}

- (void)asyncInMain4Block:(void (^)(void))handler {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler();
        });
}

- (void)statusBarFrameChanged:(NSNotification *)notification {
    if (self.toastWindow) {
        [self asyncInMain4Block:^{
            if (self.toastQueue && self.toastQueue.operationCount > 0 ) {
                [self layoutToastView];
            }
        }];
    }
}

- (void)handleRotate:(UIInterfaceOrientation)orientation {
    if (self.toastWindow) {
        [self asyncInMain4Block:^{
            if (self.toastQueue && self.toastQueue.operationCount > 0 ) {
                [self layoutToastView];
            }
        }];
    }
}

- (void)toastWindow:(PLToastWindow *)window safeAreaInsetsDidChanged:(UIEdgeInsets)safeAreaInsets{
    if (self.toastWindow) {
        [self asyncInMain4Block:^{
            if (self.toastQueue && self.toastQueue.operationCount > 0 ) {
                [self layoutToastView];
            }
        }];
    }
}

- (void)layoutToastView {
    UIEdgeInsets safeInsets = self.toastWindow.layoutEdgeInsets;
    UIEdgeInsets marginInsets = [[PLToastConfig shareConfig] minMarginInsets];
    
    CGPoint innerOrigin = (CGPoint){safeInsets.left+marginInsets.left, safeInsets.top+marginInsets.top};
    CGSize innerSize = (CGSize){
        CGRectGetWidth(self.toastWindow.frame)-safeInsets.left-marginInsets.left-safeInsets.right-marginInsets.right,
        CGRectGetHeight(self.toastWindow.frame)-safeInsets.top-safeInsets.bottom-marginInsets.top-safeInsets.bottom-marginInsets.bottom
    };
    CGRect innerRect = (CGRect){innerOrigin, innerSize};
    
#if __SHOW_LAYOUT_BORDER__
    self.layoutRectView.frame = innerRect;
#endif
    
    CGSize toastSize = [self.toastView sizeThatFits:innerRect.size];
    
    CGRect resultRect = CGRectZero;
    resultRect.origin.x = CGRectGetMinX(innerRect) + (CGRectGetWidth(innerRect)-toastSize.width)/2;
    PLToastPosition position = PLToastPositionBottom;
    if (self.handlingOperation && self.handlingOperation.toastObj) {
        position = self.handlingOperation.toastObj.position;
    }
    switch (position) {
        case PLToastPositionTop:{
            resultRect.origin.y = CGRectGetMinY(innerRect);
        } break;
        case PLToastPositionCenter:{
            resultRect.origin.y = CGRectGetMidY(innerRect) - toastSize.height/2.0f;
        } break;
        default:{
            resultRect.origin.y = CGRectGetMaxY(innerRect) - toastSize.height;
        } break;
    }
    
    resultRect.size = toastSize;
    [self.toastView setFrame:resultRect];
}

#pragma mark - public class Methods

+ (void)configMaxToastCountInQueue:(NSInteger)maxCount {
    PLToaster *toaster = [PLToaster toaster];
    toaster.maxTaskCount = maxCount;
}

+ (BOOL)queueToastWithIcon:(UIImage *)toastIcon
                     title:(NSString *)title
                       msg:(NSString *)toastMsg
                  interval:(NSTimeInterval)interval
                  complete:(void (^)(id sender))completeHandler {
    PLToastObj *toastObj  = [PLToastObj toastObjWithIcon:toastIcon title:title desc:toastMsg interval:interval];
    toastObj.completeHandler = completeHandler;
    PLToaster *toaster = [PLToaster toaster];
    return [toaster addToastTask4ToastObject:toastObj];
}

+ (BOOL)instantToastWithIcon:(UIImage *)toastIcon
                       title:(NSString *)title
                         msg:(NSString *)toastMsg
                    interval:(NSTimeInterval)interval
                    complete:(void (^)(id sender))completeHandler {
    PLToaster *toaster = [PLToaster toaster];
    for (PLToastOperation *operation in toaster.toastQueue.operations) {
        [operation cancelOperation];
    }
    PLToastObj *toastObj  = [PLToastObj toastObjWithIcon:toastIcon title:title desc:toastMsg interval:interval];
    return [toaster addToastTask4ToastObject:toastObj];
}

+ (BOOL)queueToastWithToastObj:(PLToastObj *)toastObj {
    PLToaster *toaster = [PLToaster toaster];
    return [toaster addToastTask4ToastObject:toastObj];
}

+ (BOOL)instantToastWithToastObj:(PLToastObj *)toastObj {
    PLToaster *toaster = [PLToaster toaster];
    for (PLToastOperation *operation in toaster.toastQueue.operations) {
        [operation cancelOperation];
    }
    return [toaster addToastTask4ToastObject:toastObj];
}

- (BOOL)addToastTask4ToastObject:(PLToastObj *)object {
    PLToastOperation *toastOperation = [PLToastOperation operation4ToastObj:object delegate:self];
    if ([self.toastQueue operations].count < self.maxTaskCount) {
        [self.toastQueue addOperation:toastOperation];
        return YES;
    } else {
        if (toastOperation.toastObj && toastOperation.toastObj.completeHandler) {
            toastOperation.toastObj.completeHandler(toastOperation.toastObj);
        }
        return NO;
    }
}

#pragma mark - PLToasterDelegate
- (void)toastOperation:(PLToastOperation *)operation afterStartWithObj:(PLToastObj *)toastObj completion:(void(^)(void))completeHandler {
    self.handlingOperation = operation;
    
    UIWindow *currentWindow = [self toastWindow];
    if (!currentWindow) {
        [operation finishOperation];
        return;
    }
    [self asyncInMain4Block:^{
        if (currentWindow.hidden) {
            currentWindow.hidden = NO;
        }
        Class viewClass = self.viewClass;
        NSAssert(ClassIsInherited(viewClass, [UIView class]), @"Custimize Class Must Inherit From UIView");
        if (!self.toastView || ![self.toastView isKindOfClass:viewClass]) {
            self.toastView = nil;
            id toastView = [[viewClass alloc] init];
            self.toastView = toastView;
        }
        [self.toastView cofigToastObj:toastObj];
        if (self.tapRecognizer && (self.tapRecognizer.view != self.toastView)) {
            [self.toastView addGestureRecognizer:self.tapRecognizer];
        }
        [currentWindow addSubview:self.toastView];
        [self layoutToastView];
        
        self.toastView.alpha = CGFLOAT_MIN;
        [UIView animateWithDuration:.25f animations:^{
            self.toastView.alpha = 1.001f;
        } completion:^(BOOL finished) {
            if (finished) {
                if (completeHandler) {
                    completeHandler();
                }
            }
        }];
    }];
}

BOOL ClassIsInherited(Class subClass, Class superClass) {
    Class classA = subClass;
    Class classB = superClass;
    while(1)
    {
        if(classA == classB) return YES;
        id superClass = class_getSuperclass(classA);
        if(classA == superClass) return (superClass == classB);
        classA = superClass;
    }
}

- (void)toastOperation:(PLToastOperation *)operation beforeFinishWithObj:(PLToastObj *)toastObj completion:(void(^)(void))completeHandler {
    BOOL shouldHidWindow = NO;
    if ([self.toastQueue operations].count <= 1) {
        shouldHidWindow = YES;
    }
    [self asyncInMain4Block:^{
        if (self.toastView){
            [UIView animateWithDuration:.25f animations:^{
                self.toastView.alpha = CGFLOAT_MIN;
            } completion:^(BOOL finished) {
                if (finished) {
                    [self.toastView cofigToastObj:nil];
                    if(self.toastView.superview) {
                        [self.toastView removeFromSuperview];
                    }
                    if (shouldHidWindow) {
                        self.toastWindow.hidden = YES;
                    }
                    if (toastObj && toastObj.completeHandler) {
                        toastObj.completeHandler(toastObj);
                    }
                    if (completeHandler) {
                        completeHandler();
                    }
                }
            }];
        } else {
            if (shouldHidWindow) {
                self.toastWindow.hidden = YES;
            }
            if (toastObj && toastObj.completeHandler) {
                toastObj.completeHandler(toastObj);
            }
            if (completeHandler) {
                completeHandler();
            }
        }
        
        
    }];
}

- (void)toastOperation:(PLToastOperation *)operation beforeUnexecutionFinishWithObj:(PLToastObj *)toastObj completion:(void(^)(void))completeHandler {
    if (toastObj && toastObj.completeHandler) {
        toastObj.completeHandler(toastObj);
    }
    if (completeHandler) {
        completeHandler();
    }
}
@end
