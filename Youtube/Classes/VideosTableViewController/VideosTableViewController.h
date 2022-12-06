//
//  VideosTableViewController.h
//  Yewtube
//
//  Created by electimon on 7/15/21.
//  Copyright (c) 2021 electimon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideosTableViewController : UITableViewController
@property (nonatomic, strong) NSString *channelID;
@property (nonatomic, strong) MPMoviePlayerViewController *mp;
@end
