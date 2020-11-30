//
//  SGNewsFeedVideoCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGPostVideo.h"
#import "SGNewsFeedBubbleCell.h"
#import "SGButton.h"
@protocol SGNewsFeedVideoCellDelegate <NSObject>
@optional
- (void)sgNewsFeedVideoCellClickeVideoforUrl:(NSString*)videoUrl;
@end
@interface SGNewsFeedVideoCell : SGNewsFeedBubbleCell <CommonApiCallDelegate>
{
    UHLabel         *lblLikesAndComments;
    UIImageView     *imgViewPost;
    UHLabel         *lblDiscription;
    SGButton        *btnPlay;
    NSString        *postType;
    SGPostVideo     *_post;
}
@property (nonatomic,assign)id<SGNewsFeedVideoCellDelegate>videodelegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withLine:(BOOL)status;
- (void)customizeWithPost:(SGPostVideo*)post withFullVersion:(BOOL)status forType:(NSString*)strType;
+ (CGFloat)getHeightForPost:(SGPostVideo*)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus;
+ (CGFloat)getheightWithLikeAndCommentForPost:(SGPostVideo*)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus;
@end
