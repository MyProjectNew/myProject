//
//  PKPropertyCell.m
//  PropKaro
//
//  Created by kartik shahzadpuri on 3/27/16.
//  Copyright © 2016 Ajay Awasthi. All rights reserved.
//

#import "PKPropertyCell.h"
#import "PKPropertyView.h"
@interface PKPropertyCell()
@property (nonatomic, strong) PKPropertyView * cellView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIView *shadowView2;
@property (nonatomic, strong) UIView *shadowView3;
@end
@implementation PKPropertyCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setUp
{
    self.backgroundColor = [UIColor lightGrayColor];
    self.cellView = [[PKPropertyView alloc] initWithFrame:CGRectZero];
    self.cellView.layer.cornerRadius = 4.0;
    self.cellView.clipsToBounds = YES;
    
    self.shadowView2 = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_shadowView2];
    [self setupShadowView:self.shadowView2];
    
    self.shadowView3 = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_shadowView3];
    [self setupShadowView:self.shadowView3];
    
    self.shadowView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setupShadowView:self.shadowView];
    
    [self.shadowView addSubview:self.cellView];
    [self.contentView addSubview:self.shadowView];
    
}
- (void)setupShadowView:(UIView *)shadowView
{
    shadowView.backgroundColor = [UIColor whiteColor];
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadowView.layer.shadowRadius = 2.0;
    shadowView.layer.shadowOpacity = 0.5f;
    shadowView.layer.cornerRadius = 4.0;
    shadowView.layer.masksToBounds = NO;
}

- (void)updateCell
{
    self.cellView.propertyItem = self.propertyItem;
    [self.cellView updateView];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.contentView.bounds;
    
    
    CGRect mainFrame = CGRectMake(10.0, 5.0, rect.size.width - 20.0, rect.size.height - 10.0);
    self.shadowView.frame = mainFrame;
    self.cellView.frame = self.shadowView.bounds;
    
    mainFrame.origin.y += 5.0;
    self.shadowView3.frame = mainFrame;
    
    mainFrame.origin.y += 5.0;
    self.shadowView2.frame = mainFrame;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds cornerRadius:4.0];
    self.shadowView.layer.shadowPath = shadowPath.CGPath;
    self.shadowView2.layer.shadowPath = shadowPath.CGPath;
    self.shadowView3.layer.shadowPath = shadowPath.CGPath;
    
    [self.cellView setNeedsLayout];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (CGFloat)heightForCellForProperty:(PKPropertyItem *)property
{
    return [PKPropertyView heightForCellForProperty:property];
}

@end
