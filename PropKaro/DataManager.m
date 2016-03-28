//
//  DataManager.m

//
//  Created by Pulkit Arora on 22/11/15.
//  Copyright © 2015 Pulkit Arora. All rights reserved.
//

#import "DataManager.h"
#import "WebServiceManager.h"
#import "WebEngineConstants.h"
#import "RestaurantModel.h"
#import "GLUtility.h"
#import "GLAccountManager.h"
#import "GLConstants.h"
#import "FilterModel.h"
#import "CuisineModel.h"
#import "LocationsModel.h"
#import "CostModel.h"
#import "CityModel.h"
#import "RedemptionModel.h"
#import "PaymentModel.h"
#import "GLPurchaseItem.h"

@implementation DataManager

+ (instancetype)sharedManager{
    
    static DataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataManager alloc] init];
    });
    
    return sharedInstance;
}

-(void)getAllRestaurants:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray,NSMutableArray *cuisineList,NSMutableArray *mallHotelList,NSMutableArray *locationsList, NSString *nextUrl, NSNumber *totalCount, NSString * savings, GLError *error))completionBlock
{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else
        {
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    //Warning city_id harcoded for V1
//    NSString * userCity = (NSString *)[GLAccountManager getDataForKey:kUserCityId];
    NSString * userCity = @"76";
    if (userCity.length > 0) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:userCity forKey:kUserCityId];
        }
        else{
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:userCity forKey:kUserCityId];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            GLLOG(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(nil,nil, nil,nil,nil, nil, nil, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(nil,nil, nil,nil,nil, nil, nil, errorC);
                    return;
                }
            }
            else
            {
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"])
                    {
                        if ([[responseObject allKeys] containsObject:@"message"])
                        {
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        completionBlock(nil, nil, nil,nil, nil, nil, nil, errorC);
                    }
                }

                NSString * nextUrl;
                NSNumber * totalCount;
                if ([[responseObject allKeys] containsObject:@"UrlNext"])
                {
                    nextUrl = responseObject[@"UrlNext"];
                }
                if ([[responseObject allKeys] containsObject:@"total_records"]) {
                    totalCount = [NSNumber numberWithInteger:[responseObject[@"total_records"] integerValue]];
                }
                if ([[responseObject allKeys] containsObject:@"restaurantList"]) {
                    
                        NSArray * outletList = (NSArray *)responseObject[@"restaurantList"];
                            NSMutableArray * restaurantList = [[NSMutableArray alloc] init];
                            for (NSDictionary * dict in outletList) {
                                if ([[dict allKeys] containsObject:@"nID"]) {
                                    RestaurantModel * restaurant = [[RestaurantModel alloc] initWithDictionary:dict];
                                    
                                    [restaurantList addObject:restaurant];
                                }
                                
                            }
                        NSString * savings = nil;

                        NSMutableArray *cuisineList = [[NSMutableArray alloc] init];
                        NSMutableArray *costRangeList = [[NSMutableArray alloc] init];
                        NSMutableArray *locationsList = [[NSMutableArray alloc] init];
                        NSArray *cuisineArray,*mallHotelArray,*locationsArray;
                  
                        if ([[responseObject allKeys] containsObject:@"cuisine"])
                        {
                            if (responseObject[@"cuisine"]) {
                                cuisineArray = (NSArray *)responseObject[@"cuisine"];
                                for (NSDictionary * dict in cuisineArray) {
                                    CuisineModel * cuisine = [[CuisineModel alloc] initWithDictionary:dict];
                                    [cuisineList addObject:cuisine];
                                }
                            }
                        }
                        
                        if ([[responseObject allKeys] containsObject:@"cost"])
                        {
                            if (responseObject[@"cost"]) {
                                mallHotelArray = (NSArray *)responseObject[@"cost"];
                                for (NSDictionary * dict in mallHotelArray) {
                                    CostModel *cost = [[CostModel alloc] initWithDictionary:dict];
                                    [costRangeList addObject:cost];
                                }
                            }
                        }

                        if ([[responseObject allKeys] containsObject:@"locations"])
                        {
                            if (responseObject[@"locations"]) {
                                locationsArray = (NSArray *)responseObject[@"locations"];
                                for (NSDictionary * dict in locationsArray) {
                                    LocationsModel * locations = [[LocationsModel alloc] initWithDictionary:dict];
                                    [locationsList addObject:locations];
                                }
                            }
                        }
                        if ([[responseObject allKeys] containsObject:@"youSave"])
                        {
                            if (responseObject[@"youSave"]){
                                savings = responseObject[@"youSave"];
                            }
                        }
            
                        if (completionBlock) {
                            completionBlock(restaurantList,cuisineList,costRangeList,locationsList, nextUrl, totalCount, savings, nil);
                        }
                    }
                else{
                    errorC = [[GLError alloc] init];
                    if (completionBlock) {
                        completionBlock(nil,nil, nil,nil,nil, nil, nil, errorC);
                        return;
                    }
                }
            }
        }
    }];
}

-(void)getFavouriteRestaurants:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray, NSString *nextUrl, NSNumber *totalCount, GLError *error))completionBlock
{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else
        {
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            GLLOG(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(nil, nil, nil, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(nil, nil, nil, errorC);
                    return;
                }
            }
            else
            {
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"])
                    {
                        if ([[responseObject allKeys] containsObject:@"message"])
                        {
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        completionBlock(nil, nil, nil, errorC);
                    }
                }

                NSString * nextUrl;
                NSNumber * totalCount;
                if ([[responseObject allKeys] containsObject:@"UrlNext"])
                {
                    nextUrl = responseObject[@"UrlNext"];
                }
                if ([[responseObject allKeys] containsObject:@"total_records"]) {
                    totalCount = [NSNumber numberWithInteger:[responseObject[@"total_records"] integerValue]];
                }
                if ([[responseObject allKeys] containsObject:@"restaurantisFvr"]) {
                    
                    NSArray * outletList = (NSArray *)responseObject[@"restaurantisFvr"];
                    NSMutableArray * restaurantList = [[NSMutableArray alloc] init];
                    for (NSDictionary * dict in outletList) {
                        if ([[dict allKeys] containsObject:@"nID"]){
                        RestaurantModel * restaurant = [[RestaurantModel alloc] initWithDictionary:dict];
                        [restaurantList addObject:restaurant];
                        }
                    }
                    if (completionBlock) {
                        completionBlock(restaurantList, nextUrl, totalCount, nil);
                    }
                }
                else{
                    errorC = [[GLError alloc] init];
                    if (completionBlock) {
                        completionBlock(nil, nil, nil, errorC);
                        return;
                    }
                }
            }
        }
    }];
}

-(void)applyFilters:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray, NSString *nextUrl, NSNumber *totalCount, NSString *savings, GLError *error))completionBlock
{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else
        {
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    //Warning city_id harcoded for V1
    //    NSString * userCity = (NSString *)[GLAccountManager getDataForKey:kUserCityId];
    NSString * userCity = @"76";
    if (userCity.length > 0) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:userCity forKey:kUserCityId];
        }
        else{
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:userCity forKey:kUserCityId];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }

    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            GLLOG(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(nil, nil, nil, nil, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(nil, nil, nil, nil, errorC);
                    return;
                }
            }
            else{
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        completionBlock(nil, nil, nil, nil, errorC);
                    }
                }
                
                NSString * nextUrl;
                NSString * savings;
                NSNumber * totalCount;
                if ([[responseObject allKeys] containsObject:@"UrlNext"]){
                    nextUrl = responseObject[@"UrlNext"];
                }
                if ([[responseObject allKeys] containsObject:@"total_records"]) {
                    totalCount = [NSNumber numberWithInteger:[responseObject[@"total_records"] integerValue]];
                }
                if ([[responseObject allKeys] containsObject:@"youSave"])
                {
                    if (responseObject[@"youSave"]){
                        savings = responseObject[@"youSave"];
                    }
                }
                if ([[responseObject allKeys] containsObject:@"searchList"]) {
                    NSArray * outletList = (NSArray *)responseObject[@"searchList"];
                    NSMutableArray * restaurantList = [[NSMutableArray alloc] init];
                    for (NSDictionary * dict in outletList) {
                        if ([[dict allKeys] containsObject:@"nID"]){
                        RestaurantModel * restaurant = [[RestaurantModel alloc] initWithDictionary:dict];
                        [restaurantList addObject:restaurant];
                        }
                    }
                    if (completionBlock) {
                        completionBlock(restaurantList, nextUrl, totalCount, savings, nil);
                    }
                }
                else{
                    errorC = [[GLError alloc] init];
                    if (completionBlock) {
                        completionBlock(nil, nil, nil, nil, errorC);
                        return;
                    }
                }
            }
        }
    }];
}

-(void)getNearByRestaurants:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray,NSMutableArray *cuisineList,NSMutableArray *mallHotelList,NSMutableArray *locationsList, NSString *nextUrl, NSNumber *totalCount, GLError *error))completionBlock{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else
        {
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    NSString * userCity = (NSString *)[GLAccountManager getDataForKey:kUserCityId];
    if (userCity.length > 0) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:userCity forKey:kUserCityId];
        }
        else{
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:userCity forKey:kUserCityId];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            GLLOG(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(nil, nil, nil, nil, nil, nil, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(nil, nil, nil, nil, nil, nil, errorC);
                    return;
                }
            }
            else{
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        completionBlock(nil, nil, nil,nil, nil, nil, errorC);
                    }
                }
                NSString * nextUrl;
                NSNumber * totalCount;
                if ([[responseObject allKeys] containsObject:@"UrlNext"]){
                    nextUrl = responseObject[@"UrlNext"];
                }
                if ([[responseObject allKeys] containsObject:@"total_records"]) {
                    totalCount = [NSNumber numberWithInteger:[responseObject[@"total_records"] integerValue]];
                }
                if ([[responseObject allKeys] containsObject:@"nearbySearch"]) {
                    NSArray * outletList = (NSArray *)responseObject[@"nearbySearch"];
                    NSMutableArray * restaurantList = [[NSMutableArray alloc] init];
                    for (NSDictionary * dict in outletList) {
                        if ([[dict allKeys] containsObject:@"nID"]){
                        RestaurantModel * restaurant = [[RestaurantModel alloc] initWithDictionary:dict];
                        [restaurantList addObject:restaurant];
                        }
                    }
                    NSMutableArray *cuisineList = [[NSMutableArray alloc] init];
                    NSMutableArray *costRangeList = [[NSMutableArray alloc] init];
                    NSMutableArray *locationsList = [[NSMutableArray alloc] init];
                    NSArray *cuisineArray,*mallHotelArray,*locationsArray;
                    
                    if ([[responseObject allKeys] containsObject:@"cuisine"]){
                        if (responseObject[@"cuisine"]) {
                            cuisineArray = (NSArray *)responseObject[@"cuisine"];
                            for (NSDictionary * dict in cuisineArray) {
                                CuisineModel * cuisine = [[CuisineModel alloc] initWithDictionary:dict];
                                [cuisineList addObject:cuisine];
                            }
                        }
                    }
                    if ([[responseObject allKeys] containsObject:@"cost"]){
                        if (responseObject[@"cost"]) {
                            mallHotelArray = (NSArray *)responseObject[@"cost"];
                            for (NSDictionary * dict in mallHotelArray) {
                                CostModel *cost = [[CostModel alloc] initWithDictionary:dict];
                                [costRangeList addObject:cost];
                            }
                        }
                    }
                    if ([[responseObject allKeys] containsObject:@"locations"]){
                        if (responseObject[@"locations"]) {
                            locationsArray = (NSArray *)responseObject[@"locations"];
                            for (NSDictionary * dict in locationsArray) {
                                LocationsModel * locations = [[LocationsModel alloc] initWithDictionary:dict];
                                [locationsList addObject:locations];
                            }
                        }
                    }
                    if (completionBlock) {
                        completionBlock(restaurantList,cuisineList,costRangeList,locationsList, nextUrl, totalCount, nil);
                    }
                }
                else{
                    errorC = [[GLError alloc] init];
                    if (completionBlock) {
                        completionBlock(nil,nil, nil,nil,nil, nil, errorC);
                        return;
                    }
                }
            }
        }
    }];
}

-(void)searchRestaurants:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray, NSString *nextUrl, NSNumber *totalCount, NSString * savings, GLError *error))completionBlock{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else{
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    //Warning city_id harcoded for V1
    //    NSString * userCity = (NSString *)[GLAccountManager getDataForKey:kUserCityId];
    NSString * userCity = @"76";
    if (userCity.length > 0) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:userCity forKey:kUserCityId];
        }
        else{
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:userCity forKey:kUserCityId];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }

    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            GLLOG(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(nil, nil, nil, nil, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(nil, nil, nil, nil, errorC);
                    return;
                }
            }
            else{
                NSString * savings;
//                NSNumber * totalCount;
//                if ([[responseObject allKeys] containsObject:@"UrlNext"])
//                {
//                    nextUrl = responseObject[@"UrlNext"];
//                }
//                if ([[responseObject allKeys] containsObject:@"total_records"]) {
//                    totalCount = [NSNumber numberWithInteger:[responseObject[@"total_records"] integerValue]];
//                }
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        completionBlock(nil, nil, nil, nil, errorC);
                    }
                }
                if ([[responseObject allKeys] containsObject:@"youSave"])
                {
                    if (responseObject[@"youSave"]){
                        savings = responseObject[@"youSave"];
                    }
                }
                if ([[responseObject allKeys] containsObject:@"searchList"]) {
                    NSArray * outletList = (NSArray *)responseObject[@"searchList"];
                    NSMutableArray * restaurantList = [[NSMutableArray alloc] init];
                    for (NSDictionary * dict in outletList) {
                        if ([[dict allKeys] containsObject:@"nID"]){
                        RestaurantModel * restaurant = [[RestaurantModel alloc] initWithDictionary:dict];
                        [restaurantList addObject:restaurant];
                        }
                    }
                    if (completionBlock) {
                        completionBlock(restaurantList, nil, nil, savings, nil);
                    }
                }
                else{
                    errorC = [[GLError alloc] init];
                    if (completionBlock) {
                        completionBlock(nil, nil, nil, nil, errorC);
                        return;
                    }
                }
            }
        }
    }];
}

-(void)favouriteARestaurant:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL _isSuccess, GLError *error))completionBlock{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else
        {
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }

    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            NSLog(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(false, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(false, errorC);
                    return;
                }
            }
            else{
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        completionBlock(false, errorC);
                    }
                }
                if ([[responseObject allKeys] containsObject:@"detail"]) {
                    
                    NSDictionary * detail = (NSDictionary *)responseObject[@"detail"];
                    if ([[detail allKeys]containsObject:@"status"]) {
                        NSString * status = (NSString *)detail[@"status"];
                        BOOL stat = NO;
                        if ([status isEqualToString:@"y"]) {
                            stat = YES;
                        }
                        completionBlock(stat, nil);
                    }
                }
                else{
                    errorC = [[GLError alloc] init];
                    if (completionBlock) {
                        completionBlock(false, errorC);
                        return;
                    }
                }
            }
        }
    }];
}

-(void)changePassword:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL isSuccess, GLError *error))completionBlock{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else
        {
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    
    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            NSLog(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(false, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(false, errorC);
                    return;
                }
            }
            else{
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        completionBlock(false, errorC);
                    }
                    else{
                         completionBlock(true, nil);
                    }
                }
            }
        }
    }];
}

-(void)postFeedback:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL isSuccess, GLError *error))completionBlock{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else{
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            NSLog(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(false, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(false, errorC);
                    return;
                }
            }
            else{
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        completionBlock(false, errorC);
                    }
                    else{
                        completionBlock(true, nil);
                    }
                }
            }
        }
    }];
}

-(void)fetchCityList:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray, GLError *error))completionBlock{
    [[WebServiceManager sharedManager] createGetRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            NSLog(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(false, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(false, errorC);
                    return;
                }
            }
            else{
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        completionBlock(nil, errorC);
                    }
                }
                if([[responseObject allKeys] containsObject:@"cityList"]){
                    NSMutableArray * cityArray = [[NSMutableArray alloc] init];
                    NSMutableArray * cityList = (NSMutableArray *)responseObject[@"cityList"];
                    for (NSDictionary * dict in cityList) {
                        CityModel * city = [[CityModel alloc] initWithDictionary:dict];
                        [cityArray addObject:city];
                    }
                    completionBlock (cityArray, nil);
                }
                else{
                    errorC = [[GLError alloc] init];
                    if (completionBlock) {
                        completionBlock(false, errorC);
                        return ;
                    }
                }
            }
        }
    }];
}


- (void)getPaymentHistoryList:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *packsArray, NSMutableArray *transactionArray, NSString * validity, GLError *error))completionBlock{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else{
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    //Warning city_id harcoded for V1
    //    NSString * userCity = (NSString *)[GLAccountManager getDataForKey:kUserCityId];
    NSString * userCity = @"76";
    if (userCity.length > 0) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:userCity forKey:kUserCityId];
        }
        else{
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:userCity forKey:kUserCityId];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    
    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            NSLog(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(nil, nil, nil, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(nil, nil, nil, errorC);
                    return;
                }
            }
            else{
                NSString * nextUrl;
                NSNumber * totalCount;
                if ([[responseObject allKeys] containsObject:@"UrlNext"])
                {
                    nextUrl = responseObject[@"UrlNext"];
                }
                if ([[responseObject allKeys] containsObject:@"total_records"]) {
                    totalCount = [NSNumber numberWithInteger:[responseObject[@"total_records"] integerValue]];
                }

                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        completionBlock(nil, nil, nil, errorC);
                    }
                }
                NSString * lastDate;
                if ([[responseObject allKeys] containsObject:@"tillDate"])
                {
                    lastDate = responseObject[@"tillDate"];
                }
                
                NSMutableArray * txnHisArray = [[NSMutableArray alloc] init];
                NSMutableArray * packsArray = [[NSMutableArray alloc] init];
                if([[responseObject allKeys] containsObject:@"slab"]){
                    NSMutableArray * slabs = (NSMutableArray *)responseObject[@"slab"];
                    for (NSDictionary * dict in slabs) {
                        GLPurchaseItem * pack = [[GLPurchaseItem alloc] initWithDictionary:dict];
                        
                        NSAttributedString *attString = [[NSAttributedString alloc] initWithData:[dict[@"desc"] dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
                        
                        pack.packDesc = [attString.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        [packsArray addObject:pack];
                    }

                    if([[responseObject allKeys] containsObject:@"history"]){
                        NSMutableArray * paymentList = (NSMutableArray *)responseObject[@"history"];
                        for (NSDictionary * dict in paymentList) {
                            PaymentModel * redemption = [[PaymentModel alloc] initWithDictionary:dict];
                            [txnHisArray addObject:redemption];
                        }
                    }
                    completionBlock (packsArray, txnHisArray, lastDate, nil);
                }
                else{
                    errorC = [[GLError alloc] init];
                    if (completionBlock) {
                        completionBlock(nil, nil, nil, errorC);
                        return ;
                    }
                }
            }
        }
    }];
}


-(void)getRedemptionList:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(NSMutableArray *responseArray, NSString *_nextUrl, NSNumber *totalCount,  GLError *error))completionBlock{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else{
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            NSLog(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(nil, nil, nil, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(nil, nil, nil, errorC);
                    return;
                }
            }
            else{
                NSString * nextUrl;
                NSNumber * totalCount;
                if ([[responseObject allKeys] containsObject:@"UrlNext"])
                {
                    nextUrl = responseObject[@"UrlNext"];
                }
                if ([[responseObject allKeys] containsObject:@"total_records"]) {
                    totalCount = [NSNumber numberWithInteger:[responseObject[@"total_records"] integerValue]];
                }
                
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        completionBlock(nil, nil, nil, errorC);
                    }
                }
                if([[responseObject allKeys] containsObject:@"redemptions"]){
                    NSMutableArray * cityArray = [[NSMutableArray alloc] init];
                    NSMutableArray * cityList = (NSMutableArray *)responseObject[@"redemptions"];
                    for (NSDictionary * dict in cityList) {
                        RedemptionModel * redemption = [[RedemptionModel alloc] initWithDictionary:dict];
                        [cityArray addObject:redemption];
                    }
                    completionBlock (cityArray, nextUrl, totalCount, nil);
                }
                else{
                    errorC = [[GLError alloc] init];
                    if (completionBlock) {
                        completionBlock(nil, nil, nil, errorC);
                        return ;
                    }
                }
            }
        }
    }];
}

-(void)redeemCoupons:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL isSuccess, NSString * transactionId, NSString * savings, GLError *error))completionBlock{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else{
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            NSLog(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(false, nil, nil, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(false, nil, nil, errorC);
                    return;
                }
            }
            else{
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        if (completionBlock){
                            completionBlock(false, nil, nil, nil);
                        }
                    }
                    else{
                        if ([[responseObject allKeys] containsObject:@"transactionid"] && [[responseObject allKeys] containsObject:kUserSavingsKey]) {
                            NSNumber * txn_id = (NSNumber *)responseObject[@"transactionid"];
                            
                            NSString * transaction_id = [NSString stringWithFormat:@"%ld",[txn_id longValue]];
                            NSString * savings = (NSString *)responseObject[kUserSavingsKey];
                            
                            if (transaction_id && transaction_id.length > 0) {
                                if (completionBlock){
                                    completionBlock (true, transaction_id, savings, nil);
                                }
                            }
                            else{
                                completionBlock (false, nil, nil, nil);
                            }
                        }
                        else{
                            errorC = [[GLError alloc] init];
                            completionBlock (false, nil, nil, errorC);
                        }
                    }
                }
            }
        }
    }];
}

-(void)getCodeToResetPassword:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL isSuccess, GLError *error))completionBlock{
    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            NSLog(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(false, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(false, errorC);
                    return;
                }
            }
            else{
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        if (completionBlock){
                            completionBlock(false, nil);
                        }
                    }
                    else{
                        if (completionBlock){
                            completionBlock(true, nil);
                        }
                    }
                }
            }
            
        }
    }];
}

-(void)resetPassword:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(BOOL isSuccess, GLError *error))completionBlock{
    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            NSLog(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(false, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(false, errorC);
                    return;
                }
            }
            else{
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    if([responseObject[@"data"] isEqualToString:@"failed"]){
                        if ([[responseObject allKeys] containsObject:@"message"]){
                            NSString * str = responseObject[@"message"];
                            errorC = [[GLError alloc] initWithMessage:str];
                        }
                        else{
                            errorC = [[GLError alloc] init];
                        }
                        if (completionBlock){
                            completionBlock(false, nil);
                        }
                    }
                    else{
                        if (completionBlock){
                            completionBlock(true, nil);
                        }
                    }
                }
            }
            
        }
    }];
}

- (void)createPaymentHash:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(PaymentHash * hashInfo, GLError * error))completionBlock{
    NSMutableDictionary * params;
    if ([GLAccountManager sharedManager].isUserLoggedIn) {
        if (!customParams) {
            params = [[NSMutableDictionary alloc] init];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        else{
            params = [[NSMutableDictionary alloc] initWithDictionary:customParams];
            [params setObject:[GLAccountManager sharedManager].userInfo.userId forKey:kUserIdKey];
            [params setObject:[GLAccountManager sharedManager].userInfo.userToken forKey:kUserAccessTokenKey];
        }
        if (customParams) {
            customParams = params;
        }
        else{
            customParams = [NSDictionary dictionaryWithDictionary:params];
        }
    }
    [[WebServiceManager sharedManager] createPostRequestWithParameters:customParams withRequestPath:url withCompletionBlock:^(id responseObject, NSError *error) {
        GLError * errorC = nil;
        if (error) {
            NSLog(@"Error : %@", error.localizedDescription);
            errorC = [[GLError alloc] initWithError:error];
            if (completionBlock) {
                completionBlock(nil, errorC);
                return ;
            }
        }
        else{
            errorC = [GLError validateDictionary:responseObject];
            if (errorC) {
                if (completionBlock) {
                    completionBlock(nil, errorC);
                    return;
                }
            }
            else{
                
                PaymentHash * hash = [[PaymentHash alloc] initWithDictionary:responseObject];
                
                completionBlock(hash, nil);
//                NSString * nextUrl;
//                NSNumber * totalCount;
//                if ([[responseObject allKeys] containsObject:@"UrlNext"])
//                {
//                    nextUrl = responseObject[@"UrlNext"];
//                }
//                if ([[responseObject allKeys] containsObject:@"total_records"]) {
//                    totalCount = [NSNumber numberWithInteger:[responseObject[@"total_records"] integerValue]];
//                }
//                
//                if ([[responseObject allKeys] containsObject:@"data"]) {
//                    if([responseObject[@"data"] isEqualToString:@"failed"]){
//                        if ([[responseObject allKeys] containsObject:@"message"]){
//                            NSString * str = responseObject[@"message"];
//                            errorC = [[GLError alloc] initWithMessage:str];
//                        }
//                        else{
//                            errorC = [[GLError alloc] init];
//                        }
//                        completionBlock(nil, nil, nil, errorC);
//                    }
//                }
//                if([[responseObject allKeys] containsObject:@"redemptions"]){
//                    NSMutableArray * cityArray = [[NSMutableArray alloc] init];
//                    NSMutableArray * cityList = (NSMutableArray *)responseObject[@"redemptions"];
//                    for (NSDictionary * dict in cityList) {
//                        RedemptionModel * redemption = [[RedemptionModel alloc] initWithDictionary:dict];
//                        [cityArray addObject:redemption];
//                    }
//                    completionBlock (cityArray, nextUrl, totalCount, nil);
//                }
//                else{
//                    errorC = [[GLError alloc] init];
//                    if (completionBlock) {
//                        completionBlock(nil, nil, nil, errorC);
//                        return ;
//                    }
//                }
            }
        }
    }];
}
@end
