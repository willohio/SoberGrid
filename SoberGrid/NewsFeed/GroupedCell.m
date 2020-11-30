//
//  GroupedCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/22/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "GroupedCell.h"

@implementation GroupedCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Initialization code
        _viewContentHolder = [[UIView alloc]initWithFrame:CGRectMake(10, 0, CGRectGetWidth([UIScreen mainScreen].bounds)-20, self.frame.size.height)];
        _viewContentHolder.backgroundColor = [UIColor whiteColor];
        _viewContentHolder.layer.cornerRadius = 5.0;
        _viewContentHolder.clipsToBounds = YES;
        [self.contentView addSubview:_viewContentHolder];
        
        self.contentView.backgroundColor = SG_BACKGROUD_COLOR;
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)setHight:(CGFloat)height{
    _viewContentHolder.frame = CGRectMake(10, 0, CGRectGetWidth([UIScreen mainScreen].bounds)-20, height);
}
-(void)unload{
    [_viewContentHolder removeFromSuperview];
    _viewContentHolder = nil;
}

@end
