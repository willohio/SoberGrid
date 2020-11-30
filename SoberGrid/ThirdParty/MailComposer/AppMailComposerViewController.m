//
//  AppMailComposerViewController.m
//  SoberGrid
//
//  Created by agilepc-159 on 11/24/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "AppMailComposerViewController.h"

@interface AppMailComposerViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation AppMailComposerViewController

+ (AppMailComposerViewController*)showMailComposerInController:(UIViewController*)controller withEmailSubject:(NSString*)emailSubject withMessageBody:(NSString*)messageBody withReciepts:(NSArray*)receipts withCompletionBlock:(composerCompletionHendler)completion{
    if([MFMailComposeViewController canSendMail])
        {
        AppMailComposerViewController * obj = [[self alloc] init];
        if (obj) {
            obj = [[super alloc] init];
            obj.completionBlock = completion;
            obj.mailComposeDelegate = obj;
            if (emailSubject) {
                [obj setSubject:emailSubject];

            }
            if (messageBody) {
                [obj setMessageBody:messageBody isHTML:NO];

            }
            if (receipts) {
                [obj setToRecipients:receipts];

            }
            [controller presentViewController:obj animated:true completion:nil];
            // Initialization code
        }
        return obj;
        }
    return nil;

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if(_completionBlock){
        _completionBlock (result);
        _completionBlock = nil;
    }
    [self dismissViewControllerAnimated:true completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
