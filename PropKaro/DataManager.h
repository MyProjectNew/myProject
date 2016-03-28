//
//  DataManager.h
//  Vella
//
//  Created by Pulkit Arora on 22/11/15.
//  Copyright © 2015 Pulkit Arora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLError.h"
#import "PaymentHash.h"

@interface DataManager : NSObject

+ (instancetype)sharedManager;

-(void)getAllRestaurants:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray,NSMutableArray *cuisineList,NSMutableArray *mallHotelList,NSMutableArray *locationsList, NSString *nextUrl, NSNumber *totalCount, NSString * savings, GLError *error))completionBlock;

-(void)getFavouriteRestaurants:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray, NSString *nextUrl, NSNumber *totalCount, GLError *error))completionBlock;

-(void)getNearByRestaurants:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray,NSMutableArray *cuisineList,NSMutableArray *mallHotelList,NSMutableArray *locationsList, NSString *nextUrl, NSNumber *totalCount, GLError *error))completionBlock;

-(void)searchRestaurants:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray, NSString *nextUrl, NSNumber *totalCount, NSString * savings, GLError *error))completionBlock;

-(void)favouriteARestaurant:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL _isSuccess, GLError *error))completionBlock;

-(void)applyFilters:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray, NSString *nextUrl, NSNumber *totalCount, NSString *savings, GLError *error))completionBlock;

-(void)changePassword:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL isSuccess, GLError *error))completionBlock;

-(void)postFeedback:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL isSuccess, GLError *error))completionBlock;

-(void)fetchCityList:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray, GLError *error))completionBlock;

-(void)getRedemptionList:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray, NSString *_nextUrl, NSNumber *totalCount, GLError *error))completionBlock;

- (void)getPaymentHistoryList:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *packsArray, NSMutableArray *transactionArray, NSString * validity, GLError *error))completionBlock;

-(void)redeemCoupons:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL isSuccess, NSString * transactionId, NSString * savings, GLError *error))completionBlock;

-(void)getCodeToResetPassword:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL isSuccess, GLError *error))completionBlock;

-(void)resetPassword:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL isSuccess, GLError *error))completionBlock;

- (void)createPaymentHash:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(PaymentHash * hashInfo, GLError * error))completionBlock;

@end
