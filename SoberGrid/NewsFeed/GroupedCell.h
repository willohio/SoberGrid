//
//  GroupedCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/22/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupedCell : UITableViewCell
@property (nonatomic,strong)UIView *viewContentHolder;

- (void)setHight:(CGFloat)height;

@end
