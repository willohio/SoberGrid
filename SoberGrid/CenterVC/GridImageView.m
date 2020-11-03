//
//  PLCellHelpers.m
//  Project172
//
//  Created by Aik Ampardjian on 24.08.13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import "GridImageView.h"
#import "DatabaseManager.h"
#import "OBGradientView.h"
#import "UHLabel.h"
@implementation GridImageView

- (void)customise{
    // if (name) {
    lblName=[[UILabel alloc]initWithFrame:CGRectMake(3, 3, self.frame.size.width-6, 20)];
    lblName.textColor=[UIColor whiteColor];
   // lblName.text = name;
    lblName.font = [UIFont systemFontOfSize:10.0];
    [self addSubview:lblName];
    // }
    //    if (count > 0) {
    
    // lower par shadow
    _gdview = [[OBGradientView alloc]initWithFrame:CGRectMake(self.frame.origin.x,(CGRectGetHeight(self.bounds) - self.frame.size.height/4), self.frame.size.width, self.frame.size.height/4)];
    NSArray *arrColor=[NSArray arrayWithObjects:[UIColor clearColor],[UIColor blackColor], nil];
    
    _gdview.colors=arrColor;
    [self addSubview:_gdview];
    //_gdview = nil;
    
//    NSString *strCount;
//    if (count > 99) {
//        strCount = @"99+";
//    }else
//        strCount = [NSString stringWithFormat:@"%d",count];
    
    
    CGFloat paddingX = -5;
    CGFloat paddingY = -3;
    
    imgBubbleView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bubble"]];
    imgBubbleView.frame = CGRectMake(self.bounds.size.width - imgBubbleView.frame.size.width + paddingX, self.bounds.size.height - imgBubbleView.frame.size.height + paddingY, imgBubbleView.frame.size.width, imgBubbleView.frame.size.height);
    
    
    
    lblCount=[[UILabel alloc]initWithFrame:imgBubbleView.bounds];
    lblCount.font = [UIFont boldSystemFontOfSize:12.0];
    lblCount.textColor = [UIColor redColor];
    lblCount.textAlignment = NSTextAlignmentCenter;
    lblCount.adjustsFontSizeToFitWidth = true;
  //  lblCount.text = strCount;
    [imgBubbleView addSubview:lblCount];
    
    [self addSubview:imgBubbleView];
    
  //  imgBubbleView = nil;
    
    
    //   }
    
    // Create distance lable
    lblDistance=[[UHLabel alloc]initWithFrame:CGRectMake(0, 7,20, 16)];
    lblDistance.textColor = [UIColor blackColor];
    lblDistance.font = SGREGULARFONT(12.0);
    lblDistance.textAlignment = NSTextAlignmentCenter;
    lblDistance.backgroundColor = [UIColor whiteColor];
//    if (distance <= 1) {
//        lblDistance.text = [NSString stringWithFormat:@"%d ft",(int)(distance * 5280.0)];
//    }else
//        lblDistance.text = [NSString stringWithFormat:@"%d mi",(int)distance];
    
    
//    [lblDistance resizeToStretch];
//    lblDistance.frame = CGRectMake(self.frame.size.width - 3 -10- lblDistance.frame.size.width, 3, lblDistance.frame.size.width+10, lblDistance.frame.size.height);
    lblDistance.layer.cornerRadius = lblDistance.frame.size.height / 2;
    lblDistance.clipsToBounds = YES;
    [self addSubview:lblDistance];
//    lblDistance = nil;
    
    
}
- (void)setImageURL:(NSURL *)imageURL withName:(NSString*)name withDelayMessageCount:(int)count withDisatnce:(float)distance{
     lblName.text = name;
    [self sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder_iPad"] options:SDWebImageRetryFailed];
    if (count > 0) {
        _gdview.hidden = NO;
        imgBubbleView.hidden = NO;
          NSString *strCount;
          if (count > 99) {
              strCount = @"99+";
          }else
             strCount = [NSString stringWithFormat:@"%d",count];
        lblCount.text = strCount;
    }else{
        _gdview.hidden = YES;
        imgBubbleView.hidden = YES;
    }
    
    if (distance <= 1) {
        lblDistance.text = [NSString stringWithFormat:@"%d ft",(int)(distance * 5280.0)];
    }else
        lblDistance.text = [NSString stringWithFormat:@"%d mi",(int)distance];
    
    
    [lblDistance resizeToStretch];
    lblDistance.frame = CGRectMake(self.frame.size.width - 3 -10- lblDistance.frame.size.width, 3, lblDistance.frame.size.width+10, lblDistance.frame.size.height);
    

}

+ (GridImageView *)getImageViewWithFrame:(CGRect)frame
{
    
    GridImageView * imageView = [[GridImageView alloc] initWithFrame:frame];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    [imageView customise];
    return imageView;
    
}



/**
 Description from Trello...
 
* However, we ensure diversity by taking a random sample from each starred channel in sequence.
* user has 4 starred channels A B C D
* shuffle each of them separately to make shuffledA, shuffledB, shuffledC, shuffledD
* now our sequence is
* shuffledA[0]
* shuffledB[0]
* shuffledC[0]
* shuffledD[0]
* shuffledA[1]
* shuffledB[1]
* shuffledC[1]
* shuffledD[1]
**/
+ (NSMutableArray *)shuffleDictionary:(NSMutableDictionary *)dict
{
    NSMutableArray * arr = [@[] mutableCopy];
    NSArray * keys = [dict allKeys];
    int keysCount = (int)keys.count;
    int maxArrCount = 0;
    for (NSString * key in dict) {
        int arrCount = (int)((NSArray*)dict[key]).count;
        maxArrCount = (arrCount > maxArrCount) ? arrCount : maxArrCount;
    }
    
    for (int i = 0; i < maxArrCount * keysCount; i++)
        [arr addObject:[NSNull null]];
    
    for (int i = 0; i < keysCount; i++) {
        NSArray *series = [dict objectForKey:keys[i]];
        for (int k = 0; k < series.count; k++) {
            [arr replaceObjectAtIndex:k * keysCount + i withObject:series[k]];
        }
    }
    [arr removeObjectIdenticalTo:[NSNull null]];
    return arr;
}

+ (NSDictionary *)dateInIntegerAndTimeRange:(NSTimeInterval)lastUpdate trimmed:(BOOL)trimmed
{
    NSInteger dateNumber = 0;
    NSString * dateDescription = @"";
    NSTimeInterval dateDifference = [[NSDate date] timeIntervalSince1970] - lastUpdate;
    if (dateDifference >= (3600 * 24 * 365)) {
        dateNumber = fabs(dateDifference / (3600 * 24 * 365));
        dateDescription = (dateNumber > 1) ? @"years" : @"year";
    } else if (dateDifference >= (3600 * 24 * 31)) {
        dateNumber = fabs(dateDifference / (3600 * 24 * 31));
        dateDescription = (dateNumber > 1) ? @"months" : @"month";
    } else if (dateDifference >= (3600 * 24 * 7)) {
        dateNumber = fabs(dateDifference / (3600 * 24 * 7));
        dateDescription = (dateNumber > 1) ? @"weeks" : @"week";
    } else if (dateDifference >= (3600 * 24)) {
        dateNumber = fabs(dateDifference / (3600 * 24));
        dateDescription = (dateNumber > 1) ? @"days" : @"day";
    } else if (dateDifference >= 3600) {
        dateNumber = fabs
        (dateDifference / 3600);
        dateDescription = (dateNumber > 1) ? @"hours" : @"hour";
    } else if (dateDifference >= 60) {
        dateNumber = fabs(dateDifference / 60);
        dateDescription = (dateNumber > 1) ? @"minutes" : @"minute";
    } else {
        dateNumber = fabs(dateDifference);
        dateDescription = (dateNumber > 1) ? @"seconds" : @"second";
    }
    if (trimmed) dateDescription = [dateDescription substringWithRange:NSMakeRange(0, 1)];
    return @{@"dateNumber" : @(dateNumber), @"dateDescription" : dateDescription};
}

@end
