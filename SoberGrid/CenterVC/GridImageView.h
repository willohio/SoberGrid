//
//  PLCellHelpers.h
//  Project172
//
//  Created by Aik Ampardjian on 24.08.13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "OBGradientView.h"
#import "UHLabel.h"
@interface GridImageView : UIImageView{
    UILabel *lblName;
    OBGradientView* _gdview;
    UIImageView *imgBubbleView;
    UHLabel *lblDistance;
    UILabel *lblCount;
}
- (void)setImageURL:(NSURL *)imageURL withName:(NSString*)name withDelayMessageCount:(int)count withDisatnce:(float)distance;

+ (GridImageView *)getImageViewWithFrame:(CGRect)frame;
+ (NSMutableArray *)shuffleDictionary:(NSMutableDictionary *)dict;
+ (NSDictionary *)dateInIntegerAndTimeRange:(NSTimeInterval)lastUpdate trimmed:(BOOL)trimmed;

@end
