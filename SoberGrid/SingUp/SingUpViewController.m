//
//  SingUpViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/11/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "SingUpViewController.h"
#import "LoginViewController.h"
#import "UHLocationManager.h"
#import "SGXMPP.h"
#import "SoberGridIAPHelper.h"

@interface SingUpViewController()

@end

@implementation SingUpViewController

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
    
    [SubViewForControlls contentSizeToFit];
    viewLogo.center = CGPointMake(SubViewForControlls.bounds.size.width/2, viewLogo.center.y);
    
    lblWithLinks.delegate=self;
    [lblWithLinks setText:@"By creating an account,you agree to the <a href='http://www.sobergridapp.com/#!termsofuse/c5dv'><font size=16 color='#0000ff'>Terms of Use</font></a> and you acknowledge that you have read the <a href='http://www.sobergridapp.com/#!privacy/cudd'><font size=16 color='#0000ff'>Privacy Policy.</font></a>"];
    lblWithLinks.textColor = [UIColor whiteColor];
    lblWithLinks.center = CGPointMake(SubViewForControlls.bounds.size.width/2, lblWithLinks.center.y);
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        lblWithLinks.font = [UIFont boldSystemFontOfSize:18];
     
    }
    else
    {
    
        lblWithLinks.font = [UIFont boldSystemFontOfSize:14];
    }
    lblWithLinks.textAlignment=kCTTextAlignmentCenter;

   

    
    [super viewDidLoad];
//    [_txtEmail setValue:[UIColor whiteColor]
//             forKeyPath:@"_placeholderLabel.textColor"];
//    [_txtPassword setValue:[UIColor whiteColor]
//             forKeyPath:@"_placeholderLabel.textColor"];
//    [_txtUsername setValue:[UIColor whiteColor]
//             forKeyPath:@"_placeholderLabel.textColor"];
    
    self.txtEmail.layer.cornerRadius=6.0;
    self.txtPassword.layer.cornerRadius=6.0;
    self.txtUsername.layer.cornerRadius=6.0;
    
    btnCreateAccount.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    // you probably want to center it
    btnCreateAccount.titleLabel.textAlignment = NSTextAlignmentCenter; // if you want to
//    [btnCreateAccount setTitle: @"Create Account\n(Anonymous)" forState: UIControlStateNormal];
    btnCreateAccount.layer.cornerRadius=6.0;
    
   
    
 
    
    UIFont *font1 = [UIFont boldSystemFontOfSize:18.0];
   
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
   
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Create Account\n"] attributes: arialDict];
        UIFont *font2 = [UIFont systemFontOfSize:12.0];
  
    NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
   
    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@"(Anonymous)" attributes: arialDict2];
   

    
    [aAttrString1 appendAttributedString:aAttrString2];
   
    [btnCreateAccount setAttributedTitle:aAttrString1 forState:UIControlStateNormal];
    
    
    //textfield left padding
    UIView *paddingViewForEmail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.txtEmail.leftView = paddingViewForEmail;
    self.txtEmail.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingViewForPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.txtPassword.leftView = paddingViewForPassword;
    self.txtPassword.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingViewForUsername = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.txtUsername.leftView = paddingViewForUsername;
    self.txtUsername.leftViewMode = UITextFieldViewModeAlways;
    
    
    CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) M_PI);
    _viewDisclosure.transform = transform;
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    self.sidePanelController.recognizesPanGesture=false;

    self.navigationController.navigationBarHidden = true;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.sidePanelController.recognizesPanGesture=true;

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
- (IBAction)btnBack_Clicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (IBAction)btnSignUp_Clicked:(UIButton *)sender
{
    
    [self.view endEditing:YES];
 
    
        NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
   
        if (!_txtUsername.text.length==0)
        {
            if (!_txtEmail.text.length==0)
            {
                if(![self isValidEmail:_txtEmail.text])
                {
                    [appDelegate showAlertMessage:@"Not valid Email"];
                }
                else
                {
                    if (!_txtPassword.text.length==0)
                    {
                        if ([[_txtPassword.text stringByTrimmingCharactersInSet: set] length] != 0)
                        {
                            [appDelegate startLoadingview:@"Loading"];
                            
                            UHLocationManager *locManager=[UHLocationManager sharedManager];
                            [locManager getLocationWithCompletionHandler:^(CLLocation *location, NSError *error, BOOL locationServicesDisabled) {
                                NSString *deviceToken;
                                if([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]){
                                    deviceToken =[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN];
                                }else
                                    deviceToken = @"";
                                
                                
                              //  ApiClass *aClass=[ApiClass sharedClass];
                               // aClass.delegate = self;
                                CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@register",baseUrl()] andDelegate:self];
                                if (error) {
                                    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"user_email":_txtEmail.text ,@"user_password":_txtPassword.text,@"user_name":_txtUsername.text,@"device_platform":@"0",@"latitude":@"0",@"longitude":@"0",@"device_token":deviceToken} options:NSJSONWritingPrettyPrinted error:nil]];
                                   // [aClass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@register",baseUrl()]] withPostParameters:@{@"user_email":_txtEmail.text ,@"user_password":_txtPassword.text,@"user_name":_txtUsername.text,@"device_platform":@"0",@"latitude":@"0",@"longitude":@"0",@"device_token":deviceToken}withRequestMethod:POST];
                                }else{
                                      [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"user_email":_txtEmail.text ,@"user_password":_txtPassword.text,@"user_name":_txtUsername.text,@"device_platform":@"0",@"latitude":[NSString stringWithFormat:@"%f",location.coordinate.latitude],@"longitude":[NSString stringWithFormat:@"%f",location.coordinate.longitude],@"device_token":deviceToken} options:NSJSONWritingPrettyPrinted error:nil]];
                                  //  [aClass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@register",baseUrl()]] withPostParameters:@{@"user_email":_txtEmail.text ,@"user_password":_txtPassword.text,@"user_name":_txtUsername.text,@"device_platform":@"0",@"latitude":[NSString stringWithFormat:@"%f",location.coordinate.latitude],@"longitude":[NSString stringWithFormat:@"%f",location.coordinate.longitude],@"device_token":deviceToken}withRequestMethod:POST];
                                }
                            }];
                           
                        }
                        else
                        {
                            [appDelegate showAlertMessage:@"Please enter keyword in password"];
                        }
                    }
                    else
                    {
                        [appDelegate showAlertMessage:@"Please enter password"];
                    }
                }
            }
            else
            {
                [appDelegate showAlertMessage:@"Please enter email address"];
            }
        }
        else
        {
            [appDelegate showAlertMessage:@"Please enter username"];
        }

    
//    //////////////////
//    if (_txtEmail.text.length > 0 && _txtPassword.text.length > 0 && _txtUsername.text.length > 0) {
//        ApiClass *aClass=[[ApiClass alloc]init];
//        aClass.delegate = self;
//        
//        [aClass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@register",baseUrl()]] withPostParameters:@{@"user_email":_txtEmail.text ,@"user_password":_txtPassword.text,@"user_name":_txtUsername.text,@"device_platform":@"0",@"latitude":@"22.0",@"longitude":@"73.0"}];
//        
//    }

}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];
    if ([requestedURL rangeOfString:@"register"].location  != NSNotFound) {
        NSDictionary *dictUser=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        dictUser = [dictUser dictionaryByReplacingNullsWithBlanks];
        if ([[dictUser objectForKey:@"Type"] isEqualToString:@"OK"]) {
            [appDelegate registerForPush];
            [[User currentUser] saveUser:[[dictUser objectForKey:@"Responce"] objectForKey:@"User"]];
            [[SGXMPP sharedInstance] connect];
            NSDictionary *dictTemp  = [[dictUser objectForKey:@"Responce"] objectForKey:@"User"];
            int   _premiumType          = (dictTemp[@"premium"]) ? [dictTemp[@"premium"] intValue] : 0;
            [[SoberGridIAPHelper sharedInstance] setTypeOfSubscription:_premiumType];
            [[User currentUser] setInviteFriendsBool:NO];
            [self popToProfile];
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:[dictUser objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }

}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];
    if ([requestedURL rangeOfString:@"register"].location  != NSNotFound) {
        
    }
}
- (void)returnData:(id)data forUrl:(NSURL *)url withTag:(int)tag
{
    if ([url.absoluteString rangeOfString:@"register"].location  != NSNotFound) {
    [appDelegate stopLoadingview];
    NSDictionary *dictUser=(NSDictionary*)data;
    if ([[dictUser objectForKey:@"Type"] isEqualToString:@"OK"]) {
        [appDelegate registerForPush];
        [[User currentUser] saveUser:[[dictUser objectForKey:@"Responce"] objectForKey:@"User"]];
        [[SGXMPP sharedInstance] connect];
        [self popToProfile];
        
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:[dictUser objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    }
    
}
- (void)failedData:(NSError *)error forUrl:(NSURL *)url withTag:(int)tag{
    if ([url.absoluteString rangeOfString:@"register"].location  != NSNotFound) {
    [appDelegate stopLoadingview];
    }
}
- (void)popToProfile{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATIN_NEWUSERLOGGEDIN object:nil];
}
#pragma mark - Textfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@" "]) {
        return false;
    }
    if(textField == _txtUsername || textField == _txtPassword){
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        
        if (isBackSpace == -8) {
            // is backspace
            return true;
        }
        if (textField.text.length > 15) {
            return false;
        }
    }
    return true;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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

#pragma mark RTLabel delegate

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)url
{
    WebViewViewController *WebView=[self.storyboard instantiateViewControllerWithIdentifier:@"WebViewViewController"];
    
    [WebView loadURLToWebView:url];
    
    [self.navigationController pushViewController:WebView animated:true];
}




@end
