//
//  YTInnerTubeAPIClient.h
//  Yewtube
//
//  Created by SpaceSaver2000 on 8/28/24.
//

#import <Foundation/Foundation.h>

@interface YTInnerTubeAPIClient : NSObject

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *clientVersion;
@property (nonatomic, strong) NSString *accessToken;

// Singleton instance
+ (instancetype)sharedClient;

- (instancetype)initWithAPIKey:(NSString *)apiKey clientVersion:(NSString *)clientVersion;

- (void)sendRequestToEndpoint:(NSString *)endpoint
                   withParams:(NSDictionary *)params
                    onSuccess:(void (^)(NSDictionary *response))success
                    onFailure:(void (^)(NSError *error))failure;

// Methods from previous implementation
- (void)searchWithQuery:(NSString *)query
              onSuccess:(void (^)(NSDictionary *response))success
              onFailure:(void (^)(NSError *error))failure;

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                onSuccess:(void (^)(NSDictionary *response))success
                onFailure:(void (^)(NSError *error))failure;

- (void)getRecommendationsOnSuccess:(void (^)(NSDictionary *response))success
                          onFailure:(void (^)(NSError *error))failure;

- (void)loadPlayerResponseForVideoId:(NSString *)videoId
                           onSuccess:(void (^)(NSDictionary *response))success
                           onFailure:(void (^)(NSError *error))failure;

@end
