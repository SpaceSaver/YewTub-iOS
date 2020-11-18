//
//  MostViewedViewController.h
//  Youtube
//
//  Created by electimon on 1/21/20.
//  Copyright (c) 2020 1pwn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MostViewedViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (nonatomic, strong) MPMoviePlayerViewController *mp;
@end
