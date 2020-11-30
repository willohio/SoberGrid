//
//  SGNewsFeedPhotoCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "SGNewsFeedPhotoCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+Utilities.h"
#import <objc/runtime.h>
static char * kIndexPathAssociationKeySTR = "associated_string_key";

@implementation SGNewsFeedPhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withLine:(BOOL)status
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier lineType:kSGNewsFeedTypePhoto withLine:status];
    if (self) {
        // Initialization code
        [self customise];
    }
    return self;
}
- (void)customise{
    lblDiscription = [[UHLabel alloc]initWithFrame:CGRectZero];
    lblDiscription.textColor = [UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1];
    [lblDiscription enableDetection];
    lblDiscription.font = SGREGULARFONT(16.0);
    [lblDiscription enableContinueReading];
    lblDiscription.delegate = self;
    [self.bubbleContentView addSubview:lblDiscription];
    
    _imgViewPost = [[UIImageView alloc] init];
      _imgViewPost.contentMode = UIViewContentModeScaleAspectFit;
    [self.bubbleContentView addSubview:_imgViewPost];
    
    lblLikesAndComments = [[UHLabel alloc]initWithFrame:CGRectZero];
    [lblLikesAndComments enableDetection];
    lblLikesAndComments.delegate = self;
 
    
    lblLikesAndComments.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName:(__bridge id)[[UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1] CGColor]};
    lblLikesAndComments.textColor = [UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1];
    lblLikesAndComments.font = SGREGULARFONT(10);
    lblLikesAndComments.userInteractionEnabled = true;
       [self.bubbleContentView addSubview:lblLikesAndComments];


}
- (void)customizeWithPost:(id)post withFullVersion:(BOOL)status forType:(NSString *)strType {
    _feedPost = post;
    CGFloat height = 0;
    postType = strType;
    if ([post isKindOfClass:[SGPostPage class]]) {
        _feedType = kSGNewsFeedTypePage;
        _page = post;
       height =  [SGNewsFeedPhotoCell getHeightForPage:_page withFullVersion:status withLine:isLine];
        
    }else if([post isKindOfClass:[SGPostPhoto class]]){
        _post = post;
        _feedType = kSGNewsFeedTypePhoto;
        if (hideLike && hideComment) {
            height = [SGNewsFeedPhotoCell getHeightWithoutLikeAndCommentForPost:_post withFullVersion:status withLine:isLine];
        }else
        height = [SGNewsFeedPhotoCell getHeightForPost:_post withFullVersion:status withLine:isLine];

    }else{
        _postStatus = post;
        _feedType = kSGNewsFeedTypeStatus;
        if (hideLike && hideComment) {
            height = [SGNewsFeedPhotoCell getHeightWithoutLikeAndCommentForPostStatus:_postStatus withFullVersion:status withLine:isLine];
        }else
        height = [SGNewsFeedPhotoCell getHeightForPostStatus:_postStatus withFullVersion:status withLine:isLine];
    }
    CGRect buubleFrame=self.bubbleContentView.frame;
    buubleFrame.size.height = height - SGBubbleOffsetFromTop;
    self.bubbleContentView.frame = buubleFrame;
    cellHeight = height;
   
    if (_feedType == kSGNewsFeedTypePhoto) {
        _imgViewPost.hidden = NO;

        [super customizeWithUser:_post.objUser postDate:_post.datePosted withMoodMessage:@"Feeling Happy" isLiked:[_post.strIsLike boolValue]];
        
        if (_post.strDesrciption.length > 0) {
            lblDiscription.hidden = NO;
            // Text
            lblDiscription.frame =CGRectMake(kBubbleCellContentPaddingRight, 60+kBubbleCellBubblePaddingTop, self.bubbleContentView.frame.size.width - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight, (_post.strImageUrl.length > 0)?57:80);
            
            
            
            NSData *newdata=[_post.strDesrciption dataUsingEncoding:NSUTF8StringEncoding
                                         allowLossyConversion:YES];
            NSString *mystring=[[NSString alloc] initWithData:newdata encoding:NSNonLossyASCIIStringEncoding];

            NSLog(@"%@",mystring);
            
            
            if (_post.strDesrciption.length>0) {
                
                
                NSString *correctString = [NSString stringWithCString:[_post.strDesrciption cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];
                
                NSLog(@"mystring------%@",correctString);
                
                lblDiscription.text = correctString;
            }
            else
                lblDiscription.text = _post.strDesrciption;

            
            
            
            
            if (status) {
                lblDiscription.numberOfLines = 0;
                [lblDiscription resizeToHeight];
            }else{
                lblDiscription.numberOfLines = 3;
                lblDiscription.lineBreakMode = NSLineBreakByTruncatingTail;
            }
            
            
            //[self setBorderTo:lblStatus];
            
        }else{
            lblDiscription.hidden = YES;
        }
        
        if (_post.strImageUrl.length > 0) {
            _imgViewPost.hidden = NO;
            _imgViewPost.frame =CGRectMake(0,(_post.strDesrciption.length > 0)?(lblDiscription.frame.size.height+5+lblDiscription.frame.origin.y):(60+kBubbleCellBubblePaddingTop), self.bubbleContentView.frame.size.width, kSGNEWSFEED_PHOTOCELL_HEIGHT/2);
            
            
            NSString *strUrl = (_post.strThumImageUrl.length > 0) ? _post.strThumImageUrl : _post.strImageUrl;
            [_imgViewPost sd_setImageWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] placeholderImage:[UIImage imageNamed:@"placeholderImage"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    
                }else{
                    [_imgViewPost sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[_post.strImageUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] andPlaceholderImage:[UIImage imageNamed:@"placeholderImage"] options:SDWebImageRetryFailed progress:nil completed:nil];
                    NSLog(@"did not got image ---> ImageURl %@",imageURL);
                }
            }];
            
        }else{
            _imgViewPost.hidden = YES;
        }
        
        
        CGRect tempFrame;
        if (!_imgViewPost.hidden) {
            tempFrame = _imgViewPost.frame;
        }else
        {
            tempFrame = lblDiscription.frame;
        }
        lblLikesAndComments.frame =CGRectMake(kBubbleCellBubblePaddingRight, tempFrame.origin.y+tempFrame.size.height + 5, 50, 12);
        
        [self upadateLikeCountwithValue:_post.likesCount];
    }else if(_feedType == kSGNewsFeedTypePage){
        _imgViewPost.hidden = NO;

        [super customizeWithPage:_page];
        
        if (_page.strPageDiscription.length > 0) {
            lblDiscription.hidden = NO;
            // Text
            lblDiscription.frame =CGRectMake(kBubbleCellContentPaddingRight, 90+kBubbleCellBubblePaddingTop, self.bubbleContentView.frame.size.width - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight, (_page.strPageBanner_Url.length > 0)?57:80);
            
            
            
            
            if (_page.strPageDiscription.length>0) {
                
                
                NSString *correctString = [NSString stringWithCString:[_page.strPageDiscription cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];
                
                NSLog(@"mystring------%@",correctString);
                
                lblDiscription.text = correctString;
            }
            else
                lblDiscription.text = _page.strPageDiscription;

            
            
            
            if (status) {
                lblDiscription.numberOfLines = 0;
                [lblDiscription resizeToHeight];
            }else{
                lblDiscription.numberOfLines = 3;
                lblDiscription.lineBreakMode = NSLineBreakByTruncatingTail;
            }
            
            //[self setBorderTo:lblStatus];
            
        }else{
            lblDiscription.hidden = YES;
        }
        
        if (_page.strPageBanner_Url.length > 0) {
            _imgViewPost.hidden = NO;
            _imgViewPost.frame =CGRectMake(0,(_page.strPageBanner_Url.length > 0)?(lblDiscription.frame.size.height+5+lblDiscription.frame.origin.y):(90+kBubbleCellBubblePaddingTop), self.bubbleContentView.frame.size.width, kSGNEWSFEED_PHOTOCELL_HEIGHT/2);
            _imgViewPost.userInteractionEnabled = YES;
            
            
            
          
            UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(handleTouch:)];
            pgr.delegate = self;
            
            objc_setAssociatedObject(pgr,
                                     kIndexPathAssociationKeySTR,
                                     _page.strPageDiscription,
                                     OBJC_ASSOCIATION_RETAIN);

            [_imgViewPost addGestureRecognizer:pgr];

            NSString *strUrl = (_page.strPageBanner_Url.length > 0) ? _page.strPageBanner_Url : @"";
            [_imgViewPost sd_setImageWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] placeholderImage:[UIImage imageNamed:@"placeholderImage"] options:SDWebImageRetryFailed completed:nil];
            
        }else{
            _imgViewPost.hidden = YES;
        }
        
        
        CGRect tempFrame;
        if (!_imgViewPost.hidden) {
            tempFrame = _imgViewPost.frame;
        }else
        {
            tempFrame = lblDiscription.frame;
        }
        lblLikesAndComments.frame =CGRectMake(kBubbleCellBubblePaddingRight, tempFrame.origin.y+tempFrame.size.height + 5, 50, 12);
        
        [self upadateLikeCountwithValue:_page.likesCount];
    }else{
        [super customizeWithUser:_postStatus.objUser postDate:_postStatus.datePosted withMoodMessage:@"Feeling Happy" isLiked:[_postStatus.strIsLike boolValue]];
        
        
        // Text
        lblDiscription.hidden = NO;
        _imgViewPost.hidden = YES;
        lblDiscription.frame =CGRectMake(kBubbleCellContentPaddingRight, 60+kBubbleCellBubblePaddingTop, self.bubbleContentView.frame.size.width - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight, (_post.strImageUrl.length > 0)?57:80);
        
        NSData *newdata=[_postStatus.strStatus dataUsingEncoding:NSUTF8StringEncoding
                                           allowLossyConversion:YES];
        NSString *mystring=[[NSString alloc] initWithData:newdata encoding:NSNonLossyASCIIStringEncoding];
        if (_postStatus.strStatus.length>0) {
            
        
        NSString *correctString = [NSString stringWithCString:[_postStatus.strStatus cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];

        NSLog(@"mystring------%@",correctString);
        
        lblDiscription.text = correctString;
        }
        else
            lblDiscription.text = _postStatus.strStatus;
        
        if (status) {
            lblDiscription.numberOfLines = 0;
            [lblDiscription resizeToHeight];
        }else{
            lblDiscription.lineBreakMode = NSLineBreakByTruncatingTail;
            lblDiscription.numberOfLines = 3.0;
        }
        
        lblLikesAndComments.frame =CGRectMake(kBubbleCellBubblePaddingRight, lblDiscription.frame.origin.y+lblDiscription.frame.size.height + 5, 50, 12);

        
        [self upadateLikeCountwithValue:_postStatus.likesCount];
    }
    
  
    
    
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)handleTouch:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSString *valueIs = (NSString *)objc_getAssociatedObject(tapGestureRecognizer, kIndexPathAssociationKeySTR);
    [self handleTap:valueIs];

}
- (void)handleTap:(NSString *)string
{
    //handle tap...
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            NSLog(@"found URL: %@", url);
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LINKTAPPED object:url];

        }
    }

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    
    
    if([postType isEqualToString:@"post"]){
        CommonApiCall *apiclass=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kAPI_LIKE) andDelegate:self];
        
        if (_feedType == kSGNewsFeedTypePhoto) {
            _post.strIsLike=[NSString stringWithFormat:@"%d",sender.selected];
            [self upadateLikeCountwithValue:_post.likesCount + ((sender.selected)?(1):(-1))];
            [apiclass startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"id":_post.strFeedId,@"likestatus":[NSNumber numberWithBool:sender.selected],@"type":postType} options:NSJSONWritingPrettyPrinted error:nil]];
        }else if (_feedType == kSGNewsFeedTypeStatus){
            _postStatus.strIsLike=[NSString stringWithFormat:@"%d",sender.selected];
            [self upadateLikeCountwithValue:_postStatus.likesCount + ((sender.selected)?(1):(-1))];
            [apiclass startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"id":_postStatus.strFeedId,@"likestatus":[NSNumber numberWithBool:sender.selected],@"type":postType} options:NSJSONWritingPrettyPrinted error:nil]];
            
        }else{
            _page.strIsLike=[NSString stringWithFormat:@"%d",sender.selected];
            [self upadateLikeCountwithValue:_page.likesCount + ((sender.selected)?(1):(-1))];
            [apiclass startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"id":_page.strPageId,@"likestatus":[NSNumber numberWithBool:sender.selected],@"type":@"page"} options:NSJSONWritingPrettyPrinted error:nil]];
        }
        
    }else{
        _post.strIsLike=[NSString stringWithFormat:@"%d",sender.selected];
        [self upadateLikeCountwithValue:_post.likesCount + ((sender.selected)?(1):(-1))];
        CommonApiCall *apiclass=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kAPI_PAGEFEED_LIKE) andDelegate:self];
        [apiclass startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"page_feed_id":_post.strFeedId,@"likestatus":[NSNumber numberWithBool:sender.selected]} options:NSJSONWritingPrettyPrinted error:nil]];
    }
   

}
- (void)btnComment_Clicked:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(btnCommentClickedForPost:fromCell:)]) {
        [self.delegate btnCommentClickedForPost:_feedPost fromCell:(UITableViewCell*)self];
    }
    
}
- (void)btnLIkeTouched{
    if ([self.delegate respondsToSelector:@selector(btnLikeClickedForPost:fromCell:)]) {
        [self.delegate btnLikeClickedForPost:_feedPost fromCell:(UITableViewCell*)self];
    }
}
- (void)btnShare_Clicked:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(btnShareClickedForPost:fromCell:)]) {
        [self.delegate btnShareClickedForPost:_feedPost fromCell:(UITableViewCell*)self];
        
    }
}
- (void)profileViewTapped:(UIView *)view{
    if ([self.delegate respondsToSelector:@selector(profileViewTappedForPost:)]) {
        [self.delegate profileViewTappedForPost:_feedPost];
        
    }
}
- (void)blockOptionClicked:(UIView *)view{
    if ([self.delegate respondsToSelector:@selector(blockOptionClickedForPost:)]) {
        [self.delegate blockOptionClickedForPost:_feedPost];
    }
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    if (([requestedURL rangeOfString:kAPI_LIKE].location != NSNotFound) ||
        ([requestedURL rangeOfString:kAPI_PAGEFEED_LIKE].location != NSNotFound)) {
        [self upadateLikeCountwithValue:[dictResponse[RESPONSE][@"totatllikes"] intValue]];
       
        if ([self.delegate respondsToSelector:@selector(updatedPost:ForCell:)]) {
            [self.delegate updatedPost:_feedPost ForCell:self];
        }
    }
    
}
- (void)upadateLikeCountwithValue:(int)value{
    NSString *strLikes;
    NSString *strComment;
    if (_feedType == kSGNewsFeedTypePhoto) {
        _post.likesCount = value;
        strLikes =[NSString stringWithFormat:@"%d %@",_post.likesCount,NSLocalizedString([@"Like" stringWithExtensionforCount:_post.likesCount], nil)];
        
        strComment = [NSString stringWithFormat:@"%d %@",_post.commentsCount,NSLocalizedString([@"Comment" stringWithExtensionforCount:_post.commentsCount], nil)];

    }else if (_feedType == kSGNewsFeedTypeStatus){
        _postStatus.likesCount = value;
        strLikes =[NSString stringWithFormat:@"%d %@",_postStatus.likesCount,NSLocalizedString([@"Like" stringWithExtensionforCount:_postStatus.likesCount], nil)];
        strComment = [NSString stringWithFormat:@"%d %@",_postStatus.commentsCount,NSLocalizedString([@"Comment" stringWithExtensionforCount:_postStatus.commentsCount], nil)];
    }else{
        _page.likesCount = value;
        strLikes =[NSString stringWithFormat:@"%d %@",_page.likesCount,NSLocalizedString([@"Like" stringWithExtensionforCount:_page.likesCount], nil)];
//        strComment = [NSString stringWithFormat:@"%d %@",_page.commentsCount,NSLocalizedString([@"Comment" stringWithExtensionforCount:_page.commentsCount], nil)];
        strComment = @"";
    }
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
    //    lblLikesAndComments.text = [NSString stringWithFormat:@"%d %@ . %d %@",_post.likesCount,NSLocalizedString([@"Like" stringWithExtensionforCount:_post.likesCount], nil),_post.commentsCount,NSLocalizedString([@"Comment" stringWithExtensionforCount:_post.commentsCount], nil)];
    //    [lblLikesAndComments sizeToFit];
    //    lblLikesAndComments.frame =CGRectMake(self.bubbleContentView.frame.size.width-kBubbleCellBubblePaddingLeft-lblLikesAndComments.frame.size.width, lblLikesAndComments.frame.origin.y, lblLikesAndComments.frame.size.width, 12);
    
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}

#pragma Mark - Height Helper
+ (CGFloat)getHeightForPage:(SGPostPage *)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus{
    
    if (post.strPageDiscription.length > 0) {
        CGFloat totaltextHeight = [UHLabel getHeightOfText:post.strPageDiscription forWidth:[SGNewsFeedBubbleCell bubbleWidthwithLine:lineStatus ] - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight withAttributes:@{NSFontAttributeName:SGREGULARFONT(16.0)}];
        CGFloat textHeight = totaltextHeight + 15;
        if ((post.strPageBanner_Url.length > 0)) {
            return kSGNEWSFEED_PHOTOCELL_HEIGHT + ((status)?MAX(62, textHeight) : 62) + 30;
        }else
            return kSGNEWSFEED_PHOTOCELL_HEIGHT + ((status)?MAX(62, textHeight) : 62) + 30 - kSGNEWSFEED_PHOTOCELL_HEIGHT/2;
        
    }else{
        if ((post.strPageBanner_Url.length > 0)) {
            return kSGNEWSFEED_PHOTOCELL_HEIGHT +30;
        }else
            return kSGNEWSFEED_PHOTOCELL_HEIGHT + 30 - kSGNEWSFEED_PHOTOCELL_HEIGHT/2;
    }
}
+ (CGFloat)getHeightWithoutLikeAndCommentForPost:(SGPostPhoto*)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus{
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
        if (post.strImageUrl.length > 0) {
            totalHeight = (kSGNEWSFEED_PHOTOCELL_HEIGHT + textHeight);
            
        }else
            totalHeight = (kSGNEWSFEED_CELL_HEIGHT + textHeight);
    }else{
        if (post.strImageUrl.length > 0) {
            totalHeight = kSGNEWSFEED_PHOTOCELL_HEIGHT ;
            
        }else
            totalHeight = kSGNEWSFEED_CELL_HEIGHT ;
    }
    
   
        return totalHeight - 50;
}
+ (CGFloat)getHeightForPost:(SGPostPhoto*)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus{
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
        if (post.strImageUrl.length > 0) {
            return kSGNEWSFEED_PHOTOCELL_HEIGHT + textHeight;

        }else
            return kSGNEWSFEED_CELL_HEIGHT + textHeight;
    }else{
        if (post.strImageUrl.length > 0) {
            return kSGNEWSFEED_PHOTOCELL_HEIGHT ;
            
        }else
            return kSGNEWSFEED_CELL_HEIGHT ;
    }
    
    
}

#pragma Mark - Height Helper
+ (CGFloat)getHeightWithoutLikeAndCommentForPostStatus:(SGPostStatus*)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus{
    
    CGFloat textHeight =(status)?([UHLabel getHeightOfText:post.strStatus forWidth:[SGNewsFeedBubbleCell bubbleWidthwithLine:lineStatus ]-(kBubbleCellContentPaddingLeft + kBubbleCellBubblePaddingRight) withAttributes:@{NSFontAttributeName:SGREGULARFONT(16.0)}]) : 0;
    
    if (status) {
        if (textHeight > 62) {
            textHeight = textHeight - 62;
        }
    }
    CGFloat totalHeight = (kSGNEWSFEED_CELL_HEIGHT + textHeight);
    totalHeight  = totalHeight - 50;
    
    return totalHeight;
}
+ (CGFloat)getHeightForPostStatus:(SGPostStatus*)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus{
    
    CGFloat textHeight =(status)?([UHLabel getHeightOfText:post.strStatus forWidth:[SGNewsFeedBubbleCell bubbleWidthwithLine:lineStatus ]-(kBubbleCellContentPaddingLeft + kBubbleCellBubblePaddingRight) withAttributes:@{NSFontAttributeName:SGREGULARFONT(16.0)}]) : 0;
    
    if (status) {
        if (textHeight > 62) {
            textHeight = textHeight - 62;
        }
    }
    return (kSGNEWSFEED_CELL_HEIGHT + textHeight);
}
+ (CGFloat)getHeightAccordingToPost:(id)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus{
    if ([post isKindOfClass:[SGPostPage class]]) {
        return [SGNewsFeedPhotoCell getHeightForPage:post withFullVersion:status withLine:lineStatus];
        
    }else if([post isKindOfClass:[SGPostPhoto class]]){
        return [SGNewsFeedPhotoCell getHeightForPost:post withFullVersion:status withLine:lineStatus];
    }else{
        return [SGNewsFeedPhotoCell getHeightForPostStatus:post withFullVersion:status withLine:lineStatus];
    }

}
+ (CGFloat)getHeightWithoutLikeAndCommentAccordintToPost:(id)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus{
    if([post isKindOfClass:[SGPostPhoto class]]){
        return [SGNewsFeedPhotoCell getHeightWithoutLikeAndCommentForPost:post withFullVersion:status withLine:lineStatus];
    }else{
        return [SGNewsFeedPhotoCell getHeightWithoutLikeAndCommentForPostStatus:post withFullVersion:status withLine:lineStatus];
    }
    
}
- (void)dealloc{
    [_imgViewPost sd_cancelCurrentImageLoad];
    self.delegate       = nil;
    lblLikesAndComments = nil;
    _imgViewPost        = nil;
    lblDiscription      = nil;

    
}

@end
