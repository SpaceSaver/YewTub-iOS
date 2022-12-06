//
//  SubscriberTableViewCell.h
//  Yewtube
//
//  Created by electimon on 7/14/21.
//  Copyright (c) 2021 electimon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscriberTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subscribedLabel;
@property (nonatomic) int indicatorCounter;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;

@end
