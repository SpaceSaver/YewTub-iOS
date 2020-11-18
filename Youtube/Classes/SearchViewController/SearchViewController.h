//
//  SearchViewController.h
//  Youtube
//
//  Created by electimon on 1/20/20.
//  Copyright (c) 2020 1pwn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SearchTableView.h"

@interface SearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SearchTableView *tableViewFeatured;
@property (nonatomic, strong) MPMoviePlayerViewController *mp;


@end
