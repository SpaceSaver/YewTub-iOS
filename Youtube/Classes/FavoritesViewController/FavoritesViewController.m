//
//  FavoritesViewController.m
//  Youtube
//
//  Created by electimon on 1/21/20.
//  Copyright (c) 2020 1pwn. All rights reserved.
//

#import "FavoritesViewController.h"
#import "FeaturedTableViewCell.h"
#import "TuberAPI.h"

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController {
    NSMutableArray *favoritesArray;
    NSArray *videoJSON;
    BOOL favoritesEmpty;
    NSMutableArray *favoritesJSON;
    NSOperationQueue *queue;
    NSString *videoID;
    BOOL favoritesJSONSet;
}

@synthesize tableView;
@synthesize editButton;

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
    [self Refresh:self];
    favoritesJSONSet = NO;
    queue = [NSOperationQueue new];
}

- (IBAction)Refresh:(id)sender {
    NSLog(@"favoritesArrayBefore = %@", favoritesArray);
    NSArray *temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"favorites"];
    NSLog(@"favoritesArrayBefore = %@", temp);
    if (![temp count] == 0) {
        favoritesEmpty = NO;
        favoritesArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"favorites"] mutableCopy];
        NSLog(@"favoritesArray = %@", favoritesArray);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getVideoJSON];
        });
    } else {
        favoritesEmpty = YES;
    }
    if (favoritesEmpty == YES) {
        NSLog(@"favoritesEmpty = %hhd", favoritesEmpty);
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (IBAction)Edit:(id)sender {
    [[self tableView] setEditing:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (favoritesEmpty == YES) {
        NSLog(@"We are returning 0");
        return 0;
    } else {
        if (!favoritesJSON) {
            NSLog(@"We are returning 0");
            return 0;
        } else {
            //NSLog(@"DEBUGGGG = %@", favoritesArray);
            return [favoritesArray count];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeaturedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeaturedTableViewCell" forIndexPath:indexPath];
    
    videoID = [favoritesArray objectAtIndex:indexPath.row];
    
    //NSLog(@"featuredAAA = %@", favoritesJSON);
    
    cell.detailButton.enabled = NO;
    cell.indicatorCounter = 0;
    cell.videoImageIndicator.hidden = NO;
    [cell.videoImageIndicator startAnimating];
    
    if (cell.indicatorCounter == 0) {
        
        cell.videoImage.image = [UIImage imageNamed:@"noimage"];
        
        
    }
    int durationMin = [[[favoritesJSON objectAtIndex:indexPath.row] valueForKey:@"lengthSeconds"] integerValue];
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
    
    cell.titleLabel.text = [[favoritesJSON objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.creatorLabel.text = [[favoritesJSON objectAtIndex:indexPath.row] valueForKey:@"author"];
    
    CGRect newFrame = cell.creatorLabel.frame;
    newFrame.origin.x = CGRectGetMaxX(cell.durationLabel.frame)+10;
    newFrame.origin.y = CGRectGetMinY(cell.durationLabel.frame)-2.2;
    cell.creatorLabel.frame = newFrame;
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[[[favoritesJSON objectAtIndex:indexPath.row] valueForKey:@"viewCount"] integerValue]]];
    
    cell.viewsLabel.text = [formatted stringByAppendingString:@" views"];
    
    if (cell.videoImage.image == [UIImage imageNamed:@"noimage"]) {
        
        [queue addOperationWithBlock:^{
            
            //NSURL *imageURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@", [[[[[featuredJSON valueForKey:@"snippet"] valueForKey:@"thumbnails"] valueForKey:@"medium"] valueForKey:@"url"] objectAtIndex:indexPath.row]]];
            
            NSURL *imageURL = [NSURL URLWithString: [[[[favoritesJSON objectAtIndex:indexPath.row] valueForKey:@"videoThumbnails"] objectAtIndex:2] valueForKey:@"url"]];
            
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

- (void)getVideoJSON {
    int x;
    for (x = 0;x <= [favoritesArray count] - 1; x++) {
    NSURL *videoAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://invidio.us/api/v1/videos/%@", [favoritesArray objectAtIndex:x]]];
    
    NSLog(@"videoAPIURL = %@", [videoAPIURL absoluteString]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:videoAPIURL];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:nil];
    
    NSArray *tempDict = [NSJSONSerialization JSONObjectWithData:responseData options: NSJSONReadingMutableContainers error:NULL];
    //NSLog(@"tempDict = %@", tempDict);
        
    if (favoritesJSONSet == NO) {
        favoritesJSONSet = YES;
        favoritesJSON = [[NSMutableArray alloc] init];
    }
    [favoritesJSON insertObject:tempDict atIndex:x];
    [self.tableView reloadData];
    //NSLog(@"OKKKKKK = %@", favoritesJSON);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //FeaturedTableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    [self playVideo:[[favoritesJSON objectAtIndex:indexPath.row] valueForKey:@"videoId"]];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)playVideo:(NSString *)videoID {
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove here your data
        NSLog(@"indexPath.row = %ld", (long)indexPath.row);
        [favoritesArray removeObjectAtIndex:indexPath.row];
        if (![favoritesArray count] == 0){
        [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"favorites"];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"favorites"];
        }
        NSLog(@"favoritesArray = %@", favoritesArray);
        // This line manages to delete the cell in a nice way
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
