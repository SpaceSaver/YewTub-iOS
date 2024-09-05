//
//  FeaturedViewController.h
//  Youtube
//
//  Created by electimon on 6/29/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "FeaturedViewController.h"

@interface FeaturedViewController_iPad : FeaturedViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (nonatomic, strong) MPMoviePlayerViewController *mp;

@end