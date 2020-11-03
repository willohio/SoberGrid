//
//  AppMailComposerViewController.h
//  SoberGrid
//
//  Created by agilepc-159 on 11/24/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//


#import <MessageUI/MessageUI.h>

typedef void (^composerCompletionHendler)(MFMailComposeResult MFMailComposeResult);


@interface AppMailComposerViewController : MFMailComposeViewController
+ (AppMailComposerViewController*)showMailComposerInController:(UIViewController*)controller withEmailSubject:(NSString*)emailSubject withMessageBody:(NSString*)messageBody withReciepts:(NSArray*)receipts withCompletionBlock:(composerCompletionHendler)completion;
@property (copy)composerCompletionHendler completionBlock;
@end
