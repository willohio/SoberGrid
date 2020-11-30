//
//  LoginViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/11/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "LoginViewController.h"
#import "UIViewController+JASidePanel.h"
#import "SingUpViewController.h"
#import "SGXMPP.h"
#import "SoberGridIAPHelper.h"
#import "SGGroup.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [contentHolder contentSizeToFit];
    
//    [_txtEmail setValue:[UIColor blackColor]
//             forKeyPath:@"_placeholderLabel.textColor"];
//    [_txtPassword setValue:[UIColor blackColor]
//                forKeyPath:@"_placeholderLabel.textColor"];
    
    btnLogin.layer.cornerRadius=6.0;
    btnSignUp.layer.cornerRadius=6.0;
    btnLogInViaFacebook.layer.cornerRadius=6.0;
    self.txtEmail.layer.cornerRadius=6.0;
    self.txtPassword.layer.cornerRadius=6.0;
    
    //to set textfield placeholder color
//    [self.txtEmail setValue:[UIColor whiteColor]
//                 forKeyPath:@"_placeholderLabel.textColor"];
//    [self.txtPassword setValue:[UIColor whiteColor]
//                    forKeyPath:@"_placeholderLabel.textColor"];
    
    
    //textfield left padding
    UIView *paddingViewForEmail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.txtEmail.leftView = paddingViewForEmail;
    self.txtEmail.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingViewForPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.txtPassword.leftView = paddingViewForPassword;
    self.txtPassword.leftViewMode = UITextFieldViewModeAlways;
        
    //_txtEmail.text=@"mannconsulting@gmail.com";
    //_txtPassword.text=@"BeauMann123";
    
    //_txtEmail.text=@"keyan@mailinator.com";
    //_txtPassword.text=@"123456";
    
    // Do any additional setup after loading the view.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [btnSignUp setTitle:@"Create an Anonymous Account" forState:UIControlStateNormal];
}
- (void)viewWillAppear:(BOOL)animated{
    self.sidePanelController.recognizesPanGesture = false;
    
    self.navigationController.navigationBar.hidden=true;
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.sidePanelController.recognizesPanGesture = true;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)btnLogin_Clicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    //SET VALIDATION
    if(!_txtEmail.text.length==0)
    {
        if(![self isValidEmail:_txtEmail.text])
        {
            [appDelegate showAlertMessage:@"Please enter valid email address"];
        }
        
        else if(!_txtPassword.text.length==0)
        {
            [appDelegate startLoadingview:@"Loading"];
            // ApiClass *aClass=[ApiClass sharedClass];
            // aClass.delegate = self;
            
            
            
            CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@login",baseUrl()] andDelegate:self];
            
            
            NSString *deviceToken;
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]){
                deviceToken =[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN];
            }else
                deviceToken = @"";
            
            NSDictionary *dict = @{@"user_email":_txtEmail.text ,@"user_password":_txtPassword.text,@"device_token":deviceToken,@"device_platform":@"0"};
            // NSLog(@"Login Parameters %@",dict);
            
            NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            [apicall startAPICallWithJSON:jsonData];
            
            //  [aClass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@login",baseUrl()]] withPostParameters:@{@"user_email":_txtEmail.text ,@"user_password":_txtPassword.text,@"device_token":deviceToken} withRequestMethod:POST];
        }
        else
        {
            [appDelegate showAlertMessage:@"Please enter password"];
            return;
        }
    }
    else
    {
        [appDelegate showAlertMessage:@"Please enter email"];
    }
}

- (IBAction)btnFacebook_Clicked:(UIButton *)sender
{
    
    NSLog(@"IS session open %d",[FBSession activeSession].isOpen);
    [appDelegate startLoadingview:@"Loading"];
    
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email"]
                                       allowLoginUI:!([FBSession activeSession].isOpen)
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Retrieve the app delegate
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (IBAction)btnForgorPassword_Clicked:(UIButton *)sender {
    UIAlertView *alerview = [[UIAlertView alloc]initWithTitle:@"Forgot your Password ?" message:@"Please enter your email. We will then send you a link so you may reset your password." delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
    alerview.delegate = self;
    alerview.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alerview textFieldAtIndex:0];
    textField.placeholder=@"Email";
    [alerview show];
}

- (IBAction)btnSignup_Clicked:(UIButton *)sender {
    //  SignUpVC
    [self performSegueWithIdentifier:@"loginToSignup" sender:nil];
}

#pragma mark - Textfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@" "]) {
        return false;
    }
    return true;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Apiclass delegate
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];
    NSDictionary *dictUser=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    dictUser = [dictUser dictionaryByReplacingNullsWithBlanks];
    if ([requestedURL rangeOfString:@"login"].location != NSNotFound){
        
        if ([[dictUser objectForKey:@"Type"] isEqualToString:@"OK"]) {
           
            // Group Code
            if ([[[dictUser objectForKey:@"Responce"] objectForKey:@"User"] objectForKey:@"groups"]) {
                NSArray *arrGroups = [[[dictUser objectForKey:@"Responce"] objectForKey:@"User"] objectForKey:@"groups"];
                for (NSDictionary *dictTemp in arrGroups) {
                    [SGGroup groupWithDetails:dictTemp];
                }
                [SGGroup save];
            }
            
            // Localytics code
            [Localytics tagEvent:LLUserDidLogin];
            
            // If Unread notification Badge
            if ([[dictUser objectForKey:@"Responce"] objectForKey:@"unread"]) {
                appDelegate.notificationBadge = [[[dictUser objectForKey:@"Responce"] objectForKey:@"unread"] integerValue];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
            }
            
            // Register for push
            [appDelegate registerForPush];
            
            // Save User
            [[User currentUser] saveUser:[[dictUser objectForKey:@"Responce"] objectForKey:@"User"]];
            [[SGXMPP sharedInstance] connect];
            NSDictionary *dictTemp  = [[dictUser objectForKey:@"Responce"] objectForKey:@"User"];
            int   _premiumType          =(dictTemp[@"premium"]) ? [dictTemp[@"premium"] intValue] : 0;
            [[SoberGridIAPHelper sharedInstance] setTypeOfSubscription:_premiumType];
            [[User currentUser] setInviteFriendsBool:YES];
            [self popToHome];
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:[dictUser objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }else if([requestedURL rangeOfString:@"forgot_password"].location != NSNotFound){
        if ([[dictUser objectForKey:@"Type"] isEqualToString:@"OK"]) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:[dictUser objectForKey:@"Responce"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:[dictUser objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];
}

- (void)popToHome
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATIN_NEWUSERLOGGEDIN object:nil];
}

#pragma mark - Validation Methods

// CHECK EMAIL VALID OR NOT
-(BOOL) isValidEmail:(NSString *)checkString
{
    checkString = [checkString lowercaseString];
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - Facebook Methods

//  Facebook Response
// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        
        if (FBSession.activeSession.isOpen) {
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 if (!error) {
                     
                     if (![user objectForKey:@"email"]) {
                         [self showErrorAlert];
                         return ;
                     }
                     NSString *email = [user objectForKey:@"email"];
                     if (email.length == 0) {
                         [self showErrorAlert];
                         return ;
                     }
                     // CALL API
                     // ApiClass *aClass=[ApiClass sharedClass];
                     // aClass.delegate = self;
                     CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@fblogin",baseUrl()] andDelegate:self];
                     
                     
                     
                     
                     [appDelegate registerForPush];
                     
                     NSString *deviceToken;
                     if([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]){
                         deviceToken =[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN];
                     }else
                         deviceToken = @"";
                     
                     
                     NSDictionary *dict =@{@"user_fbid":[user objectForKey:@"id"] ,@"user_fbtoken":[[[FBSession activeSession] accessTokenData] accessToken],@"device_platform":@"0" ,@"user_email":[user objectForKey:@"email"],@"device_token":deviceToken};
                     NSError *error=nil;
                     NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
                     
                     [apicall startAPICallWithJSON:jsonData];
                     
                     //  [aClass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@fblogin",baseUrl()]] withPostParameters:@{@"user_fbid":[user objectForKey:@"id"] ,@"user_fbtoken":[[FBSession activeSession] accessTokenData],@"device_platform":@"0" ,@"user_email":[user objectForKey:@"email"],@"device_token":deviceToken }withRequestMethod:POST];
                     
                 }else{
                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"Try Again", nil) otherButtonTitles: nil];
                     [alert show];;
                 }
             }];
        }
        
        
        // Show the user the logged-in UI
        return;
    }
    else
    {
        //            [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email"]
        //                                               allowLoginUI:YES
        //                                          completionHandler:
        //             ^(FBSession *session, FBSessionState state, NSError *error) {
        //
        //                 // Retrieve the app delegate
        //                 // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
        //                 [self sessionStateChanged:session state:state error:error];
        //             }];
        //
    }
    [appDelegate stopLoadingview];
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        // Show the user the logged-out UI
    }
    
    // Handle errors
    if (error){
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            //            [[AppDelegate sharedInstance] showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                //                [[AppDelegate sharedInstance] showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                //                [[AppDelegate sharedInstance] showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        [[FBSession activeSession] close];
        [FBSession setActiveSession:nil];
        // Show the user the logged-out UI
    }
}
- (void)showErrorAlert{
    [appDelegate stopLoadingview];
    [FBSession.activeSession closeAndClearTokenInformation];
    [[FBSession activeSession] close];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"SoberGrid is not able to fetch email from facebook", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Try Again", nil) otherButtonTitles: nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        if (![self isValidEmail:textField.text] || textField.text.length == 0){
            [appDelegate showAlertMessage:@"Not valid Email"];
            return;
        }
        
        [appDelegate startLoadingview:@"Sending Email..."];
        // ApiClass *apiclass = [ApiClass sharedClass];
        //  apiclass.delegate = self;
        CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@forgot_password",baseUrl()] andDelegate:self];
        NSDictionary *dict = @{@"email": textField.text};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        [apicall startAPICallWithJSON:jsonData];
        
        
        
        
        //   [apiclass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@forgot_password",baseUrl()]] withPostParameters:@{@"email": textField.text} withRequestMethod:POST];
    }
}



@end
