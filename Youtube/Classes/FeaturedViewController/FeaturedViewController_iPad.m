//
//  FeaturedViewController.m
//  Youtube
//
//  Created by electimon on 6/29/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "FeaturedViewController_iPad.h"
#import "../FeaturedTableViewCell/FeaturedTableViewCell_iPad.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DetailViewController.h"
#import "../TuberAPI/TuberAPI.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

#define API_BASE_URL "https://www.googleapis.com/youtube/v3/"
#define FEATURED_MAX_RESULTS "20"
#define API_KEY "AIzaSyDtltt-rSBbdsy7EVqwnmGXlqQtrc2FujY"

@interface FeaturedViewController_iPad ()
@end

@interface NSMutableURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@implementation FeaturedViewController_iPad {
    NSArray *videoJSON;
    NSArray *featuredJSON;
    NSOperationQueue *queue;
    NSIndexPath *tableIndexPath;
    NSUserDefaults *defaults;
    AppDelegate *delegate;
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
    [self.navigationController.navigationBar setTranslucent:NO];
    [super viewDidLoad];
    
    featuredJSON = nil;
    queue = [[NSOperationQueue alloc] init];
    defaults = [NSUserDefaults standardUserDefaults];
    delegate = [[UIApplication sharedApplication] delegate];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.hidden = true;
    
    [self getFeaturedJSON];
    NSLog(@"Meow");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Neigh");
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
    NSLog(@"Bark");
    FeaturedTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"FeaturedTableViewCell"];
    
    cell.detailButton.enabled = NO;
    cell.indicatorCounter = 0;
    cell.videoImageIndicator.hidden = NO;
    [cell.videoImageIndicator startAnimating];
    
    if (cell.indicatorCounter == 0) {
        
        cell.videoImage.image = [UIImage imageNamed:@"noimage"];
        
        
    }
    
    int durationMin = [[[featuredJSON objectAtIndex:indexPath.row] valueForKey:@"lengthSeconds"] integerValue];
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
    
    cell.titleLabel.text = [[featuredJSON objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.creatorLabel.text = [[featuredJSON objectAtIndex:indexPath.row] valueForKey:@"author"];
    
    CGRect newFrame = cell.creatorLabel.frame;
    newFrame.origin.x = CGRectGetMaxX(cell.durationLabel.frame)+10;
    newFrame.origin.y = CGRectGetMinY(cell.durationLabel.frame)-2.2;
    cell.creatorLabel.frame = newFrame;
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[[[featuredJSON objectAtIndex:indexPath.row] valueForKey:@"viewCount"] integerValue]]];
    
    cell.viewsLabel.text = [formatted stringByAppendingString:@" views"];
    
    NSString *imageURLstr = [[[[featuredJSON objectAtIndex:indexPath.row] valueForKey:@"videoThumbnails"] objectAtIndex:3] valueForKey:@"url"];
    UIImage *image = [delegate.videoImageCache objectForKey:imageURLstr];
    if (image) {
        cell.videoImage.image = image;
        [cell.videoImageIndicator stopAnimating];
        cell.videoImageIndicator.hidden = YES;
        cell.detailButton.enabled = YES;
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *imageURL = [NSURL URLWithString:[imageURLstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (!cell.videoImage.image || cell.videoImage.image == [UIImage imageNamed:@"noimage"]) {
                    cell.videoImage.image = [UIImage imageWithData:imageData];
                    if (cell.videoImage.image) {
                        [delegate.videoImageCache setObject:cell.videoImage.image forKey:imageURLstr];
                    }
                    [cell.videoImageIndicator stopAnimating];
                    cell.videoImageIndicator.hidden = YES;
                    cell.detailButton.enabled = YES;
                }
            }];
        });
    }
    cell.detailButton.tag = indexPath.row;
    
    return cell;
}

- (void)getFeaturedJSON {
    
    NSURL *featuredAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/trending", delegate.apiEndpoint]];
    
    NSLog(@"featuredAPIURL = %@", [featuredAPIURL absoluteString]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:featuredAPIURL];
    [request setHTTPMethod:@"GET"];
    [NSMutableURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[featuredAPIURL host]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
        
        if (!(d == nil)) {
            if (e == nil) {
                NSArray *tempDict = [NSJSONSerialization JSONObjectWithData:d options: NSJSONReadingMutableContainers error:NULL];
                NSLog(@"hiiii");
                
                featuredJSON = tempDict;
                if (featuredJSON) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        [[self loadingIndicator] stopAnimating];
                        self.loadingLabel.hidden = YES;
                        self.tableView.hidden = NO;
                        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                        
                        NSLog(@"Reloading...");
                        [[self tableView] reloadData];
                        
                    }];
                } else {
                    self.loadingLabel.text = @"Taking longer than usual";
                    self.loadingLabel.textAlignment = UITextAlignmentCenter;
                    [self.loadingLabel sizeToFit];
                }
            } else {
                
                featuredJSON = [NSDictionary dictionaryWithObject:@"ERROR" forKey:@"ERROR"];
                NSLog(@"ERROR");
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:[e description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue() , ^{
               [alertView show];
            });
        }
    }];
    
}

- (void)getVideoJSON:(NSString *) videoID {
    
    NSURL *videoAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/videos/%@", delegate.apiEndpoint, videoID]];
    
    NSLog(@"videoAPIURL = %@", [videoAPIURL absoluteString]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:videoAPIURL];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:nil];
    
    NSArray *tempDict = [NSJSONSerialization JSONObjectWithData:responseData options: NSJSONReadingMutableContainers error:NULL];
    //NSLog(@"tempDict = %@", tempDict);
    videoJSON = tempDict;
    [SVProgressHUD dismiss];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //FeaturedTableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    [self playVideo:[[featuredJSON objectAtIndex:indexPath.row] valueForKey:@"videoId"] retry:NO moviePlayer:NULL];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)playVideo:(NSString *)videoID retry:(BOOL)retry moviePlayer:(MPMoviePlayerController *)moviePlayer {

    [self getVideoJSON:videoID];
    
    // objectAtIndex:1 is 720p
    // Edit, set to defres set in settings
    NSURL *movieURL = [NSURL URLWithString:[[[videoJSON valueForKey:@"formatStreams"] objectAtIndex:delegate.defRes == 0 ? 0 : 1] valueForKey:@"url"]];
    
    NSLog(@"YESSIR = %@", videoJSON);
    
    if ([videoJSON valueForKey:@"error"] != nil) {
        NSLog(@"aa");
    }
    
    if (retry) {
        NSLog(@"We are retrying");
        // objectAtIndex:0 is 360p or lower than 720p
        // Edit, set to defres set in settings
        movieURL = [NSURL URLWithString:[[[videoJSON valueForKey:@"formatStreams"] objectAtIndex:delegate.defRes == 0 ? 0 : 1] valueForKey:@"url"]];
        NSLog(@"We are playing: %@", movieURL.absoluteString);

        [moviePlayer setContentURL:movieURL];
        [moviePlayer play];
        NSLog(@"Triggered play");
        NSLog(@"Resolution = %d", delegate.defRes == 0 ? 1 : 0);
        return;
    }
    
    self.mp = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];

    [self.mp.moviePlayer prepareToPlay];
    self.mp.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.mp
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.mp.moviePlayer];
    
    // Register this class as an observer instead
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.mp.moviePlayer];
    
    self.mp.view.frame = self.view.bounds;
    [[self navigationController] presentMoviePlayerViewControllerAnimated:self.mp];
    
    // save the movie player object
    //[self.mp.moviePlayer setFullscreen:YES];
    
    // Play the movie!
    
    NSLog(@"We are playing: %@", movieURL.absoluteString);
    NSLog(@"Resolution = %d", delegate.defRes);
    
    [self.mp.moviePlayer play];
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
        // Apparently if this error than it failed to play the 720p clip, we will retry with lower res
        if ([[mediaPlayerError localizedDescription] isEqual: @"The operation could not be completed"]) {
        //if (1) {
            [self playVideo:[[featuredJSON objectAtIndex:tableIndexPath.row+1] valueForKey:@"videoId"] retry:YES moviePlayer:moviePlayer];
        } else {
            
            // Remove this class from the observers
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:MPMoviePlayerPlaybackDidFinishNotification
                                                          object:moviePlayer];
            
            [self dismissMoviePlayerViewControllerAnimated];
            
            self.navigationController.navigationBarHidden = NO;
            self.tabBarController.tabBar.hidden = NO;
        }
    }
}

- (IBAction)buttonWasPressed:(id)sender {
    
    NSIndexPath *indexPath =
    [self.tableView
     indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    tableIndexPath = indexPath;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"FeaturedDetailPush"]) {
        
        
        
        FeaturedTableViewCell_iPad *cell = [self.tableView cellForRowAtIndexPath:tableIndexPath];
        
        DetailViewController *destinationViewController = segue.destinationViewController;
        
        destinationViewController.currentJSON = videoJSON;
        destinationViewController.currentVideoID = [[featuredJSON objectAtIndex:tableIndexPath.row] valueForKey:@"id"];
        destinationViewController.currentVideoDescription = @"meep";
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)  // 0 == the cancel button
    {
        //home button press programmatically
        UIApplication *app = [UIApplication sharedApplication];
        [app performSelector:@selector(suspend)];
        
        //wait 2 seconds while app is going background
        [NSThread sleepForTimeInterval:2.0];
        
        //exit app when app is in background
        exit(0);
    }
}

@end
