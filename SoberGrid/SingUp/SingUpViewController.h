//
//  SingUpViewController.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/11/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiClass.h"
#import "CommonApiCall.h"
#import "RTLabel.h"
#import "WebViewViewController.h"
#import "TPKeyboardAvoidingScrollView.h"


@interface SingUpViewController : UIViewController <UITextFieldDelegate,ApiclassDelegate,CommonApiCallDelegate,RTLabelDelegate>
{
    
    __weak IBOutlet UIView *viewLogo;
   
    IBOutlet TPKeyboardAvoidingScrollView *SubViewForControlls;
    
    IBOutlet RTLabel *lblWithLinks;
    
    IBOutlet UIButton *btnCreateAccount;
}
@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
- (IBAction)btnSignUp_Clicked:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *viewDisclosure;
- (IBAction)btnBack_Clicked:(UIButton *)sender;

@end
