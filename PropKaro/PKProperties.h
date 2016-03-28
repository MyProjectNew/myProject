//
//  PKProperties.h
//  PropKaro
//
//  Created by kartik shahzadpuri on 3/27/16.
//  Copyright © 2016 Ajay Awasthi. All rights reserved.
//

#import <Mantle.h>

@interface PKProperties : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSArray * allProperties;
@end


@interface PKPropertyItem : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSString * propertyId;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * propertyListingType;
@property (nonatomic, strong) NSString * propertyListingParent;
@property (nonatomic, strong) NSString * propertyTypeName;
@property (nonatomic, strong) NSString * propertyTypeNameParent;
@property (nonatomic, strong) NSString * propertyLandmark;
@property (nonatomic, strong) NSString * propertyCity;
@property (nonatomic, strong) NSString * propertyLattitude;
@property (nonatomic, strong) NSString * propertyLongitude;
@property (nonatomic, strong) NSString * propertyExpectedUnitPrice;
@property (nonatomic, strong) NSString * propertyExpectedUnitPriceUnit;
@property (nonatomic, strong) NSString * propertyNumberOfBedrooms;
@property (nonatomic, strong) NSString * propertyNumberOfBathrooms;
@property (nonatomic, strong) NSString * propertyNumberOfWashrooms;
@property (nonatomic, strong) NSString * propertyNumberOfBalcony;
@property (nonatomic, strong) NSString * propertyOwnership;
@property (nonatomic, strong) NSString * propertyAvailability;
@property (nonatomic, strong) NSString * propertyPrice;
@property (nonatomic, strong) NSString * propertyDate;
@property (nonatomic, strong) NSString * propertyUserType;
@property (nonatomic, strong) NSString * propertyEmail;
@property (nonatomic, strong) NSString * propertyPhoneNumber;
@property (nonatomic, strong) NSString * propertyImage;
@property (nonatomic, strong) NSString * propertyRegOn;


@end
