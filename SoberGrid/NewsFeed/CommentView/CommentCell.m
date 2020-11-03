//
//  CommentCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/22/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "CommentCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+NVTimeAgo.h"
#import "NSString+Utilities.h"
#import "NSDictionary+Null.h"
@implementation CommentCell
@synthesize imgProfile,objCmt,btnLike,lblComment,lblDate,lblLikes,lblUserName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDelegate:(id<CommentCellDelegate>)delegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _delegate = delegate;
        // Initialization code
        self.contentView.backgroundColor = SG_BACKGROUD_COLOR;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self customise];
        // Create Line
       
        
    }
    return self;
}
- (void)customise{
    imgProfile = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
    imgProfile.layer.cornerRadius = 20;
    imgProfile.clipsToBounds = YES;
    [self.viewContentHolder addSubview:imgProfile];
    imgProfile.userInteractionEnabled = YES;
    UITapGestureRecognizer *tpGes=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgProfile_Tapped:)];
    [imgProfile addGestureRecognizer:tpGes];
    
    lblUserName = [[UHLabel alloc]initWithFrame:CGRectMake(50, 5,CGRectGetWidth(self.viewContentHolder.bounds) - (5 + 40 + 5 + 5), 20)];
    lblUserName.font=SGBOLDFONT(14.0);
    lblUserName.textColor = [UIColor blackColor];
    lblUserName.userInteractionEnabled = YES;
    [self.viewContentHolder addSubview:lblUserName];
    
    UITapGestureRecognizer *tpGesName=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgProfile_Tapped:)];
    [lblUserName addGestureRecognizer:tpGesName];

    
    lblComment = [[UHLabel alloc]initWithFrame:CGRectMake(50, lblUserName.frame.origin.y + lblUserName.frame.size.height + 2, CGRectGetWidth(self.viewContentHolder.bounds) - (5 + 40 + 5 + 5), 20)];
    lblComment.font = SGREGULARFONT(14.0);
    lblComment.textColor  = [UIColor grayColor];
    [lblComment enableDetection];
    /*
     developer :- Agile
     date :- 1/5/2015
     comment :- add the enablecontinueReading line
     */
    [lblComment enableContinueReading];
  
    lblComment.userInteractionEnabled = true;
    lblComment.delegate = self;
   
    [self.viewContentHolder addSubview:lblComment];
    lblDate = [[UHLabel alloc] initWithFrame:CGRectMake(50, lblComment.frame.origin.y + lblComment.frame.size.height + 2, CGRectGetWidth(self.viewContentHolder.bounds) - (5 + 40 + 5 + 5), 20)];
    lblDate.font = SGREGULARFONT(12.0);
    lblDate.textColor=[UIColor grayColor];
    [self.viewContentHolder addSubview:lblDate];
    
    lblLikes = [[UILabel alloc]initWithFrame:CGRectMake(50, lblComment.frame.origin.y + lblComment.frame.size.height + 2, 100, 20)];
    lblLikes.font = SGREGULARFONT(12.0);
    lblLikes.textColor = [UIColor grayColor];
    
    [self.viewContentHolder addSubview:lblLikes];
    
    UITapGestureRecognizer *tapLike = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lblLike_Clicked)];
    lblLikes.userInteractionEnabled = YES;
    [lblLikes addGestureRecognizer:tapLike];
    btnLike = [[UIButton alloc]initWithFrame:CGRectMake(lblLikes.frame.origin.x - 33, lblLikes.frame.origin.y-5, 30, 30)];
    [btnLike setImage:[UIImage imageNamed:@"Like_Logo"] forState:UIControlStateNormal];
    [btnLike setImage:[UIImage imageNamed:@"Liked_Logo"] forState:UIControlStateSelected];
    
    
    [btnLike addTarget:self action:@selector(lblLike_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewContentHolder addSubview:btnLike];


}
- (void)customizeWithComment:(Comment*)cmt{
    objCmt = cmt;
    
    [self setHight:[CommentCell getHeightForCellForComment:objCmt]];
   
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:cmt.objUser.strProfilePicThumb] placeholderImage:[UIImage imageNamed:@"avator"] options:SDWebImageRetryFailed];
   
    
    if ([cmt.objUser.strName isKindOfClass:[NSNull class]])
    {
        lblUserName.text =@"";
    }
    else
    {
        lblUserName.text = cmt.objUser.strName;
    }

    lblComment.text=cmt.strComment;
     [lblComment resizeToHeight];
    
    lblDate.frame = CGRectMake(50, lblComment.frame.origin.y + lblComment.frame.size.height + 2, CGRectGetWidth(self.viewContentHolder.bounds) - (5 + 40 + 5 + 5), 20);
    if ([[cmt.postDate formattedAsTimeAgo] isKindOfClass:[NSNull class]])
    {
        lblDate.text=@"";
    }
    else
    {
        lblDate.text=[cmt.postDate formattedAsTimeAgo];
    }
    [lblDate sizeToFit];
    
   
    
    lblLikes.attributedText = [self likeString];
    [lblLikes sizeToFit];
    lblLikes.frame = CGRectMake(self.viewContentHolder.frame.size.width - lblLikes.frame.size.width - 5, lblComment.frame.origin.y + lblComment.frame.size.height + 2, lblLikes.frame.size.width, 20);
    btnLike.frame =CGRectMake(lblLikes.frame.origin.x - 33, lblLikes.frame.origin.y-5, 30, 30);
    btnLike.selected = objCmt.isLiked;
    
}
- (void)imgProfile_Tapped:(UITapGestureRecognizer*)recognizer{
    if ([_delegate respondsToSelector:@selector(commentCellDidSelectedProfileWithUser:)]) {
        [_delegate commentCellDidSelectedProfileWithUser:objCmt.objUser];
    }
}
- (void)lblLike_Clicked{
    if ([_delegate respondsToSelector:@selector(likeClickedForComment:)]) {
        [_delegate likeClickedForComment:objCmt];
    }
}
- (void)lblLike_Clicked:(UIButton*)sender{
    
    objCmt.isLiked = !objCmt.isLiked;
    sender.selected = objCmt.isLiked;
    objCmt.likesCount = objCmt.likesCount + ((objCmt.isLiked)?(+1):(-1));
    [self updateLikeLable];
    [self likeComment];
}
- (void)updateLikeLable{
    lblLikes.attributedText = [self likeString];
    [lblLikes sizeToFit];
    lblLikes.frame = CGRectMake(self.viewContentHolder.frame.size.width - lblLikes.frame.size.width - 5, lblLikes.frame.origin.y, lblLikes.frame.size.width, 20);
    btnLike.frame =CGRectMake(lblLikes.frame.origin.x - 31, lblLikes.frame.origin.y-5, 30, 30);
}
- (NSMutableAttributedString*)likeString{
    NSAttributedString *myString= [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %d %@",objCmt.likesCount,[@"Like" stringWithExtensionforCount:objCmt.likesCount]]];
    NSMutableAttributedString *totalString = [[NSMutableAttributedString alloc]init];
    [totalString appendAttributedString:myString];
    return totalString;

}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LINKTAPPED object:url];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (CGFloat)getHeightForCellForComment:(Comment*)cmt{
    CGFloat height = 40;
    CGFloat finalHeight = 0;
    finalHeight = (5 + 20 + 2 + [UHLabel getHeightOfText:cmt.strComment forWidth:(CGRectGetWidth([UIScreen mainScreen].bounds)-20) - (5 + 40 + 5 + 5) withAttributes:@{NSFontAttributeName:SGREGULARFONT(14.0)}] + 2 + 20 +2);
    if (finalHeight < height) {
        finalHeight = height;
    }
    return finalHeight;
}


- (void)likeComment{
    CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kCommentApi) andDelegate:self];
    [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"commentid":objCmt.strCommentID,@"likestatus":@(objCmt.isLiked).stringValue,@"type":objCmt.commentType} options:NSJSONWritingPrettyPrinted error:nil]];
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dict = [dict dictionaryByReplacingNullsWithBlanks];
    if ([[dict objectForKey:TYPE] isEqualToString:RESPONSE_OK]) {
        if (dict[@"totatllikes"]) {
            objCmt.likesCount = [dict[@"totatllikes"] intValue];
            [self updateLikeLable];
        }
    }
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
- (void)dealloc{
    [imgProfile sd_cancelCurrentImageLoad];
    imgProfile = nil;
    lblUserName = nil;
    lblDate = nil;
    lblLikes = nil;
}

@end
