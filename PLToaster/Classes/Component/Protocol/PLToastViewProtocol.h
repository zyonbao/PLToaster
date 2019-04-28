//
//  PLToastViewProtocol.h
//  PLToaster
//
//  Created by sungrow on 2019/4/28.
//

#import <Foundation/Foundation.h>
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
