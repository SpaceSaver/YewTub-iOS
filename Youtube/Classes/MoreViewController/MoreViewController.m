//
//  MoreViewController.m
//  Yewtube
//
//  Created by electimon on 7/13/21.
//  Copyright (c) 2021 electimon. All rights reserved.
//

#import "MoreViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "SVProgressHUD.h"

@interface MoreViewController ()

@end

@implementation MoreViewController {
    UIAlertView *alert;
    UIWebView *webView;
    NSUserDefaults *defaults;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    defaults = [NSUserDefaults standardUserDefaults];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.sectionHeaderHeight = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    // Configure the cell...
    NSLog(@"Running");
    switch (indexPath.row) {
        case 0:
            NSLog(@"Unicode");
            cell.textLabel.text = @"Subscriptions";
            break;
        case 1:
            cell.textLabel.text = @"My Videos";
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            NSLog(@"Selected Subscriptions");
            [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
            [self performSegueWithIdentifier:@"MoreToSubPush" sender:self];
            break;
        case 1:
            NSLog(@"Selected My Videos");
            break;
        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Called!");
    if ([segue.identifier isEqual:@"FeaturedDetailPush"]) {
    
    }
}


- (IBAction)signinButtonClick:(id)sender {
    NSLog(@"Just clicked ur mum ");
    NSError *error;
    NSString *urlString = @"https://oauth2.googleapis.com/token";
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *oauthToken = [defaults objectForKey:@"oauthToken"];
    if (![defaults objectForKey:@"accessToken"] || [defaults boolForKey:@"tokenNeedsRefresh"] == YES) {
        if (oauthToken) {
            NSLog(@"AAA = %@", [defaults dictionaryRepresentation]);
            [SVProgressHUD show];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            
            NSString *parameterString = [NSString stringWithFormat:@"client_id=277136978076-las5e1p14oe1vg6m357279bqqc97etcn.apps.googleusercontent.com&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=%@", oauthToken];
            
            NSLog(@"%@",parameterString);
            
            [request setHTTPMethod:@"POST"];
            
            [request setURL:url];
            
            NSData *postData = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
            
            [request setHTTPBody:postData];
            
            NSData *finalData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            
            NSLog(@"honour = %@", [[NSString alloc] initWithData:finalData encoding:NSUTF8StringEncoding]);
            error = nil;
            NSDictionary *finalArray = [NSJSONSerialization JSONObjectWithData:finalData options:kNilOptions error:&error];
            if (error != nil || [finalArray objectForKey:@"error"]) {
                // error contains something gay check it
                NSLog(@"a shack deep in the forest no one ever comes near");
                if ([[finalArray valueForKey:@"error"] isEqualToString:@"invalid_grant"]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sign in" message:@"Sign in failed! Check your OAuth Token!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alertView show];
                    [SVProgressHUD dismiss];
                    return;
                }
            } else {
                NSLog(@"finallyArray = %@", finalArray);
                [defaults setValue:[finalArray valueForKey:@"access_token"] forKey:@"accessToken"];
                [defaults setValue:[finalArray valueForKey:@"refresh_token"] forKey:@"refreshToken"];
                [defaults setValue:[finalArray valueForKey:@"expires_in"] forKey:@"tokenExpiresIn"];
                [defaults synchronize];
                [SVProgressHUD dismiss];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sign in" message:@"Sign in Successful!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sign in" message:@"Sign in failed! Check your OAuth Token!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"OAuth Token" message:@"No OAuth Token Found, Set one in Settings!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
            [SVProgressHUD dismiss];
            return;
        }
    } else {
        NSLog(@"accessToken = %@", [defaults valueForKey:@"accessToken"]);
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sign In" message:@"Already Signed In!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        [SVProgressHUD dismiss];
        return;
    }
}

@end
