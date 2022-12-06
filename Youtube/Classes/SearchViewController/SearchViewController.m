//
//  SearchViewController.m
//  Youtube
//
//  Created by electimon on 1/20/20.
//  Copyright (c) 2020 1pwn. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchTableView.h"
#import "FeaturedTableViewCell.h"
#import "TuberAPI.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"

@interface SearchViewController ()
 
@end

@implementation SearchViewController {
    NSMutableArray *searchResults;
    NSArray *searchJSON;
    NSArray *videoJSON;
    AppDelegate *delegate;

    NSDictionary *searchJSONResults;
    NSOperationQueue *_searchOperationQueue;
    NSString *searchTerm;
    NSOperationQueue *queue;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Search", @"Search");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    delegate = [[UIApplication sharedApplication] delegate];
    //[self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SearchBasicTableCell"];
    queue = [[NSOperationQueue alloc] init];
    _searchOperationQueue = [NSOperationQueue new];
    _searchOperationQueue.maxConcurrentOperationCount = 1;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewFeatured) {
            NSLog(@"COUNT = %lu", (unsigned long)[searchJSON count]);
            return [searchJSON count];
    } else {
        return [searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
    static NSString *cellIdentifier = @"SearchBasicTableCell";
    
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (!searchResults || !searchResults.count){
        
    } else {
        cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
    }
    return cell;
    } else {
     
        FeaturedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeaturedTableViewCell"];
        
        cell.detailButton.enabled = NO;
        cell.indicatorCounter = 0;
        cell.videoImageIndicator.hidden = NO;
        [cell.videoImageIndicator startAnimating];
        
        if (cell.indicatorCounter == 0) {
            
            cell.videoImage.image = [UIImage imageNamed:@"noimage"];
            
            
        }
        
        if ([[[searchJSON objectAtIndex:indexPath.row] valueForKey:@"viewCount"] integerValue] == 0) {
            cell.viewsLabel.text = @"LIVE";
            cell.durationLabel.text = @"LIVE";
        } else {
            
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
            
            NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[[[searchJSON objectAtIndex:indexPath.row] valueForKey:@"viewCount"] integerValue]]];
            
            cell.viewsLabel.text = [formatted stringByAppendingString:@" views"];
        
        
        int durationMin = [[[searchJSON objectAtIndex:indexPath.row] valueForKey:@"lengthSeconds"] integerValue];
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
        }
        cell.titleLabel.text = [[searchJSON objectAtIndex:indexPath.row] valueForKey:@"title"];
        cell.creatorLabel.text = [[searchJSON objectAtIndex:indexPath.row] valueForKey:@"author"];
        
        CGRect newFrame = cell.creatorLabel.frame;
        newFrame.origin.x = CGRectGetMaxX(cell.durationLabel.frame)+10;
        newFrame.origin.y = CGRectGetMinY(cell.durationLabel.frame)-2.2;
        cell.creatorLabel.frame = newFrame;
        
        
        if (cell.videoImage.image == [UIImage imageNamed:@"noimage"]) {
            
            [queue addOperationWithBlock:^{
                
                //NSURL *imageURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@", [[[[[featuredJSON valueForKey:@"snippet"] valueForKey:@"thumbnails"] valueForKey:@"medium"] valueForKey:@"url"] objectAtIndex:indexPath.row]]];
                
                NSURL *imageURL = [NSURL URLWithString: [[[[searchJSON objectAtIndex:indexPath.row] valueForKey:@"videoThumbnails"] objectAtIndex:3] valueForKey:@"url"]];
                
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
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

    // cancel any existing search
    [_searchOperationQueue cancelAllOperations];
    
    // begin new search
    [_searchOperationQueue addOperationWithBlock:^{
        NSUInteger length = [searchText length];
        if ((length > 3))
        {
            
            [self getSearchJSON:YES searchTerm:searchText];
            
            
            if (searchJSON == nil) {
                [self getSearchJSON:YES searchTerm:searchText];
                if (searchJSON == nil) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The server could not be contacted, try again later!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertView show];
                }
            }
            
            searchJSONResults = [searchJSON valueForKey:@"suggestions"];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [searchResults removeAllObjects];
                [self.searchDisplayController.searchResultsTableView reloadData];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"its very important to stay after = %@", searchJSONResults);

            searchResults = searchJSONResults;
            [self.searchDisplayController.searchResultsTableView reloadData];
        });
    }];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"Part 1 Complete! = %@", [searchResults objectAtIndex:indexPath.row]);
        NSString *search = [searchResults objectAtIndex:indexPath.row];
        [[self searchDisplayController] setActive:NO];
        [self getSearchJSON:NO searchTerm:search];
        [self.tableViewFeatured reloadData];
        
    } else {
        
        self.navigationController.navigationBarHidden = YES;
        self.tabBarController.tabBar.hidden = YES;
        
        [self playVideo:[[searchJSON objectAtIndex:indexPath.row] valueForKey:@"videoId"]];
        
        NSLog(@"haha - %@", [[searchJSON objectAtIndex:indexPath.row] valueForKey:@"videoId"]);
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableViewFeatured) {
        return 90;
    } else {
        return 44;
    }
}

/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"SearchViewAppInfoPush"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
    }
}*/

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)getSearchJSON:(BOOL)suggestable searchTerm:(NSString *)searchTerm {
    NSURL *searchAPIURL = [NSURL URLWithString:@""];
    if (suggestable == true) {
        searchAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/search/suggestions?q=%@", delegate.apiEndpoint, [searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
    } else {
        searchAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/search?q=%@&sort_by=relevance", delegate.apiEndpoint, [searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
    }
    NSLog(@"searchAPIURL = %@", [searchAPIURL absoluteString]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:searchAPIURL];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:nil];
    
    NSArray *tempDict = [NSJSONSerialization JSONObjectWithData:responseData options: NSJSONReadingMutableContainers error:NULL];
    //NSLog(@"tempDict = %@", tempDict);
    searchJSON = tempDict;
    
}

- (void)playVideo:(NSString *)videoID {
    NSURL *movieURL;
    
    [self getVideoJSON:videoID];
    @try {
        movieURL = [NSURL URLWithString:[[[videoJSON valueForKey:@"formatStreams"] objectAtIndex:1] valueForKey:@"url"]];
    } @catch (NSException *exception) {
        movieURL = [NSURL URLWithString:[[[videoJSON valueForKey:@"formatStreams"] objectAtIndex:0] valueForKey:@"url"]];
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
        
        self.navigationController.navigationBarHidden = YES;
        self.tabBarController.tabBar.hidden = NO;
    }
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
     NSLog(@"tempDict = %@", tempDict);
    videoJSON = tempDict;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    NSLog(@"Part 1 Complete! = %@", searchBar.text);
      NSString *search = searchBar.text;
    [[self searchDisplayController] setActive:NO];
    [self getSearchJSON:NO searchTerm:search];
    [self.tableViewFeatured reloadData];
}

@end
