//
//  NotificationTableViewCell.m
//  SoberGrid
//
//  Created by agilepc-159 on 6/23/15.
//  Copyright (c) 2015 William Santiago All rights reserved.
//
static float cellHeight = 80;
#import "NotificationTableViewCell.h"
#import "NotificationViewController.h"
#import "NSDate+NVTimeAgo.h"
@interface NotificationTableViewCell()
{
    Notification *objNotif;
}
@end
@implementation NotificationTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customise];
    }
    return self;
}
- (void)customise{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    imgProfile = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, cellHeight, cellHeight)];
    [self.contentView addSubview:imgProfile];
    
    lblName = [[UILabel alloc]initWithFrame:CGRectMake(cellHeight + 5, 10, [UIScreen mainScreen].bounds.size.width - (cellHeight + 5) - 50, 20)];
    lblName.textColor = [UIColor blackColor];
    lblName.font = [UIFont boldSystemFontOfSize:16.0];
    [self.contentView addSubview:lblName];
    
    lblMessage = [[UILabel alloc]initWithFrame:CGRectMake(lblName.frame.origin.x, lblName.frame.origin.y + lblName.frame.size.height + 3, lblName.frame.size.width, 20)];
    lblMessage.textColor = [UIColor grayColor];
    lblMessage.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:lblMessage];
    
    lblTime = [[UILabel alloc]initWithFrame:CGRectMake(lblName.frame.origin.x, lblMessage.frame.origin.y + lblMessage.frame.size.height + 3, lblName.frame.size.width, 20)];
    lblTime.textColor = [UIColor grayColor];
    lblTime.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:lblTime];
    
    
    
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNameRefToDevice(@"Right_Arrow")]];
    
    imgDot =[[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 50, 0, 10, 10)];
    imgDot.center = CGPointMake(imgDot.center.x, cellHeight/2);
    imgDot.layer.cornerRadius = imgDot.frame.size.height/2;
    imgDot.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:imgDot];

}
- (void)updateWithNotification:(id)notif{
    objNotif = notif;
    NSLog(@"Show url");
    [imgProfile setImageWithURL:[NSURL URLWithString:objNotif.objUser.strProfilePic] placeholderImage:[UIImage imageWithColor:[UIColor lightGrayColor]]];
    NSLog(@"Name shown");
    lblName.text = objNotif.objUser.strName;
    
    lblMessage.text = objNotif.strMessage;
    lblTime.text = [objNotif.notifDate formattedAsTimeAgo];
    if (objNotif.isRead) {
        imgDot.hidden = YES;
    }else
        imgDot.hidden = NO;
    
     NSLog(@"Name shown Done");
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (CGFloat)getCellHeight{
    return cellHeight;
}
- (void)dealloc{
    imgProfile = nil;
    lblName = nil;
    lblMessage = nil;
    lblTime = nil;
    imgDot = nil;
}
@end
