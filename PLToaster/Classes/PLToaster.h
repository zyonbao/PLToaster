//
//  PLToaster.h
//  PLToaster
//
//  Created by zyonpaul on 2018/7/9.
//  Copyright © 2018年 picolustre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - shortcut functions in C
typedef NS_ENUM(NSInteger, PLToastPosition);
void PLMakeInstantToast(NSString *toastMsg);
void PLMakeToast(NSString *toastMsg, BOOL isInstant, PLToastPosition position);

@class PLToastObj;
@protocol PLToastViewProtocol;
@interface PLToaster: NSObject

/**
 Set the maximum task count of the task queue
 
 @param maxCount the maximum count tasks waiting in the queue
 */
+ (void)configMaxToastCountInQueue:(NSInteger)maxCount;

/**
 config the customize toastView for the Toasts

 @param viewClass ToastViewClass
 */
+ (void)configToastViewClass:(Class<PLToastViewProtocol>)viewClass;

/**
 Add a toast task to the task queue
 
 @param toastIcon icon
 @param title title
 @param toastMsg message
 @param interval showtime interval
 @param completeHandler completeHandler
 @return whether added succeed
 */
+ (BOOL)queueToastWithIcon:(UIImage *)toastIcon
                     title:(NSString *)title
                       msg:(NSString *)toastMsg
                  interval:(NSTimeInterval)interval
                  complete:(void (^)(id sender))completeHandler;

/**
 Cancel all the task in the queue and add a new task
 
 @param toastIcon toastIcon
 @param title toastTitle
 @param toastMsg toast message
 @param interval toast showtime interval
 @param completeHandler completeHandler
 @return whether added succeed
 */
+ (BOOL)instantToastWithIcon:(UIImage *)toastIcon
                       title:(NSString *)title
                         msg:(NSString *)toastMsg
                    interval:(NSTimeInterval)interval
                    complete:(void (^)(id sender))completeHandler;

/**
 Add a toast task to the task queue with the toast object

 @param toastObj toast object
 @return whether added succeed
 */
+ (BOOL)queueToastWithToastObj:(PLToastObj *)toastObj;

/**
 Cancel all the task in the queue and add a new task with the toast object

 @param toastObj toast object
 @return whether added succeed
 */
+ (BOOL)instantToastWithToastObj:(PLToastObj *)toastObj;

@end


@interface PLToastConfig : NSObject

/// Toast view background color
@property (nonatomic, strong) UIColor *toastBgColor;
/// Toast view title color
@property (nonatomic, strong) UIColor *toastTitleColor;
/// Toast view subtitle color
@property (nonatomic, strong) UIColor *toastDescColor;
/// Toast view title font
@property (nonatomic, strong) UIFont *titleFont;
/// Toast view subtitle font
@property (nonatomic, strong) UIFont *descFont;
/// Toast view icon size, default is {0, 0}, means the image size
@property (nonatomic, assign) CGSize imgSize;
/// Toast view conrner radius, default is 5.0f
@property (nonatomic, assign) CGFloat cornerRadius;
/// Toast view content edgeInsets {5, 5, 5, 5}
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;
/// The minimum margin to the window's edge. Default is {20, 16, 20, 16}
@property (nonatomic, assign) UIEdgeInsets minMarginInsets;

+ (instancetype)shareConfig;

@end

