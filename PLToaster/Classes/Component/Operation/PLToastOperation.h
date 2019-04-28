//
//  PLToastOperation.h
//  PLToaster
//
//  Created by sungrow on 2019/4/28.
//

#import <Foundation/Foundation.h>
#import "PLToastObj.h"

@class PLToastOperation;
@protocol PLToastOperationDelegate<NSObject>
@required
- (void)toastOperation:(PLToastOperation *)operation afterStartWithObj:(PLToastObj *)toastObj completion:(void(^)(void))completeHandler;
- (void)toastOperation:(PLToastOperation *)operation beforeFinishWithObj:(PLToastObj *)toastObj completion:(void(^)(void))completeHandler;
- (void)toastOperation:(PLToastOperation *)operation beforeUnexecutionFinishWithObj:(PLToastObj *)toastObj completion:(void(^)(void))completeHandler;

@end

@interface PLToastOperation : NSOperation

@property (nonatomic, strong, readonly) PLToastObj *toastObj;

- (void)finishOperation;
- (void)cancelOperation;
+ (instancetype)operation4ToastObj:(PLToastObj *)toastObj delegate:(id<PLToastOperationDelegate>) delegate;

@end
