//
//  ChatViewController.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/23/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@interface ChatViewController : UIViewController
@property (nonatomic,copy)User *otherUser;
- (IBAction)sendMessage_Clicked:(UIButton *)sender;

@end
