//
//  MintyButton.h
//  MintyFusion
//
//  Created by agilepc-38 on 1/4/14.
//  Copyright (c) 2014 Vandana Vyas. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SGRoundButton : UIButton
@property (nonatomic,assign)UIColor *borderColor;
@property (nonatomic,assign)UIColor *selectedStateBorderColor;
@property (nonatomic,assign)CGFloat borderWidth;

- (void)setLeftImage:(UIImage*)image forState:(UIControlState)state;
@end
