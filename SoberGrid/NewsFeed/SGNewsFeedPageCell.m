//
//  SGNewsFeedPageCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/20/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#define kSGNEWSFEED_PAGE_HEIGHT 390

#import "SGNewsFeedPageCell.h"
#import "SGNewsFeedBubbleCell.h"
#import "UIImageView+WebCache.h"

@implementation SGNewsFeedPageCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier lineType:(int)lineType withLine:(BOOL)status
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier lineType:lineType withLine:status];
    if (self) {
        // Initialization code
        [self customise];
        
    }
    return self;
}
-(void)customise{
    lblDiscription = [[UHLabel alloc]initWithFrame:CGRectMake(kBubbleCellContentPaddingRight, 90+kBubbleCellBubblePaddingTop, self.bubbleContentView.frame.size.width - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight, 57)];
    lblDiscription.textColor = [UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1];
    [lblDiscription enableDetection];
    [lblDiscription enableContinueReading];
    lblDiscription.font = SGREGULARFONT(16.0);
    lblDiscription.numberOfLines = 0;
    lblDiscription.userInteractionEnabled = true;
    lblDiscription.delegate = self;
    [self.bubbleContentView addSubview:lblDiscription];
    
    _imgViewPost = [[UIImageView alloc] init];
    [self.bubbleContentView addSubview:_imgViewPost];
    
    _imgViewPost.contentMode = UIViewContentModeScaleAspectFit;
    _imgViewPost.userInteractionEnabled = true;
    
    // Likes
        lblLikesAndComments = [[UHLabel alloc]initWithFrame:CGRectZero];
        [self.bubbleContentView addSubview:lblLikesAndComments];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(profileViewTapped:)];
        tapGesture.numberOfTouchesRequired = 1.0;
        tapGesture.numberOfTapsRequired = 1.0;
        [lblLikesAndComments addGestureRecognizer:tapGesture];
    
    lblLikesAndComments.frame =CGRectMake(kBubbleCellBubblePaddingRight,(_imgViewPost) ? ( _imgViewPost.frame.origin.y+_imgViewPost.frame.size.height + 5) : (lblDiscription.frame.size.height+5+lblDiscription.frame.origin.y), 50, 12);
    lblLikesAndComments.font = SGREGULARFONT(10);
    lblLikesAndComments.textColor = [UIColor colorWithRed:96.0/255.0 green:94.0/255.0 blue:95.0/255.0 alpha:1];
    lblLikesAndComments.userInteractionEnabled = true;
}
- (void)customizewithPage:(SGPostPage *)page withFullVersion:(BOOL)status forType:(NSString *)strType withHeight:(CGFloat)height{
    
    CGRect buubleFrame=self.bubbleContentView.frame;
    buubleFrame.size.height = height - SGBubbleOffsetFromTop;
    self.bubbleContentView.frame = buubleFrame;
    
    cellHeight = height;
    
    postType = strType;
    [super customizeWithPage:page];
    _page = page;
    
    if (page.strPageDiscription.length > 0) {
        // Text
            lblDiscription.hidden = NO;
            lblDiscription.text = page.strPageDiscription;

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
    
    if ((page.strPageBanner_Url.length > 0)) {
        _imgViewPost.hidden = NO;
        _imgViewPost.frame =CGRectMake(0,(page.strPageDiscription.length > 0)?(lblDiscription.frame.size.height+5+lblDiscription.frame.origin.y):(60+kBubbleCellBubblePaddingTop), self.bubbleContentView.frame.size.width, kSGNEWSFEED_PHOTOCELL_HEIGHT/2);

        [_imgViewPost sd_setImageWithURL:[NSURL URLWithString:[page.strPageProfile_Url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"placeholderImage"] options:SDWebImageRetryFailed];
       
     

    }else{
        _imgViewPost.hidden = YES;
    }
    CGRect tempFrame ;
    if (!_imgViewPost.hidden) {
        tempFrame = _imgViewPost.frame;
    }else
    {
        tempFrame = lblDiscription.frame;
    }
    lblLikesAndComments.frame =CGRectMake(kBubbleCellBubblePaddingRight, tempFrame.origin.y+tempFrame.size.height + 5, 50, 12);

   
    lblLikesAndComments.text =[NSString stringWithFormat:@"%d %@",page.likesCount,NSLocalizedString([@"Like" stringWithExtensionforCount:page.likesCount], nil)];
    [lblLikesAndComments sizeToFit];
    lblLikesAndComments.frame =CGRectMake(self.bubbleContentView.frame.size.width-kBubbleCellBubblePaddingLeft-lblLikesAndComments.frame.size.width, tempFrame.origin.y+tempFrame.size.height + 5, lblLikesAndComments.frame.size.width, 12);

}
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LINKTAPPED object:url];
}
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectNormaltext:(NSString *)strText{
    [self profileViewTapped:nil];
}

- (void)btnComment_Clicked:(UIButton *)sender{
    
}
- (void)btnLike_Clicked:(UIButton *)sender{
    sender.selected = !sender.selected;
    _page.strIsLike =[NSString stringWithFormat:@"%d",sender.selected];
    [self upadateLikeCountwithValue:_page.likesCount + ((sender.selected)?(1):(-1))];

    CommonApiCall *apiclass=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kAPI_LIKE) andDelegate:self];
    [apiclass startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"id":_page.strPageId,@"likestatus":[NSNumber numberWithBool:sender.selected],@"type":@"page"} options:NSJSONWritingPrettyPrinted error:nil]];
    [self.delegate updatedPost:_page ForCell:self];
}
- (void)btnShare_Clicked:(UIButton *)sender{
    
}
-(void)profileViewTapped:(UIView *)view{
    if ([self.delegate respondsToSelector:@selector(profileViewTappedForPost:)]) {
        [self.delegate profileViewTappedForPost:_page];

    }
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse =[dictResponse dictionaryByReplacingNullsWithBlanks];
    if ([requestedURL rangeOfString:kAPI_LIKE].location != NSNotFound) {

        [self upadateLikeCountwithValue:[dictResponse[RESPONSE][@"totatllikes"] intValue]];
        if ([self.delegate respondsToSelector:@selector(updatedPost:ForCell:)]) {
            [self.delegate updatedPost:_page ForCell:self];
        }
        
    }
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
- (void)upadateLikeCountwithValue:(int)value{
    _page.likesCount = value;
    lblLikesAndComments.text = [NSString stringWithFormat:@"%d %@",_page.likesCount,NSLocalizedString([@"Like" stringWithExtensionforCount:_page.likesCount], nil)];
    [lblLikesAndComments sizeToFit];
    lblLikesAndComments.frame =CGRectMake(self.bubbleContentView.frame.size.width-kBubbleCellBubblePaddingLeft-lblLikesAndComments.frame.size.width, lblLikesAndComments.frame.origin.y, lblLikesAndComments.frame.size.width, 12);
    
}
#pragma Mark - Height Helper
+ (CGFloat)getHeightForPage:(SGPostPage *)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus{
    
    if (post.strPageDiscription.length > 0) {
        CGFloat totaltextHeight = [UHLabel getHeightOfText:post.strPageDiscription forWidth:[SGNewsFeedBubbleCell bubbleWidthwithLine:lineStatus ] - kBubbleCellContentPaddingLeft-kBubbleCellBubblePaddingRight withAttributes:@{NSFontAttributeName:SGREGULARFONT(16.0)}];
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
        if ((post.strPageBanner_Url.length > 0)) {
            return kSGNEWSFEED_PHOTOCELL_HEIGHT + textHeight + 30;
        }else
            return kSGNEWSFEED_PHOTOCELL_HEIGHT + textHeight + 30 - kSGNEWSFEED_PHOTOCELL_HEIGHT/2;

    }else{
        if ((post.strPageBanner_Url.length > 0)) {
            return kSGNEWSFEED_PHOTOCELL_HEIGHT +30;
        }else
            return kSGNEWSFEED_PHOTOCELL_HEIGHT + 30 - kSGNEWSFEED_PHOTOCELL_HEIGHT/2;
    }
}


- (void)dealloc{
    [_imgViewPost sd_cancelCurrentImageLoad];
    self.delegate  = nil;
    lblSuggestedPost = nil;
    lblDiscription = nil;
    _imgViewPost = nil;
    lblLikesAndComments = nil;
}

@end
