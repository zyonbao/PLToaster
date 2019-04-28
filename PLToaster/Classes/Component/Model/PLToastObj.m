//
//  PLToastObj.m
//  PLToaster
//
//  Created by zyonpaul on 2018/7/9.
//  Copyright © 2018年 picolustre. All rights reserved.
//

#import "PLToastObj.h"

@implementation PLToastObj

- (instancetype)init {
    if (self = [super init]) {
        _timeInterval = 3.0f;
    }
    return self;
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    if (timeInterval > 0) {
        _timeInterval = timeInterval;
    }
}

+ (instancetype)toastObjWithIcon:(UIImage *)image title:(NSString *)title desc:(NSString *)desc interval:(NSTimeInterval)interval {
    PLToastObj *obj = [[[self class] alloc] init];
    obj.iconImg = image;
    obj.toastTitle = title;
    obj.toastDesc = desc;
    obj.position = PLToastPositionBottom;
    if (obj.timeInterval > 0) {
        obj.timeInterval = interval;
    }
    return obj;
}

+ (instancetype)toastObjWithTitle:(NSString *)title {
    return [[self class] toastObjWithIcon:nil title:title desc:nil interval:0];
}

+ (instancetype)toastObjWithContent:(NSString *)content {
    return [[self class] toastObjWithIcon:nil title:nil desc:content interval:0];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p %lfs %@>", self, self.timeInterval, self.toastTitle];
}

@end
