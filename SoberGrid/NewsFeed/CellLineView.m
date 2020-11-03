//
//  CellLineView.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "CellLineView.h"

@implementation CellLineView

- (id)initWithFrame:(CGRect)frame andType:(int)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        lineType = type;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIImage *image;
    if (lineType == kSGNewsFeedTypeStatus) {
        image = [UIImage imageNamed:imageNameRefToDevice(@"StatusIndicator")];
    }else if (lineType == kSGNewsFeedTypePhoto || lineType == kSGNewsFeedTypeVideo){
        image = [UIImage imageNamed:imageNameRefToDevice(@"mediaIndicator")];
    }
    imageIndicater=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 28, 28)];
    imageIndicater.image = image;
    imageIndicater.center = CGPointMake(self.frame.size.width/2, image.size.height + 20);
    [self addSubview:imageIndicater];
    imageIndicater = nil;
    [self drawLineWithStartPoint:CGPointMake(self.frame.size.width/2,0) toEndPoint:CGPointMake(self.frame.size.width/2, self.frame.size.height)];
    
}
- (void) drawLineWithStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint {

    [SG_LINE_COLOR setStroke];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    [path setLineWidth:2];
    [path stroke];
}

- (void)updateLineType:(int)type{
    lineType = type;
    UIImage *image;
    if (lineType == kSGNewsFeedTypeStatus) {
        image = [UIImage imageNamed:imageNameRefToDevice(@"StatusIndicator")];
    }else if (lineType == kSGNewsFeedTypePhoto || lineType == kSGNewsFeedTypeVideo){
        image = [UIImage imageNamed:imageNameRefToDevice(@"mediaIndicator")];
    }
     imageIndicater.image = image;

}
- (void)removeFromSuperview{
    [imageIndicater removeFromSuperview];
    imageIndicater = nil;
}


@end
