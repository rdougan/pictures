//
//  LoginViewController.h
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@protocol LoginViewControllerDelegate <NSObject>

@required
- (void)loginViewController:(LoginViewController *)viewController didLoginWithUsername:(NSString *)username password:(NSString *)password;
- (void)loginViewControllerDidCancel:(LoginViewController *)viewController;

@end

@interface LoginViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) id <LoginViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, assign) BOOL loading;

@end
