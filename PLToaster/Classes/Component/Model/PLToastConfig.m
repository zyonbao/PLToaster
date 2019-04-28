//
//  PLToastConfig.m
//  PLToaster
//
//  Created by sungrow on 2019/4/28.
//

#import "PLToastConfig.h"

@implementation PLToastConfig

- (instancetype)init {
    if (self = [super init]) {
        self.toastBgColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
        self.toastTitleColor = [UIColor whiteColor];
        self.toastDescColor = [UIColor whiteColor];
        self.titleFont = [UIFont systemFontOfSize:15.0f];
        self.descFont = [UIFont systemFontOfSize:12.0f];
        self.imgSize = CGSizeZero;
        self.cornerRadius = 5.0f;
        self.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        self.minMarginInsets = UIEdgeInsetsMake(20, 16, 20, 16);
    }
    return self;
}

+ (instancetype)shareConfig {
    static PLToastConfig *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PLToastConfig alloc] init];
    });
    return _instance;
}

@end

