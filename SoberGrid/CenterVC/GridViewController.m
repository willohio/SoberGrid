//
//  CenterVC.m
//  SoberGrid
//
//  Created by William Santiago on 9/2/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

typedef enum {
  kSectionTypeInvite,
  kSectionTypeGrid,
  kSectionTypeLoader,
}kSectionType;

static NSString *const kApiTypeKey     = @"apitype";
static NSString *const kApiOffset      = @"apioffset";

static NSString *const kApiWithFilter  = @"kApiwithFilter";
static NSString *const kApiWithoutFiler = @"kApiWithoutFilter";

static NSString *const kApiNearByUser  = @"nearbyuser";


#import "GridViewController.h"
#import "Global.h"
#import "MainVC.h"
#import "ProfileVC.h"
#import "PopUpNotification.h"
#import "FilterVC.h"
#import "JSON.h"
#import "UHLocationManager.h"
#import "User.h"
#import "GridCollectionViewCell.h"
#import "SGXMPP.h"
#import "SoberGridIAPHelper.h"
#import "NSObject+ConvertingViewPixels.h"
#import "SDWebImageManager.h"
#import <StoreKit/StoreKit.h>
#import <AddressBook/AddressBook.h>
#import "PSTAlertController.h"
#import "THContactPickerViewController.h"
#import "NotificationViewController.h"
#define RESPONSE_LIMIT 30
#define RESPONSE_LIMIT_NEW 15

#define IMAGE_VIEW_TAG 99
#define TABLEVIEW_START_INDEX 0
#define TABLEVIEW_PAGE_SIZE 10
#define TABLEVIEW_CELL_HEIGHT 44.0

#define kTotalViewHeight    400


@interface GridViewController ()<UIScrollViewDelegate>{
    UserChoicesView *viewUserChoices;
    BOOL isLoadMoreData;
    UIButton *btnBadge;
}

@end

@implementation GridViewController
@synthesize ResponseArray,arr,arrFinalObjects;

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
        [Localytics tagEvent:LLUserInGridScreen];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadge) name:NOTIFICATION_BADGECHANGED object:nil];
    [self customizeAppearance];
    [PopUpNotification sharedInstance];
    
    // SET SPINNER TO TABLEVIEW
   // spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] ;
    [self createCollectionview];

    
  //  refreshControl = [[ODRefreshControl alloc] initInScrollView:mainCollectionView];
  //  [refreshControl addTarget:self action:@selector(PullToRefresh_Clicked:) forControlEvents:UIControlEventValueChanged];
    
    UIRefreshControl *refreShController = [[UIRefreshControl alloc]init];
    [refreShController addTarget:self action:@selector(PullToRefresh_Clicked:) forControlEvents:UIControlEventValueChanged];
    [mainCollectionView addSubview:refreShController];
    
    viewUserChoices=[[UserChoicesView alloc]initWithFrame:CGRectMake(0,mainCollectionView.frame.origin.y + mainCollectionView.frame.size.height, CGRectGetWidth(self.view.bounds), [self deviceSpesificValue:75])];
    [viewUserChoices customizewithChoiceTitlesAndImagesDict:@{NSLocalizedString(@"Pro", nil): @"pro",NSLocalizedString(@"Burning Desire", nil):@"burning_fire",NSLocalizedString(@"Need a Ride", nil):@"ride"}];
    viewUserChoices.delegate = self;
    [self.view addSubview:viewUserChoices];
    
}
- (void)createCollectionview{
    // UICollection View
  
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    mainCollectionView.scrollEnabled=TRUE;
    
    mainCollectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(5, 73, CGRectGetWidth([UIScreen mainScreen].bounds)-10, CGRectGetHeight([UIScreen mainScreen].bounds)- ([self deviceSpesificValue:75]+73)) collectionViewLayout:layout];
    //layout.minimumLineSpacing = (isIPad) ? 2 : 5;
    
    [mainCollectionView setDataSource:self];
    [mainCollectionView setDelegate:self];
    [mainCollectionView registerClass:[GridCollectionViewCell class] forCellWithReuseIdentifier:@"GridCell"];
    [mainCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [mainCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"InviteCell"];
    [mainCollectionView setBackgroundColor:[UIColor clearColor]];
    
    
    [self.view addSubview:mainCollectionView];
}


-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    self.title=NSLocalizedString(@"The Grid", nil);
    [mainCollectionView reloadData];
    if (_inSearchMode) {
        self.navigationController.navigationBarHidden = true;
    }
    if (!arrFinalObjects) {
        [self callAPIWithZeroOffset:true];
    }else{
        if (arrFinalObjects.count > 0) {
             [mainCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kSectionTypeGrid]]];
        }
       
    }
    // Allocate Memory to variables
    
    // CALL API
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollection:) name:NOTIFICATION_NEW_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollection:) name:NOTIFICATIN_RECEIVED_PRESENCE_REPORT object:nil];

    self.navigationController.navigationBar.alpha = 1.0;
    

}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NEW_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATIN_RECEIVED_PRESENCE_REPORT object:nil];
   
    self.navigationController.navigationBarHidden = false;
  

}
- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
           // [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
}
- (void)customizeAppearance
{
//    UIImage *menuImage = [UIImage imageNamed:@"icon_open_menu.png"];
//    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    menuButton.bounds = CGRectMake(0, 0, 32, 32);
//    [menuButton setImage:menuImage forState:UIControlStateNormal];
//    [menuButton setContentMode:UIViewContentModeScaleAspectFill];
//    [menuButton addTarget:self action:@selector(toggleLeftPanel:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    UIImage *rightBarImage = [UIImage imageNamed:@"filter.png"];
    UIButton *rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBar.bounds = CGRectMake(0, 0, 25, 25);
    [rightBar setImage:rightBarImage forState:UIControlStateNormal];
    [rightBar setContentMode:UIViewContentModeScaleAspectFill];
    [rightBar addTarget:self action:@selector(FilterVC_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightBar];
    
    UIImage *toggleImage = [UIImage imageNamed:@"search"];
    UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    toggleButton.bounds = CGRectMake(0, 0, 32, 32);
    [toggleButton setImage:toggleImage forState:UIControlStateNormal];
    [toggleButton setContentMode:UIViewContentModeScaleAspectFill];
    [toggleButton addTarget:self action:@selector(btnSearch_clicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *toggleBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toggleButton];
    
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
    
   // self.navigationItem.leftBarButtonItem = leftBarButton;
    self.navigationItem.rightBarButtonItems = @[badgeButton,rightBarButton, toggleBarButtonItem];
    self.navigationController.navigationBar.barTintColor=[UIColor whiteColor];
    // self.navigationController.navigationBar.translucent = YES;
}
- (void)changeBadge{
    if (appDelegate.notificationBadge <= 100) {
          [btnBadge setTitle:[NSString stringWithFormat:@"%ld",(long)appDelegate.notificationBadge] forState:UIControlStateNormal];
    }else
          [btnBadge setTitle:@"100+" forState:UIControlStateNormal];
  
}
// Please remove this method
- (IBAction)btnBadge_Clicked:(id)sender{
    NotificationViewController *notVC = [[NotificationViewController alloc]init];
    [self.navigationController pushViewController:notVC animated:YES];
}
- (IBAction)btnSearch_clicked:(id)sender{
    [arrFinalObjects removeAllObjects];
    [mainCollectionView reloadData];
    
    
    _inSearchMode = true;
    self.navigationController.navigationBarHidden = true;
    if (!barWrapper) {
        topsearchBar = [UISearchBar new];
        topsearchBar.barTintColor = [UIColor whiteColor];
        topsearchBar.tintColor = [UIColor redColor];
        topsearchBar.placeholder = NSLocalizedString(@"Search by City or Username", nil);
        topsearchBar.showsCancelButton = YES;
        topsearchBar.delegate = self;
        [topsearchBar sizeToFit];
        barWrapper = [[UIView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(topsearchBar.bounds), CGRectGetHeight(topsearchBar.bounds))];
        [barWrapper addSubview:topsearchBar];
        [self.view addSubview:barWrapper];
    }
    barWrapper.hidden = NO;
    [topsearchBar becomeFirstResponder];
    
}
-(void)FilterVC_Clicked:(UIButton *)sender
{
 
    FilterVC *filterVC=[self.storyboard instantiateViewControllerWithIdentifier:@"FilterVC"];
    filterVC.objFilter = [[Filter alloc]init];
    filterVC.delegate=self;
    [[Filter sharedInstance] copyToObject:filterVC.objFilter];
    SGNavigationController *navBar=[[SGNavigationController alloc]initWithRootViewController:filterVC];
    [self presentViewController:navBar animated:YES completion:nil];
}
- (void)filterVCDoneClicked{
    isFilterApplied = true;
    arr = [[NSMutableArray alloc] init];
    arrFinalObjects=[[NSMutableArray alloc] init];
    [self reloadCollectionView];
    [self callAPIWithZeroOffset:true];
}
- (void)clearFilterClicked{
    isFilterApplied = false;
    arrFinalObjects = [arr mutableCopy];
    
}
#pragma mark - API

// Call API
-(void)callAPIWithZeroOffset:(BOOL)status
{

    if (isApiRunning) {
        return;
    }
    isApiRunning = true;
    if (status)
    {
        isLoadMoreData=true;
    }
    [self getSoberUsersWithstart:status withResponsLimit:RESPONSE_LIMIT_NEW withOnlineFilter:[Filter sharedInstance].onlyOnline withGroup:[Filter sharedInstance].onlyRehabGroup];
//
}

- (void)stopLoadingViewinMainThread:(BOOL)status{
    if (status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [appDelegate stopLoadingview];
            
        });
    }else
        [appDelegate stopLoadingview];
   
}

- (void)reloadCollectionView{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [mainCollectionView reloadData];
        [self stopLoadingViewinMainThread:false];
    });

}

#pragma mark - Collection View delegate methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(section==kSectionTypeGrid){
        return  [arrFinalObjects count];
    }
    else if(section == kSectionTypeInvite){
        return ([[User currentUser] inviteProcessDone]) ? 0 : 1;
    }else
        return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==kSectionTypeGrid)
    {
        GridCollectionViewCell * gridCell = [collectionView1 dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
        if (gridCell == nil) {
            
        }
        
        if (indexPath.row > arrFinalObjects.count-1) {
            return gridCell;
        }
        if (arrFinalObjects.count == 0) {
            return gridCell;
        }
        User *gUser=[arrFinalObjects objectAtIndex:indexPath.row];
        if ([gUser.struserId isEqualToString:[User currentUser].struserId]) {
            //NSLog(@"profile pic url %@",[User currentUser].dictProfilePic);
            [gridCell customizewithUser:[User currentUser]];
        }else
        [gridCell customizewithUser:gUser];
       
        return gridCell;
    }
    else if(indexPath.section == kSectionTypeLoader)
    {
        static NSString *identifier = @"Cell";
        
        UICollectionViewCell *cell = [collectionView1 dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.layer.borderWidth=0.0f;
        cell.layer.borderColor=[UIColor colorWithRed:247.0/255 green:215.0/255 blue:181.0/255 alpha:1].CGColor;
        cell.backgroundColor=[UIColor clearColor];
//        if (self.navigationController.navigationBarHidden) {
//            return cell;
//        }
        
        
        // Set view for content
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
       // if(arrFinalObjects.count>0 || isFilterApplied)
         if(arrFinalObjects.count>0)
        {
            
            
            if (isLoadMoreData)
            {
                [self performSelector:@selector(stopAnimatingFooter) withObject:nil afterDelay:0.5];
            }
            else
            {
               
                 [self stopLoadingViewinMainThread:true];
                [spinner stopAnimating];
                
                
            }
        }
        [cell.contentView addSubview:spinner];
        spinner.center = CGPointMake(collectionView1.frame.size.width/2, 50/2);
        return cell;
    }else{
        static NSString *identifier = @"InviteCell";
        
        UICollectionViewCell *cell = [collectionView1 dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.layer.borderWidth=0.0f;
        cell.layer.borderColor=[UIColor colorWithRed:247.0/255 green:215.0/255 blue:181.0/255 alpha:1].CGColor;
        
        UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, collectionView1.frame.size.width, 50)];
        lbl.text = @"Invite your friends to join Sober Grid!";
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
        btn.center = CGPointMake(collectionView1.frame.size.width/2, btn.center.y);
        [cell.contentView addSubview:btn];
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
        
        UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(collectionView1.frame.size.width - 40, 0, 40, 40)];
        btnCancel.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 20, 0);
        [btnCancel setTitle:@"X" forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(btnCancelInviteFriends_Clicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnCancel];
        
        return cell;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionTypeLoader) {
        return CGSizeMake(collectionView.frame.size.width, 50);
    }else if(indexPath.section == kSectionTypeInvite){
            return CGSizeMake(collectionView.frame.size.width, 100);
    }else{
    if (isIPad) {
       return CGSizeMake(collectionView.frame.size.width/5  - 8, collectionView.frame.size.width/5 - 8);
    
    }
    
        return CGSizeMake(collectionView.frame.size.width/3 - 6, collectionView.frame.size.width/3 - 6);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0;
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[GridCollectionViewCell class]]) {
        
    }else{
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
    }
   
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"GridToProfilePush" sender:nil];
 //   [self performSegueWithIdentifier:@"GridToTemp" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"GridToProfilePush"])
    {
        NSArray *arrIndexpaths = [mainCollectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath=[arrIndexpaths lastObject];
        
        // Get reference to the destination view controller
        ProfileVC *profileVC = [segue destinationViewController];
        [profileVC setUsers:arrFinalObjects withShowIndex:indexPath.row];
        profileVC.isCurrentUserProfile=false;
        // Pass any objects to the view controller here, like...
        
    }
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
    [mainCollectionView reloadData];
}
#pragma mark - Pull To Refresh

// Pull To Refresh with 10 Rows
- (IBAction)PullToRefresh_Clicked:(UIRefreshControl *)refreshControl1
{
    [refreshControl1 endRefreshing];

    if (_inSearchMode) {
        return;
    }
    // Stop Pull To Refresh
    
    // Allocate Memory to variables
    [self callAPIWithZeroOffset:true];
}
//stop the footer spinner
- (void) stopAnimatingFooter
{
    [self callAPIWithZeroOffset:false];
}
- (void)reloadCollection:(NSNotification*)notif{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* userId = notif.object;
        int intUserId = [userId intValue];
        NSArray *arrVisiblCells =   [mainCollectionView visibleCells];
        
        for (GridCollectionViewCell *cell in arrVisiblCells) {
            if (cell.tag == intUserId) {
                NSIndexPath *indexPath = [mainCollectionView indexPathForCell:cell];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [mainCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                });
                
            }
        }
    });

    
}
#pragma mark - Choice View delegate
- (void)didSelectedChoiceWithChoiceNumber:(int)choiceNo{
    NSLog(@"number %d",choiceNo);
}
#pragma mark - Searchbar Delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"btn cancel _Clickedddd---------");
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    _inSearchMode = false;
    arrFinalObjects = nil;
    [mainCollectionView reloadData];
    self.navigationController.navigationBarHidden = false;
    NSLog(@"btn cancel _Clickedddd delegate nil--------- Done");
    
    barWrapper.hidden = YES;
    //   searchBar.delegate = nil;
    NSLog(@"btn cancel _Clickedddd remove from superview--------- Done");
    
    //   [searchBar removeFromSuperview];
    NSLog(@"btn cancel _Clickedddd object nil--------- Done");
    
    //  topsearchBar =  nil;
    searchOffset = 0;
    offset = 0;
    [self callAPIWithZeroOffset:YES];
    NSLog(@"btn cancel _Clickedddd--------- Done");
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self callAPIWithZeroOffset:YES];
}
- (void)searchSoberUsersFromText:(NSString*)strText
{

}
- (void)userStateChanged{
    [mainCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:kSectionTypeGrid]]];
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    if ([requestedURL rangeOfString:@"search_user"].location != NSNotFound)
    {
        [self stopLoadingViewinMainThread:false];

        NSDictionary *dictTemp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        dictTemp = [dictTemp dictionaryByReplacingNullsWithBlanks];
        if ([[dictTemp objectForKey:@"Type"] isEqualToString:@"OK"])
        {
            /*
            NSArray *arrTemp =[[dictTemp objectForKey:@"Responce"] objectForKey:@"users"];
            arrFinalObjects = [[NSMutableArray alloc] init];
            [[SGXMPP sharedInstance] subscribePresenceForUsers:arrTemp];
            for (NSDictionary *dictTemp in arrTemp) {
                User *objUser=[[User alloc]init];
                [objUser createUserWithDict:dictTemp];
                [arrFinalObjects addObject:objUser];
            }
            
            [mainCollectionView reloadData];
             */
            
            
            NSDictionary *dictInfo =(NSDictionary*)userInfo;
            BOOL status=false;
            if ([[dictInfo objectForKey:kApiTypeKey] isEqualToString:kApiWithFilter]) {
                status = true;
            }else
                status = false;
            
            //    dispatch_sync(gridApiQueue, ^{
            NSDictionary *dictUser=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:Nil];
            if ([[dictUser objectForKey:@"Type"] isEqualToString:@"OK"]) {
                if ([[dictUser objectForKey:@"Responce"] isKindOfClass:[NSDictionary class]]) {
                    NSArray *arrTemp=[[dictUser objectForKey:@"Responce"] objectForKey:@"users"] ;
                    
                    if ([[dictUser objectForKey:@"Responce"] objectForKey:@"unread"]) {
                        appDelegate.notificationBadge = [[[dictUser objectForKey:@"Responce"] objectForKey:@"unread"] integerValue];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
                    }
                    
                    if ([[dictUser objectForKey:@"Responce"] objectForKey:@"devicetoken"]) {
                        NSString *strToken = [[dictUser objectForKey:@"Responce"] objectForKey:@"devicetoken"];
                        if (strToken.length == 0) {
                            [appDelegate registerForPush];
                        }
                    }
                    
                    searchOffset = (int)(searchOffset +arrTemp.count);
                  //  [self gotNewUsersWithArray:arrTemp withError:nil withOnlineUsers:NO withPastOffset:[[dictInfo objectForKey:kApiOffset] intValue]];
                   
                    [self gotNewUsersWithArray:arrTemp withError:nil withOnlineUsers:status withPastOffset:[[dictInfo objectForKey:kApiOffset] intValue]];

                }
                
                
            }else{
                [self gotNewUsersWithArray:nil withError:[dictUser objectForKey:@"Error"] withOnlineUsers:status withPastOffset:0];

              //  [self gotNewUsersWithArray:nil withError:[dictUser objectForKey:@"Error"] withOnlineUsers:NO withPastOffset:0];
                }

            
            
            
        }else{
            isApiRunning = false;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[dictTemp objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
             
    }

    
    if ([requestedURL rangeOfString:kApiNearByUser].location != NSNotFound) {
        
        NSDictionary *dictInfo =(NSDictionary*)userInfo;
        BOOL status=false;
        if ([[dictInfo objectForKey:kApiTypeKey] isEqualToString:kApiWithFilter]) {
            status = true;
        }else
            status = false;
        
        //    dispatch_sync(gridApiQueue, ^{
        NSDictionary *dictUser=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:Nil];
        dictUser = [dictUser dictionaryByReplacingNullsWithBlanks];
        if ([[dictUser objectForKey:@"Type"] isEqualToString:@"OK"]) {
            if ([[dictUser objectForKey:@"Responce"] isKindOfClass:[NSDictionary class]]) {
                NSArray *arrTemp=[[dictUser objectForKey:@"Responce"] objectForKey:@"users"] ;
                if ([[dictUser objectForKey:@"Responce"] objectForKey:@"unread"]) {
                    appDelegate.notificationBadge = [[[dictUser objectForKey:@"Responce"] objectForKey:@"unread"] integerValue];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGECHANGED object:nil];
                }
                
                if ([[dictUser objectForKey:@"Responce"] objectForKey:@"devicetoken"]) {
                    NSString *strToken = [[dictUser objectForKey:@"Responce"] objectForKey:@"devicetoken"];
                    if (strToken.length == 0) {
                        [appDelegate registerForPush];
                    }
                }
                
                offset = (int)(offset +arrTemp.count);
                [self gotNewUsersWithArray:arrTemp withError:nil withOnlineUsers:status withPastOffset:[[dictInfo objectForKey:kApiOffset] intValue]];
                
            }
        }else{
            [self gotNewUsersWithArray:nil withError:[dictUser objectForKey:@"Error"] withOnlineUsers:status withPastOffset:0];

        }

        
    }


}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    if ([requestedURL rangeOfString:@"search_user"].location != NSNotFound) {
          BOOL status=false;
        [self gotNewUsersWithArray:nil withError:error withOnlineUsers:status withPastOffset:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopLoadingViewinMainThread:false];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:error delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        });

    }
   else if ([requestedURL rangeOfString:kApiNearByUser].location != NSNotFound) {
        NSDictionary *dictInfo =(NSDictionary*)userInfo;
        BOOL status=false;
        if ([[dictInfo objectForKey:kApiTypeKey] isEqualToString:kApiWithFilter]) {
            status = true;
        }else
            status = false;
        
        [self gotNewUsersWithArray:nil withError:error withOnlineUsers:status withPastOffset:0];
        //      dispatch_sync(gridApiQueue, ^{
//        if(_completionblock){
//            _completionblock (nil,error,status,0);
//            _completionblock = nil;
//        }
        //       });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    viewUserChoices.delegate = nil;
    viewUserChoices = nil;
    mainCollectionView = nil;
    topsearchBar = nil;
    barWrapper = nil;

    _locHelper = nil;
    self.arr = nil;
    self.arrFinalObjects = nil;
   
}
#pragma mark pullToRefresh and Load more
- (void)getSoberUsersWithstart:(BOOL)fromStart withResponsLimit:(int)responseLimit withOnlineFilter:(BOOL)status withGroup:(BOOL)rstatus{
    [appDelegate startLoadingview:@"Please Wait..."];

    if (fromStart) {
        if (topsearchBar.text.length > 0) {
            searchOffset = 0;
        }else
        offset = 0;
    }
    if (!_locHelper) {
        _locHelper=[[XHLocationHelper alloc]init];

    }
    [_locHelper getCurrentGeolocationsWithPlaceMarkCompled:^(NSArray *placemarks,CLLocation *location) {
        
        //   dispatch_sync(gridApiQueue, ^{
        // ApiClass *aClass=[ApiClass sharedClass];
        // aClass.delegate = self;
        if (topsearchBar.text.length > 0) {
            CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@search_user",baseUrl()] andDelegate:self];
            
            //ApiClass *apiclass=[ApiClass sharedClass];
            // apiclass.delegate=self;
            if (placemarks) {
                
                NSDictionary *dict = @{@"searchText": topsearchBar.text,@"latitude":[NSNumber numberWithFloat:location.coordinate.latitude],@"longitude":[NSNumber numberWithFloat:location.coordinate.longitude],@"userid":[User currentUser].struserId,@"user_status":(status)?@"available":@"",@"withGroup":((rstatus)?@"1":@"0"),@"offset":[NSNumber numberWithInt:searchOffset],@"limit":[NSNumber numberWithInt:responseLimit]};
                NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
                [apicall startAPICallWithJSON:jsonData withObject:@{kApiTypeKey:((status)?kApiWithFilter:kApiWithoutFiler),kApiOffset:[NSNumber numberWithInt:searchOffset]}];
                
                //    [apiclass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@search_user",baseUrl()]] withPostParameters:@{@"searchText": strText,@"latitude":[NSNumber numberWithFloat:location.coordinate.latitude],@"longitude":[NSNumber numberWithFloat:location.coordinate.longitude]} withRequestMethod:POST];
            }else{
                NSDictionary *dict = @{@"searchText": topsearchBar.text,@"latitude":[NSNumber numberWithFloat:0],@"longitude":[NSNumber numberWithFloat:0],@"userid":[User currentUser].struserId,@"offset":[NSNumber numberWithInt:searchOffset],@"user_status":(status)?@"available":@"",@"withGroup":((rstatus)?@"1":@"0"),@"limit":[NSNumber numberWithInt:RESPONSE_LIMIT]};
                NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
                [apicall startAPICallWithJSON:jsonData withObject:@{kApiTypeKey:((status)?kApiWithFilter:kApiWithoutFiler),kApiOffset:[NSNumber numberWithInt:searchOffset]}];
                //[apiclass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@search_user",baseUrl()]] withPostParameters:@{@"searchText": strText,@"latitude":[NSNumber numberWithFloat:0],@"longitude":[NSNumber numberWithFloat:0]} withRequestMethod:POST];
            }

        }else{
        CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kApiNearByUser) andDelegate:self];
        if (placemarks) {
            
            CLPlacemark *placemark = [placemarks lastObject];
            NSDictionary *addressDictionary = placemark.addressDictionary;
            NSString *geoLocations = addressDictionary[(NSString *)kABPersonAddressCityKey];
            if (![[User currentUser]isLogin]) {
                return ;
            }
            
            NSDictionary *dict = @{@"latitude":[NSNumber numberWithFloat:location.coordinate.latitude],@"longitude":[NSNumber numberWithFloat:location.coordinate.longitude],@"distance":[NSNumber numberWithInt:40000],@"userid":[User currentUser].struserId,@"offset":[NSNumber numberWithInt:offset],@"limit":[NSNumber numberWithInt:responseLimit],@"current_city":geoLocations,@"user_status":(status)?@"available":@"",@"withGroup":((rstatus)?@"1":@"0")};
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            
            [apicall startAPICallWithJSON:data withObject:@{kApiTypeKey:((status)?kApiWithFilter:kApiWithoutFiler),kApiOffset:[NSNumber numberWithInt:offset]}];
            
            
        }else{
            if (![[User currentUser]isLogin]) {
                return ;
            }
            NSDictionary *dict=@{@"latitude":@"0",@"longitude":@"0",@"distance":@"500",@"offset":[NSNumber numberWithInt:offset],@"limit":[NSNumber numberWithInt:responseLimit],@"userid":[User currentUser].struserId,@"current_city":@"",@"user_status":(status)?@"available":@"",@"withGroup":((rstatus)?@"1":@"0")};
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            [apicall startAPICallWithJSON:data withObject:@{kApiTypeKey:((status)?kApiWithFilter:kApiWithoutFiler),kApiOffset:[NSNumber numberWithInt:offset]}];
            
        }
        }
        
        //      });
    }];
    
    
}
//(NSArray *arrUser,NSString *strError,BOOL forOfflineUsers,int pastOffset);
- (void)gotNewUsersWithArray:(NSArray*)arrUser withError:(NSString*)strError withOnlineUsers:(BOOL)withOnlinFilter withPastOffset:(int)pastOffset
    {
        isApiRunning = false;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!strError) {
            if ([Filter sharedInstance].onlyOnline && !withOnlinFilter && (topsearchBar.text.length == 0)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self callAPIWithZeroOffset:true];
                    [self stopLoadingViewinMainThread:false];
                    
                });
                return ;
            }
            
            if (![Filter sharedInstance].onlyOnline && withOnlinFilter) {
                isApiRunning = false;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self callAPIWithZeroOffset:true];
                    [self stopLoadingViewinMainThread:false];
                    
                });
                return ;
            }
            
            
            isApiRunning = false;
            UICollectionViewCell *cell=[mainCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kSectionTypeLoader]];
            if(cell){
                for(UIView *view in [cell.contentView subviews]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [view removeFromSuperview];
                    });
                }
            }
            
            
            if (arrUser.count > 0 ) {
                NSMutableArray *arrUserConvertedArray=[[NSMutableArray alloc]init];
                for (NSDictionary *dictUser in arrUser) {
                    User *usertemp=[[User alloc]init];
                    [usertemp createUserWithDict:dictUser];
                    if ([Filter sharedInstance].onlyOnline && (topsearchBar.text.length == 0)) {
                        usertemp.isOnline = true;
                    }
                   else if ([Filter sharedInstance].onlyOnline && (topsearchBar.text.length > 0)) {
                        usertemp.isOnline = true;
                    }
                    [arrUserConvertedArray addObject:usertemp];
                }
                if (pastOffset == 0) {
                    self.arr = [[NSMutableArray alloc] init];
                    self.arrFinalObjects = [[NSMutableArray alloc]init];
                  //  [arrUserConvertedArray insertObject:[User currentUser] atIndex:0];
                }
                
                [[SGXMPP sharedInstance] subscribePresenceForUsers:arrUser];
                if (arrUser.count!=15)
                {
                    [self stopLoadingViewinMainThread:true];
                    isLoadMoreData=false;
                }
                if (self.arr) {
                    [self.arr addObjectsFromArray:arrUserConvertedArray];
                    
                    if (isFilterApplied && topsearchBar.text.length == 0) {
                        [[Filter sharedInstance] filteredArray:[arrUserConvertedArray mutableCopy] withCompletion:^(NSMutableArray *arrFilteredObjects) {
                            [self.arrFinalObjects addObjectsFromArray:arrFilteredObjects];
                            if (self.arrFinalObjects.count == 0 &&isLoadMoreData) {
                                [self getSoberUsersWithstart:NO withResponsLimit:RESPONSE_LIMIT_NEW withOnlineFilter:[Filter sharedInstance].onlyOnline withGroup:[Filter sharedInstance].onlyRehabGroup];
                            }
                            [self reloadCollectionView];
                        }];
                    }
                    if (isFilterApplied && topsearchBar.text.length > 0) {
                        [[Filter sharedInstance] filteredArray:[arrUserConvertedArray mutableCopy] withCompletion:^(NSMutableArray *arrFilteredObjects) {
                            [self.arrFinalObjects addObjectsFromArray:arrFilteredObjects];
                            if (self.arrFinalObjects.count == 0 &&isLoadMoreData) {
                                [self getSoberUsersWithstart:NO withResponsLimit:RESPONSE_LIMIT_NEW withOnlineFilter:[Filter sharedInstance].onlyOnline withGroup:[Filter sharedInstance].onlyRehabGroup];
                            }
                            [self reloadCollectionView];
                        }];
                    }
                    else{
                        self.arrFinalObjects = [arr mutableCopy];
                        [self reloadCollectionView];
                    }
                    
                }else{
                    self.arr = [[NSMutableArray alloc]initWithArray:arrUserConvertedArray];
                    
                    if (isFilterApplied && topsearchBar.text.length == 0)
                    {
                        [[Filter sharedInstance] filteredArray:[arrUserConvertedArray mutableCopy] withCompletion:^(NSMutableArray *arrFilteredObjects) {
                            self.arrFinalObjects = [arrFilteredObjects mutableCopy];
                            if (self.arrFinalObjects.count == 0 &&isLoadMoreData) {
                                [self getSoberUsersWithstart:NO withResponsLimit:RESPONSE_LIMIT withOnlineFilter:[Filter sharedInstance].onlyOnline withGroup:[Filter sharedInstance].onlyRehabGroup];
                            }
                            [self reloadCollectionView];
                        }];
                    }else{
                        self.arrFinalObjects = [self.arr mutableCopy];
                        [self reloadCollectionView];
                    }
                }
                
               
                
            }else{
                [self stopLoadingViewinMainThread:true];
            }
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopLoadingViewinMainThread:false];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:strError delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
            
            
        }
        
    
                       
                       });
}

@end
