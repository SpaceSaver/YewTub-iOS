//
//  SubscriberTableViewController.m
//  Yewtube
//
//  Created by electimon on 7/14/21.
//  Copyright (c) 2021 electimon. All rights reserved.
//

#import "SubscriberTableViewController.h"
#import "SubscriberTableViewCell.h"
#import "TuberAPI.h"
#import "VideosTableViewController.h"

@interface SubscriberTableViewController ()

@end

@implementation SubscriberTableViewController {
    NSUserDefaults *defaults;
    NSOperationQueue *queue;
    NSDictionary *flipDict;
    NSDictionary *flopDict;
    BOOL fliporflop;
    NSIndexPath *_indexPath;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.navigationController.navigationBar setTranslucent:NO];
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    queue = [[NSOperationQueue alloc] init];
    defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"AA = %@", [defaults dictionaryRepresentation]);
    flipDict = [TuberAPI getSubAPI:nil];
    fliporflop = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (!(fliporflop)) {
        return [[flipDict objectForKey:@"items"] count];
    } else {
        return [[flopDict objectForKey:@"items"] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubscriberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubscriberTableViewCell"];
    NSDictionary *currentItem;
    
    cell.thumbImage.image = [UIImage imageNamed:@"noimage"];
    
    if (!(fliporflop)) {
        currentItem = [[[flipDict objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"snippet"];
    } else {
        currentItem = [[[flopDict objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"snippet"];
    }
    cell.titleLabel.text = [currentItem valueForKey:@"title"];
    [queue addOperationWithBlock:^{
        
        //NSURL *imageURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@", [[[[[featuredJSON valueForKey:@"snippet"] valueForKey:@"thumbnails"] valueForKey:@"medium"] valueForKey:@"url"] objectAtIndex:indexPath.row]]];
        
        NSURL *imageURL = [NSURL URLWithString: [[[currentItem objectForKey:@"thumbnails"] objectForKey:@"medium"] valueForKey:@"url"]];
        
        NSLog(@"imageURL = %@", [imageURL absoluteString]);
        
        NSData* imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [cell.loadingIndicator stopAnimating];
            cell.loadingIndicator.hidden = YES;
            cell.thumbImage.image = [UIImage imageWithData:imageData];
            cell.indicatorCounter = 1;
            cell.detailButton.enabled = YES;
            [[self view] setNeedsDisplay];
            
        }];
    }];
    cell.subscribedLabel.text = [NSString stringWithFormat:@"Subscribed on: %@", [[currentItem valueForKey:@"publishedAt"] substringToIndex:10]];
    cell.detailButton.tag = indexPath.row;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 79;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    _indexPath = [self.tableView indexPathForCell:sender];
    VideosTableViewController *viewController = [segue destinationViewController];
    if (!(fliporflop)) {
        viewController.channelID = [[[[[flipDict objectForKey:@"items"] objectAtIndex:_indexPath.row] objectForKey:@"snippet"] objectForKey:@"resourceId"] valueForKey:@"channelId"];
    } else {
        viewController.channelID = [[[[[flopDict objectForKey:@"items"] objectAtIndex:_indexPath.row] objectForKey:@"snippet"] objectForKey:@"resourceId"] valueForKey:@"channelId"];
    }
}

- (IBAction)buttonWasPressed:(id)sender {
}

@end
