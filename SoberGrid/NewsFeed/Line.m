//
//  Line.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/10/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "Line.h"

@implementation Line


+ (Line*)drawStraightLineFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint ofWidth:(CGFloat)width inView:(UIView*)view{
    CGFloat framewidth;
    CGFloat frameheight;
    CGFloat originX;
    CGFloat originY;
    if (startPoint.x != endPoint.x) {
        framewidth = endPoint.x - startPoint.x;
    }else {
        framewidth = width;
    }
    
    
    if (startPoint.y != endPoint.y) {
        frameheight = endPoint.y - startPoint.y;
    }else{
        frameheight = width;
    }
    originX = startPoint.x;
    originY = startPoint.y;
    CGRect frame = CGRectMake(originX, originY, framewidth, frameheight);
    
    id obj = [[self alloc] initWithFrame:frame andWidth:width];
    if (obj) {
        [view addSubview:obj];
        // Initialization code
    }
    return obj;
    
    
}
- (id)initWithFrame:(CGRect)frame andWidth:(CGFloat)width
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        lineWidth = width;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawLineWithStartPoint:CGPointMake(0,0) toEndPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];

}

- (void) drawLineWithStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint {
    
    [SG_LINE_COLOR setStroke];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    [path setLineWidth:2];
    [path stroke];
}
@end
