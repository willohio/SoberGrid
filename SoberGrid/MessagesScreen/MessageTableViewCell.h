//
//  MessageTableViewCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/30/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UHLabel.h"

@interface MessageTableViewCell : UITableViewCell{
    UILabel *lblName;
    UILabel *lblMessage;
    UHLabel *lblTime;
    UIImageView *imgUnread;
}
@property (nonatomic,copy)NSDictionary *dictInfo;
- (void)customizewithData:(NSDictionary*)dict;
- (void)unload;
@end
