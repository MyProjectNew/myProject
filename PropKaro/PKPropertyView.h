//
//  PKPropertyView.h
//  PropKaro
//
//  Created by kartik shahzadpuri on 3/27/16.
//  Copyright © 2016 Ajay Awasthi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKProperties.h"
@interface PKPropertyView : UIView
@property (nonatomic, strong) PKPropertyItem * propertyItem;
- (void)updateView;
+ (CGFloat)heightForCellForProperty:(PKPropertyItem *)property;

@end
