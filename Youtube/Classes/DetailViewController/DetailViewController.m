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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"loaded");
    self.navigationItem.title = @"More Info";
    tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[DetailCurrentTableViewCell class] forCellReuseIdentifier:@"DetailCurrentTableViewCell"];
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"called2");
    return 1;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 90;
    
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DetailCurrentTableViewCell *cell = [self->tableView dequeueReusableCellWithIdentifier:@"DetailCurrentTableViewCell"];
    NSLog(@"called!");
    cell.videoDescription = self.currentVideoDescription;
    
    return cell;
}

@end
