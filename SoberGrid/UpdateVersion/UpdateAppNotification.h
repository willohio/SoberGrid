//
//  UpdateAppNotification.h
//  SoberGrid
//
//  Created by agilepc-159 on 4/18/15.
//  Copyright (c) 2015 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateAppNotification : NSObject
{
    UIView *viewUpdation;
}
+ (UpdateAppNotification *)sharedInstance;
- (void)show;
- (void)hide;

@end
