//
//  SGNewsFeedViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//
typedef enum {
    kSectionTypeInvite,
    kSectionTypeFeeds,
    kSectionTypeLoader,
}kSectionType;

#define kSpinnerTag 7847
#define kPageLimit 3


#import "SGNewsFeedViewController.h"
#import "SGNewsFeedPhotoCell.h"
#import "SGNewsFeedStatusCell.h"
#import "SGNewsFeedVideoCell.h"
#import "Line.h"
#import "SGRoundButton.h"
#import "SGNewsFeedPostViewController.h"
#import "MHFacebookImageViewer.h"
#import "XHDisplayMediaViewController.h"
#import "CommentsViewController.h"
#import "SGNewsFeedPageCell.h"
#import <Social/Social.h>
#import "SDWebImageManager.h"
#import "SGNewsFeedPageDetailViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "ProfileVC.h"
#import "THContactPickerViewController.h"
#import "LikesViewController.h"
#import "UIImageView+WebCache.h"
#import "FilterTableViewController.h"
#import "NotificationViewController.h"
@interface SGNewsFeedViewController()<SGNewsFeedPostDelegate,MHFacebookImageViewerDatasource,SGNewsFeedVideoCellDelegate,CommonApiCallDelegate,SGNewsFeedCellDelegate,UIAlertViewDelegate,NewsFeedFilterDelegate>{
    UIButton *btnBadge;
}

@end

@implementation SGNewsFeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)setUpNavigationBar{
    
    UIImage *rightBarImage = [UIImage imageNamed:@"filter.png"];
    UIButton *rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBar.bounds = CGRectMake(0, 0, 25, 25);
    [rightBar setImage:rightBarImage forState:UIControlStateNormal];
    [rightBar setContentMode:UIViewContentModeScaleAspectFill];
    [rightBar addTarget:self action:@selector(FilterVC_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightBar];
    
    btnBadge = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBadge.frame = CGRectMake(0, 0, 40, 32);
    if (appDelegate.notificationBadge <= 100) {
        [btnBadge setTitle:[NSString stringWithFormat:@"%ld",(long)appDelegate.notificationBadge] forState:UIControlStateNormal];
    }else
        [btnBadge setTitle:@"100+" forState:UIControlStateNormal];

    btnBadge.titleLabel.font = [UIFont systemFontOfSize:14.0];
    btnBadge.layer.cornerRadius = 5.0;
    [btnBadge addTarget:self action:@selector(btnBadge_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    btnBadge.clipsToBounds = YES;
    [btnBadge.titleLabel sizeToFit];
    [btnBadge setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnBadge.backgroundColor = [UIColor redColor];
    
    UIBarButtonItem *badgeButton = [[UIBarButtonItem alloc]initWithCustomView:btnBadge];
    
    self.navigationItem.rightBarButtonItems = @[badgeButton,rightBarButton];

    
    //self.navigationItem.rightBarButtonItem = badgeButton;

}
- (void)changeBadge{
    if (appDelegate.notificationBadge <= 100) {
        [btnBadge setTitle:[NSString stringWithFormat:@"%ld",(long)appDelegate.notificationBadge] forState:UIControlStateNormal];
    }else
        [btnBadge setTitle:@"100+" forState:UIControlStateNormal];
    
}
- (IBAction)btnBadge_Clicked:(id)sender{
    NotificationViewController *notVC = [[NotificationViewController alloc]init];
    [self.navigationController pushViewController:notVC animated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localytics tagEvent:LLUserInNewsFeedScreen];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadge) name:NOTIFICATION_BADGECHANGED object:nil];
    [self setUpNavigationBar];
    arrBlockedUsers = [[NSMutableArray alloc]init];
    arrDeletedPost  = [[NSMutableArray alloc]init];
    self.view.backgroundColor =SG_BACKGROUD_COLOR;
   
    [self createNewsFeedTable];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    self.title = NSLocalizedString(@"Newsfeed", nil);
    [tblNewsFeed reloadData];
}
- (void)viewWillDisappear:(BOOL)animated{
   // [self unloadVisibleCells];
    self.title = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    // Dispose of any resources that can be recreated.
}
- (void)createNewsFeedTable{
    tblNewsFeed = [[UITableView alloc]initWithFrame:self.view.bounds];
    tblNewsFeed.dataSource = self;
    tblNewsFeed.delegate   = self;
    tblNewsFeed.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tblNewsFeed];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(PullToRefresh_Clicked:) forControlEvents:UIControlEventValueChanged];
    [tblNewsFeed addSubview:refreshControl];
    
    [self loadDummyPost];
    
}
- (void)loadDummyPost{
    _arrPosts = [[NSMutableArray alloc] init];
    [self getNewsFeeds];
}
#pragma mark - Pull To Refresh

// Pull To Refresh with 10 Rows
- (IBAction)PullToRefresh_Clicked:(UIRefreshControl *)refreshControl1
{
    // Stop Pull To Refresh
    [refreshControl1 endRefreshing];
    
    // Allocate Memory to variables
    
    pagNo = 0;
    pageOffset = 0;
    [self getNewsFeeds];
}

#pragma mark - Tableview Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == kSectionTypeFeeds) {
        return _arrPosts.count;
    }else if(section == kSectionTypeInvite){
        return ([[User currentUser] inviteProcessDone]) ? 0 : 1;
    }else
        return 1;

}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == kSectionTypeLoader) {
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            cell.layer.borderWidth=0.0f;
            cell.layer.borderColor=[UIColor colorWithRed:247.0/255 green:215.0/255 blue:181.0/255 alpha:1].CGColor;
            cell.backgroundColor=[UIColor clearColor];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinner setTag:99];
            spinner.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 50/2);
            spinner.tag = kSpinnerTag;
            [cell.contentView addSubview:spinner];
        }
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:kSpinnerTag];
        [spinner startAnimating];

        if(_arrPosts.count>0)
        {
            [self performSelector:@selector(getNewsFeeds) withObject:nil afterDelay:0.5];
        }
        else
        {
            UIView *view = [cell.contentView viewWithTag:99];
            [view setHidden:NO];
        }

            return cell;
        
    }
    if (indexPath.section == kSectionTypeFeeds) {
     if([[_arrPosts objectAtIndex:indexPath.row] isKindOfClass:[SGPostVideo class]]){
        SGNewsFeedVideoCell *videoCell = [tableView dequeueReusableCellWithIdentifier:kVideoCellIdentifier];
    
        if (videoCell == nil) {
            videoCell = [[SGNewsFeedVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVideoCellIdentifier  withLine:YES];
            videoCell.delegate = self;
            videoCell.videodelegate = self;
        }
        
         [videoCell customizeWithPost:[_arrPosts objectAtIndex:indexPath.row] withFullVersion:false forType:@"post"];
        
        return videoCell;
    }else{
    
        SGNewsFeedPhotoCell *photocell =[tableView dequeueReusableCellWithIdentifier:kPhotosCellIdentifier];
        if (photocell == nil) {
            photocell = [[SGNewsFeedPhotoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPhotosCellIdentifier withLine:YES];
            photocell.delegate = self;
        }
        [photocell customizeWithPost:[_arrPosts objectAtIndex:indexPath.row] withFullVersion:false forType:@"post"];
        
        if ([[_arrPosts objectAtIndex:indexPath.row] isKindOfClass:[SGPostPhoto class]]) {
            SGPostPhoto *postPhoto = [_arrPosts objectAtIndex:indexPath.row];
            NSInteger index = [arrOnlyImages indexOfObjectPassingTest:[self blockTestingForid:postPhoto.strFeedId]];
            [photocell.imgViewPost setupImageViewerWithDatasource:self initialIndex:index onOpen:^{
                NSLog(@"OPEN!");
            } onClose:^{
                NSLog(@"CLOSE!");
            }];
        }else{
            [photocell.imgViewPost removeImageViewer];
        }
        
        return photocell;
        
    }
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InviteCell"];
            cell.layer.borderWidth=0.0f;
            cell.layer.borderColor=[UIColor colorWithRed:247.0/255 green:215.0/255 blue:181.0/255 alpha:1].CGColor;
            
            UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
            lbl.text = @"Invite your friends to join Sober!";
            lbl.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:lbl];
            cell.contentView.clipsToBounds = YES;
            cell.clipsToBounds  = YES;
            
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 50, 80, 30)];
            btn.backgroundColor = [UIColor redColor];
            btn.layer.cornerRadius = btn.frame.size.height/2;
            [btn setTitle:@"Invite" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnInvite_Clicked:) forControlEvents:UIControlEventTouchUpInside];
            btn.center = CGPointMake(tableView.frame.size.width/2, btn.center.y);
            [cell.contentView addSubview:btn];
            cell.contentView.backgroundColor = [UIColor lightGrayColor];
            
            UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(tableView.frame.size.width - 40, 0, 40, 40)];
            btnCancel.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 20, 0);
            [btnCancel setTitle:@"X" forState:UIControlStateNormal];
            [btnCancel addTarget:self action:@selector(btnCancelInviteFriends_Clicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btnCancel];
           

        }
         return cell;
    }
    return nil;
    
}
#pragma mark - Tableview Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == kSectionTypeLoader) {
        return 40;
    }
    if (indexPath.section == kSectionTypeInvite) {
        return 100;
    }
    // FOR PAGE CELL
    if ([[_arrPosts objectAtIndex:indexPath.row] isKindOfClass:[SGPostPage class]]) {
        return [SGNewsFeedPhotoCell getHeightForPage:[_arrPosts objectAtIndex:indexPath.row] withFullVersion:false withLine:true];
    }
    SGPost *spost=(SGPost*)[_arrPosts objectAtIndex:indexPath.row];
    if ([arrBlockedUsers containsObject:spost.objUser.struserId] || spost.objUser.isBlocked || [arrDeletedPost containsObject:spost.strFeedId]) {
        return 0;
    }
    if ([[_arrPosts objectAtIndex:indexPath.row] isKindOfClass:[SGPostVideo class]]) {
        return [SGNewsFeedVideoCell getHeightForPost:[_arrPosts objectAtIndex:indexPath.row] withFullVersion:NO withLine:YES];
    }
    return [SGNewsFeedPhotoCell getHeightAccordingToPost:spost withFullVersion:false withLine:YES];
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == kSectionTypeFeeds) {
       return kSGNEWSFEED_HEADER_HEIGHT;
    }else
        return 0;
    
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == kSectionTypeInvite || section == kSectionTypeLoader) {
        return nil;
    }
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), kSGNEWSFEED_HEADER_HEIGHT)];
    view.backgroundColor = [UIColor whiteColor];

    [Line drawStraightLineFromStartPoint:CGPointMake(view.center.x, 12) toEndPoint:CGPointMake(view.center.x, 12+20) ofWidth:1 inView:view];
    
    SGRoundButton *btnStatus=[[SGRoundButton alloc] initWithFrame:CGRectMake(25 + 10, 0, view.frame.size.width / 2-1-50,44)];
    [btnStatus setLeftImage:[UIImage imageNamed:imageNameRefToDevice(@"Status_Icon")] forState:UIControlStateNormal];
    [btnStatus setTitle:NSLocalizedString(@"Status", nil) forState:UIControlStateNormal];
    [btnStatus setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnStatus setBorderColor:[UIColor clearColor]];
    [btnStatus setBorderWidth:0.5];
    btnStatus.titleLabel.font = SGBOLDFONT(17);
    [btnStatus addTarget:self action:@selector(btnStatus_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnStatus];
    btnStatus = nil;
    
    SGRoundButton *btnMedia=[[SGRoundButton alloc] initWithFrame:CGRectMake(view.frame.size.width/2+1+ 25, 0, view.frame.size.width / 2-1-50,44)];
    [btnMedia setLeftImage:[UIImage imageNamed:imageNameRefToDevice(@"Media_Icon")] forState:UIControlStateNormal];
    [btnMedia setTitle:NSLocalizedString(@"Media", nil) forState:UIControlStateNormal];
    [btnMedia setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnMedia setBorderColor:[UIColor clearColor]];
    [btnMedia setBorderWidth:0.5];
    btnMedia.titleLabel.font = SGBOLDFONT(17);
    [btnMedia addTarget:self action:@selector(btnMedia_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnMedia];
    
    btnMedia = nil;
    
    
    return view;
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //    for (UIView *view in [cell.contentView subviews]) {
//        [view removeFromSuperview];
//    }
    
}

- (void)actionButtonPressed:(id)sender {
    
    UIBarButtonItem* myButton = (UIBarButtonItem*)sender;
    
    // Show activity view controller
    NSMutableArray *items = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"“I’m staying sober with Sober Grid—a new free app for people in recovery. Go to http://goo.gl/NglQWa to check it out!”"]];
    
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    // Show loading spinner after a couple of seconds
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.activityViewController) {
            //  [self showProgressHUDWithMessage:nil];
        }
    });
    
    // Show
    typeof(self) __weak weakSelf = self;
    [self.activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        weakSelf.activityViewController = nil;
        //  [weakSelf hideControlsAfterDelay];
        // [weakSelf hideProgressHUD:YES];
    }];
    // iOS 8 - Set the Anchor Point for the popover
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        self.activityViewController.popoverPresentationController.barButtonItem = myButton;
    }
    [self presentViewController:self.activityViewController animated:YES completion:nil];
    
    
    
    
    
}

- (IBAction)btnInvite_Clicked:(UIButton*)sender{
//    THContactPickerViewController *thContactPicker = [[THContactPickerViewController alloc]init];
//    SGNavigationController *sgNav=[[SGNavigationController alloc]initWithRootViewController:thContactPicker];
//    [self presentViewController:sgNav animated:YES completion:nil];
    
    [self actionButtonPressed:nil];
}
- (IBAction)btnCancelInviteFriends_Clicked:(id)sender{
    [[User currentUser] setInviteFriendsBool:YES];
    [tblNewsFeed reloadData];
    
}

//#pragma mark - Unload cells
//- (void)unloadCell:(UITableViewCell*)cell{
//    if ([cell isKindOfClass:[SGNewsFeedStatusCell class]]) {
//        SGNewsFeedStatusCell *scell =(SGNewsFeedStatusCell*)cell;
//        [scell unload];
//    }
//    if ([cell isKindOfClass:[SGNewsFeedPhotoCell class]]) {
//        SGNewsFeedPhotoCell *pcell =(SGNewsFeedPhotoCell*)cell;
//        [pcell unload];
//    }
//    if ([cell isKindOfClass:[SGNewsFeedVideoCell class]]) {
//        SGNewsFeedVideoCell *vcell =(SGNewsFeedVideoCell*)cell;
//        [vcell unload];
//    }
//    if ([cell isKindOfClass:[SGNewsFeedPageCell class]]) {
//        SGNewsFeedPageCell *pCell = (SGNewsFeedPageCell*)cell;
//        [pCell unload];
//    }
//
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
    
}
- (BOOL (^)(id obj, NSUInteger idx, BOOL *stop))blockTestingForid:(NSString*)feedID {
    return [^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj objectForKey:@"id"] isEqualToString:feedID]) {
            *stop = YES;
            return YES;
        }
        return NO;
    } copy];
}
#pragma mark - IBActions
- (IBAction)btnStatus_Clicked:(UIButton*)sender{
    SGNewsFeedPostViewController *fpViewController = [[SGNewsFeedPostViewController alloc]init];
    fpViewController.delegate = self;
    SGNavigationController *navController=[[SGNavigationController alloc]initWithRootViewController:fpViewController];
    
    [self presentViewController:navController animated:YES completion:nil];
}
-(IBAction)btnMedia_Clicked:(UIButton*)sender{
    SGNewsFeedPostViewController *fpViewController = [[SGNewsFeedPostViewController alloc]init];
    fpViewController.delegate = self;
    fpViewController.isTypeMedia = true;
    SGNavigationController *navController=[[SGNavigationController alloc]initWithRootViewController:fpViewController];
    
    [self presentViewController:navController animated:YES completion:nil];
}
- (void)sgnewsFeedPostPostedThePost:(id)post{
    if ([post isKindOfClass:[SGPostPhoto class]]) {
        SGPostPhoto *pPhoto=(SGPostPhoto*)post;
        [arrOnlyImages insertObject:@{@"id":pPhoto.strFeedId,@"url":pPhoto.strImageUrl,@"userid":pPhoto.objUser.struserId} atIndex:0];
    }
    [_arrPosts insertObject:post atIndex:0];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - VideoCell delegate
- (void)sgNewsFeedVideoCellClickeVideoforUrl:(NSString *)videoUrl{
    XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
    messageDisplayTextView.videoUrl = [NSURL URLWithString:videoUrl];
    [self.navigationController pushViewController:messageDisplayTextView animated:YES];
}
- (void)btnLikeUnlikeDoneForPost:(id)post fromCell:(UITableViewCell*)cell{

    
}
-(void)FilterVC_Clicked:(UIButton *)sender
{
    FilterTableViewController *filterVC=[SGstoryBoard() instantiateViewControllerWithIdentifier:@"NFFilter_VC"];
    [filterVC setDelegate:self];
    SGNavigationController *navBar=[[SGNavigationController alloc]initWithRootViewController:filterVC];
    [self presentViewController:navBar animated:YES completion:nil];
}
- (void)btnCommentClickedForPost:(id)post fromCell:(UITableViewCell*)cell{
    if ([post isKindOfClass:[SGPostPage class]]) {
        SGPostPage *page = (SGPostPage*)post;
        SGNewsFeedPageDetailViewController *sgfpViewController=[[SGNewsFeedPageDetailViewController alloc]init];
        [sgfpViewController setDetailMode:kDetailModePage WithObject:page];
        [self.navigationController pushViewController:sgfpViewController animated:YES];
        return;
    }
    CommentsViewController *cmVC=[[CommentsViewController alloc]init];
    [cmVC setPost:post];
    [self.navigationController pushViewController:cmVC animated:YES];
}
- (void)btnLikeClickedForPost:(id)post fromCell:(UITableViewCell *)cell{
    if ([post isKindOfClass:[SGPostPage class]]) {
        return;
    }
    LikesViewController * likeVC = [[LikesViewController alloc]init];
    
    likeVC.likeOn = kLikeOnPost;
    [likeVC setPost:post];
    [self.navigationController pushViewController:likeVC animated:YES];

}

- (void)profileViewTappedForPost:(id)post{
    if ([post isKindOfClass:[SGPostPage class]]) {
        SGPostPage *page = (SGPostPage*)post;
        SGNewsFeedPageDetailViewController *sgfpViewController=[[SGNewsFeedPageDetailViewController alloc]init];
        [sgfpViewController setDetailMode:kDetailModePage WithObject:page];
        [self.navigationController pushViewController:sgfpViewController animated:YES];
    }else{
        SGPost *spost = (SGPost*)post;
        if ([spost.objUser.struserId isEqualToString:[User currentUser].struserId]) {
            SGNavigationController *temNc=(SGNavigationController*)self.sidePanelController.centerPanel;
            ProfileVC *profileVC=[SGstoryBoard() instantiateViewControllerWithIdentifier:@"ProfileVC"];
            // profileVC.pUser = [User currentUser];
            [profileVC setUsers:[@[[User currentUser]]mutableCopy] withShowIndex:0];
            [temNc pushViewController:profileVC animated:YES];

            return;
        }
        [appDelegate startLoadingview:@"Loading..."];
        CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@get_user_details",baseUrl()] andDelegate:self];
        [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": spost.objUser.struserId,@"myuserid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
    }
}
- (void)blockOptionClickedForPost:(id)post{
    if ([post isKindOfClass:[SGPost class]]) {
        SGPost *spost=(SGPost*)post;
        if ([spost.objUser.struserId isEqualToString:[User currentUser].struserId]) {
        
            MEAlertView *alert=[[MEAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Would you like to delete this post", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
            alert.Object = spost;
            [alert show];
            
        }else{
        MEAlertView *alert=[[MEAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Would you like to hide all post of this user? User will be moved to your block list.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        alert.Object = spost;
        [alert show];
        }
    
    }
    
}
- (void)btnShareClickedForPost:(id)post fromCell:(UITableViewCell*)cell{
    NSArray *activityItems ;
    if ([post isKindOfClass:[SGPostStatus class]]) {
        SGPostStatus *sPost = post;
        activityItems    = @[sPost.strStatus];
        [self shareWIthItems:activityItems];

    }
    if ([post isKindOfClass:[SGPostPhoto class]]) {
        SGPostPhoto *pPost=post;
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:pPost.strImageUrl] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                NSArray*   activityItemsTemp = @[pPost.strDesrciption,image];
                [self shareWIthItems:activityItemsTemp];

        }];
    }
    if ([post isKindOfClass:[SGPostVideo class]]) {
        SGPostVideo *vPost=post;
        
        activityItems = @[vPost.strDesrciption,[NSURL URLWithString:vPost.strVideoUrl]];
        [self shareWIthItems:activityItems];
    }
    
    
}

- (void)shareWIthItems:(NSArray*)arrItems{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] )
    {
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:arrItems applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                                         UIActivityTypeMessage,
                                                         UIActivityTypeMail,
                                                         UIActivityTypePrint,
                                                         UIActivityTypeCopyToPasteboard,
                                                         UIActivityTypeAssignToContact,
                                                         UIActivityTypeSaveToCameraRoll,
                                                         UIActivityTypeAddToReadingList,
                                                         UIActivityTypePostToFlickr,
                                                         UIActivityTypePostToVimeo,
                                                         UIActivityTypePostToTencentWeibo,
                                                         UIActivityTypeAirDrop];
        
        
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [alertView show];
    }else{
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"No Facebook Account" message:@"There are no Facebook accounts configured.You can add or create a Facebook account in Settings."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [alertView show];
    }

}
- (void)updatedPost:(id)post ForCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [tblNewsFeed indexPathForCell:cell];
    [_arrPosts replaceObjectAtIndex:indexPath.row withObject:post];
    //[tblNewsFeed reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - MHFacebookImageViewer Datasource
- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer *)imageViewer {
    return arrOnlyImages.count;
}

-  (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer {
    return [NSURL URLWithString:[arrOnlyImages objectAtIndex:index][@"url"]];
}

- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer{
    return [UIImage imageNamed:@"placeholderImage"];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    tblNewsFeed = nil;
    [self cancelImageLoad];
   // [[SDWebImageManager sharedManager] cancelAll];
}
- (void)cancelImageLoad{
    [self listSubviewsOfView:self.view];
}
- (void)listSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    for (UIView *subview in subviews) {
        // Do what you want to do with the subview
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imgView=(UIImageView*)subview;
            [imgView sd_cancelCurrentImageLoad];
        }
        
        // List the subviews of subview
        [self listSubviewsOfView:subview];
    }
}

#pragma mark - UIAlertviewdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    MEAlertView *meAlert = (MEAlertView*)alertView;
    
    if (buttonIndex == 1) {
        SGPost *spost=meAlert.Object;
        
        if ([spost.objUser.struserId isEqualToString:[User currentUser].struserId]){
            [arrDeletedPost addObject:spost.strFeedId];
            [tblNewsFeed reloadData];
            [arrOnlyImages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
                if ([obj[@"id"] isEqualToString:spost.strFeedId]) {
                    [arrOnlyImages removeObject:obj];
                }
            }];
            CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"delete_post") andDelegate:self];
            [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"post_id":spost.strFeedId} options:NSJSONWritingPrettyPrinted error:nil]];

        }else{
        [arrBlockedUsers addObject:spost.objUser.struserId];
        [tblNewsFeed reloadData];
       
        [arrOnlyImages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            if ([obj[@"userid"] isEqualToString:spost.objUser.struserId]) {
                [arrOnlyImages removeObject:obj];
            }
        }];
        
        CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"block") andDelegate:self];
        [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"type":@"add",@"userid":[User currentUser].struserId,@"sobergrid_user":spost.objUser.struserId} options:NSJSONWritingPrettyPrinted error:nil]];
        }
    }
}
#pragma mark - Getnewsfeeds
- (void)getNewsFeeds{
    if (isApiRunning) {
        return;
    }
    isApiRunning = true;
    NSString *filterMyPosts = [Filter sharedInstance].myPosts ? @"1" : @"";
    NSString *filterIsCommented = [Filter sharedInstance].mySubscribed ? @"1" : @"";
    CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@%@",baseUrl(),API_GET_NEWS_FEED] andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,
                                                                            @"offset":[NSNumber numberWithInt:pagNo],
                                                                            @"limit":@"30",
                                                                            @"page_offset":[NSString stringWithFormat:@"%ld",(long)pageOffset],
                                                                            @"page_limit":[NSString stringWithFormat:@"%d",kPageLimit],
                                                                            @"my_feed": filterMyPosts,
                                                                            @"my_subscribed": filterIsCommented}
                                                                  options:NSJSONWritingPrettyPrinted error:nil]];
    
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{

    if ([requestedURL rangeOfString:@"delete_post"].location != NSNotFound) {

        return;

    }
    if ([requestedURL rangeOfString:@"block"].location !=NSNotFound) {
        
        return;
    }
    
     if ([requestedURL rangeOfString:@"get_user_details"].location !=NSNotFound) {
         [appDelegate stopLoadingview];
        NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
         dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
        if ([[[dictResponse objectForKey:@"Responce"] objectForKey:@"user"] isKindOfClass:[NSDictionary class]]) {
            User *userTemp = [[User alloc]init];
            [userTemp createUserWithDict:[[dictResponse objectForKey:@"Responce"] objectForKey:@"user"]];
            SGNavigationController *temNc=(SGNavigationController*)self.sidePanelController.centerPanel;
            ProfileVC *profileVC=[SGstoryBoard() instantiateViewControllerWithIdentifier:@"ProfileVC"];
            // profileVC.pUser = [User currentUser];
            [profileVC setUsers:[@[userTemp]mutableCopy] withShowIndex:0];
            [temNc pushViewController:profileVC animated:YES];
        }
        
        return;
    }
    if (pagNo == 0) {
        _arrPosts=[[NSMutableArray alloc]init];
        arrOnlyImages = [[NSMutableArray alloc]init];
    }
    isApiRunning = false;
  
    NSDictionary *dictResponse=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    NSArray *arrFeeds = [[dictResponse objectForKey:@"Responce"] objectForKey:@"newsfeed"];
 
    if ([[dictResponse objectForKey:@"Responce"] objectForKey:@"unread"]) {
        appDelegate.notificationBadge = [[[dictResponse objectForKey:@"Responce"] objectForKey:@"unread"] integerValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
    }
    if ([[dictResponse objectForKey:@"Responce"] objectForKey:@"devicetoken"]) {
        NSString *strToken = [[dictResponse objectForKey:@"Responce"] objectForKey:@"devicetoken"];
        if (strToken.length == 0) {
            [appDelegate registerForPush];
        }
    }

    NSArray *arrPages = [[dictResponse objectForKey:RESPONSE] objectForKey:@"page"];
    NSMutableArray *arrPagesToBemerged = [[NSMutableArray alloc]init];
    if (arrPages.count > 0) {
        pageOffset = pageOffset + arrPages.count;
         for (NSDictionary *dict in arrPages) {
             SGPostPage *postPage = [[SGPostPage alloc]init];
             [postPage setValuesfromDictionary:dict];
             [arrPagesToBemerged addObject:postPage];
         }
    }
    NSMutableArray *arrPostsToBeMerged=[[NSMutableArray alloc]init];
    if (arrFeeds.count > 0) {
        pagNo = (int)(pagNo+arrFeeds.count+1);
        for (NSDictionary *dict in arrFeeds) {
            User *objUser=[[User alloc]init];
            objUser.strName = (dict[@"username"]) ? dict[@"username"] : @"Dummy User";
            objUser.struserId = (dict[@"user_id"]) ? dict[@"user_id"] : @"0";
            objUser.strProfilePicThumb = (dict[@"user_picture"]) ? dict[@"user_picture"] : @"";
            if ([dict[@"feedtype"] intValue] == kSGNewsFeedTypeStatus) {
                SGPostStatus *sgStatus = [[SGPostStatus alloc]initWithDictionary:dict];
                sgStatus.objUser = objUser;
               
                [arrPostsToBeMerged addObject:sgStatus];
            }else if ([dict[@"feedtype"] intValue] == kSGNewsFeedTypePhoto){
                SGPostPhoto *sgStatus = [[SGPostPhoto alloc]initWithDictionary:dict];
                sgStatus.objUser = objUser;
                [arrOnlyImages addObject:@{@"id":sgStatus.strFeedId,@"url":sgStatus.strImageUrl,@"userid":sgStatus.objUser.struserId}];
                
                [arrPostsToBeMerged addObject:sgStatus];
            }else{
                SGPostVideo *sgVideo=[[SGPostVideo alloc]initWithDictionary:dict];
                sgVideo.objUser = objUser;
                
                [arrPostsToBeMerged addObject:sgVideo];
            }
        }
    }
    [_arrPosts addObjectsFromArray:[self mergePages:arrPagesToBemerged withPost:arrPostsToBeMerged]];
    [arrPostsToBeMerged removeAllObjects];
    [arrPagesToBemerged removeAllObjects];
    arrPagesToBemerged = nil;
    arrPostsToBeMerged = nil;
    if (arrPages.count > 0 || arrFeeds.count > 0) {
        [tblNewsFeed reloadData];
    }
    else if(pagNo > 0) {
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"No more news to show"
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        
        [alertView show];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableViewCell *cell=[tblNewsFeed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionTypeLoader]];
        if(cell){
            UIView *view = [cell.contentView viewWithTag:99];
            [view setHidden:YES];
            //        for(UIView *view in [cell.contentView subviews]){
            //            [view removeFromSuperview];
            //        }
        }
    });
}
- (NSMutableArray*)mergePages:(NSArray*)arrpages withPost:(NSArray*)arrPost{
    NSMutableArray *arrMerges=[[NSMutableArray alloc]init];
    int totalLoops = (int)(arrPost.count /10);
    for (int i = 0; i<totalLoops; i++) {
        [arrMerges addObjectsFromArray:[arrPost subarrayWithRange: NSMakeRange( i*10, 10 )]];
        if (arrpages.count > i) {
            if ([arrpages objectAtIndex:i]) {
                [arrMerges addObject:[arrpages objectAtIndex:i]];
            }
        }
    }
    [arrMerges addObjectsFromArray:[arrPost subarrayWithRange:NSMakeRange(totalLoops*10, arrPost.count-(totalLoops*10))]];
    if (arrpages.count > totalLoops) {
         [arrMerges addObjectsFromArray:[arrpages subarrayWithRange:NSMakeRange(totalLoops, 1)]];//arrpages.count - totalLoops
    }
   
    return arrMerges;
    
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    isApiRunning = false;
    UITableViewCell *cell=[tblNewsFeed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionTypeLoader]];
    if(cell){
        UIView *view = [cell.contentView viewWithTag:99];
        [view setHidden:YES];
//        for(UIView *view in [cell.contentView subviews]){
//            [view removeFromSuperview];
//        }
    }
}

#pragma mark NewsFeed Filter

- (void)filterDone_Pressed {
    //[self.refreshControl beginRefreshing];
    _arrPosts = nil;
    [tblNewsFeed reloadData];
//    [self.refreshControl beginRefreshing];
    
    pagNo = 0;
    pageOffset = 0;
    [self loadDummyPost];
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

@end
