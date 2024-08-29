//
//  YTInnerTubeAPIClient.m
//  Yewtube
//
//  Created by SpaceSaver2000 on 8/28/24.
//

#import "YTInnerTubeAPIClient.h"

@implementation YTInnerTubeAPIClient

+ (instancetype)sharedClient {
    static YTInnerTubeAPIClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Initialize with default values or load from a configuration
        sharedClient = [[self alloc] initWithAPIKey:@"YOUR_API_KEY" clientVersion:@"YOUR_CLIENT_VERSION"];
    });
    return sharedClient;
}

- (instancetype)initWithAPIKey:(NSString *)apiKey clientVersion:(NSString *)clientVersion {
    self = [super init];
    if (self) {
        _apiKey = apiKey;
        _clientVersion = clientVersion;
        _accessToken = nil; // Access token can be set later
    }
    return self;
}

- (void)sendRequestToEndpoint:(NSString *)endpoint
                   withParams:(NSDictionary *)params
                    onSuccess:(void (^)(NSDictionary *response))success
                    onFailure:(void (^)(NSError *error))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"https://www.youtube.com/youtubei/v1/%@?key=%@", endpoint, self.apiKey];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:self.clientVersion forHTTPHeaderField:@"X-Goog-Visitor-Id"];
    
    if (self.accessToken) {
        NSString *authHeader = [NSString stringWithFormat:@"Bearer %@", self.accessToken];
        [request addValue:authHeader forHTTPHeaderField:@"Authorization"];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    
    if (error) {
        if (failure) {
            failure(error);
        }
        return;
    }
    
    [request setHTTPBody:jsonData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            if (failure) {
                failure(error);
            }
            return;
        }
        
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (success) {
            success(responseDict);
        }
    }];
    
    [task resume];
}

#pragma mark - New Methods

- (void)searchWithQuery:(NSString *)query
              onSuccess:(void (^)(NSDictionary *response))success
              onFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = @{
                             @"context": @{
                                     @"client": @{
                                             @"clientName": @"WEB",
                                             @"clientVersion": self.clientVersion
                                             }
                                     },
                             @"query": query
                             };
    
    [self sendRequestToEndpoint:@"search" withParams:params onSuccess:success onFailure:failure];
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                onSuccess:(void (^)(NSDictionary *response))success
                onFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = @{
                             @"context": @{
                                     @"client": @{
                                             @"clientName": @"WEB",
                                             @"clientVersion": self.clientVersion
                                             }
                                     },
                             @"credentials": @{
                                     @"username": username,
                                     @"password": password
                                     }
                             };
    
    [self sendRequestToEndpoint:@"auth" withParams:params onSuccess:^(NSDictionary *response) {
        self.accessToken = response[@"access_token"];
        if (success) {
            success(response);
        }
    } onFailure:failure];
}

- (void)getRecommendationsOnSuccess:(void (^)(NSDictionary *response))success
                          onFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = @{
                             @"context": @{
                                     @"client": @{
                                             @"clientName": @"WEB",
                                             @"clientVersion": self.clientVersion
                                             }
                                     }
                             };
    
    [self sendRequestToEndpoint:@"browse" withParams:params onSuccess:success onFailure:failure];
}

- (void)loadPlayerResponseForVideoId:(NSString *)videoId
                           onSuccess:(void (^)(NSDictionary *response))success
                           onFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = @{
                             @"context": @{
                                     @"client": @{
                                             @"clientName": @"WEB",
                                             @"clientVersion": self.clientVersion
                                             }
                                     },
                             @"videoId": videoId
                             };
    
    [self sendRequestToEndpoint:@"player" withParams:params onSuccess:success onFailure:failure];
}

@end
