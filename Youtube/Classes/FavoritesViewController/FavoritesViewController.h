//
//  FavoritesViewController.h
//  Youtube
//
//  Created by electimon on 1/21/20.
//  Copyright (c) 2020 1pwn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface FavoritesViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) MPMoviePlayerViewController *mp;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@end
