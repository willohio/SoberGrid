//
//  UHLabel.h
//  Unitehood Beta
//
//  Created by Haresh Kalyani on 5/27/14.
//  Copyright (c) 2014 agilepc-120. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "AMAttributedHighlightLabel.h"
#import "TTTAttributedLabel.h"

@interface UHLabel : TTTAttributedLabel
-(void)resizeToStretch;
- (void)resizeToHeight;
- (void)enableDetection;
- (void)enableContinueReading;
+ (CGFloat)getHeightOfText:(NSString*)string forWidth:(CGFloat)width withAttributes:(NSDictionary*)dictAttribute;
+ (CGFloat)getWidthOfText:(NSString*)string forHight:(CGFloat)hight withAttributes:(NSDictionary*)dictAttribute;
- (void)setAttributes:(NSDictionary *)attributes;
@end
