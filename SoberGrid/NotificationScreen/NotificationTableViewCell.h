//
//  NotificationTableViewCell.h
//  SoberGrid
//
//  Created by agilepc-159 on 6/23/15.
//  Copyright (c) 2015 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell
{
    UIImageView *imgProfile;
    UILabel     *lblName;
    UILabel     *lblMessage;
    UILabel     *lblTime;
    UIImageView *imgDot;
    
}
- (void)updateWithNotification:(id)notif;
+ (CGFloat)getCellHeight;
@end
