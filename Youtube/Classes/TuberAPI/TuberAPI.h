//
//  TuberAPI.h
//  Youtube
//
//  Created by electimon on 6/29/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TuberAPI : NSObject

+ (NSString*)parseISO8601Time:(NSString*)duration;
+ (BOOL)initialize;
+ (NSDictionary*)getSubAPI:(NSString*)pageToken;
+ (NSDictionary*)getVideosAPI:(NSString*)pageToken channelID:(NSString*)channelID;

@end
