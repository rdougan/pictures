//
//  CommentsTreeViewController.m
//  Pictures for Reddit
//
//  Created by Robert Dougan on 06/09/15.
//  Copyright © 2015 Robert Dougan. All rights reserved.
//

#import "CommentsTreeViewController.h"

#import "CommentTableViewCell.h"

@interface CommentsTreeViewController ()

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (nonatomic, strong) RATreeView *treeView;

@property (nonatomic, strong) NSArray *comments;

@end

@implementation CommentsTreeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.treeView = [[RATreeView alloc] initWithFrame:self.view.bounds style:RATreeViewStylePlain];
    self.treeView.delegate = self;
    self.treeView.dataSource = self;
    self.treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.treeView];
    
    [self.treeView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)];
    self.navigationItem.rightBarButtonItem = closeButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.treeView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, 0.0, 0.0, 0.0);
    self.treeView.scrollIndicatorInsets = self.treeView.contentInset;
    
    if (self.link != nil) {
        [[RKClient sharedClient] commentsForLink:self.link completion:^(NSArray *collection, NSError *error) {
            [self.loadingIndicatorView stopAnimating];
            
            self.comments = collection;
            
            [self.treeView reloadData];
            
            NSInteger rows = [self.treeView numberOfRows];
            
            for (int i = 0; i < rows; i++) {
                id item = [self treeView:self.treeView child:i ofItem:nil];
                [self.treeView expandRowForItem:item expandChildren:YES withRowAnimation:RATreeViewRowAnimationNone];
            }
        }];
    }
}

- (IBAction)close:(id)sender
{
    if (self.delegate) {
        [self.delegate commentsTreeViewControllerClose:self];
    }
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        id lastComment = [self.comments lastObject];
        if (lastComment != nil && [lastComment isKindOfClass:[RKMoreComments class]]) {
            return [self.comments count] - 1;
        }
        
        return [self.comments count];
    }
    
    RKComment *comment = item;
    id lastComment = [comment.replies lastObject];
    if (lastComment != nil && [lastComment isKindOfClass:[RKMoreComments class]]) {
        return [comment.replies count] - 1;
    }
    
    return [comment.replies count];
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
{
    CommentTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"Cell"];
    RKComment *comment = item;
    
    [cell configureForComment:comment level:[treeView levelForCellForItem:item]];
    
    return cell;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return [self.comments objectAtIndex:index];
    }
    
    RKComment *comment = item;
    return [comment.replies objectAtIndex:index];
}

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item
{
    if ([treeView isCellForItemExpanded:item]) {
        return UITableViewAutomaticDimension;
    }
    else {
        return 30.0f;
    }
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item
{
    CommentTableViewCell *cell = (CommentTableViewCell *)[treeView cellForItem:item];
    
    [UIView animateWithDuration:.3f animations:^{
        cell.collapsed = YES;
    }];
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item
{
    CommentTableViewCell *cell = (CommentTableViewCell *)[treeView cellForItem:item];
    
    [UIView animateWithDuration:.3f animations:^{
        cell.collapsed = NO;
    }];
}

@end
