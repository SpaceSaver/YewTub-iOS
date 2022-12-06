//
//  VideosTableViewCell.m
//  Yewtube
//
//  Created by electimon on 7/15/21.
//  Copyright (c) 2021 electimon. All rights reserved.
//

#import "VideosTableViewCell.h"

@implementation VideosTableViewCell

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
