//
//  DetailViewController.h
//  Youtube
//
//  Created by electimon on 6/30/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *tableView;
}

@property (nonatomic, strong) NSArray *currentJSON;
@property (nonatomic, strong) NSString *currentVideoID;
@property (nonatomic, strong) NSString *currentVideoDescription;
@property (nonatomic, strong) NSString *currentVideoTags;
@property (nonatomic, strong) NSString *currentVideoCategory;
@property (nonatomic, strong) NSString *currentVideoAdded;

@end
