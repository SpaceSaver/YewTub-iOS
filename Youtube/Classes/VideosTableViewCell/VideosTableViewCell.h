//
//  VideosTableViewCell.h
//  Yewtube
//
//  Created by electimon on 7/15/21.
//  Copyright (c) 2021 electimon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideosTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *videoImageIndicator;
@property (nonatomic) int indicatorCounter;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UILabel *publishedLabel;

@end
