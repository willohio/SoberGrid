//
//  PostImagesCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/14/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "PostImagesCell.h"

@implementation PostImagesCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)customizeWithImage:(UIImage*)image forSize:(CGSize)size ofTypeVideo:(BOOL)status{
    imgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5,size.width - 10, size.height-10)];
    imgView.image = image;
    [self.contentView addSubview:imgView];
    
    btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    [btnCancel setTitle:@"x" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    btnCancel.backgroundColor = [UIColor grayColor];
    [btnCancel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btnCancel.layer.cornerRadius=10;
    btnCancel.layer.borderColor=[UIColor whiteColor].CGColor;
    btnCancel.layer.borderWidth = 1.0;
    [self.contentView addSubview:btnCancel];
    
    viewTouch = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    viewTouch.backgroundColor = [UIColor clearColor];
    viewTouch.userInteractionEnabled = true;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnCancel_Clicked:)];
    tapGesture.numberOfTapsRequired=1.0;
    [viewTouch addGestureRecognizer:tapGesture];
    [self.contentView addSubview:viewTouch];
    
    if (status) {
        imgView.userInteractionEnabled = true;
        btnPlay =   [[UIButton alloc]initWithFrame:imgView.bounds];
        [btnPlay addTarget:self action:@selector(btnPlay_Clicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        imgView.userInteractionEnabled = true;
        [imgView addSubview:btnPlay];
        
    }
    
}
- (void)btnPlay_Clicked:(UIButton*)sender{
    [_delegate postImageCellPlayButtonClicked:(UITableViewCell*)self];
}
- (void)btnCancel_Clicked:(UITapGestureRecognizer*)gestureRecognizer{
    [_delegate postImageCellCancelButtonClicked:(UITableViewCell*)self];
}
- (void)unload{
    [imgView    removeFromSuperview];
    [btnCancel  removeFromSuperview];
    [viewTouch  removeFromSuperview];
    [btnPlay    removeFromSuperview];
    
    btnCancel       =   nil;
    imgView         =   nil;
    viewTouch       =   nil;
    self.delegate   =   nil;
    btnPlay         =   nil;
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
