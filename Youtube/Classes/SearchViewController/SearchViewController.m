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
    NSMutableArray *searchJSON;
    NSArray *videoJSON;
    AppDelegate *delegate;
    NSMutableArray *suggestJSON;
    NSDictionary *suggestJSONResults;
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
        return [suggestJSON count];
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
        if (suggestJSONResults || suggestJSONResults.count){
            cell.textLabel.text = [suggestJSON objectAtIndex:indexPath.row];
        }
        return cell;
    } else {
     
        FeaturedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeaturedTableViewCell"];
        
        cell.videoImage.image = [UIImage imageNamed:@"noimage"];
        cell.detailButton.enabled = NO;
        cell.videoImageIndicator.hidden = NO;
        [cell.videoImageIndicator startAnimating];
            
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
            
            NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[[[searchJSON objectAtIndex:indexPath.row] valueForKey:@"viewCount"] integerValue]]];
            
            cell.viewsLabel.text = [formatted stringByAppendingString:@" views"];
        
        
            int durationMin = [[[searchJSON objectAtIndex:indexPath.row] valueForKey:@"lengthSeconds"] integerValue];
            int durationSec = durationMin % 60;
        
            durationMin = durationMin / 60;
            durationMin = floorf(durationMin);
        
            bool durationSecInRange = NSLocationInRange(durationSec, NSMakeRange(0, (9 - 0)));
        
            if (durationSecInRange == true) {
                cell.durationLabel.text = [NSString stringWithFormat:@"%d:0%d", durationMin, durationSec];
            } else {
                cell.durationLabel.text = [NSString stringWithFormat:@"%d:%d", durationMin, durationSec];
            }
        
        cell.titleLabel.text = [[searchJSON objectAtIndex:indexPath.row] valueForKey:@"title"];
        cell.creatorLabel.text = [[searchJSON objectAtIndex:indexPath.row] valueForKey:@"author"];
        
        CGRect newFrame = cell.creatorLabel.frame;
        newFrame.origin.x = CGRectGetMaxX(cell.durationLabel.frame)+10;
        newFrame.origin.y = CGRectGetMinY(cell.durationLabel.frame)-2.2;
        cell.creatorLabel.frame = newFrame;
        
        
            NSString *imageURLstr = [[[[searchJSON objectAtIndex:indexPath.row] valueForKey:@"videoThumbnails"] objectAtIndex:3] valueForKey:@"url"];
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
            
            
            if (suggestJSON == nil) {
                [self getSearchJSON:YES searchTerm:searchText];
                if (suggestJSON == nil) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The server could not be contacted, try again later!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertView show];
                }
            }
            
            suggestJSONResults = [suggestJSON valueForKey:@"suggestions"];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [suggestJSON removeAllObjects];
                [self.searchDisplayController.searchResultsTableView reloadData];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            suggestJSON = suggestJSONResults;
            if (suggestJSON) {
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
        });
    }];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"Part 1 Complete! = %@", [suggestJSON objectAtIndex:indexPath.row]);
        NSString *search = [suggestJSON objectAtIndex:indexPath.row];
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
    NSURL *searchAPIURL;
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
    
    NSMutableArray *tempDict = [NSJSONSerialization JSONObjectWithData:responseData options: NSJSONReadingMutableContainers error:NULL];
    if (suggestable) {
        suggestJSON = tempDict;
    } else {
        NSMutableArray *remove = [NSMutableArray new];
        for (NSArray *object in tempDict) {
            if ([object valueForKey:@"viewCount"] == 0) {
                [remove addObject:object];
            }
        }
        [tempDict removeObjectsInArray:remove];
        searchJSON = tempDict;
        
        // Now's our chance to scroll to the top
        NSIndexPath *topPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableViewFeatured scrollToRowAtIndexPath:topPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    }
    
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
