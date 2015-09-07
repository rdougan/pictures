//
//  LoginViewController.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *loginButton;

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationItem setTitleView:self.loadingIndicator];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.usernameField becomeFirstResponder];
}

- (void)setLoading:(BOOL)loading
{
    if (loading != _loading) {
        _loading = loading;
        
        [self.usernameField setEnabled:!loading];
        [self.passwordField setEnabled:!loading];
        [self.loginButton setEnabled:!loading];
        
        if (loading) {
            [self.loadingIndicator startAnimating];
        }
        else {
            [self.loadingIndicator stopAnimating];
        }
    }
}

- (UIActivityIndicatorView *)loadingIndicator
{
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44.0f, 44.0f)];
        _loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _loadingIndicator.color = [UIColor blackColor];
    }
    
    return _loadingIndicator;
}

- (IBAction)login:(id)sender
{
    if (self.delegate != nil) {
        [self.delegate loginViewController:self didLoginWithUsername:self.usernameField.text password:self.passwordField.text];
    }
}

- (IBAction)cancel:(id)sender
{
    if (self.delegate != nil) {
        [self.delegate loginViewControllerDidCancel:self];
    }
}

- (IBAction)textDidChange:(id)sender
{
    if (self.usernameField.text != nil && ![self.usernameField.text isEqualToString:@""] && self.passwordField.text != nil && ![self.passwordField.text isEqualToString:@""]) {
        [self.loginButton setEnabled:YES];
    }
    else {
        [self.loginButton setEnabled:NO];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self textDidChange:nil];
    
    if (self.loginButton.enabled) {
        [self login:nil];
    }
    
    return YES;
}

@end
