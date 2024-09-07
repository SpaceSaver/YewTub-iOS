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

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180;
}
@end
