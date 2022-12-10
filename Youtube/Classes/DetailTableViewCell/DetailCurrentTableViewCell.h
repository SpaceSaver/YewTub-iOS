//
//  DetailTableViewCell.h
//  Youtube
//
//  Created by electimon on 6/30/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCurrentTableViewCell : UITableViewCell
@property (nonatomic, strong) NSString *videoDescription;
@property (nonatomic, strong) NSString *videoTags;
@property (nonatomic, strong) NSString *videoCategory;
@property (nonatomic, strong) NSString *videoAdded;
@property (strong, nonatomic) IBOutlet UILabel *viewsLabel;

@end
