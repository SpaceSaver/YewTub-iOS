//
//  SubscriberTableViewCell.m
//  Yewtube
//
//  Created by electimon on 7/14/21.
//  Copyright (c) 2021 electimon. All rights reserved.
//

#import "SubscriberTableViewCell.h"

@implementation SubscriberTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.indicatorCounter = 0;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
