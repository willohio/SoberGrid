//
//  MessageTableViewCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/30/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#define ACCESSORYVIEWPADDING 30
#import "MessageTableViewCell.h"
#import "JSON.h"
#import "User.h"
#import "NSDate+NVTimeAgo.h"
#import "NSObject+ConvertingViewPixels.h"
#import "SGXMPP.h"
@implementation MessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      //  UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Right_Arrow"]];
     //   self.accessoryView = imgView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
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
- (void)customizewithData:(NSDictionary*)dict{
    
    _dictInfo = dict;
    
    lblTime = [[UHLabel alloc]initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 100, [self deviceSpesificValue:10], 50, [self deviceSpesificValue:30])];
    NSDate *timeStamp = dict[@"timestamp"];
    lblTime.textColor = [UIColor grayColor];
    lblTime.font = SGREGULARFONT([self deviceSpesificValue:14.0]);
    lblTime.text = [timeStamp formattedAsTimeAgo];
    [lblTime sizeToFit];
    
    CGRect lblTimeFrame = lblTime.frame ;
    lblTimeFrame.origin.x = CGRectGetWidth([UIScreen mainScreen].bounds) - ACCESSORYVIEWPADDING -5-5-lblTime.frame.size.width;
    lblTime.frame = lblTimeFrame;
    [self.contentView addSubview:lblTime];

    UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Right_Arrow.png"]];
    imgView.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - (CGRectGetWidth(imgView.bounds))-15, lblTime.frame.origin.y + lblTime.frame.size.height /2 -  CGRectGetHeight(imgView.bounds)/2 , CGRectGetWidth(imgView.bounds), CGRectGetHeight(imgView.bounds));
    [self.contentView addSubview:imgView];
    imgView = nil;
   
    NSDictionary *dictMessage = [[dict objectForKey:@"message"] JSONValue];

    
    lblName = [[UILabel alloc]initWithFrame:CGRectMake(40, [self deviceSpesificValue:10], lblTime.frame.origin.x -15, [self deviceSpesificValue:30])];
    lblName.font = SGBOLDFONT([self deviceSpesificValue:17]);
    
    NSString *sender =([dict objectForKey:@"senderid"])?[dict objectForKey:@"senderid"] : [dict objectForKey:@"otherUser"];
    if ([sender isEqualToString:[User currentUser].struserId]) {
         lblName.text=([dictMessage objectForKey:@"to"])?[dictMessage objectForKey:@"to"] : [dict objectForKey:@"otherUser"];
    }else{
        lblName.text=([dictMessage objectForKey:@"sender"])?[dictMessage objectForKey:@"sender"] : [dict objectForKey:@"otherUser"];
    }
   
    [self.contentView addSubview:lblName];
    
    lblMessage = [[UILabel alloc]initWithFrame:CGRectMake(40, CGRectGetHeight(lblName.frame)+lblName.frame.origin.y, CGRectGetWidth(lblName.frame), 40)];
    lblMessage.numberOfLines = 0;
    
    
    NSString *message;
    if (dictMessage) {
        if ([[dictMessage objectForKey:@"type"] intValue] == 0) {
            message = [dictMessage objectForKey:@"message"];
        }
        // FOR PHOTO MESSAGE
        else if ([[dictMessage objectForKey:@"type"] intValue] == 1){
             if ([sender isEqualToString:[User currentUser].struserId]) {
                 message = @"You sent a photo";

             }else
            message = @"Has sent you a photo";
            
            
        }
        // FOR VIDEO MESSAGE
        else if([[dictMessage objectForKey:@"type"] intValue] == 2){
            
        }
        // FOR VOICE MESSAGE
        else if([[dictMessage objectForKey:@"type"] intValue] == 3){
            
        }
        // FOR LOCATION MESSAGE
        else if([[dictMessage objectForKey:@"type"] intValue] == 5){
            if ([sender isEqualToString:[User currentUser].struserId]) {
                message = @"You shared location";
            }else
                message = @"Has shared loction";
            
        }
        // FOR EMOTIONS MESSAGE
        else if([[dictMessage objectForKey:@"type"] intValue] == 4){
           
        }else
            message = @"";

    }else{
        message = [dict objectForKey:@"message"];
    }
    

    lblMessage.text=message;
    lblMessage.textColor = [UIColor grayColor];
    lblMessage.font = SGREGULARFONT([self deviceSpesificValue:14]);
    [self.contentView addSubview:lblMessage];
    
    if ([[SGXMPP sharedInstance] isUnReadMessageForUserid:_dictInfo[@"otherUser"]]) {
        imgUnread = [[UIImageView alloc]initWithFrame:CGRectMake(12, lblName.frame.origin.y, 10, 10)];
        imgUnread.layer.cornerRadius = imgUnread.frame.size.height/2;
        imgUnread.clipsToBounds = YES;
        imgUnread.center = CGPointMake(imgUnread.center.x, lblName.center.y);
        imgUnread.backgroundColor = RGB(117, 142, 249, 1);
        [self.contentView addSubview:imgUnread];
    }
    
}
- (void)unload{
    [lblName removeFromSuperview];
    [lblMessage removeFromSuperview];
    [lblTime removeFromSuperview];
    [imgUnread removeFromSuperview];
    
    
    lblTime = nil;
    lblName = nil;
    lblMessage = nil;
    imgUnread = nil;
}
- (void)dealloc{
    lblTime = nil;
    lblName = nil;
    lblMessage = nil;
    imgUnread = nil;
}

@end
