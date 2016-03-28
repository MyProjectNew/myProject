//
//  DataManager.h
//  Vella
//
//  Created by Pulkit Arora on 22/11/15.
//  Copyright © 2015 Pulkit Arora. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PKProperties;

@interface DataManager : NSObject

+ (instancetype)sharedManager;


-(void)getpropertyListWithParam:(NSDictionary *)customParams url:(NSString *)url withCompletionHandler:(void(^)(PKProperties *properties,NSError *error))completionBlock;
@end
