//
//  SubscribedViewController.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChooseSubredditTableViewController.h"
#import "LoginViewController.h"

@interface SubscribedViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, ChooseSubredditTableViewControllerDelegate, LoginViewControllerDelegate>



@end
