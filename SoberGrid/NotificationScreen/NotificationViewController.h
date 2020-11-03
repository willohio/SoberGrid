//
//  NotificationViewController.h
//  SoberGrid
//
//  Created by agilepc-159 on 6/22/15.
//  Copyright (c) 2015 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonApiCall.h"
#import "User.h"
@interface Notification : NSObject <CommonApiCallDelegate>
@property (strong,nonatomic)NSDate      *notifDate;
@property (strong,nonatomic)NSString    *strID;
@property (strong,nonatomic)NSString    *strMessage;
@property (strong,nonatomic)NSString    *strPostID;
@property (assign,nonatomic)BOOL        isRead;
@property (assign,nonatomic)int         type;
@property (strong,nonatomic)User        *objUser;
+ (Notification*)createNotificationWithDetails:(NSDictionary*)dict;
@end

@interface NotificationViewController : UIViewController <CommonApiCallDelegate>

@end
