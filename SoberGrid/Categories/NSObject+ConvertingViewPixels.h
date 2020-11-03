//
//  NSObject+ConvertingViewPixels.h
//  iPadVJApp
//
//  Created by Haresh Kalyani on 8/6/14.
//  Copyright (c) 2014 agilepc-38. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ConvertingViewPixels)
- (CGPoint)convertPoint:(CGPoint)point FromView:(UIView*)sourceView toView:(UIView*)destinationView;
- (CGFloat)percentageHeightFromView:(UIView*)sourceView toView:(UIView*)destinationView;
- (CGFloat)percentageWidthFromView:(UIView*)sourceView toView:(UIView*)destinationView;
- (CGRect)frame:(CGRect)frame withHeightPer:(CGFloat)height withWidthPer:(CGFloat)width;
- (CGFloat)value:(CGFloat)value withPercentage:(CGFloat)percentage;
- (CGRect)scaleDownFrame:(CGRect)frame withHeightPer:(CGFloat)height    withtWidthPer:(CGFloat)width;
- (CGFloat)deviceSpesificValue:(CGFloat)value;
@end
