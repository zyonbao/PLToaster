//
//  PLToastObj.h
//  PLToaster
//
//  Created by sungrow on 2018/7/9.
//  Copyright © 2018年 sungrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PLToastPosition) {
    PLToastPositionBottom = 0,
    PLToastPositionTop,
    PLToastPositionCenter
};

@interface PLToastObj : NSObject

/**
 The icon image for the toast
 */
@property (nonatomic, strong) UIImage *iconImg;

/**
 The title for the toast
 */
@property (nonatomic, copy) NSString *toastTitle;

/**
 The description subtitle for the toast
 */
@property (nonatomic, copy) NSString *toastDesc;

/**
 The time interval for the toast on screen lasts
 */
@property (nonatomic, assign) NSTimeInterval timeInterval;

/**
 The position toast shows on screen
 */
@property (nonatomic, assign) PLToastPosition position;

/**
 The callback when the toast view clicked.
 The return value of the block indicates that whether should toast view should been removed from screen
 */
@property (nonatomic, copy) BOOL (^clickHandler)(id sender);

/**
 The callback when the toast showing ended.
 */
@property (nonatomic, copy) void (^completeHandler)(id sender);

/**
 Other Attributes if you need handle in your custom toast view class.
 Default implemetation does not use this property.
 */
@property (nonatomic, strong) NSDictionary *otherAttributes;

/// Class Methods
+ (instancetype)toastObjWithIcon:(UIImage *)image title:(NSString *)title desc:(NSString *)desc interval:(NSTimeInterval)interval;
+ (instancetype)toastObjWithTitle:(NSString *)desc;
+ (instancetype)toastObjWithContent:(NSString *)content;

@end
