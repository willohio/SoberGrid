//
//  NotificationViewController.m
//  SoberGrid
//
//  Created by agilepc-159 on 6/22/15.
//  Copyright (c) 2015 William Santiago All rights reserved.
//
static NSString* const kGetAllNotificationApi = @"get_all_notification";
#import "NotificationViewController.h"
#import "NotificationTableViewCell.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "ProfileVC.h"
#import "CommentsViewController.h"
#import "SGPostStatus.h"
#import "SGPostPhoto.h"
#import "SGPostVideo.h"
#import "PSTAlertController.h"
#import "NSArray+Null.h"
#import "NSDictionary+Null.h"
@implementation Notification

+ (Notification *)createNotificationWithDetails:(NSDictionary *)dict{
    Notification *notif = [[Notification alloc]init];
    [notif createUserWithDetail:dict];
    return notif;
}
- (void)createUserWithDetail:(NSDictionary*)detail{
    NSDateFormatter *datFormat = [[NSDateFormatter alloc]init];
    [datFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [datFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    _notifDate = [datFormat dateFromString:detail[@"creationdate"]];
    _strID = detail[@"id"];
    _strMessage = detail[@"message"];
    _strPostID = detail[@"postid"];
    _isRead = [detail[@"status"] boolValue];
    _type = [detail[@"type"] intValue];
    _objUser = [[User alloc]init];
    _objUser.strProfilePic = detail[@"user_picture"];
    _objUser.strProfilePicThumb = detail[@"user_thumb_pic"];
    _objUser.struserId = detail[@"userid"];
    _objUser.strName = detail[@"username"];
}
- (void)markAsRead{
    if (!_isRead) {
        _isRead = YES;
//        CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"updateNotificationStatus") andDelegate:self];
//        [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"notification_id":self.strID} options:NSJSONWritingPrettyPrinted error:nil]];
    }
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dict = [dict dictionaryByReplacingNullsWithBlanks];
    NSLog(@"Dict %@",dict);
    appDelegate.notificationBadge = [dict[RESPONSE][@"unread"] integerValue];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
@end

static float limit = 50;

@interface NotificationViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tblView;
    NSMutableArray *arrNotifications;
    int offset;
}
@end

@implementation NotificationViewController
- (void)formatUI{
    self.view.backgroundColor = [UIColor whiteColor];
    tblView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (self.navigationController.navigationBar.frame.size.height + 20))];

    tblView.dataSource = self;
    tblView.delegate = self;
    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tblView];

    [self addPullToRefreshInTable:tblView];
    [self addInfinitesScrollInTable:tblView];
    self.title = @"Notifications";
    
    UIBarButtonItem *setButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(settings_Clicked)];
    self.navigationItem.rightBarButtonItem = setButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self formatUI];
    [self getNotification];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [tblView reloadData];
    self.navigationController.navigationBar.translucent = NO;
}
- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)settings_Clicked{
    PSTAlertController *alertCtrl = [PSTAlertController alertControllerWithTitle:nil message:nil preferredStyle:PSTAlertControllerStyleActionSheet];
    [alertCtrl addAction:[PSTAlertAction actionWithTitle:@"Mark all read" handler:^(PSTAlertAction *action) {
        [self markAllAsRead];
    }]];
    [alertCtrl addAction:[PSTAlertAction actionWithTitle:@"Cancel" style:PSTAlertActionStyleCancel handler:nil]];
    [alertCtrl showWithSender:self controller:self animated:YES completion:nil];
}
#pragma mark - UITableViewDatasource Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self arrNotifications].count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notcell"];
    if (cell == nil) {
        cell = [[NotificationTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notcell"];
    }
    Notification *notif = [[self arrNotifications] objectAtIndex:indexPath.row];
    [cell updateWithNotification:notif];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [NotificationTableViewCell getCellHeight];
}
- (void) addPullToRefreshInTable:(UITableView *)tableView {
    __weak NotificationViewController *weakSelf = self;
    [tableView addPullToRefreshWithActionHandler:^{
        NSLog(@"pull to refresh called");
        offset = 0;
        [weakSelf getNotification];
    }];
    tblView.showsPullToRefresh = YES;
}
- (void) addInfinitesScrollInTable:(UITableView *)tableView {
    __weak NotificationViewController *weakSelf = self;
    __block UITableView *blockSafeTable  = tblView;
    
    [tableView addInfiniteScrollingWithActionHandler:^{
        //  [weakSelf fetchUserContactswithFirstTime:NO];
        NSLog(@"infinite scrollvie called");
        blockSafeTable.showsInfiniteScrolling = YES;
        [weakSelf getNotification];
    }];
    tableView.showsInfiniteScrolling = YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [appDelegate startLoadingview:@"Please Wait..."];
    Notification *notif = [[self arrNotifications] objectAtIndex:indexPath.row];
    [notif markAsRead];
    if (notif.type == 1) {
        CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"get_user_news_feed") andDelegate:self];
        [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"postid":notif.strPostID,@"notification_id":notif.strID} options:NSJSONWritingPrettyPrinted error:nil]];
    }else if (notif.type == 2 || notif.type == 3){
        CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@get_user_details",baseUrl()] andDelegate:self];
        [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": notif.objUser.struserId,@"myuserid":[User currentUser].struserId,@"notification_id":notif.strID} options:NSJSONWritingPrettyPrinted error:nil]];
    }else if (notif.type == 4){
        
    }
}
#pragma mark - Mark All Messages as Read
- (void)markAllAsRead{
    CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"updateNotificationStatus") andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
}
#pragma mark - GET NOTIFICATIONS
- (void)getNotification{
    CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kGetAllNotificationApi) andDelegate:self];
    NSLog(@"userid %@",[User currentUser].struserId);
    [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"offset":[NSString stringWithFormat:@"%d",offset],@"limit":[NSString stringWithFormat:@"%d",(int)limit]} options:NSJSONWritingPrettyPrinted error:nil]];
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dict = [dict dictionaryByReplacingNullsWithBlanks];
    if ([[dict objectForKey:TYPE] isEqualToString:RESPONSE_OK]) {
        if ([requestedURL rangeOfString:@"get_user_news_feed"].location != NSNotFound) {
            if (dict[RESPONSE][@"unread"]) {
                appDelegate.notificationBadge = [dict[RESPONSE][@"unread"] integerValue];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
            }
            NSArray *arrFeeds = [[dict objectForKey:@"Responce"] objectForKey:@"newsfeed"];
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
                        [self.navigationController pushViewController:cmVC animated:YES];
                    }else if ([dict[@"feedtype"] intValue] == kSGNewsFeedTypePhoto){
                        SGPostPhoto *sgStatus = [[SGPostPhoto alloc]initWithDictionary:dict];
                        sgStatus.objUser = objUser;
                        //                    [arrOnlyImages addObject:@{@"id":sgStatus.strFeedId,@"url":sgStatus.strImageUrl,@"userid":sgStatus.objUser.struserId}];
                        
                        CommentsViewController *cmVC=[[CommentsViewController alloc]init];
                        [cmVC setPost:sgStatus];
                        [self.navigationController pushViewController:cmVC animated:YES];
                    }else{
                        SGPostVideo *sgVideo=[[SGPostVideo alloc]initWithDictionary:dict];
                        sgVideo.objUser = objUser;
                        CommentsViewController *cmVC=[[CommentsViewController alloc]init];
                        [cmVC setPost:sgVideo];
                        [self.navigationController pushViewController:cmVC animated:YES];
                    }
                }
            }
        }else if([requestedURL rangeOfString:@"get_user_details"].location != NSNotFound){
            if (dict[RESPONSE][@"unread"]) {
                appDelegate.notificationBadge = [dict[RESPONSE][@"unread"] integerValue];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
            }
            if ([[[dict objectForKey:@"Responce"] objectForKey:@"user"] isKindOfClass:[NSDictionary class]])
            {
                User *userTemp = [[User alloc]init];
                [userTemp createUserWithDict:[[dict objectForKey:@"Responce"] objectForKey:@"user"]];
                ProfileVC *profileVC=[SGstoryBoard() instantiateViewControllerWithIdentifier:@"ProfileVC"];
                //                profileVC.pUser = [User currentUser];
                [profileVC setUsers:[@[userTemp]mutableCopy] withShowIndex:0];
                [self.navigationController pushViewController:profileVC animated:YES];
            }
        }else if([requestedURL rangeOfString:kGetAllNotificationApi].location != NSNotFound){
            [tblView.pullToRefreshView stopAnimating];
            [tblView.infiniteScrollingView stopAnimating];

            NSArray *arrNotif = dict[@"Responce"][@"notification"];
            if (dict[RESPONSE][@"unread"]) {
                appDelegate.notificationBadge = [dict[RESPONSE][@"unread"] integerValue];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
            }
            
            
            if (offset == 0) {
                arrNotifications = nil;
            }
            if (arrNotif.count < limit) {
                tblView.infiniteScrollingView.enabled = NO;
            }else
                tblView.infiniteScrollingView.enabled = YES;
            
            offset = offset + (int)arrNotif.count;
            
            for (NSDictionary *dicTemp in arrNotif) {
                [[self arrNotifications] addObject:[Notification createNotificationWithDetails:dicTemp]];
            }
            [tblView reloadData];
        }else{
            NSLog(@"Dict %@",dict);
            for (Notification *notif in [self arrNotifications]) {
                notif.isRead = YES;
            }
            appDelegate.notificationBadge = [dict[RESPONSE][@"unread"] integerValue];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
            [tblView reloadData];
        }
    }
    
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
- (NSMutableArray*)arrNotifications{
    if (!arrNotifications) {
        arrNotifications = [[NSMutableArray alloc]init];
    }
    return arrNotifications;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)dealloc{
    NSLog(@"dealloc called");
    tblView = nil;
}
@end
