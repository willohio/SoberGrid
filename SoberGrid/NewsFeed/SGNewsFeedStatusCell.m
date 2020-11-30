//
//  SGStatusCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//



#import "SGNewsFeedStatusCell.h"
#import "CellLineView.h"
#import "NewsFeedTopView.h"
#import <Social/Social.h>


@implementation SGNewsFeedStatusCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier lineType:(int)lineType withLine:(BOOL)status
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier  lineType:kSGNewsFeedTypeStatus withLine:status];
    if (self) {
        // Initialization code
        [self customise];
    }
    return self;
}
- (void)customise{
    lblStatus = [[UHLabel alloc]initWithFrame:CGRectZero];
    lblStatus.frame = CGRectMake(kBubbleCellContentPaddingRight, 60+kBubbleCellBubblePaddingTop, self.bubbleContentView.frame.size.width - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight, 80);
    
    lblStatus.userInteractionEnabled = YES;
    lblStatus.numberOfLines = 0;
    lblStatus.textColor = [UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1];
    [lblStatus enableDetection];
    [lblStatus enableContinueReading];
    // set attributed truncation token string
    lblStatus.font = SGREGULARFONT(16.0);
    lblStatus.delegate = self;
    [self.bubbleContentView addSubview:lblStatus];
    
        lblLikesAndComments = [[UHLabel alloc]initWithFrame:CGRectMake(kBubbleCellBubblePaddingRight, lblStatus.frame.origin.y+lblStatus.frame.size.height + 5, 50, 12)];
    
        [lblLikesAndComments enableDetection];
        lblLikesAndComments.delegate = self;
        lblLikesAndComments.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName:(__bridge id)[[UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1] CGColor]};
    lblLikesAndComments.font = SGREGULARFONT(10);
    lblLikesAndComments.textColor = [UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1];
    lblLikesAndComments.userInteractionEnabled = true;
    [self.bubbleContentView addSubview:lblLikesAndComments];
    
}

- (void)customizeWithPost:(SGPostStatus*)post withFullVersion:(BOOL)status forType:(NSString *)strType{
    
    postType = strType;
    _post = post;
    
   CGFloat  height = [SGNewsFeedStatusCell getHeightForPost:_post withFullVersion:status withLine:isLine];
    CGRect buubleFrame=self.bubbleContentView.frame;
    buubleFrame.size.height = height - SGBubbleOffsetFromTop;
    self.bubbleContentView.frame = buubleFrame;
    cellHeight = height;
    
    
    
    [super customizeWithUser:_post.objUser postDate:_post.datePosted withMoodMessage:@"Feeling Happy" isLiked:[_post.strIsLike boolValue]];
    
    
    // Text
    
    
    lblStatus.text = post.strStatus;
    if (status) {
        lblStatus.numberOfLines = 0;
        [lblStatus resizeToHeight];
    }else{
        lblStatus.lineBreakMode = NSLineBreakByTruncatingTail;
        lblStatus.numberOfLines = 4.0;
    }

   [self upadateLikeCountwithValue:_post.likesCount];
}


- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    if ([label isEqual:lblLikesAndComments]) {
        if ([url.absoluteString isEqualToString:linkLikeDetection]) {
            [self btnLIkeTouched];
        }else if ([url.absoluteString isEqualToString:linkCommentDetection]){
            [self btnComment_Clicked:nil];
        }
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LINKTAPPED object:url];
}
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectNormaltext:(NSString *)strText{
    [self btnComment_Clicked:nil];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - NewsFeedButtonsView Delegate
- (void)btnLike_Clicked:(UIButton *)sender{
    sender.selected = !sender.selected;
    _post.strIsLike=[NSString stringWithFormat:@"%d",sender.selected];
    [self upadateLikeCountwithValue:_post.likesCount + ((sender.selected)?(1):(-1))];
    if ([self.delegate respondsToSelector:@selector(btnLikeUnlikeDoneForPost: fromCell:)]) {
        [self.delegate btnLikeUnlikeDoneForPost:_post fromCell:(UITableViewCell*)self];
        
    }
    if([postType isEqualToString:@"post"]){
    CommonApiCall *apiclass=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kAPI_LIKE) andDelegate:self];
    [apiclass startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"id":_post.strFeedId,@"likestatus":[NSNumber numberWithBool:sender.selected],@"type":postType} options:NSJSONWritingPrettyPrinted error:nil]];
    }else{
        CommonApiCall *apiclass=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kAPI_PAGEFEED_LIKE) andDelegate:self];
        [apiclass startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"page_feed_id":_post.strFeedId,@"likestatus":[NSNumber numberWithBool:sender.selected]} options:NSJSONWritingPrettyPrinted error:nil]];
    }

}
- (void)btnComment_Clicked:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(btnCommentClickedForPost:fromCell:)]) {
        [self.delegate btnCommentClickedForPost:_post fromCell:(UITableViewCell*)self];
    }

}
- (void)btnLIkeTouched{
    if ([self.delegate respondsToSelector:@selector(btnLikeClickedForPost:fromCell:)]) {
        [self.delegate btnLikeClickedForPost:_post fromCell:(UITableViewCell*)self];
    }
}
- (void)btnShare_Clicked:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(btnShareClickedForPost:fromCell:)]) {
        [self.delegate btnShareClickedForPost:_post fromCell:(UITableViewCell*)self];
        
    }
}
- (void)profileViewTapped:(UIView *)view{
    if ([self.delegate respondsToSelector:@selector(profileViewTappedForPost:)]) {
        [self.delegate profileViewTappedForPost:_post];
        
    }
}
- (void)blockOptionClicked:(UIView *)view{
    if ([self.delegate respondsToSelector:@selector(blockOptionClickedForPost:)]) {
        [self.delegate blockOptionClickedForPost:_post];
    }
}
- (void)upadateLikeCountwithValue:(int)value{
    _post.likesCount = value;
    NSString *strLikes =[NSString stringWithFormat:@"%d %@",_post.likesCount,NSLocalizedString([@"Like" stringWithExtensionforCount:_post.likesCount], nil)];
    NSString *strComment = [NSString stringWithFormat:@"%d %@",_post.commentsCount,NSLocalizedString([@"Comment" stringWithExtensionforCount:_post.commentsCount], nil)];
    lblLikesAndComments.text =[NSString stringWithFormat:@"%@ . %@",strLikes,strComment];
    [lblLikesAndComments sizeToFit];
    lblLikesAndComments.frame =CGRectMake(self.bubbleContentView.frame.size.width-kBubbleCellBubblePaddingLeft-lblLikesAndComments.frame.size.width, lblStatus.frame.origin.y+lblStatus.frame.size.height + 5, lblLikesAndComments.frame.size.width, 12);
    
    [lblLikesAndComments addLinkToURL:[NSURL URLWithString:linkLikeDetection] withRange:NSMakeRange(0, strLikes.length)];
    [lblLikesAndComments addLinkToURL:[NSURL URLWithString:linkCommentDetection] withRange:NSMakeRange(strLikes.length+3, strComment.length)];
//    lblLikesAndComments.text = [NSString stringWithFormat:@"%d %@ . %d %@",_post.likesCount,NSLocalizedString([@"Like" stringWithExtensionforCount:_post.likesCount], nil),_post.commentsCount,NSLocalizedString([@"Comment" stringWithExtensionforCount:_post.commentsCount], nil)];
//    [lblLikesAndComments sizeToFit];
//    lblLikesAndComments.frame =CGRectMake(self.bubbleContentView.frame.size.width-kBubbleCellBubblePaddingLeft-lblLikesAndComments.frame.size.width, lblLikesAndComments.frame.origin.y, lblLikesAndComments.frame.size.width, 12);
    
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    if (([requestedURL rangeOfString:kAPI_LIKE].location != NSNotFound) ||
        ([requestedURL rangeOfString:kAPI_PAGEFEED_LIKE].location != NSNotFound)) {
        [self upadateLikeCountwithValue:[dictResponse[RESPONSE][@"totatllikes"] intValue]];
        if ([self.delegate respondsToSelector:@selector(updatedPost:ForCell:)]) {
        [self.delegate updatedPost:_post ForCell:self];
        }
        
    }
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
#pragma Mark - Height Helper
+ (CGFloat)getHeightForPost:(SGPostStatus*)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus{
   
    CGFloat textHeight =(status)?([UHLabel getHeightOfText:post.strStatus forWidth:[SGNewsFeedBubbleCell bubbleWidthwithLine:lineStatus ]-(kBubbleCellContentPaddingLeft + kBubbleCellBubblePaddingRight) withAttributes:@{NSFontAttributeName:SGREGULARFONT(16.0)}]) : 0;
    
    if (status) {
        if (textHeight > 62) {
            textHeight = textHeight - 62;
        }
    }
    return (kSGNEWSFEED_CELL_HEIGHT + textHeight);
}
- (void)dealloc{
    self.delegate = nil;
    lblLikesAndComments = nil;
    lblStatus      = nil;
    lblSuggestedPost    =   nil;
}

@end
