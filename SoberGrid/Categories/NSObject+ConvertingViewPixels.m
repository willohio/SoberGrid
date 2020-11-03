//
//  NSObject+ConvertingViewPixels.m
//  iPadVJApp
//
//  Created by Haresh Kalyani on 8/6/14.
//  Copyright (c) 2014 agilepc-38. All rights reserved.
//

#import "NSObject+ConvertingViewPixels.h"

@implementation NSObject (ConvertingViewPixels)
- (CGPoint)convertPoint:(CGPoint)point FromView:(UIView*)sourceView toView:(UIView*)destinationView{
    CGPoint finalPoint;
    CGFloat xPoint=point.x;
    CGFloat yPoint=point.y;
    BOOL check=false;
    if (xPoint == 390) {
        check = true;
    }
    
    CGFloat heightPer=[self percentageHeightFromView:sourceView toView:destinationView];
    CGFloat widthPer=[self percentageWidthFromView:sourceView toView:destinationView];
    xPoint = ((xPoint*widthPer)/100);
    yPoint = ((yPoint*heightPer)/100);
    finalPoint = CGPointMake(xPoint, yPoint);
    if (check) {
        NSLog(@"xpoing in bigger %f",xPoint);
    }
    
    return finalPoint;
}
- (CGFloat)percentageHeightFromView:(UIView*)sourceView toView:(UIView*)destinationView{
    CGFloat final = 0;
    CGFloat heightOFSource=sourceView.frame.size.height;
    CGFloat destinationHeight=destinationView.frame.size.height;
    final = (destinationHeight*100)/heightOFSource;
    return final;
}
- (CGFloat)percentageWidthFromView:(UIView*)sourceView toView:(UIView*)destinationView{
    CGFloat final = 0;
    CGFloat widthOFSource=sourceView.frame.size.width;
    CGFloat destinationwidth=destinationView.frame.size.width;
    final = (destinationwidth*100)/widthOFSource;
    return final;
}
- (CGRect)frame:(CGRect)frame withHeightPer:(CGFloat)height withWidthPer:(CGFloat)width{
    CGFloat resultHeight=frame.size.height;
    CGFloat resultWidth=frame.size.width;
    resultHeight = resultHeight*height/100;
    resultWidth = resultWidth*width/100;
    return CGRectMake(frame.origin.x, frame.origin.y, resultWidth, resultHeight);
}
- (CGRect)scaleDownFrame:(CGRect)frame withHeightPer:(CGFloat)height    withtWidthPer:(CGFloat)width{
    CGFloat resultHeight=frame.size.height;
    CGFloat resultWidth=frame.size.width;
    resultHeight =resultHeight- resultHeight*height/100;
    resultWidth =resultWidth- resultWidth*width/100;
    return CGRectMake(frame.origin.x, frame.origin.y, resultWidth, resultHeight);
}
- (CGFloat)value:(CGFloat)value withPercentage:(CGFloat)percentage{
    return value*percentage/100;
}
- (CGFloat)deviceSpesificValue:(CGFloat)value{
    return (isIPad)?[self value:value withPercentage:I_PAD_PERCENTAGE]:value;
}

@end
