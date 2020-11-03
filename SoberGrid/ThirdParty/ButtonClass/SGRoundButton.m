//
//  MintyButton.m
//  MintyFusion
//
//  Created by agilepc-38 on 1/4/14.
//  Copyright (c) 2014 Vandana Vyas. All rights reserved.
//

#import "SGRoundButton.h"
#import "NSObject+ConvertingViewPixels.h"

@implementation SGRoundButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       // self.titleLabel.font=[UIFont systemFontOfSize:[self deviceSpesificValue:14.0]];
        self.titleLabel.font = SGREGULARFONT([self deviceSpesificValue:14.0]);
        _borderColor = [UIColor whiteColor];
        _borderWidth = 2;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)drawRect:(CGRect)rect {
    
    [self.layer setMasksToBounds:YES];
    [self.layer setBorderWidth:_borderWidth];
    [self.layer setCornerRadius:self.frame.size.height/2];
    if (_selectedStateBorderColor) {
        [self.layer setBorderColor:(self.selected)?_selectedStateBorderColor.CGColor:_borderColor.CGColor];
    }else
    [self.layer setBorderColor:_borderColor.CGColor];
}
- (void)setLeftImage:(UIImage*)image forState:(UIControlState)state{
    [self setImage:image forState:state];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
//    UIImageView *imgView=[[UIImageView alloc]initWithImage:image];
//    imgView.contentMode=UIViewContentModeScaleAspectFit;
//    [self addSubview:imgView];
//    imgView.center = CGPointMake(self.frame.size.width/4, self.frame.size.height/2);
//    self.contentEdgeInsets = UIEdgeInsetsMake(0, self.frame.size.width/4 + 5, 0, 0);
}
- (void)setBorderColor:(UIColor *)borderColor{
    _borderColor = borderColor;
    [self setNeedsDisplay];
}
- (void)setSelectedStateBorderColor:(UIColor *)selectedStateBorderColor{
    _selectedStateBorderColor = selectedStateBorderColor;
    [self setNeedsDisplay];
}

- (void)setBorderWidth:(CGFloat)borderWidth{
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}

@end
