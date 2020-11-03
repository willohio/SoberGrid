//
//  SGNewsFeedBubbleCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//
#define kBubbleCellContentPaddingRight  20
#define kBubbleCellContentPaddingLeft   20
#define kBubbleCellBubblePaddingTop     10
#define kBubbleCellBubblePaddingRight   10
#define kBubbleCellBubblePaddingLeft    10
#define kBubbleCellBubblePaddingBottom  10

#define SGBubbleOffsetFromRight                 15
#define SGBubbleOffsetFromRightWithourArrow     7.5
#define SGBubbleOffsetFromLeft                  10
#define SGBubbleOffsetFromTop                   10

#define kSGNEWSFEED_CELL_HEIGHT         240
#define kSGNEWSFEED_PHOTOCELL_HEIGHT    360

#define kSGLine_Origin_X        (isIPad)?30:7
#define kSGLine_Size_Width      (isIPad)?46:28

#define kAPI_LIKE                       @"Add_likeunlike"
#define kAPI_PAGEFEED_LIKE              @"Add_LikeUnlikePageFeed"


#import <UIKit/UIKit.h>
#import "KBPopupBubbleView.h"
#import "CellLineView.h"
#import "NewsFeedButtonsView.h"
#import "User.h"
#import "NewsFeedTopView.h"
#import "SGPostPage.h"
#import "NSString+Utilities.h"

static NSString *const linkLikeDetection = @"www.google.com";
static NSString *const linkCommentDetection = @"www.yahoo.com";

@protocol SGNewsFeedCellDelegate <NSObject>
@optional
- (void)btnLikeUnlikeDoneForPost:(id)post fromCell:(UITableViewCell*)cell;
- (void)btnCommentClickedForPost:(id)post fromCell:(UITableViewCell*)cell;
- (void)btnLikeClickedForPost:(id)post fromCell:(UITableViewCell*)cell;
- (void)btnShareClickedForPost:(id)post fromCell:(UITableViewCell*)cell;
- (void)updatedPost:(id)post ForCell:(UITableViewCell*)cell;
- (void)profileViewTappedForPost:(id)post;
- (void)blockOptionClickedForPost:(id)post;


@end


@interface SGNewsFeedBubbleCell : UITableViewCell <NewsFeedButtonsViewDelegate,NewsFeedTopViewDelegate,TTTAttributedLabelDelegate>{
    CellLineView *line;
    NewsFeedButtonsView *nsButtonsView;
    NewsFeedTopView *viewHeader;
    CGFloat cellHeight;
    UILabel *lblSuggestedPost;
    BOOL isLine;
    kSGNewsFeedType  _feedType;
    BOOL         hideLike;
    BOOL         hideComment;
}
@property (nonatomic,strong)KBPopupBubbleView *bubbleContentView;
@property (nonatomic,assign)id<SGNewsFeedCellDelegate>delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier lineType:(int)lineType withLine:(BOOL)status;
- (void)customizeWithUser:(User*)objUser postDate:(NSDate*)postDate withMoodMessage:(NSString*)moodMessage isLiked:(BOOL)status;
- (void)customizeWithPage:(SGPostPage*)page;
+ (CGFloat)bubbleWidthwithLine:(BOOL)status;
- (void)hideLikeOption;
- (void)hideCommentOption;

@end
