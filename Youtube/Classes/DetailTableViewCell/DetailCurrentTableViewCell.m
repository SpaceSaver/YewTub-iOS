//
//  DetailTableViewCell.m
//  Youtube
//
//  Created by electimon on 6/30/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "DetailCurrentTableViewCell.h"

@implementation DetailCurrentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
