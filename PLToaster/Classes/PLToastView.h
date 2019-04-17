//
//  PLToastView.h
//  PLToaster
//
//  Created by zyonpaul on 2018/7/11.
//  Copyright © 2018年 picolustre. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 View class for the toast view must implement this protocol.
 If you are using your own view class, the protocol must be implemented.
 */
@class PLToastObj;
@protocol PLToastViewProtocol<NSObject>
@required
- (BOOL)shouldRespond2Touch;
- (void)cofigToastObj:(PLToastObj *)toastObj;
- (CGSize)sizeThatFits:(CGSize)size;

@end


@interface PLToastView : UIView <PLToastViewProtocol>

@end


UIKIT_EXTERN const UIWindowLevel UIWindowLevelToast;

@class PLToastWindow;
@protocol PLToastWindowDelegate<NSObject>

- (void)toastWindow:(PLToastWindow *)window safeAreaInsetsDidChanged:(UIEdgeInsets)safeAreaInsets;

@end
@interface PLToastWindow : UIWindow

@property (nonatomic, weak) id<PLToastWindowDelegate> toastDelegate;

- (UIEdgeInsets)layoutEdgeInsets;

@end

