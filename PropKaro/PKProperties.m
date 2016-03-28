//
//  PKProperties.m
//  PropKaro
//
//  Created by kartik shahzadpuri on 3/27/16.
//  Copyright © 2016 Ajay Awasthi. All rights reserved.
//

#import "PKProperties.h"

@implementation PKProperties
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"allProperties": @"data"
             };
}

+ (NSValueTransformer *)allPropertiesJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[PKPropertyItem class]];
}
@end




@implementation PKPropertyItem
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"propertyId": @"property_id",
             @"userId": @"user_id",
             @"propertyListingType": @"property_listing_type",
             @"propertyListingParent": @"property_listing_parent",
             @"propertyTypeName": @"property_type_name",
             @"propertyTypeNameParent": @"property_type_name_parent",
             @"propertyLandmark": @"property_landmark",
             @"propertyCity": @"property_city",
             @"propertyLattitude": @"property_latitude",
             @"propertyLongitude": @"property_longitude",
             @"propertyExpectedUnitPrice": @"expected_unit_price",
             @"propertyExpectedUnitPriceUnit": @"expected_unit_price_unit",
             @"propertyNumberOfBedrooms": @"no_of_bedrooms",
             @"propertyNumberOfBathrooms": @"no_of_bathrooms",
             @"propertyNumberOfWashrooms": @"no_of_washrooms",
             @"propertyNumberOfBalcony": @"no_of_balcony",
             @"propertyOwnership": @"property_ownership",
             @"propertyAvailability": @"property_availability",
             @"propertyPrice": @"expected_price",
             @"propertyDate": @"timestamp",
             @"propertyUserType": @"user_type",
             @"propertyEmail": @"email",
             @"propertyPhoneNumber": @"phone_no",
             @"propertyImage": @"image",
             @"propertyRegOn": @"registered_on",
             };
}

@end
