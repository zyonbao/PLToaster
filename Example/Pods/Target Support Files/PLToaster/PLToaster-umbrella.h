#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "PLToast.h"
#import "PLToaster.h"
#import "PLToastObj.h"
#import "PLToastView.h"

FOUNDATION_EXPORT double PLToasterVersionNumber;
FOUNDATION_EXPORT const unsigned char PLToasterVersionString[];

