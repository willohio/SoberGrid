//
//  SGStatusCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGPostStatus.h"
#import "SGNewsFeedBubbleCell.h"
#import "UHLabel.h"



@interface SGNewsFeedStatusCell : SGNewsFeedBubbleCell<CommonApiCallDelegate>{
    UHLabel     *lblStatus;
    UHLabel     *lblLikesAndComments;
    NSString    *postType;
    SGPostStatus *_post;
}


- (void)customizeWithPost:(SGPostStatus*)post withFullVersion:(BOOL)status forType:(NSString*)strType;
+ (CGFloat)getHeightForPost:(SGPostStatus*)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus;

@end
