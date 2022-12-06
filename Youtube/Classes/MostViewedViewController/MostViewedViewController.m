//
//  MostViewedViewController.m
//  Youtube
//
//  Created by electimon on 1/21/20.
//  Copyright (c) 2020 1pwn. All rights reserved.
//

#import "MostViewedViewController.h"
#import "FeaturedTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TuberAPI.h"

@interface MostViewedViewController ()

@end

@implementation MostViewedViewController {
    NSArray *mostViewedJSON;
    NSOperationQueue *queue;
    NSIndexPath *tableIndexPath;
    NSArray *videoJSON;
    BOOL flag;
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
    // Do any additional setup after loading the view.
    mostViewedJSON = nil;
    queue = [[NSOperationQueue alloc] init];
    
    [self getmostViewedJSON];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (flag == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Server Administrator has disabled this endpoint." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        self.tableView.hidden = YES;
        
    }
    
    if (mostViewedJSON == nil) {
        
        NSLog(@"We're waiting");
        
        //[self getmostViewedJSON];
        //[[self tableView] reloadData];
        
        return 0;
        
    } else {
        
        return [[[mostViewedJSON valueForKey:@"snippet"] valueForKey:@"title"] count];
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FeaturedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeaturedTableViewCell"];
    
    cell.detailButton.enabled = NO;
    cell.indicatorCounter = 0;
    cell.videoImageIndicator.hidden = NO;
    [cell.videoImageIndicator startAnimating];
    
    if (cell.indicatorCounter == 0) {
        
        cell.videoImage.image = [UIImage imageNamed:@"noimage"];
        
        
    }
    
    int durationMin = [[[mostViewedJSON objectAtIndex:indexPath.row] valueForKey:@"lengthSeconds"] integerValue];
    int durationSec = durationMin % 60;
    
    durationMin = durationMin / 60;
    
    NSLog(@"durationMin = %d durationSec = %d", durationMin, durationSec);
    
    durationMin = floorf(durationMin);
    
    bool durationSecInRange = NSLocationInRange(durationSec, NSMakeRange(0, (9 - 0)));
    
    if (durationSecInRange == true) {
        cell.durationLabel.text = [NSString stringWithFormat:@"%d:0%d", durationMin, durationSec];
    } else {
        cell.durationLabel.text = [NSString stringWithFormat:@"%d:%d", durationMin, durationSec];
    }
    
    cell.titleLabel.text = [[mostViewedJSON objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.creatorLabel.text = [[mostViewedJSON objectAtIndex:indexPath.row] valueForKey:@"author"];
    
    CGRect newFrame = cell.creatorLabel.frame;
    newFrame.origin.x = CGRectGetMaxX(cell.durationLabel.frame)+10;
    newFrame.origin.y = CGRectGetMinY(cell.durationLabel.frame)-2.2;
    cell.creatorLabel.frame = newFrame;
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[[[mostViewedJSON objectAtIndex:indexPath.row] valueForKey:@"viewCount"] integerValue]]];
    
    cell.viewsLabel.text = [formatted stringByAppendingString:@" views"];
    
    if (cell.videoImage.image == [UIImage imageNamed:@"noimage"]) {
        
        [queue addOperationWithBlock:^{
            
            //NSURL *imageURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@", [[[[[mostViewedJSON valueForKey:@"snippet"] valueForKey:@"thumbnails"] valueForKey:@"medium"] valueForKey:@"url"] objectAtIndex:indexPath.row]]];
            
            NSURL *imageURL = [NSURL URLWithString: [[[[mostViewedJSON objectAtIndex:indexPath.row] valueForKey:@"videoThumbnails"] objectAtIndex:2] valueForKey:@"url"]];
            
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

- (void)getmostViewedJSON {
    
    NSURL *mostViewedAPIURL = [NSURL URLWithString:@"https://invidio.us/api/v1/top"];
    
    NSLog(@"mostViewedAPIURL = %@", [mostViewedAPIURL absoluteString]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:mostViewedAPIURL];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
        
        NSArray *tempDict = [NSJSONSerialization JSONObjectWithData:d options: NSJSONReadingMutableContainers error:NULL];
        
        NSLog(@"tempDict = %@", tempDict);
        
        if (e == nil) {
            
            NSLog(@"hiiii");
            
            mostViewedJSON = tempDict;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [[self loadingIndicator] stopAnimating];
                self.loadingLabel.hidden = YES;
                self.tableView.hidden = NO;
                
                [[self tableView] reloadData];
                
            }];
            
        } else {
            
            mostViewedJSON = [NSDictionary dictionaryWithObject:@"ERROR" forKey:@"ERROR"];
            
        }
        if ([[mostViewedJSON valueForKey:@"error"]  isEqual:@"Administrator has disabled this endpoint."]) {
            flag = YES;
            NSLog(@"flag = %d", flag);
        }
        
    }];
    
}

- (void)getVideoJSON:(NSString *) videoID {
    
    NSURL *videoAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://invidio.us/api/v1/videos/%@", videoID]];
    
    NSLog(@"videoAPIURL = %@", [videoAPIURL absoluteString]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:videoAPIURL];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:nil];
    
    NSArray *tempDict = [NSJSONSerialization JSONObjectWithData:responseData options: NSJSONReadingMutableContainers error:NULL];
    //NSLog(@"tempDict = %@", tempDict);
    videoJSON = tempDict;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //FeaturedTableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    [self playVideo:[[mostViewedJSON objectAtIndex:indexPath.row] valueForKey:@"videoId"]];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)playVideo:(NSString *)videoID {
    
    [self getVideoJSON:videoID];
    NSURL *movieURL = [NSURL URLWithString:[[[videoJSON valueForKey:@"adaptiveFormats"] objectAtIndex:3] valueForKey:@"url"]];
    
    self.mp = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    
    [self.mp.moviePlayer prepareToPlay];
    self.mp.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    
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
    NSDictionary *notificationUserInfo = [aNotification userInfo];
    
    // Dismiss the view controller ONLY when the reason is not "playback ended"
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
    {
        MPMoviePlayerController *moviePlayer = [aNotification object];
        
        NSError *mediaPlayerError = [notificationUserInfo objectForKey:@"error"];
        
        NSLog(@"ERROR = %@", [mediaPlayerError localizedDescription]);
        
        // Remove this class from the observers
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
        
        [self dismissMoviePlayerViewControllerAnimated];
        
        self.navigationController.navigationBarHidden = NO;
        self.tabBarController.tabBar.hidden = NO;
    }
}

@end
