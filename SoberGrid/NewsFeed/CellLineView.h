//
//  CellLineView.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellLineView : UIView{
    UIImageView *imageIndicater;
    int lineType;
}
- (id)initWithFrame:(CGRect)frame andType:(int)type;
- (void)updateLineType:(int)type;

@end
