//
//  DetailViewController.m
//  Youtube
//
//  Created by electimon on 6/30/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "DetailViewController.h"
#import "../DetailTableViewCell/DetailCurrentTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface DetailViewController ()

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.currentVideoTitle;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 90;
    
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DetailCurrentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCurrentTableViewCell"];
    
    cell.videoImage.image = [UIImage imageNamed:@"noimage"];
    
    cell.durationLabel.text = self.currentVideoDuration;
    [cell.durationLabel sizeToFit];
    
    cell.titleLabel.text = self.currentVideoTitle;
    cell.viewsLabel.text = self.currentVideoViews;
    cell.creatorLabel.text = self.currentVideoCreator;
    
    cell.videoImage.image = self.currentVideoImage;
    cell.videoImage.layer.masksToBounds = YES;
    cell.videoImage.layer.cornerRadius = 7.0;
        
    CGRect newFrame = cell.creatorLabel.frame;
    newFrame.origin.x = CGRectGetMaxX(cell.durationLabel.frame)+10;
    newFrame.origin.y = CGRectGetMinY(cell.durationLabel.frame)-2.2;
    cell.creatorLabel.frame = newFrame;
    
    return cell;
}

@end
