 //
//  AppDelegate.m
//  SoberGrid
//
//  Created by William Santiago on 8/28/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "MainVC.h"
#import "NetworkListioner.h"
#import "SGXMPP.h"
#import "User.h"
#import "DatabaseManager.h"
#import "SoberGridIAPHelper.h"
#import <Parse/Parse.h>
#import "XHDemoWeChatMessageTableViewController.h"
#import "UIViewController+JASidePanel.h"
#import "SGGroup.h"

#define KEYFORAPPNAME @"SoberGrid"

@implementation AppDelegate
@synthesize NotificationObj, AppComesFromNotification;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Localytics autoIntegrate:@"59b7909af4f7ed73da1ed87-9a0233f8-3426-11e5-ff80-00deb82fd81f" launchOptions:launchOptions];

    _notificationBadge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(badgeChanged) name:NOTIFICATION_BADGECHANGED object:nil];
    _assetLibrary = [[ALAssetsLibrary alloc]init];
    [[DatabaseManager sharedInstance] clearTableData];
    
    [Parse setApplicationId:@"zopAnX4nDWATvCdS55PGwuUmKFEZjlQgth30QEs3"
                  clientKey:@"jNKSaBMJ2Y7NNbR0pzw1VfuitiK3soGrFoop7sL8"];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]) {
        [self registerForPush];
    }
    

    [FBProfilePictureView class];
    [NetworkListioner listner] ;
    NSLog(@"is network available : %d",[[NetworkListioner listner] isInternetAvailable]);
    [[DatabaseManager sharedInstance] checkUpdates];

    
    isIPad=FALSE;
    isIPhone5=FALSE;
    isIPhone4=FALSE;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        isIPad=TRUE;
    }
    else if([[UIScreen mainScreen] bounds].size.height >= 568 ){
        isIPhone5=TRUE;
    }
    else{
        isIPhone4=TRUE;
    }
    
    if ([[User currentUser] isLogin]) {
        [[SGXMPP sharedInstance] connect];
    }
    [[SoberGridIAPHelper sharedInstance] fetchProducts];
    [[SoberGridIAPHelper sharedInstance] checkIfSubscriptionExpired];
    
    NSDictionary *notification =  [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"Localinfo %@",notification);
//    if (notification) {
//        NSLog(@"Userinfo From Push *********** from did finish launch----------> %@ <----------------**********",notification);
//        
//       [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_NEWPUSH object:notification];
//        //[self showAlertForPushDetail:notification];
//    }
    
    return YES;
}


- (void)showAlertForPushDetail:(NSDictionary*)pushDetail{
    if ([[pushDetail objectForKey:@"aps"] objectForKey:@"alert"]) {
        NSDictionary *dictDetail = [pushDetail objectForKey:@"cdata"];
        
        NSString *strMessage=[[pushDetail objectForKey:@"aps"] objectForKey:@"alert"];
        
        if ([dictDetail[@"type"] integerValue] == 4) {
            SGGroup *sgGroup = [SGGroup getGroupWithGroupId:dictDetail[@"groupid"]];
            if (dictDetail[@"status"]) {
                sgGroup.joinStatus = [NSNumber numberWithInteger:[dictDetail[@"status"] integerValue]];
                [SGGroup save];
            }
        }
        
        if ([dictDetail[@"type"] integerValue] != 3) {
            [self showNotificationwithTitle:@"Notification" withIconUrl:nil withSubtitle:strMessage withObject:pushDetail];
        }
        
        /*
         {
         aps =     {
         alert = "Haresh Kalyani, Accepted Your Request";
         };
         cdata =     {
         groupid = 34;
         nm = luther;
         status = 2;
         type = 4;
         };
         }*/
        
    }
}


- (void)Logoutuserafterdelete:(NSDictionary*)pushDetail{
   
    NSDictionary *apsInfo = [pushDetail objectForKey:@"aps"];
    
    NSString *alertMsg = @"";
    
    
    if( [apsInfo objectForKey:@"alert"] != NULL)
    {
        alertMsg = [apsInfo objectForKey:@"alert"];
        if ([alertMsg isEqualToString:@"User Deleted"]) {
            [[Filter sharedInstance] clearFilter];
            [[User currentUser]logout];
            
            UIStoryboard *mainStoryboard;
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                
                mainStoryboard = [UIStoryboard storyboardWithName:@"iPad"
                                                           bundle: nil];
            else
                
                mainStoryboard = [UIStoryboard storyboardWithName:@"iPhone"
                                                           bundle: nil];
            
            SGNavigationController*    centerNC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
            self.window.rootViewController=centerNC;
        }
        
        
        
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    _notificationBadge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [Localytics tagEvent:LLAppInBackground];
    [[SGXMPP sharedInstance] disconnect];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([[User currentUser] isLogin]) {
        [[SGXMPP sharedInstance] connect];
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[SGXMPP sharedInstance] disconnect];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error{
    
}
#pragma mark - Push notif methods
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    //NSLog(@"content---%@", token);
    [[NSUserDefaults standardUserDefaults]setObject:token forKey:DEVICE_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //NSLog(@"------ I am in didRegisterForRemoteNotificationsWithDeviceToken----");
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    if ([[User currentUser] isLogin]) {
        [self updateDeviceTokenToServerWithToken:token];
    }
}
- (void)updateDeviceTokenToServerWithToken:(NSString*)token{
    CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"update_devicetoken") andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"devicetoken":token,@"deviceplatform":@"0"} options:NSJSONWritingPrettyPrinted error:nil]];
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"Device got registerd with detail %@",dict);
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

   
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    NSString *alertMsg = @"";
   
    
    if([apsInfo objectForKey:@"alert"] != NULL)
    {
        alertMsg = [apsInfo objectForKey:@"alert"];
        if ([alertMsg isEqualToString:@"User Deleted"]) {
            [self Logoutuserafterdelete:userInfo];
        }
    }
    
    
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"badge"]) {
         _notificationBadge = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] integerValue];
    }
    
    NSLog(@"Userinfo From Push ***********----------> %@ <----------------**********",userInfo);
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        NSLog(@"===== we are in push notification ---");
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_NEWPUSH object:userInfo];
    }
    else{
        [self showAlertForPushDetail:userInfo];
    }
    
   
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];

  /*  aps =     {
        alert = "(jklmn) has visited your profile ,Say Hello on Sobergrid ";
    };*/
    
   
  //  [PFPush handlePush:userInfo];
}
- (void)showNotificationwithTitle:(NSString*)title withIconUrl:(NSString*)iconUrl withSubtitle:(NSString*)subtitle withObject:(id)object;
{
   // NSArray *buttonArray = [NSArray arrayWithObjects:@"Show",@"Later", nil];
    
    _notification = [MPGNotification notificationWithTitle:title subtitle:subtitle backgroundColor:[UIColor clearColor] iconImage:[UIImage imageNamed:@"Notif"] withObject:object];
  //  [_notification setButtonConfiguration:buttonArray.count withButtonTitles:buttonArray];
    _notification.duration = 3.0;
    [_notification setTitleColor:[UIColor whiteColor]];
    [_notification setSubtitleColor:[UIColor whiteColor]];
    _notification.swipeToDismissEnabled = NO;
    [_notification setAnimationType:MPGNotificationAnimationTypeLinear];
    [_notification show];
    
    [_notification setButtonHandler:^(MPGNotification *notification, NSInteger buttonIndex) {
         [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_NEWPUSH object:notification.object];
    }];
}
- (void)badgeChanged{
    [UIApplication sharedApplication].applicationIconBadgeNumber = _notificationBadge;
}

#pragma mark - Loader

-(void)startLoadingview :(NSString *)strMessage{
    /*
     DISPLAY CUSTOM LOADING SCREEN WHEN THIS METHOD CALLS.
     */
    // CREATE CUSTOM VIEW
    
    if (viewShowLoad) {
        return;
    }
    NSLog(@"----Show Loading view-----");
        viewShowLoad=[[UIView alloc]init];
        viewShowLoad.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        viewShowLoad.backgroundColor =[UIColor clearColor];
        
        // SET THE VIEW INSIDE MAIN VIEW
        UIView *viewUp=[[UIView alloc] initWithFrame:viewShowLoad.frame];
        viewUp.backgroundColor=[UIColor blackColor];
        viewUp.alpha=0.5;
        [viewShowLoad addSubview:viewUp];
        
        // CUSTOM ACTIVITY INDICATOR
        objSpinKit=[[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave color:[UIColor whiteColor]];
        objSpinKit.center = CGPointMake(CGRectGetMidX(viewShowLoad.frame), CGRectGetMidY(viewShowLoad.frame));
        [objSpinKit startAnimating];
        [viewShowLoad addSubview:objSpinKit];
        
        // SET THE LABLE
        UILabel *lblLoading=[[UILabel alloc] initWithFrame:CGRectMake(0, objSpinKit.frame.origin.y + 30, [UIScreen mainScreen].bounds.size.width, 50)];
        lblLoading.font=[UIFont systemFontOfSize:18.0];
        //    lblLoading.font=[UIFont fontWithName:FONTWITHREGULAR size:18.0];
        lblLoading.text=strMessage;
        lblLoading.backgroundColor=[UIColor clearColor];
        lblLoading.textColor=[UIColor whiteColor];
        lblLoading.textAlignment=NSTextAlignmentCenter;
        [viewShowLoad addSubview:lblLoading];
        [self.window addSubview:viewShowLoad];
}

-(void)stopLoadingview
{
    NSLog(@"----stop Loading view-----");
    if (viewShowLoad) {
        [objSpinKit stopAnimating];
        [viewShowLoad removeFromSuperview];
        viewShowLoad = nil;
    }
    
   
}

#pragma mark - Alert Message

-(void)showAlertMessage:(NSString *)strMessage{
    UIAlertView *alert=    [[UIAlertView alloc] initWithTitle:KEYFORAPPNAME message:strMessage delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    alert.alertViewStyle=UIAlertViewStyleDefault;
    [alert setBackgroundColor:[UIColor clearColor]];
    [alert show];
}
- (void)registerForPush{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // FOR IOS 8
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                                UIUserNotificationTypeBadge |
                                                                UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                         categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                               UIRemoteNotificationTypeAlert |
                                                                               UIRemoteNotificationTypeSound)];
    }

}
-(void)setBorderTo:(UIView*)controller{
    controller.layer.borderColor = [UIColor blueColor].CGColor;
    controller.layer.borderWidth = 1.0;
}

@end
