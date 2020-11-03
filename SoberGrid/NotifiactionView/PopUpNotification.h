//
//  PopUpNotification.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/6/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface PopUpNotification : NSObject{
    UIView *viewNotification;
}
+ (PopUpNotification *)sharedInstance;
- (void)show;
- (void)hide;
@end
