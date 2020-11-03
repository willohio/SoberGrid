//
//  NewsFeedButtonsView.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#define FONT_SIZE 12
#define BOTTON_HEIGHT 30

#import "NewsFeedButtonsView.h"
#import "NSObject+ConvertingViewPixels.h"

@implementation NewsFeedButtonsView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self customize];
    }
    return self;
}
- (void)setLikeStatus:(BOOL)status forPage:(BOOL)isPage{
    if (isPage) {
        btnComment.hidden = YES;
    }else{
        btnComment.hidden = NO;
    }
    btnLike.selected = status;
}

- (void)customize{
    btnLike=[[SGRoundButton alloc] initWithFrame:CGRectMake(8, 10, [self deviceSpesificValue:60], [self deviceSpesificValue:BOTTON_HEIGHT])];

    [btnLike setLeftImage:[UIImage imageNamed:imageNameRefToDevice(@"Like_Logo")] forState:UIControlStateNormal];
    
    [btnLike setLeftImage:[UIImage imageNamed:imageNameRefToDevice(@"Liked_Logo")] forState:UIControlStateSelected];
    [btnLike setTitle:NSLocalizedString(@"Like", nil) forState:UIControlStateNormal];
    [btnLike setTitle:NSLocalizedString(@"Liked", nil) forState:UIControlStateSelected];
    [btnLike setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnLike setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [btnLike setBorderColor:[UIColor lightGrayColor]];
    [btnLike setSelectedStateBorderColor:[UIColor redColor]];   
    [btnLike setBorderWidth:0.5];
    [btnLike addTarget:self action:@selector(btnLike_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    btnLike.titleLabel.font = SGREGULARFONT(FONT_SIZE);
    [self addSubview:btnLike];

    
    btnComment = [[SGRoundButton alloc]initWithFrame:CGRectMake(btnLike.frame.size.width+btnLike.frame.origin.x + 10, 10,[self deviceSpesificValue:90] , [self deviceSpesificValue:BOTTON_HEIGHT])];
        [btnComment setLeftImage:[UIImage imageNamed:imageNameRefToDevice(@"Comment_Logo")]forState:UIControlStateNormal];
        [btnComment setTitle:NSLocalizedString(@"Comment", nil) forState:UIControlStateNormal];
        [btnComment addTarget:self action:@selector(btnComment_Clicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnComment setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btnComment setBorderColor:[UIColor lightGrayColor]];
        [btnComment setBorderWidth:0.5];
        btnComment.titleLabel.font = SGREGULARFONT(FONT_SIZE);
        [self addSubview:btnComment];
    
    
    

    
//    btnShare=[[SGRoundButton alloc] initWithFrame:CGRectMake(btnComment.frame.size.width+btnComment.frame.origin.x + 10, 10, [self deviceSpesificValue:60], [self deviceSpesificValue:BOTTON_HEIGHT])];
//    [btnShare setLeftImage:[UIImage imageNamed:imageNameRefToDevice(@"Share_Logo")] forState:UIControlStateNormal];
//    [btnShare setTitle:@"Share" forState:UIControlStateNormal];
//    [btnShare addTarget:self action:@selector(btnShare_Clicked:) forControlEvents:UIControlEventTouchUpInside];
//    [btnShare setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    [btnShare setBorderColor:[UIColor lightGrayColor]];
//    [btnShare setBorderWidth:0.5];
//    btnShare.titleLabel.font = SGREGULARFONT(FONT_SIZE);

  //  [self addSubview:btnShare];
   

}
- (void)hideLike{
    btnLike.hidden = YES;
}
- (void)hideComment{
    btnComment.hidden = YES;
}
- (void)btnLike_Clicked:(UIButton *)sender{
    [_delegate btnLike_Clicked:sender];
}
- (void)btnComment_Clicked:(UIButton *)sender{
    [_delegate btnComment_Clicked:sender];
    
}
- (void)btnShare_Clicked:(UIButton *)sender{
    [_delegate btnShare_Clicked:sender];
}
- (void)removeFromSuperview{
    [btnLike removeFromSuperview];
    [btnComment removeFromSuperview];
    [btnShare removeFromSuperview];
    
    btnLike = nil;
    btnComment = nil;
    btnShare  = nil;
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
