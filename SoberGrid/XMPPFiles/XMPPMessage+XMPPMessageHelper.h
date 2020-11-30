//
//  XMPPMessage+XMPPMessageHelper.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/25/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "XMPPMessage.h"
#import "User.h"

@interface XMPPMessage (XMPPMessageHelper)
- (NSString*)getmessage;
- (NSString*)sender;
- (int)sendertype;
- (NSString*)sendedTo;
- (NSString*)getMessageFormattedString;
- (id)messagefromUser:(User*)sender atDate:(NSDate*)timeStamp;
@end
