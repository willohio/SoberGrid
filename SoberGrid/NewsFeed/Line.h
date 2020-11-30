//
//  Line.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/10/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Line : UIView{
    CGFloat lineWidth;
}
+ (id)drawStraightLineFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint ofWidth:(CGFloat)width inView:(UIView*)view;
@end
