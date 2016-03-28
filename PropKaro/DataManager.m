//
//  DataManager.m

//
//  Created by Pulkit Arora on 22/11/15.
//  Copyright © 2015 Pulkit Arora. All rights reserved.
//

#import "DataManager.h"
#import "WebServiceManager.h"
#import "PKProperties.h"
#define LIST @"https://www.propkaro.com/api/secure/filter-property/page/1/json/eyJieSI6eyJwcm9wZXJ0eV9saXN0aW5nX3BhcmVudCI6WyJhdmFpbGFiaWxpdHkiLCJyZXF1aXJlbWVudCJdLCJwcm9wZXJ0eV9jaXR5IjpbXX19"

@implementation DataManager

+ (instancetype)sharedManager{
    
    static DataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataManager alloc] init];
    });
    
    return sharedInstance;
}


-(void)getpropertyListWithParam:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(PKProperties *properties,NSError *error))completionBlock
{
    [[WebServiceManager sharedManager] createGetRequestWithParameters:nil withRequestPath:LIST withCompletionBlock:^(id responseObject, NSError *error) {
        
        if (!error) {
            NSDictionary * dictonary = (NSDictionary *)responseObject;
            PKProperties * properties = [MTLJSONAdapter modelOfClass:[PKProperties class]
                                                  fromJSONDictionary:dictonary
                                                               error:NULL];
            if (completionBlock) {
                completionBlock(properties,nil);
            }
        }
        else
        {
            if (completionBlock) {
                completionBlock(nil,error);
            }
        }
    }];
}

@end
