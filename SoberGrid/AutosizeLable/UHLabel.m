//
//  UHLabel.m
//  Unitehood Beta
//
//  Created by Haresh Kalyani on 5/27/14.
//  Copyright (c) 2014 agilepc-120. All rights reserved.
//

#import "UHLabel.h"

@implementation UHLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.lineBreakMode = NSLineBreakByWordWrapping;
       // self.mentionTextColor = [UIColor blueColor];
      //  self.linkTextColor    = [UIColor blueColor];
      //  self.hashtagTextColor = [UIColor blueColor];
    }
    return self;
}
-(void)resizeToStretch{
    float width = [self expectedWidth];
    CGRect newFrame = [self frame];
    newFrame.size.width = width;
    [self setFrame:newFrame];
}

-(float)expectedWidth{
    [self setNumberOfLines:1];
    
//    CGSize maximumLabelSize = CGSizeMake(9999,self.frame.size.height);
    
//    CGSize expectedLabelSize = [[self text] sizeWithFont:[self font]
//                                       constrainedToSize:maximumLabelSize
//                                           lineBreakMode:[self lineBreakMode]];
    CGSize size=[TTTAttributedLabel sizeThatFitsAttributedString:[[NSAttributedString alloc] initWithString:[self text] attributes:@{NSFontAttributeName:self.font}] withConstraints:CGSizeMake(FLT_MAX, self.frame.size.height) limitedToNumberOfLines:1];
  // CGRect  expectedLabelSize = [[self text] boundingRectWithSize:CGSizeMake(FLT_MAX, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
    return size.width;
}
- (void)resizeToHeight{
    float height = [self expectedHeight];
    CGRect newFrame = [self frame];
    newFrame.size.height = height;
    [self setFrame:newFrame];
}
-(float)expectedHeight{
    [self setNumberOfLines:0];
    //    CGSize maximumLabelSize = CGSizeMake(9999,self.frame.size.height);
    
    //    CGSize expectedLabelSize = [[self text] sizeWithFont:[self font]
    //                                       constrainedToSize:maximumLabelSize
    //                                           lineBreakMode:[self lineBreakMode]];
    CGRect  expectedLabelSize = [[self text] boundingRectWithSize:CGSizeMake(self.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
    return expectedLabelSize.size.height;
}
- (void)enableDetection
{
    @try {
        
        ///Dev :- Agile
        ///Date :- 1/5/2015
        
        self.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        
        self.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName:(__bridge id)[[UIColor blueColor] CGColor]};
    }
    @catch (NSException *exception) {
        NSLog(@"Excep in UHLabel : %@",exception);
    }    
}
- (void)enableContinueReading{
      self.attributedTruncationToken = [[NSAttributedString alloc]initWithString:@"...Continue Reading" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1],NSFontAttributeName:SGBOLDFONT(10.0)}];
//    self.truncationTokenString = @"...Continue Reading";
//    self.truncationTokenStringAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1],NSFontAttributeName:SGBOLDFONT(10.0)};

}


- (void)setAttributes:(NSDictionary *)attributes{
//    [super setAttributes:attributes];
    [self enableDetection];
    

}

+ (CGFloat)getHeightOfText:(NSString*)string forWidth:(CGFloat)width withAttributes:(NSDictionary*)dictAttribute{
    
    CGRect  expectedLabelSize = [string boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictAttribute context:nil];
    return expectedLabelSize.size.height;
}
+ (CGFloat)getWidthOfText:(NSString*)string forHight:(CGFloat)hight withAttributes:(NSDictionary*)dictAttribute{
    
    CGRect  expectedLabelSize = [string boundingRectWithSize:CGSizeMake(FLT_MAX, hight) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictAttribute context:nil];
    return expectedLabelSize.size.width;
}
- (void)setFont:(UIFont *)font{
    [super setFont:font];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
