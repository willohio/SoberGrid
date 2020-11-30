//
//  SGNewsFeedVideoCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "SGNewsFeedVideoCell.h"
#import "UIImageView+WebCache.h"

@implementation SGNewsFeedVideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withLine:(BOOL)status
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier lineType:kSGNewsFeedTypeVideo withLine:status];
    if (self) {
        [self customise];
        // Initialization code
    }
    return self;
}
- (void)customise{
    lblDiscription = [[UHLabel alloc]initWithFrame:CGRectZero];
    [self.bubbleContentView addSubview:lblDiscription];
    lblDiscription.frame = CGRectMake(kBubbleCellContentPaddingRight, 60+kBubbleCellBubblePaddingTop, self.bubbleContentView.frame.size.width - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight, 57);
    lblDiscription.textColor = [UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1];
    lblDiscription.font = SGREGULARFONT(16.0);
    [lblDiscription enableDetection];
    [lblDiscription enableContinueReading];
    lblDiscription.delegate = self;

    imgViewPost = [[UIImageView alloc] init];
    [self.bubbleContentView addSubview:imgViewPost];
    
    btnPlay = [[SGButton alloc]init];
    [btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    btnPlay.backgroundColor = [UIColor clearColor];
    [btnPlay addTarget:self action:@selector(btnPlay_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    imgViewPost.userInteractionEnabled = true;
    [imgViewPost addSubview:btnPlay];
    
    lblLikesAndComments = [[UHLabel alloc]initWithFrame:CGRectZero];
    [self.bubbleContentView addSubview:lblLikesAndComments];
    [lblLikesAndComments enableDetection];
    lblLikesAndComments.delegate = self;
    lblLikesAndComments.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName:(__bridge id)[[UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1] CGColor]};
    lblLikesAndComments.textColor = [UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1];
    lblLikesAndComments.font = SGREGULARFONT(10);
    lblLikesAndComments.userInteractionEnabled = true;


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
- (void)customizeWithPost:(SGPostVideo*)post withFullVersion:(BOOL)status forType:(NSString *)strType{
    postType = strType;
    _post = post;
    CGFloat  height = 0;
    if (hideComment && hideLike) {
        height = [SGNewsFeedVideoCell getheightWithLikeAndCommentForPost:_post withFullVersion:status withLine:isLine];
    }else
      height = [SGNewsFeedVideoCell getHeightForPost:_post withFullVersion:status withLine:isLine];
    CGRect buubleFrame=self.bubbleContentView.frame;
    buubleFrame.size.height = height - SGBubbleOffsetFromTop;
    self.bubbleContentView.frame = buubleFrame;
    cellHeight = height;
    
    
    [super customizeWithUser:_post.objUser postDate:post.datePosted withMoodMessage:@"Feeling Happy" isLiked:[post.strIsLike boolValue]];
    
    if (post.strDesrciption.length > 0) {
        // Text
        lblDiscription.hidden = NO;
       
        lblDiscription.text = post.strDesrciption;
        if (status) {
            lblDiscription.numberOfLines = 0;
            [lblDiscription resizeToHeight];
        }else{
                lblDiscription.numberOfLines = 3;
                lblDiscription.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        
    }else {
        lblDiscription.hidden = YES;
    }
    
    
    if (_post.strThumbUrl.length > 0) {
        imgViewPost.hidden = NO;
        imgViewPost.frame =CGRectMake(0,(post.strDesrciption.length > 0)?(lblDiscription.frame.size.height+5+lblDiscription.frame.origin.y):(60+kBubbleCellBubblePaddingTop), self.bubbleContentView.frame.size.width, kSGNEWSFEED_PHOTOCELL_HEIGHT/2);
        imgViewPost.contentMode = UIViewContentModeScaleAspectFit;
        [imgViewPost sd_setImageWithURL:[NSURL URLWithString:_post.strThumbUrl] placeholderImage:[UIImage imageNamed:@"placeholderImage"] options:SDWebImageRetryFailed];
        
        //  imgViewPost.contentMode=UIViewContentModeScaleAspectFit;
        
        
        btnPlay.frame=imgViewPost.bounds;
       
        btnPlay.userInfo = _post.strVideoUrl;
        

    }else{
                imgViewPost.hidden = YES;
        
    }
   
    // Likes

    CGRect tempFrame;
    if (imgViewPost.hidden) {
        tempFrame = lblDiscription.frame;

    }else
    {
         tempFrame = imgViewPost.frame;
    }
    lblLikesAndComments.frame =CGRectMake(kBubbleCellBubblePaddingRight, tempFrame.origin.y+tempFrame.size.height + 5, 50, 12);
   
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
#pragma mark - NewsFeedButtonsView Delegate
- (void)btnLike_Clicked:(UIButton *)sender{
    sender.selected  = !sender.selected;
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
- (IBAction)btnPlay_Clicked:(SGButton*)sender{
    if ([self.videodelegate respondsToSelector:@selector(sgNewsFeedVideoCellClickeVideoforUrl:)]) {
        [_videodelegate sgNewsFeedVideoCellClickeVideoforUrl:sender.userInfo];

    }
}
- (void)upadateLikeCountwithValue:(int)value{
    _post.likesCount = value;
    NSString *strLikes =[NSString stringWithFormat:@"%d %@",_post.likesCount,NSLocalizedString([@"Like" stringWithExtensionforCount:_post.likesCount], nil)];
    NSString *strComment = [NSString stringWithFormat:@"%d %@",_post.commentsCount,NSLocalizedString([@"Comment" stringWithExtensionforCount:_post.commentsCount], nil)];
    if (hideLike) {
        strLikes = @"";
    }
    if (hideComment) {
        strComment = @"";
    }
    
    lblLikesAndComments.text =[NSString stringWithFormat:@"%@ . %@",strLikes,strComment];
    [lblLikesAndComments sizeToFit];
    lblLikesAndComments.frame =CGRectMake(self.bubbleContentView.frame.size.width-kBubbleCellBubblePaddingLeft-lblLikesAndComments.frame.size.width, lblLikesAndComments.frame.origin.y, lblLikesAndComments.frame.size.width, 12);
    
    [lblLikesAndComments addLinkToURL:[NSURL URLWithString:linkLikeDetection] withRange:NSMakeRange(0, strLikes.length)];
    [lblLikesAndComments addLinkToURL:[NSURL URLWithString:linkCommentDetection] withRange:NSMakeRange(strLikes.length+3, strComment.length)];
  
    
}
+ (CGFloat)getheightWithLikeAndCommentForPost:(SGPostVideo*)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus{
    CGFloat totalHeight = 0;
    if (post.strDesrciption.length > 0) {
        CGFloat totaltextHeight = [UHLabel getHeightOfText:post.strDesrciption forWidth:[SGNewsFeedBubbleCell bubbleWidthwithLine:lineStatus] - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight withAttributes:@{NSFontAttributeName:SGREGULARFONT(16.0)}];
        CGFloat textHeight = totaltextHeight + 15;
        if (totaltextHeight < 62) {
            if (!status) {
                textHeight = 62;
            }
        }else
        {
            if (!status) {
                textHeight = 62;
            }
            
        }
        if (post.strThumbUrl.length > 0) {
            totalHeight = (kSGNEWSFEED_PHOTOCELL_HEIGHT + textHeight);
            
        }else
            totalHeight = (kSGNEWSFEED_CELL_HEIGHT + textHeight);
    }else{
        totalHeight = (post.strThumbUrl.length > 0) ? kSGNEWSFEED_PHOTOCELL_HEIGHT : kSGNEWSFEED_CELL_HEIGHT;
    }
    return  totalHeight - 50;
    
}
+ (CGFloat)getHeightForPost:(SGPostVideo*)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus{
    if (post.strDesrciption.length > 0) {
        CGFloat totaltextHeight = [UHLabel getHeightOfText:post.strDesrciption forWidth:[SGNewsFeedBubbleCell bubbleWidthwithLine:lineStatus] - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight withAttributes:@{NSFontAttributeName:SGREGULARFONT(16.0)}];
        CGFloat textHeight = totaltextHeight + 15;
        if (totaltextHeight < 62) {
            if (!status) {
                textHeight = 62;
            }
        }else
        {
            if (!status) {
                textHeight = 62;
            }
            
        }
        if (post.strThumbUrl.length > 0) {
            return kSGNEWSFEED_PHOTOCELL_HEIGHT + textHeight;
            
        }else
            return kSGNEWSFEED_CELL_HEIGHT + textHeight;
    }else{
        return (post.strThumbUrl.length > 0) ? kSGNEWSFEED_PHOTOCELL_HEIGHT : kSGNEWSFEED_CELL_HEIGHT;
        }
    
    
}

- (void)dealloc{
    [imgViewPost sd_cancelCurrentImageLoad];
    self.delegate       = nil;
    lblLikesAndComments = nil;
    imgViewPost         = nil;
    lblDiscription      = nil;
    btnPlay             = nil;
    self.videodelegate  = nil;
    
}

@end
