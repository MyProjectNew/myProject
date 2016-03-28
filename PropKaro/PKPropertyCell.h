//
//  PKPropertyCell.h
//  PropKaro
//
//  Created by kartik shahzadpuri on 3/27/16.
//  Copyright © 2016 Ajay Awasthi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKProperties.h"
@interface PKPropertyCell : UITableViewCell
@property (nonatomic, strong) PKPropertyItem * propertyItem;
- (void)updateCell;
+ (CGFloat)heightForCellForProperty:(PKPropertyItem *)property;
@end
