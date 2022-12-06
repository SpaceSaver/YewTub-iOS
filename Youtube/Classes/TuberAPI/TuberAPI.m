//
//  TuberAPI.m
//  Youtube
//
//  Created by electimon on 6/29/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#include "AppDelegate.h"
#import "TuberAPI.h"

#define API_BASE_URL "https://www.googleapis.com/youtube/v3/"
#define FEATURED_MAX_RESULTS "2"
#define API_KEY "AIzaSyDtltt-rSBbdsy7EVqwnmGXlqQtrc2FujY"

@implementation TuberAPI

+ (NSString*)parseISO8601Time:(NSString*)duration
{
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    //Get Time part from ISO 8601 formatted duration http://en.wikipedia.org/wiki/ISO_8601#Durations
    duration = [duration substringFromIndex:[duration rangeOfString:@"T"].location];
    
    while ([duration length] > 1) { //only one letter remains after parsing
        duration = [duration substringFromIndex:1];
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:duration];
        
        NSString *durationPart = [[NSString alloc] init];
        [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] intoString:&durationPart];
        
        NSRange rangeOfDurationPart = [duration rangeOfString:durationPart];
        
        duration = [duration substringFromIndex:rangeOfDurationPart.location + rangeOfDurationPart.length];
        
        if ([[duration substringToIndex:1] isEqualToString:@"H"]) {
            hours = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"M"]) {
            minutes = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"S"]) {
            seconds = [durationPart intValue];
        }
    }
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

+(BOOL)initialize {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (!delegate.apiEndpoint) {
        delegate.apiEndpoint = [defaults valueForKey:@"apiEndpoint"];
        if (!delegate.apiEndpoint) {
            delegate.apiEndpoint = @"https://vid.puffyan.us/api/v1";
        }
    }
    if (!delegate.defRes) {
        delegate.defRes = [[defaults valueForKey:@"defRes"] integerValue];
        if (!delegate.defRes) {
            delegate.defRes = 0;
        }
    }
    if (!delegate.oauthToken) {
        delegate.oauthToken = [defaults valueForKey:@"oauthToken"];
        if (!delegate.oauthToken) {
            delegate.oauthToken = @"none";
        }
    }
    
    return YES;
}

+(NSDictionary*)getSubAPI:(NSString*)pageToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *currentAPIURL;
    if (!(pageToken)) {
        currentAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%ssubscriptions?%@&%@&%@&%@", API_BASE_URL, @"mine=true", @"order=alphabetical", @"part=snippet,id", @"maxResults=50"]];
    } else {
        currentAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%ssubscriptions?%@&%@&%@&pageToken=%@&%@", API_BASE_URL, @"mine=true", @"order=alphabetical", @"part=snippet,id", pageToken, @"maxResults=50"]];
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSLog(@"URL = %@", currentAPIURL);
    [request setURL:currentAPIURL];
    NSLog(@"url = %@", currentAPIURL);
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [defaults valueForKey:@"accessToken"]] forHTTPHeaderField:@"Authorization"];

    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"Error = %@", error);
        return nil;
    }
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    return responseDict;
}

+(NSDictionary*)getVideosAPI:(NSString*)pageToken channelID:(NSString*)channelID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *currentAPIURL;
    if (!(pageToken)) {
        currentAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%ssearch?%@=%@&%@&%@&%@", API_BASE_URL, @"channelId", channelID, @"order=date", @"maxResults=50", @"part=snippet,id"]];
    } else {
        currentAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%ssearch?%@=%@&%@&%@&%@&pageToken=%@", API_BASE_URL, @"channelId", channelID, @"order=date", @"maxResults=50", @"part=snippet,id", pageToken]];

    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:currentAPIURL];
    NSLog(@"url = %@", currentAPIURL);
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [defaults valueForKey:@"accessToken"]] forHTTPHeaderField:@"Authorization"];

    
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"Error = %@", error);
        return nil;
    }
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSLog(@"responseDict = %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    return responseDict;
}

@end
