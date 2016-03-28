//
//  WebServiceManager.h
//  Vella
//
//  Created by Pulkit Arora on 22/11/15.
//  Copyright © 2015 Pulkit Arora. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface WebServiceManager : AFHTTPSessionManager

+ (instancetype)sharedManager;

- (void)createGetRequestWithParameters:(NSDictionary *)parameters withRequestPath:(NSString *)requestPath
                   withCompletionBlock:(void(^)(id responseObject, NSError *error))completionBlock;
- (void)createPostRequestWithParameters:(NSDictionary *)parameters withRequestPath:(NSString *)requestPath
                    withCompletionBlock:(void(^)(id responseObject, NSError *error))completionBlock;

-(void)createPutRequestWithParameters:(NSDictionary *)parameters withRequestPath:(NSString *)requestPath
                  withCompletionBlock:(void(^)(id responseObject, NSError *error))completionBlock;
@end
