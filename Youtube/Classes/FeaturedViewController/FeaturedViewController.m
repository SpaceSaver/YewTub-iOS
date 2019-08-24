//
//  FeaturedViewController.m
//  Youtube
//
//  Created by electimon on 6/29/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "FeaturedViewController.h"
#import "../FeaturedTableViewCell/FeaturedTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DetailViewController.h"
#import "../TuberAPI/TuberAPI.h"

#define API_BASE_URL "https://www.googleapis.com/youtube/v3/"
#define FEATURED_MAX_RESULTS "20"
#define API_KEY "AIzaSyDtltt-rSBbdsy7EVqwnmGXlqQtrc2FujY"

@interface FeaturedViewController ()
@property (nonatomic, strong) MPMoviePlayerViewController *mp;
@end

@implementation FeaturedViewController {
    
    NSArray *featuredJSON;
    NSOperationQueue *queue;
    NSIndexPath *tableIndexPath;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    featuredJSON = nil;
    queue = [[NSOperationQueue alloc] init];
    
    [self getFeaturedJSON];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (featuredJSON == nil) {
        
        NSLog(@"We're waiting");
        
        return 0;
        
    } else {
        
        return [[[featuredJSON valueForKey:@"snippet"] valueForKey:@"title"] count];
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FeaturedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeaturedTableViewCell" forIndexPath:indexPath];
    
    cell.detailButton.enabled = NO;
    cell.indicatorCounter = 0;
    cell.videoImageIndicator.hidden = NO;
    [cell.videoImageIndicator startAnimating];
    
    if (cell.indicatorCounter == 0) {
    
        cell.videoImage.image = [UIImage imageNamed:@"noimage"];
        
    
    }
    
    NSString *duration = [TuberAPI parseISO8601Time:[[[featuredJSON valueForKey:@"contentDetails"] valueForKey:@"duration"] objectAtIndex:indexPath.row]];
    
    cell.titleLabel.text = [[[featuredJSON valueForKey:@"snippet"] valueForKey:@"title"] objectAtIndex:indexPath.row];
    cell.creatorLabel.text = [[[featuredJSON valueForKey:@"snippet"] valueForKey:@"channelTitle"] objectAtIndex:indexPath.row];
    
    if ([duration rangeOfString:@"00:"].location == NSNotFound) {
        
        cell.durationLabel.text = duration;
        [[cell durationLabel] sizeToFit];
        
    } else {
        
        cell.durationLabel.text = [duration stringByReplacingOccurrencesOfString:@"00:" withString:@""];
        [[cell durationLabel] sizeToFit];
        
    }
    
    CGRect newFrame = cell.creatorLabel.frame;
    newFrame.origin.x = CGRectGetMaxX(cell.durationLabel.frame)+10;
    newFrame.origin.y = CGRectGetMinY(cell.durationLabel.frame)-2.2;
    cell.creatorLabel.frame = newFrame;
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[[[[featuredJSON objectAtIndex:indexPath.row] valueForKey:@"statistics"] valueForKey:@"viewCount"] integerValue]]];
    
    cell.viewsLabel.text = [formatted stringByAppendingString:@" views"];
    
    if (cell.videoImage.image == [UIImage imageNamed:@"noimage"]) {
        
        [queue addOperationWithBlock:^{
            
            NSURL *imageURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@", [[[[[featuredJSON valueForKey:@"snippet"] valueForKey:@"thumbnails"] valueForKey:@"medium"] valueForKey:@"url"] objectAtIndex:indexPath.row]]];
            
            NSLog(@"imageURL = %@", [imageURL absoluteString]);
            
            NSData* imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
            
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [cell.videoImageIndicator stopAnimating];
                cell.videoImageIndicator.hidden = YES;
                cell.videoImage.image = [UIImage imageWithData:imageData];
                cell.indicatorCounter = 1;
                cell.detailButton.enabled = YES;
                [[self view] setNeedsDisplay];
                
            }];
        }];
    }
    
    cell.detailButton.tag = indexPath.row;
    
    return cell;
}

- (void)getFeaturedJSON {
    
    NSURL *featuredAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%svideos?key=%s&part=snippet,contentDetails,statistics&order=date&maxResults=%s&chart=mostPopular&regionCode=US", API_BASE_URL, API_KEY, FEATURED_MAX_RESULTS]];
    
    NSLog(@"featuredAPIURL = %@", [featuredAPIURL absoluteString]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:featuredAPIURL];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
        
        NSDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:d options: NSJSONReadingMutableContainers error:NULL];
        
        if (e == nil) {
            
            NSLog(@"hiiii");
            
            featuredJSON = [tempDict objectForKey:@"items"];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [[self loadingIndicator] stopAnimating];
                self.loadingLabel.hidden = YES;
                self.tableView.hidden = NO;
                
                [[self tableView] reloadData];
                
            }];
            
        } else {
            
            featuredJSON = [NSDictionary dictionaryWithObject:@"ERROR" forKey:@"ERROR"];
            
        }
        
    }];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //FeaturedTableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    [self playVideo:[[featuredJSON objectAtIndex:indexPath.row] valueForKey:@"id"]];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)playVideo:(NSString *)videoID {
    NSURL *movieURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api-v2.tubefixer.ovh/video/hd/%@", videoID]];
    self.mp = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.mp
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.mp.moviePlayer];
    
    // Register this class as an observer instead
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.mp.moviePlayer];
    
    if (self.mp)
    {
        self.mp.view.frame = self.view.bounds;
        [[self navigationController] presentMoviePlayerViewControllerAnimated:self.mp];
        
        // save the movie player object
        //[self.mp.moviePlayer setFullscreen:YES];
        
        // Play the movie!
        
        NSLog(@"We are playing: %@", movieURL.absoluteString);
        
        [self.mp.moviePlayer play];
    }
}

- (void)movieFinished:(NSNotification*)aNotification
{
    
    
    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    // Dismiss the view controller ONLY when the reason is not "playback ended"
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
    {
        MPMoviePlayerController *moviePlayer = [aNotification object];
        
        // Remove this class from the observers
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
        
        [self dismissMoviePlayerViewControllerAnimated];
        
        self.navigationController.navigationBarHidden = NO;
        self.tabBarController.tabBar.hidden = NO;
    }
}

- (IBAction)buttonWasPressed:(id)sender {
    
    NSIndexPath *indexPath =
    [self.tableView
     indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    NSUInteger row = indexPath.row;
    tableIndexPath = indexPath;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"FeaturedDetailPush"]) {
        
       
        
        FeaturedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:tableIndexPath];
        
        DetailViewController *destinationViewController = segue.destinationViewController;

        destinationViewController.currentJSON = featuredJSON;
        destinationViewController.currentVideoID = [[featuredJSON objectAtIndex:tableIndexPath.row] valueForKey:@"id"];
        destinationViewController.currentVideoTitle = cell.titleLabel.text;
        destinationViewController.currentVideoViews = cell.viewsLabel.text;
        destinationViewController.currentVideoImage = cell.videoImage.image;
        destinationViewController.currentVideoDuration = cell.durationLabel.text;
        destinationViewController.currentVideoCreator = cell.creatorLabel.text;
        
    }
    
}

@end
