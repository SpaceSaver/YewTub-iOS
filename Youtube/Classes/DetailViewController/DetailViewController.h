//
//  DetailViewController.h
//  Youtube
//
//  Created by electimon on 6/30/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (nonatomic, strong) NSArray *currentJSON;
@property (nonatomic, strong) NSString *currentVideoID;
@property (nonatomic, strong) NSString *currentVideoTitle;
@property (nonatomic, strong) NSString *currentVideoDuration;
@property (nonatomic, strong) NSString *currentVideoViews;
@property (nonatomic, strong) NSString *currentVideoCreator;
@property (nonatomic, strong) UIImage *currentVideoImage;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
