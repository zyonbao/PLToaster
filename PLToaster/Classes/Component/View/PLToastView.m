//
//  PLToastView.m
//  PLToaster
//
//  Created by zyonpaul on 2018/7/11.
//  Copyright © 2018年 picolustre. All rights reserved.
//

#import "PLToastView.h"
#import "PLToastObj.h"
#import "PLToaster.h"

@interface PLToastView ()

@property (nonatomic, strong) UIImageView *iconImageV;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) PLToastObj *toastObj;

/// layout message
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGSize titleSize;
@property (nonatomic, assign) CGSize descSize;

@end

@implementation PLToastView

- (instancetype)init {
    if (self = [super init]) {
        [self makeInitialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self makeInitialization];
    }
    return self;
}

- (void)makeInitialization {
    PLToastConfig *config = [PLToastConfig shareConfig];
    self.backgroundColor = config.toastBgColor;
    self.layer.cornerRadius = config.cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)cofigToastObj:(PLToastObj *)toastObj {
    if (_toastObj != toastObj) {
        _toastObj = toastObj;
        // clear and create
        [self clearViews];
        PLToastConfig *config = [PLToastConfig shareConfig];
        if (toastObj.iconImg) {
            _iconImageV = [[UIImageView alloc] init];
            _iconImageV.image = toastObj.iconImg;
            [self addSubview:_iconImageV];
        }
        if (toastObj.toastTitle) {
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.font = config.titleFont;
            _titleLabel.textColor = config.toastTitleColor;
            _titleLabel.text = toastObj.toastTitle;
            [self addSubview:_titleLabel];
        }
        if (toastObj.toastDesc) {
            _descLabel = [[UILabel alloc] init];
            _descLabel.font = config.descFont;
            _descLabel.textColor = config.toastDescColor;
            _descLabel.text = toastObj.toastDesc;
            _descLabel.numberOfLines = 0;
            [self addSubview:_descLabel];
        }
    }
}

- (void)clearViews {
    if (_iconImageV && _iconImageV.superview) {
        [_iconImageV removeFromSuperview];
    }
    if (_descLabel && _descLabel.superview) {
        [_descLabel removeFromSuperview];
    }
    if (_titleLabel && _titleLabel.superview) {
        [_titleLabel removeFromSuperview];
    }
    _iconImageV = nil;
    _descLabel = nil;
    _titleLabel = nil;
}

- (CGSize)sizeThatFits:(CGSize)size {
    PLToastConfig *config = [PLToastConfig shareConfig];
    PLToastObj *obj = self.toastObj;
    
    CGSize contentSize = CGSizeZero;
    
    CGFloat padding  = 4.0f;
    
    CGSize imageSize = CGSizeZero;
    CGSize descSize = CGSizeZero;
    CGSize titleSize = CGSizeZero;
    
    if(obj.iconImg) {
        if (CGSizeEqualToSize(CGSizeZero, config.imgSize)) {
            imageSize = obj.iconImg.size;
        } else {
            imageSize = config.imgSize;
        }
    }
    
    CGSize maxSize = size;
    
    if (obj.iconImg) {
        maxSize = CGSizeMake(maxSize.width-imageSize.width-padding, size.height);
    }
    
    if (obj.toastTitle) {
        titleSize = [self.toastObj.toastTitle boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size;
    }
    if (obj.toastDesc) {
        descSize = [self.toastObj.toastDesc boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.descLabel.font} context:nil].size;
    }
    
    CGFloat rightWidth = MAX(titleSize.width, descSize.width);
    CGFloat rightHeight = CGFLOAT_MIN;
    
    self.imageSize = imageSize;
    self.titleSize = titleSize;
    self.descSize = descSize;
    
    if (obj.toastTitle && obj.toastDesc) {
        rightHeight = titleSize.height + padding + descSize.height;
    } else if (obj.toastTitle && !obj.toastDesc) {
        rightHeight = titleSize.height;
    } else if (!obj.toastTitle && obj.toastDesc) {
        rightHeight = descSize.height;
    }
    
    CGFloat contentWidth = CGFLOAT_MIN;
    CGFloat contentHeight = MAX(imageSize.height, rightHeight);
    
    if (imageSize.width > 0.01 && rightWidth > 0.01) {
        contentWidth = imageSize.width + padding + rightWidth;
    } else {
        contentWidth = MAX(imageSize.width, rightWidth);
    }
    contentSize = CGSizeMake(contentWidth, contentHeight);
    
    return CGSizeMake(contentSize.width+config.contentEdgeInsets.left+config.contentEdgeInsets.right, contentSize.height+config.contentEdgeInsets.top+config.contentEdgeInsets.bottom);
}

- (void)layoutSubviews {
    CGRect superRect = self.bounds;
    PLToastConfig *config = [PLToastConfig shareConfig];
    PLToastObj *obj = self.toastObj;
    CGFloat padding  = 4.0f;
    
    CGFloat leftX = config.contentEdgeInsets.left;
    
    if (obj.iconImg) {
        CGRect imgFrame = (CGRect){{leftX, (CGRectGetHeight(superRect)-self.imageSize.height)/2.0f}, self.imageSize};
        [self.iconImageV setFrame:imgFrame];
        leftX = CGRectGetMaxX(imgFrame) + padding;
    }
    
    if (obj.toastTitle && obj.toastDesc) {
        CGRect titleFrame = (CGRect){{leftX, config.contentEdgeInsets.top}, self.titleSize};
        CGRect descFrame = (CGRect){{leftX,CGRectGetMaxY(titleFrame)+padding}, self.descSize};
        [self.titleLabel setFrame:titleFrame];
        [self.descLabel setFrame:descFrame];
    } else {
        UILabel *label = nil;
        CGRect textFrame = CGRectZero;
        if (obj.toastTitle) {
            label = self.titleLabel;
            textFrame = (CGRect){{leftX, (CGRectGetHeight(superRect)-self.titleSize.height)/2.0f},self.titleSize};
        } else if (obj.toastDesc){
            label = self.descLabel;
            textFrame = (CGRect){{leftX, (CGRectGetHeight(superRect)-self.descSize.height)/2.0f},self.descSize};
        }
        if (label) {
            [label setFrame:textFrame];
        }
    }
}

- (BOOL)shouldRespond2Touch {
    if (self.toastObj.clickHandler) {
        return YES;
    }
    return NO;
}

@end
