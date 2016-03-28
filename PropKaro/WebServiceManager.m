//
//  WebServiceManager.m
//  
//
//  Created by Pulkit Arora on 22/11/15.
//  Copyright © 2015 Pulkit Arora. All rights reserved.
//

#import "WebServiceManager.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFNetworkReachabilityManager.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface WebServiceManager()

@property (nonatomic, strong) NSMutableArray *allTasks;

@end

@implementation WebServiceManager

+ (WebServiceManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static WebServiceManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:@""]];
        
    });
    return sharedManager;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self)
    {
        AFJSONResponseSerializer *responseSer = [AFJSONResponseSerializer serializer];
        responseSer.removesKeysWithNullValues = YES;
        responseSer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json", @"text/plain", @"text/html"]];
        
        self.responseSerializer = responseSer;
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 60.0;
    }
    return self;
}

- (void)createGetRequestWithParameters:(NSDictionary *)parameters
                       withRequestPath:(NSString *)requestPath
                   withCompletionBlock:(void(^)(id responseObject, NSError *error))completionBlock
{
    NSError *error = [self checkAndCreateInternetError];
    if (error) {
        if (completionBlock) {
            completionBlock(nil, error);
        }
        return;
    }
    
    NSDictionary *finalParameters = [NSDictionary dictionaryWithDictionary:parameters];
    NSURLSessionDataTask *task = [self GET:requestPath parameters:finalParameters success:^(NSURLSessionDataTask *task, id responseObject)
                                  {
                                     
                                      @try
                                      {
                                          if (completionBlock) {
                                              completionBlock(responseObject, nil);
                                          }
                                      }
                                      @catch (NSException *e)
                                      {
                                          if (completionBlock) {
                                              completionBlock(nil, [WebServiceManager getExceptionError]);
                                          }
                                      }
                                      [self removeTask:task];
                                      
                                  } failure:^(NSURLSessionDataTask *task, NSError *error)
                                  {
                                      if (completionBlock) {
                                          completionBlock(nil, error);
                                      }
                                      
                                      [self removeTask:task];
                                  }];
    [self addTask:task];
}

- (void)createPostRequestWithParameters:(NSDictionary *)parameters
                        withRequestPath:(NSString *)requestPath
                    withCompletionBlock:(void(^)(id responseObject, NSError *error))completionBlock
{
    NSError *error = [self checkAndCreateInternetError];
    if (error) {
        if (completionBlock) {
            completionBlock(nil, error);
        }
        return;
    }
    
    NSDictionary *finalParameters = [NSDictionary dictionaryWithDictionary:parameters];
    NSURLSessionDataTask *task = [self POST:requestPath parameters:finalParameters success:^(NSURLSessionDataTask *task, id responseObject)
                                  {
                                      @try
                                      {
                                          if (completionBlock) {
                                              completionBlock(responseObject, nil);
                                          }
                                      }
                                      @catch (NSException *e)
                                      {
                                          if (completionBlock) {
                                              completionBlock(nil, [WebServiceManager getExceptionError]);
                                          }
                                      }
                                      
                                      [self removeTask:task];
                                      
                                  } failure:^(NSURLSessionDataTask *task, NSError *error)
                                  {
                                      if (completionBlock) {
                                          completionBlock(nil, error);
                                      }
                                      [self removeTask:task];
                                  }];
    [self addTask:task];
}

- (NSError *)checkAndCreateInternetError
{
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
        NSDictionary *dict = @{NSLocalizedDescriptionKey : @"Oops!! Your internet connection seems to be offline. Please try again."};
        NSError *error = [NSError errorWithDomain:@"ed" code:1986 userInfo:dict];
        return error;
    }
    
    return nil;
}

- (void)createPutRequestWithParameters:(NSDictionary *)parameters
                       withRequestPath:(NSString *)requestPath
                   withCompletionBlock:(void(^)(id responseObject, NSError *error))completionBlock
{
    NSError *error = [self checkAndCreateInternetError];
    if (error) {
        if (completionBlock) {
            completionBlock(nil, error);
        }
        return;
    }
    
    NSURLSessionDataTask *task = [self PUT:requestPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject)
                                  {
                                      @try
                                      {
                                          if (completionBlock) {
                                              completionBlock(responseObject, nil);
                                          }
                                      }
                                      @catch (NSException *e)
                                      {
                                          if (completionBlock) {
                                              completionBlock(nil, [WebServiceManager getExceptionError]);
                                          }
                                      }
                                      
                                      [self removeTask:task];
                                  }
                                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       if (completionBlock) {
                                           completionBlock(nil, error);
                                       }
                                       [self removeTask:task];
                                   }];
    [self addTask:task];
}

- (void)addTask:(id)task
{
    if (!self.allTasks)
        self.allTasks = [[NSMutableArray alloc] init];
    
    [self.allTasks addObject:task];
}

- (void)removeTask:(id)task
{
    [self.allTasks removeObject:task];
}

- (void)cancelAllTasks
{
    for (id task in self.allTasks)
    {
        if ([task isKindOfClass:[NSURLSessionDataTask class]]) {
            [(NSURLSessionDataTask *)task cancel];
        }
        else if ([task isKindOfClass:[AFHTTPRequestOperation class]]) {
            [(AFHTTPRequestOperation *)task cancel];
        }
    }
    
    [self.allTasks removeAllObjects];
}

+ (NSError *)getExceptionError
{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:@"" forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"gp" code:200 userInfo:details];
    return error;
}

@end
