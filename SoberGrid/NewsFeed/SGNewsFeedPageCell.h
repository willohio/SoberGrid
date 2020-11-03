//
//  SGNewsFeedPageCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/20/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGPostPage.h"
#import "SGNewsFeedBubbleCell.h"
@interface SGNewsFeedPageCell : SGNewsFeedBubbleCell <CommonApiCallDelegate>
{
    UHLabel         *lblLikesAndComments;
    UHLabel         *lblDiscription;
    NSString        *postType;
    SGPostPage *_page;
}
@property (nonatomic,strong)UIImageView     *imgViewPost;

- (void)customizewithPage:(SGPostPage *)page withFullVersion:(BOOL)status forType:(NSString *)strType withHeight:(CGFloat)height;
+ (CGFloat)getHeightForPage:(SGPostPage *)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus;

@end
