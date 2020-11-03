//
//  ViewBanner.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/22/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "ViewBanner.h"
#import "UIImageView+WebCache.h"
@interface ViewBanner(){
    UIButton *btnLike;
    UIImageView *imgViewBanner;
    UIImageView *imgProfile;
    UILabel *lblTitle;
}
@end
@implementation ViewBanner
- (instancetype)initWithFrame:(CGRect)frame customizeWithBannerUrl:(NSString*)strBannerUrl withProfileImageUrl:(NSString*)strProfileUrl withTitle:(NSString*)strTitle isLiked:(BOOL)liked LikeEnable:(BOOL)enable withDelegate:(id<ViewBannerDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customizeWithBannerUrl:strBannerUrl withProfileImageUrl:strProfileUrl withTitle:strTitle isLiked:liked withLikeEnable:(BOOL)enable withDelegate:delegate];
    }
    return self;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)customizeWithBannerUrl:(NSString*)strBannerUrl withProfileImageUrl:(NSString*)strProfileUrl withTitle:(NSString*)strTitle isLiked:(BOOL)liked withLikeEnable:(BOOL)enable withDelegate:(id<ViewBannerDelegate>)delegate{
    _delegate = delegate;
    imgViewBanner = [[UIImageView alloc] initWithFrame:[strProfileUrl length] ? self.bounds : CGRectInset(self.bounds, 10, 10)];
    imgViewBanner.backgroundColor = [UIColor grayColor];
    [imgViewBanner sd_setImageWithURL:[NSURL URLWithString:strBannerUrl] placeholderImage:nil options:SDWebImageRetryFailed];
    [self addSubview:imgViewBanner];
    
    UITapGestureRecognizer *tapBanner=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(banner_Tapped:)];
    [imgViewBanner addGestureRecognizer:tapBanner];
    
    if ([strProfileUrl length]) {
        imgProfile = [[UIImageView alloc]initWithFrame:CGRectMake(10, CGRectGetHeight(self.bounds) - 15 - 80, 80, 80)];
        imgProfile.contentMode = UIViewContentModeScaleAspectFill;
        [imgProfile sd_setImageWithURL:[NSURL URLWithString:strProfileUrl] placeholderImage:[UIImage imageNamed:@"placeholderImage"] options:SDWebImageRetryFailed];
        imgProfile.clipsToBounds = YES;
        imgProfile.layer.borderColor = [UIColor whiteColor].CGColor;
        imgProfile.layer.borderWidth = 1;
        [self addSubview:imgProfile];
        UITapGestureRecognizer *tapProfile=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(profile_Tapped:)];
        [imgProfile addGestureRecognizer:tapProfile];
        
        CGRect textRect = [strTitle boundingRectWithSize:CGSizeMake(CGRectGetHeight(self.bounds) - 15 - 40, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SGBOLDFONT(20.0)} context:nil];
        
        lblTitle=[[UILabel alloc]initWithFrame:CGRectMake(imgProfile.frame.origin.x+imgProfile.frame.size.width + 10, CGRectGetHeight(self.bounds) - 15 - textRect.size.height,CGRectGetWidth(self.bounds)  -(imgProfile.frame.origin.x+imgProfile.frame.size.width + 10), textRect.size.height)];
        lblTitle.font=SGBOLDFONT(20.0);
        lblTitle.numberOfLines = 0;
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.text=strTitle;
        [self addSubview:lblTitle];
    }
    
    btnLike = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 60, 10, 50, 50)];
    btnLike.backgroundColor = [UIColor clearColor];
    
    [btnLike setImage:[UIImage imageNamed:@"Round_Unliked_thumb"] forState:UIControlStateNormal];
    [btnLike setImage:[UIImage imageNamed:@"Round_Liked_thumb"] forState:UIControlStateSelected];
    [btnLike addTarget:self action:@selector(btnLike_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnLike];
    if (liked) {
        btnLike.selected = YES;
    }
    if (!enable) {
        btnLike.hidden = YES;
    }
}

- (void)updateWithBannerUrl:(NSString*)strBannerUrl withProfileImageUrl:(NSString*)strProfileUrl withTitle:(NSString*)strTitle isLiked:(BOOL)liked withLikeEnable:(BOOL)enable{
    [imgViewBanner sd_setImageWithURL:[NSURL URLWithString:strBannerUrl] placeholderImage:nil options:SDWebImageRetryFailed];
    [imgProfile sd_setImageWithURL:[NSURL URLWithString:strProfileUrl] placeholderImage:[UIImage imageNamed:@"placeholderImage"] options:SDWebImageRetryFailed];
   
    CGRect textRect = [strTitle boundingRectWithSize:CGSizeMake(CGRectGetHeight(self.bounds) - 15 - 40, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SGBOLDFONT(20.0)} context:nil];
    lblTitle.frame = CGRectMake(imgProfile.frame.origin.x+imgProfile.frame.size.width + 10, CGRectGetHeight(self.bounds) - 15 - textRect.size.height,CGRectGetWidth(self.bounds)  -(imgProfile.frame.origin.x+imgProfile.frame.size.width + 10), textRect.size.height);
    lblTitle.text=strTitle;
    
    if (liked) {
        btnLike.selected = YES;
    }
    if (!enable) {
        btnLike.hidden = YES;
    }
}
- (void)enableLike:(BOOL)enable{
    btnLike.hidden = !enable;
}
- (IBAction)btnLike_Clicked:(UIButton*)sender{
    sender.selected = !sender.selected;
    if ([_delegate respondsToSelector:@selector(viewBannerLike_ClickedWithSelectedState:)]) {
        [_delegate viewBannerLike_ClickedWithSelectedState:sender.selected];
    }
}

- (void)banner_Tapped:(UIGestureRecognizer*)recognizer{
    
    
}
- (void)profile_Tapped:(UIGestureRecognizer*)recognizer{
    
}

@end
