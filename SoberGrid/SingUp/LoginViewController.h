//
//  LoginViewController.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/11/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainVC.h"
#import "User.h"
#import "ApiClass.h"
#import "CommonApiCall.h"
#import "TPKeyboardAvoidingScrollView.h"
@interface LoginViewController : UIViewController <UITextFieldDelegate,ApiclassDelegate,UIAlertViewDelegate,CommonApiCallDelegate>
{
    IBOutlet UIButton *btnLogin;
    IBOutlet UIButton *btnSignUp;
    IBOutlet UIButton *btnLogInViaFacebook;
    
    __weak IBOutlet TPKeyboardAvoidingScrollView *contentHolder;
}
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
- (IBAction)btnLogin_Clicked:(UIButton *)sender;
- (IBAction)btnFacebook_Clicked:(UIButton *)sender;
- (IBAction)btnForgorPassword_Clicked:(UIButton *)sender;
- (IBAction)btnSignup_Clicked:(UIButton *)sender;

@end
