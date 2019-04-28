//
//  PLToastConfig.h
//  PLToaster
//
//  Created by sungrow on 2019/4/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
