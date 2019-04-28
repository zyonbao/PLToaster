//
//  PLToastWindow.h
//  PLToaster
//
//  Created by sungrow on 2019/4/28.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN const UIWindowLevel UIWindowLevelToast;

@class PLToastWindow;
@protocol PLToastWindowDelegate<NSObject>

- (void)toastWindow:(PLToastWindow *)window safeAreaInsetsDidChanged:(UIEdgeInsets)safeAreaInsets;

@end
@interface PLToastWindow : UIWindow

@property (nonatomic, weak) id<PLToastWindowDelegate> toastDelegate;

- (UIEdgeInsets)layoutEdgeInsets;

@end
