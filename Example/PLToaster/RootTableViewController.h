//
//  RootTableViewController.h
//  PLToaster
//
//  Created by zyonpaul on 2018/7/12.
//  Copyright © 2018年 picolustre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputButton:UIButton <UIKeyInput>

@property (nonatomic, assign, readonly) BOOL canBecomeFirstResponder;
@property (nonatomic, assign) BOOL hasText;

@end

@interface RootTableViewController : UITableViewController

@end
