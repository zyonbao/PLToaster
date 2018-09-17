//
//  RootTableViewController.h
//  PLToaster
//
//  Created by sungrow on 2018/7/12.
//  Copyright © 2018年 鲍泽健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputButton:UIButton <UIKeyInput>

@property (nonatomic, assign, readonly) BOOL canBecomeFirstResponder;
@property (nonatomic, assign) BOOL hasText;

@end

@interface RootTableViewController : UITableViewController

@end
