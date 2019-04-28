//
//  PLToastOperation.m
//  PLToaster
//
//  Created by sungrow on 2019/4/28.
//

#import "PLToastOperation.h"

@interface PLToastOperation ()

@property (nonatomic, strong, readwrite) PLToastObj *toastObj;

@property (nonatomic, weak) id<PLToastOperationDelegate> delegate;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PLToastOperation
@synthesize finished = _finished;
@synthesize executing = _executing;

+ (instancetype)operation4ToastObj:(PLToastObj *)toastObj delegate:(id<PLToastOperationDelegate>) delegate{
    PLToastOperation *operation = [[[self class] alloc] init];
    operation.toastObj = toastObj;
    operation.delegate = delegate;
    return  operation;
}

- (void)start {
    BOOL isRunnable = !self.isFinished && !self.isCancelled && !self.isExecuting && self.isReady;
    if (!isRunnable) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(toastOperation:beforeUnexecutionFinishWithObj:completion:)]) {
            [self.delegate toastOperation:self beforeUnexecutionFinishWithObj:self.toastObj completion:^{
                [self configIsFinished:YES];
            }];
        } else {
            [self configIsFinished:YES];
        }
    } else {
        [self main];
    }
}

- (void)main {
    [self configIsExecuting:YES];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(toastOperation:afterStartWithObj:completion:)]) {
        [self.delegate toastOperation:self afterStartWithObj:self.toastObj completion:^{
            NSTimeInterval timeInterval = self.toastObj.timeInterval;
            [self startTimerWithInterval:timeInterval];
        }];
    } else {
        [self configIsFinished:NO];
        [self configIsFinished:YES];
    }
}

- (void)finishOperation {
    [self stopTimer];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(toastOperation:beforeFinishWithObj:completion:)]) {
        [self.delegate toastOperation:self beforeFinishWithObj:self.toastObj completion:^{
            [self configIsExecuting:NO];
            [self configIsFinished:YES];
        }];
    } else {
        [self configIsExecuting:NO];
        [self configIsFinished:YES];
    }
}

- (void)cancelOperation {
    [self cancel];
}

- (void)cancel {
    if ([self isExecuting]) {
        [super cancel];
        [self stopTimer];
        
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(toastOperation:beforeFinishWithObj:completion:)]) {
            [self.delegate toastOperation:self beforeFinishWithObj:self.toastObj completion:^{
                [self configIsExecuting:NO];
                [self configIsFinished:YES];
            }];
        } else {
            [self configIsExecuting:NO];
            [self configIsFinished:YES];
        }
    } else {
        [super cancel];
        [self stopTimer];
    }
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)configIsExecuting:(BOOL)isExecuting {
    if (_executing != isExecuting) {
        [super willChangeValueForKey:@"isExecuting"];
        _executing = isExecuting;
        [super didChangeValueForKey:@"isExecuting"];
    }
}

- (void)configIsFinished:(BOOL)isFinished {
    if (_finished != isFinished) {
        [super willChangeValueForKey:@"isFinished"];
        _finished = isFinished;
        [super didChangeValueForKey:@"isFinished"];
    }
}

- (void)startTimerWithInterval:(NSTimeInterval)interval {
    self.timer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerFired:(id)sender {
    [self finishOperation];
}

@end
