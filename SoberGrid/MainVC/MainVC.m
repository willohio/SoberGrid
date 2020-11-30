//
//  MainVC.m
//  SoberGrid
//
//  Created by William Santiago on 9/2/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "MainVC.h"
#import "PremiumMemberViewController.h"
#import "XHDemoWeChatMessageTableViewController.h"
#import "WebViewController.h"
#import "CommentsViewController.h"
#import "SGNewsFeedViewController.h"
#import "SGPostStatus.h"
#import "SGPostVideo.h"
#import "SGPostPage.h"
#import "SGPostPhoto.h"
#import "SGGroup.h"
#import "SGNewsFeedPageDetailViewController.h"

@interface MainVC () <CommonApiCallDelegate>

@end

@implementation MainVC

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
    
    // Prepare Left ViewController
    LeftNC = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftNavigationController"];
    self.leftVC = (LeftVC *)LeftNC.topViewController;
    
    // Prepare CenterviewController
    if (![[User currentUser] isLogin]) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"initial"]) {
            SGNavigationController *navCtrl  =[self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
       
            [self setCenterPanel:navCtrl];
        }else{
            SGNavigationController *navCtrl  =[self.storyboard instantiateViewControllerWithIdentifier:@"GetStartedNavigation"];
          
            [self setCenterPanel:navCtrl];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"initial"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

    }else{
        [self moveToWelcomeScreen];
    }
    
    [self setControllers];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(movetoMemeberScreen) name:NOTIFICATION_MOVETOMEMBEROPTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToNewsFeedScreen) name:NOTIFICATION_MOVETONEWSFEEDSCREEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToWelcomeScreen) name:NOTIFICATIN_NEWUSERLOGGEDIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToWechat:) name:NOTIFICATION_STARTCHAT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linkTapped:) name:NOTIFICATION_LINKTAPPED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToScreenAccordingToPushDetail:) name:NOTIFICATION_NEWPUSH object:nil];
    
}

- (void)setControllers
{
    [self setLeftPanel:LeftNC];
    [self setRightPanel:nil];
}
-(void)movetoMemeberScreen{
    SGNavigationController *temNc=(SGNavigationController*)self.centerPanel;
    [temNc dismissViewControllerAnimated:YES completion:nil];
    PremiumMemberViewController * pmVC=[[PremiumMemberViewController alloc]init];
    
    [temNc pushViewController:pmVC animated:true];
}
- (void)moveToWelcomeScreen{
    WelcomeViewController *wcVC=[[WelcomeViewController alloc]init];
    
    SGNavigationController *navCtrl  =[[SGNavigationController alloc] initWithRootViewController:wcVC];

    [self setCenterPanel:navCtrl];
}
- (void)pushToWechat:(NSNotification*)notif{
    SGNavigationController *temNc=(SGNavigationController*)self.centerPanel;
    if (temNc.presentedViewController == nil) {
        XHDemoWeChatMessageTableViewController *demoWeChatMessageTableViewController = [[XHDemoWeChatMessageTableViewController alloc] init];
        demoWeChatMessageTableViewController.otherSideUser = notif.object;
        
        [temNc pushViewController:demoWeChatMessageTableViewController animated:YES];
    }
}
- (void)linkTapped:(NSNotification*)notif{
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.webViewType = kWebViewTypeGeneral;
    SGNavigationController *temNc=(SGNavigationController*)self.centerPanel;
    [temNc pushViewController:webVC animated:YES];
    [webVC setUrl:notif.object];
    
}
#pragma mark - move according to push
- (void)pushToScreenAccordingToPushDetail:(NSNotification*)notif{
    notificationData = [notif.object objectForKey:@"cdata"];
    
    //    if ([forMessage rangeOfString:@"message"].location != NSNotFound || [forMessage rangeOfString:@"visited"].location != NSNotFound)
    //[notificationData objectForKey:@"userid"]
    if ([[notificationData objectForKey:@"type"] isEqualToString:@"1"])
    {
        CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"get_user_news_feed") andDelegate:self];
        [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"postid":[notificationData objectForKey:@"postid"],@"notification_id":[notificationData objectForKey:@"nid"]} options:NSJSONWritingPrettyPrinted error:nil]];
    }
    //    else if ([forMessage rangeOfString:@"message"].location != NSNotFound || [forMessage rangeOfString:@"visited"].location != NSNotFound)
    else if ([[notificationData objectForKey:@"type"] isEqualToString:@"2"] || [[notificationData objectForKey:@"type"] isEqualToString:@"3"])
    {
        if ([notificationData objectForKey:@"userid"])
        {
            if ([notificationData objectForKey:@"nid"]) {
                CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@get_user_details",baseUrl()] andDelegate:self];
                [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [notificationData objectForKey:@"userid"],@"myuserid":[User currentUser].struserId,@"notification_id":[notificationData objectForKey:@"nid"]} options:NSJSONWritingPrettyPrinted error:nil]];
            }else{
                CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@get_user_details",baseUrl()] andDelegate:self];
                [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [notificationData objectForKey:@"userid"],@"myuserid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
            }
            
            NSLog(@"api got called");
        }
    }else if ([[notificationData objectForKey:@"type"] isEqualToString:@"4"]){
        SGGroup *sgGroup = [SGGroup getGroupWithGroupId:notificationData[@"groupid"]];
        if (notificationData[@"status"]) {
            sgGroup.joinStatus = [NSNumber numberWithInteger:[notificationData[@"status"] integerValue]];
            [SGGroup save];
        }
        
//        if ([[notificationData objectForKey:@"status"] integerValue] == kSGGroupStatusAccepted) {
//            SGGroup *group = [SGGroup getGroupWithGroupId:notificationData[@"groupid"]];
//            SGNewsFeedPageDetailViewController *sgfpViewController=[[SGNewsFeedPageDetailViewController alloc]init];
//            [sgfpViewController setDetailMode:kDetailModeGroup WithObject:group];
//            SGNavigationController *temNc=(SGNavigationController*)self.centerPanel;
//            [temNc setNavigationBarHidden:NO];
//            [temNc pushViewController:sgfpViewController animated:YES];
//        }
    }
    
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo
{
    [appDelegate stopLoadingview];
    
    NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    SGNavigationController *temNc=(SGNavigationController*)self.centerPanel;
    [temNc setNavigationBarHidden:NO];
    
    if ([requestedURL rangeOfString:@"get_user_details"].location != NSNotFound)
    {
        /*
         if ([[dictResponse objectForKey:@"aps"] objectForKey:@"alert"]) {
         NSString *strMessage=[[dictResponse objectForKey:@"aps"] objectForKey:@"alert"];
         if ([strMessage rangeOfString:@"visited"].location != NSNotFound) {
         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:strMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
         [alert show];
         }
         
         if ([strMessage rangeOfString:@"post"].location != NSNotFound) {
         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:strMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
         [alert show];
         }
         }
         */
        
        
        if ([[[dictResponse objectForKey:@"Responce"] objectForKey:@"user"] isKindOfClass:[NSDictionary class]])
        {
            User *userTemp = [[User alloc]init];
            [userTemp createUserWithDict:[[dictResponse objectForKey:@"Responce"] objectForKey:@"user"]];
            
            //            NSString *notificationAlertMessage = [[appDelegate NotificationObj] objectForKey:@"alert"];
            //            if ([notificationAlertMessage rangeOfString:@"message"].location != NSNotFound)
            if ([[notificationData objectForKey:@"type"] isEqualToString:@"3"])
            {
                XHDemoWeChatMessageTableViewController *demoWeChatMessageTableViewController = [[XHDemoWeChatMessageTableViewController alloc] init];
                demoWeChatMessageTableViewController.otherSideUser = userTemp;
                [temNc pushViewController:demoWeChatMessageTableViewController animated:YES];
            }
            else if ([[notificationData objectForKey:@"type"] isEqualToString:@"2"])
            {
                if (dictResponse[RESPONSE][@"unread"]) {
                    appDelegate.notificationBadge = [dictResponse[RESPONSE][@"unread"] integerValue];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
                }
                ProfileVC *profileVC=[SGstoryBoard() instantiateViewControllerWithIdentifier:@"ProfileVC"];
                //                profileVC.pUser = [User currentUser];
                [profileVC setUsers:[@[userTemp]mutableCopy] withShowIndex:0];
                [temNc pushViewController:profileVC animated:YES];
            }

        }
    }
    else if (([requestedURL rangeOfString:@"get_user_news_feed"].location != NSNotFound))
    {
        if (dictResponse[RESPONSE][@"unread"]) {
            appDelegate.notificationBadge = [dictResponse[RESPONSE][@"unread"] integerValue];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
        }
        NSArray *arrFeeds = [[dictResponse objectForKey:@"Responce"] objectForKey:@"newsfeed"];
        if (arrFeeds.count > 0) {
            //            pagNo = (int)(pagNo+arrFeeds.count+1);
            for (NSDictionary *dict in arrFeeds) {
                User *objUser=[[User alloc]init];
                objUser.strName = (dict[@"username"]) ? dict[@"username"] : @"Dummy User";
                objUser.struserId = (dict[@"user_id"]) ? dict[@"user_id"] : @"0";
                objUser.strProfilePicThumb = (dict[@"user_picture"]) ? dict[@"user_picture"] : @"";
                if ([dict[@"feedtype"] intValue] == kSGNewsFeedTypeStatus) {
                    SGPostStatus *sgStatus = [[SGPostStatus alloc]initWithDictionary:dict];
                    sgStatus.objUser = objUser;
                    CommentsViewController *cmVC=[[CommentsViewController alloc]init];
                    [cmVC setPost:sgStatus];
                    [temNc pushViewController:cmVC animated:YES];
                }else if ([dict[@"feedtype"] intValue] == kSGNewsFeedTypePhoto){
                    SGPostPhoto *sgStatus = [[SGPostPhoto alloc]initWithDictionary:dict];
                    sgStatus.objUser = objUser;
                    //                    [arrOnlyImages addObject:@{@"id":sgStatus.strFeedId,@"url":sgStatus.strImageUrl,@"userid":sgStatus.objUser.struserId}];
                    
                    CommentsViewController *cmVC=[[CommentsViewController alloc]init];
                    [cmVC setPost:sgStatus];
                    [temNc pushViewController:cmVC animated:YES];
                }else{
                    SGPostVideo *sgVideo=[[SGPostVideo alloc]initWithDictionary:dict];
                    sgVideo.objUser = objUser;
                    CommentsViewController *cmVC=[[CommentsViewController alloc]init];
                    [cmVC setPost:sgVideo];
                    [temNc pushViewController:cmVC animated:YES];
                }
            }
        }
    }
    
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
- (void)moveToNewsFeedScreen{
    SGNewsFeedViewController *wcVC=[[SGNewsFeedViewController alloc]init];
    
    SGNavigationController *navCtrl  =[[SGNavigationController alloc] initWithRootViewController:wcVC];
    
    [self setCenterPanel:navCtrl];
}

#pragma mark - Navigation Bar

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
