//
//  VideosTableViewController.m
//  Yewtube
//
//  Created by electimon on 7/15/21.
//  Copyright (c) 2021 electimon. All rights reserved.
//

#import "VideosTableViewController.h"
#import "VideosTableViewCell.h"
#import "TuberAPI.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideosTableViewController ()

@end

@implementation VideosTableViewController {
    NSArray *videoJSON;
    NSUserDefaults *defaults;
    NSOperationQueue *queue;
    NSDictionary *flipDict;
    NSDictionary *flopDict;
    BOOL fliporflop;
    AppDelegate *delegate;
    NSIndexPath *_indexPath;
}
@synthesize channelID;

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
    NSLog(@"channelID = %@", channelID);
    queue = [[NSOperationQueue alloc] init];
    defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"AA = %@", [defaults dictionaryRepresentation]);
    flipDict = [TuberAPI getVideosAPI:nil channelID:channelID];
    fliporflop = 0;
    NSLog(@"flipDict = %@", flipDict);
    delegate = [[UIApplication sharedApplication] delegate];
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
    VideosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideosTableViewCell" forIndexPath:indexPath];
    NSDictionary *currentItem;
    
    if (!(fliporflop)) {
        currentItem = [[[flipDict objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"snippet"];
    } else {
        currentItem = [[[flopDict objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"snippet"];
    }
    
    cell.detailButton.enabled = NO;
    cell.indicatorCounter = 0;
    cell.videoImageIndicator.hidden = NO;
    [cell.videoImageIndicator startAnimating];
    
    if (cell.indicatorCounter == 0) {
        cell.videoImage.image = [UIImage imageNamed:@"noimage"];
    }
    
//    int durationMin = [[[featuredJSON objectAtIndex:indexPath.row] valueForKey:@"lengthSeconds"] integerValue];
//    int durationSec = durationMin % 60;
//    
//    durationMin = durationMin / 60;
//    
//    NSLog(@"durationMin = %d durationSec = %d", durationMin, durationSec);
//    
//    durationMin = floorf(durationMin);
//    
//    bool durationSecInRange = NSLocationInRange(durationSec, NSMakeRange(0, (9 - 0)));
//    
//    if (durationSecInRange == true) {
//        cell.durationLabel.text = [NSString stringWithFormat:@"%d:0%d", durationMin, durationSec];
//    } else {
//        cell.durationLabel.text = [NSString stringWithFormat:@"%d:%d", durationMin, durationSec];
//    }
    
    cell.titleLabel.text = [self decodeHtmlUnicodeCharactersToString:[currentItem valueForKey:@"title"]];
    
    if (cell.videoImage.image == [UIImage imageNamed:@"noimage"]) {
        
        [queue addOperationWithBlock:^{
            
            //NSURL *imageURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@", [[[[[featuredJSON valueForKey:@"snippet"] valueForKey:@"thumbnails"] valueForKey:@"medium"] valueForKey:@"url"] objectAtIndex:indexPath.row]]];
            
            NSURL *imageURL = [NSURL URLWithString: [[[currentItem objectForKey:@"thumbnails"] objectForKey:@"medium"] valueForKey:@"url"]];
            
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
    cell.publishedLabel.text = [NSString stringWithFormat:@"Published on: %@", [[currentItem valueForKey:@"publishedAt"] substringToIndex:10]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    _indexPath = indexPath;
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    [self playVideo:[[[[flipDict objectForKey:@"items"] objectAtIndex:_indexPath.row+1] objectForKey:@"id"] valueForKey:@"videoId"] retry:NO moviePlayer:NULL];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
}

- (void)playVideo:(NSString *)videoID retry:(BOOL)retry moviePlayer:(MPMoviePlayerController *)moviePlayer {
    
    [self getVideoJSON:videoID];
    
    // objectAtIndex:1 is 720p
    // Edit, set to defres set in settings
    NSURL *movieURL = [NSURL URLWithString:[[[videoJSON valueForKey:@"formatStreams"] objectAtIndex:delegate.defRes == 0 ? 0 : 1] valueForKey:@"url"]];
    
    NSLog(@"YESSIR = %@", videoJSON);
    
    if ([videoJSON valueForKey:@"error"] != nil) {
        void;
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
            [self playVideo:[[[[flipDict objectForKey:@"items"] objectAtIndex:_indexPath.row+1] objectForKey:@"id"] valueForKey:@"videoId"] retry:YES moviePlayer:moviePlayer];
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

- (NSString*) decodeHtmlUnicodeCharactersToString:(NSString*)str
{
    NSMutableString* string = [[NSMutableString alloc] initWithString:str];  // #&39; replace with '
    NSString* unicodeStr = nil;
    NSString* replaceStr = nil;
    int counter = -1;
    
    for(int i = 0; i < [string length]; ++i)
    {
        unichar char1 = [string characterAtIndex:i];
        for (int k = i + 1; k < [string length] - 1; ++k)
        {
            unichar char2 = [string characterAtIndex:k];
            
            if (char1 == '&'  && char2 == '#' )
            {
                ++counter;
                unicodeStr = [string substringWithRange:NSMakeRange(i + 2 , 2)];
                // read integer value i.e, 39
                replaceStr = [string substringWithRange:NSMakeRange (i, 5)];     //     #&39;
                [string replaceCharactersInRange: [string rangeOfString:replaceStr] withString:[NSString stringWithFormat:@"%c",[unicodeStr intValue]]];
                break;
            }
        }
    }
    
    if (counter > 1)
        return  [self decodeHtmlUnicodeCharactersToString:string];
    else
        return string;
}

@end
