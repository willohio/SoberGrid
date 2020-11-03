//
//  WelcomeViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 11/6/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "WelcomeViewController.h"
#import "SGNewsFeedViewController.h"
#import "UIViewController+JASidePanel.h"

#import "XHDemoWeChatMessageTableViewController.h"
#import "CommentsViewController.h"
#import "SGPostStatus.h"
#import "SGPostVideo.h"
#import "SGPostPage.h"
#import "SGPostPhoto.h"

#define kApiPostLikes @"getlikeusers_post"
#define kApiPageFeedLikes @"getlikeusers_page"
#define kApiCommentPostLikes @"getlikeusers_post_comment"
#define kApiCommentPageLikes @"getlikeusers_page_comment"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    imgView.image = [UIImage imageNamed:@"Login_BG_Screen"];
    [self.view addSubview:imgView];
    
    
    UIButton *btnFindSoberFriends=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)/2)];
    
  //  [btnFindSoberFriends setTitle:NSLocalizedString(@"Find Sober Friends", nil) forState:UIControlStateNormal];
 //   [btnFindSoberFriends setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  //  btnFindSoberFriends.titleLabel.font = SGBOLDFONT(22.0);
  //  btnFindSoberFriends.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [btnFindSoberFriends addTarget:self action:@selector(btnFindSoberFriends_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnFindSoberFriends];
    
    UIButton *btnSoberNewsfeed=[[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds)/2, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)/2)];
    
  //  [btnSoberNewsfeed setTitle:NSLocalizedString(@"Sober Newsfeed", nil) forState:UIControlStateNormal];
    //[btnSoberNewsfeed setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //btnSoberNewsfeed.titleLabel.font = SGBOLDFONT(22.0);
   // btnSoberNewsfeed.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    [btnSoberNewsfeed addTarget:self action:@selector(btnSoberNewsfeed_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSoberNewsfeed];
    
    if ([appDelegate AppComesFromNotification])
    {
        [appDelegate setAppComesFromNotification:NO];
        NSString *notificationAlertMessage = [[appDelegate NotificationObj] objectForKey:@"alert"];
        
        NSLog(@"In welcome screen: %@",[appDelegate NotificationObj]);
        [self RedirectToViewController:notificationAlertMessage];
    };

    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = true;

}
- (IBAction)btnFindSoberFriends_Clicked:(id)sender{
    SGNavigationController*  centerNC = [SGstoryBoard() instantiateViewControllerWithIdentifier:@"CenterNavigationController"];

    self.sidePanelController.centerPanel=centerNC;
}
- (IBAction)btnSoberNewsfeed_Clicked:(id)sender{
    SGNewsFeedViewController *sgNFController = [[SGNewsFeedViewController alloc]init];
    SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:sgNFController];
    self.sidePanelController.centerPanel = navCtrl;
}

-(void)RedirectToViewController:(NSString*)forMessage
{
    NSDictionary *notificationData = [[appDelegate NotificationObj] objectForKey:@"cdata"];
    
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
            CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@get_user_details",baseUrl()] andDelegate:self];
            [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [notificationData objectForKey:@"userid"],@"myuserid":[User currentUser].struserId,@"notification_id":[notificationData objectForKey:@"nid"]} options:NSJSONWritingPrettyPrinted error:nil]];
        }
    }
}

- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo
{
    [appDelegate stopLoadingview];
    NSDictionary *notificationData = [[appDelegate NotificationObj] objectForKey:@"cdata"];
    
    NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    SGNavigationController *temNc=(SGNavigationController*)self.sidePanelController.centerPanel;
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
        if (dictResponse[RESPONSE][@"unread"]) {
            appDelegate.notificationBadge = [dictResponse[RESPONSE][@"unread"] integerValue];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
        }
        
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
