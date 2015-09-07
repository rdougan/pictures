//
//  SubscribedViewController.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 04/09/15.
//  Copyright (c) 2015 Robert Dougan. All rights reserved.
//

#import "SubscribedViewController.h"

#import <RedditKit/RedditKit.h>
#import <SSKeyChain/SSKeyChain.h>

#import "Helper.h"
#import "SubredditListTableViewController.h"
#import "SubredditTableViewCell.h"

@interface SubscribedViewController ()

@property (nonatomic, strong) NSArray *subreddits;
@property (nonatomic, assign) BOOL pauseReloadData;

@end

@implementation SubscribedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SubredditTableViewCell" bundle:nil] forCellReuseIdentifier:@"SubredditCell"];
    
    self.title = nil;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Pictures for Reddit";
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    BOOL existing = NO;
    
    NSArray *accounts = [SSKeychain accountsForService:@"RedditAccount"];
    if (accounts != nil && accounts.count > 0) {
        NSDictionary *account = [accounts firstObject];
        NSString *username = [account objectForKey:@"acct"];
        NSString *password = [SSKeychain passwordForService:@"RedditAccount" account:username];
        
        if (username != nil && password != nil) {
            existing = YES;
            
            [[RKClient sharedClient] signInWithUsername:username password:password completion:^(NSError *error) {
                if (error != nil) {
                    [self signout];
                }
                else {
                    [self loadUserSubredditsWithCallback:nil];
                }
            }];
        }
    }
    
    self.refreshControl.enabled = existing;
    
    if (existing) {
        [RKClient sharedClient].modhash = @"a";
        [RKClient sharedClient].sessionIdentifier = @"a";
    }
    
    [self loadDefaultSubreddits];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self performSelector:@selector(deselectRows) withObject:nil afterDelay:0.5f];
}

- (void)deselectRows
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)loadUserSubredditsWithCallback:(void (^)(NSArray *subreddits))callback
{
    [[RKClient sharedClient] subscribedSubredditsWithCompletion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
        self.subreddits = collection;
        
        if (callback != nil) {
            callback(collection);
        }
    }];
}

- (void)loadDefaultSubreddits
{
    NSArray *existingSubreddits = [[NSUserDefaults standardUserDefaults] objectForKey:@"subreddits"];
    if (existingSubreddits == nil || existingSubreddits.count == 0) {
        existingSubreddits = @[
                               @{ @"name": @"All", @"URL": @"r/all" },
                               @{ @"name": @"Pics", @"URL": @"r/pics" },
                               @{ @"name": @"funny", @"URL": @"r/funny" },
                               @{ @"name": @"AdviceAnimals", @"URL": @"r/adviceanimals" }
                               ];
    }
    
    NSMutableArray *subreddits = [NSMutableArray array];
    
    [existingSubreddits enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RKSubreddit *subreddit = [[RKSubreddit alloc] initWithDictionary:@{
                                                                           @"name": [obj valueForKey:@"name"],
                                                                           @"URL": [obj valueForKey:@"URL"]
                                                                           } error:nil];
        [subreddits addObject:subreddit];
    }];
    
    self.subreddits = subreddits;
}

- (void)setSubreddits:(NSArray *)subreddits
{
    _subreddits = subreddits;
    
    if (!self.pauseReloadData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    
    NSMutableArray *subredditNames = [NSMutableArray array];
    [_subreddits enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RKSubreddit *subreddit = obj;
        
        [subredditNames addObject:@{
                                    @"name": subreddit.name,
                                    @"URL": subreddit.URL
                                    }];
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:subredditNames forKey:@"subreddits"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)addSubreddit:(id)sender
{
    UINavigationController *nc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChooseSubredditNavigationController"];
    
    ChooseSubredditTableViewController *vc = (ChooseSubredditTableViewController *)[nc topViewController];
    vc.delegate = self;
    
    [self.navigationController presentViewController:nc animated:YES completion:nil];
    
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@"Add a subreddit", @"Add a multireddit", @"Add a user", nil];
//    [sheet showInView:self.view];
}

- (IBAction)didRefresh:(id)sender
{
    [self loadUserSubredditsWithCallback:^(NSArray *subreddits) {
        [self.refreshControl endRefreshing];
    }];
}

- (void)signout
{
    NSArray *accounts = [SSKeychain accountsForService:@"RedditAccount"];
    if (accounts != nil && accounts.count > 0) {
        NSDictionary *account = [accounts firstObject];
        NSString *username = [account objectForKey:@"acct"];
        
        [SSKeychain deletePasswordForService:@"RedditAccount" account:username];
    }
    
    [[RKClient sharedClient] signOut];
    
    self.refreshControl.enabled = NO;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subreddits" message:@"Do you want to keep your subreddits?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)deleteSubredditAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    NSMutableArray *subreddits = [NSMutableArray arrayWithArray:self.subreddits];
    [subreddits removeObjectAtIndex:indexPath.row];
    
    self.pauseReloadData = YES;
    self.subreddits = subreddits;
    self.pauseReloadData = NO;
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
}

- (void)viewSubreddit:(RKSubreddit *)subreddit
{
    SubredditListTableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SubredditListTableViewController"];
    vc.subreddit = subreddit;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.subreddits != nil) {
            return [self.subreddits count];
        }
    }
    else if (section == 1) {
        return [[RKClient sharedClient] isSignedIn] ? 1 : 1;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60.0f;
    }
    
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        SubredditTableViewCell *subredditCell = (SubredditTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SubredditCell"];
        RKSubreddit *subreddit = [self.subreddits objectAtIndex:indexPath.row];
        
        [subredditCell configureWithSubreddit:subreddit];
        
        cell = subredditCell;
    }
    else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        NSString *text = @"Login";
        if ([[RKClient sharedClient] isSignedIn]) {
            text = @"Sign out";
        }
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
        [title appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:@{
                                                                                                     NSForegroundColorAttributeName: [UIColor blackColor],
                                                                                                     NSFontAttributeName: [UIFont systemFontOfSize:15.0f]
                                                                                                     }]];
        
        cell.textLabel.attributedText = title;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        RKSubreddit *subreddit = [self.subreddits objectAtIndex:indexPath.row];
        
        [self viewSubreddit:subreddit];
    }
    else if (indexPath.section == 1) {
        if ([[RKClient sharedClient] isSignedIn]) {
            [self signout];
        }
        else {
            UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavigationViewController"];
            LoginViewController *loginViewController = (LoginViewController *)vc.topViewController;
            loginViewController.delegate = self;
            
            [self.navigationController presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([RKClient sharedClient].isSignedIn) {
            RKSubreddit *subreddit = [self.subreddits objectAtIndex:indexPath.row];
            [[RKClient sharedClient] unsubscribeFromSubreddit:subreddit completion:^(NSError *error) {
                if (!error) {
                    [self deleteSubredditAtIndexPath:indexPath];
                }
            }];
        }
        else {
            [self deleteSubredditAtIndexPath:indexPath];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && [RKClient sharedClient].isSignedIn) {
        return @"Subscribed";
    }
    
    return nil;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 3) {
        return;
    }
    
    UINavigationController *nc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChooseSubredditNavigationController"];
    
    ChooseSubredditTableViewController *vc = (ChooseSubredditTableViewController *)[nc topViewController];
    vc.delegate = self;
    
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

#pragma mark - ChooseSubredditTableViewControllerDelegate

- (void)chooseSubreddit:(ChooseSubredditTableViewController *)viewController didSelectSubreddit:(RKSubreddit *)subreddit
{
    if ([RKClient sharedClient].isSignedIn) {
        [[RKClient sharedClient] subscribeToSubreddit:subreddit completion:^(NSError *error) {
            if (!error) {
                self.subreddits = [self.subreddits arrayByAddingObject:subreddit];
            }
            
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [self viewSubreddit:subreddit];
            }];
        }];
    }
    else {
        self.subreddits = [self.subreddits arrayByAddingObject:subreddit];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self viewSubreddit:subreddit];
        }];
    }
}

- (void)chooseSubredditDidCancel:(ChooseSubredditTableViewController *)viewController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)chooseSubreddit:(ChooseSubredditTableViewController *)viewController canAddSubreddit:(RKSubreddit *)subreddit
{
    __block BOOL subscribed = NO;
    
    [self.subreddits enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RKSubreddit *_subreddit = obj;
        
        if ([subreddit.name isEqualToString:_subreddit.name]) {
            subscribed = YES;
            *stop = YES;
        }
    }];
    
    return !subscribed;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"subreddits"];
        [self loadDefaultSubreddits];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - LoginViewControllerDelegate

- (void)loginViewController:(LoginViewController *)viewController didLoginWithUsername:(NSString *)username password:(NSString *)password
{
    [viewController setLoading:YES];
    
    [[RKClient sharedClient] signInWithUsername:username password:password completion:^(NSError *error) {
        if (error != nil) {
            viewController.loading = NO;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
        else {
            [SSKeychain setPassword:password forService:@"RedditAccount" account:username];
            
            [self loadUserSubredditsWithCallback:^(NSArray *subreddits) {
                self.refreshControl.enabled = YES;
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }];
}

- (void)loginViewControllerDidCancel:(LoginViewController *)viewController
{
    viewController.delegate = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
