//
//  NewsFeedTopView.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/10/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "NewsFeedTopView.h"
#import "UIImageView+WebCache.h"
#import "Line.h"
@implementation NewsFeedTopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = true;
        [self customise];
        
        // Initialization code
    }
    return self;
}


- (void)customise{
    imgeUser = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 32, 32)];
    imgeUser.clipsToBounds = YES;
    imgeUser.layer.cornerRadius = imgeUser.frame.size.width / 2;
    [self addSubview:imgeUser];
    
    lblUserName = [[UHLabel alloc]initWithFrame:CGRectMake(imgeUser.frame.size.width+10, 7, self.frame.size.width-(10 + CGRectGetWidth(imgeUser.frame)+10), self.frame.size.height/2 - 8)];
    
    lblUserName.font = SGBOLDFONT(12);
    lblUserName.textColor = [UIColor blackColor];
    [self addSubview:lblUserName];
    
    lblDate = [[UHLabel alloc]initWithFrame:CGRectMake(imgeUser.frame.size.width+10, self.frame.size.height/2 + 2 , self.frame.size.width-(10 + CGRectGetWidth(imgeUser.frame)+10), self.frame.size.height/2 - 1)];
    lblDate.font = SGREGULARFONT(12);
    lblDate.textColor = [UIColor grayColor];
    [self addSubview:lblDate];
        viewDisclosure=[[UIView alloc]init];
        viewDisclosure.frame =CGRectMake(self.frame.size.width - 5 - 30, 2, 30, 20);
        viewDisclosure.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
        viewDisclosure.backgroundColor=[UIColor clearColor];
        
        UIImageView *imgDisclosure=[[UIImageView alloc]initWithFrame:CGRectMake(10, 2.5, 9, 14)];
        imgDisclosure.image=[UIImage imageNamed:@"Right_Arrow"];
        
        imgDisclosure.contentMode=UIViewContentModeScaleAspectFit;
        [viewDisclosure addSubview:imgDisclosure];
        viewDisclosure.userInteractionEnabled = true;
        CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) M_PI_2);
        viewDisclosure.transform = transform;
        [self addSubview:viewDisclosure];
        UITapGestureRecognizer *tapDisclosure=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnBlock_Clicked:)];
        tapDisclosure.numberOfTapsRequired = 1.0;
        tapDisclosure.numberOfTouchesRequired = 1.0;
        [viewDisclosure addGestureRecognizer:tapDisclosure];
    
     [Line drawStraightLineFromStartPoint:CGPointMake(imgeUser.frame.size.width+10, self.frame.size.height/2) toEndPoint:CGPointMake(self.frame.size.width-10, self.frame.size.height/2) ofWidth:1 inView:self];

    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewHeaderTapped:)];
    tapGesture.numberOfTapsRequired = 1.0;
    [self addGestureRecognizer:tapGesture];
}

- (void)setUser:(User*)user withPostDate:(NSDate*)date withMoodMessage:(NSString*)moodMessage{
    self.userInteractionEnabled = true;
    _objUser = user;
    _postDate = date;
    _moodMessage = moodMessage;
    [self customizeUser];
    
}
- (void)setPage:(SGPostPage*)page{
    viewDisclosure.hidden = YES;
    _objPage = page;
    [self customizePage];
}

- (void)customizeUser{
    // Show profile image
    
    if (_objUser.strProfilePicThumb.length > 0) {
        [imgeUser sd_setImageWithURL:[NSURL URLWithString:[_objUser.strProfilePicThumb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"avator"] options:SDWebImageRetryFailed];
    }else
        imgeUser.image =[UIImage imageNamed:@"avator"];
    
       // Show Name of user
    
    lblUserName.text = _objUser.strName;
   
    lblDate.text = [_postDate formattedAsTimeAgo];
    
    if (!_objUser.isUserTypePage) {
        viewDisclosure.hidden = NO;
    }else
    {
        viewDisclosure.hidden = YES;
    }
   
   
}
- (void)customizePage{

    // Show profile image
    
    if (_objPage.strPageProfile_Url.length > 0) {
        [imgeUser sd_setImageWithURL:[NSURL URLWithString:[_objPage.strPageProfile_Url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"avator"]options:SDWebImageRetryFailed];
    }else
        imgeUser.image =[UIImage imageNamed:@"avator"];

    
    // Draw line
   
    
    // Show Name of user
    lblUserName.text = _objPage.strPageTitle;
}
- (IBAction)btnBlock_Clicked:(UIGestureRecognizer*)sender{
    if ([_delegate respondsToSelector:@selector(blockOptionClicked:)]) {
                [_delegate blockOptionClicked:self];
    }

}
- (void)viewHeaderTapped:(UIGestureRecognizer*)gesture{
    if ([_delegate respondsToSelector:@selector(profileViewTapped:)]) {
        [_delegate profileViewTapped:gesture.view];

    }
}
- (void)removeFromSuperview{
    
}
- (void)unload{
    [self unload];
}
- (void)dealloc{
    [imgeUser sd_cancelCurrentImageLoad];
    [self unload];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
