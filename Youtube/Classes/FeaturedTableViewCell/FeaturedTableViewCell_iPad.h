//
//  FeaturedTableViewCell.h
//  Youtube
//
//  Created by electimon on 6/29/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "FeaturedTableViewCell.h"

@interface FeaturedTableViewCell_iPad : FeaturedTableViewCell

//#import <UIKit/UIKit.h>
//
//@interface FeaturedTableViewCell_iPad : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *videoImageIndicator;
@property (nonatomic) int indicatorCounter;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
//@property (weak, nonatomic) IBOutlet UILabel *publicationDate;


@end
