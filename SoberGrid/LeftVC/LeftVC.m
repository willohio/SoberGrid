//
//  LeftVC.m
//  SoberGrid
//
//  Created by Binty Shah on 9/2/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

typedef enum {
    kMenuOptionGrid,
    kMenuOptionNewsFeed,
    kMenuOptionProfile,
    kMenuOptionMessage,
    kMenuOptionInviteFriends,
    kMenuOptionVisitors,
    kMenuOptionBadge,
    kMenuOptionPremium,
    kMenuOptionRehabAluminiGroup,
    kMenuOptionFavourite,
    kMenuOptionBlock,
    kMenuOptionStealthMode,
    // kMenuOptionBigBook,
    kMenuOptionSoberityCalculator,
    // kMenuOption12x12,
    kMenuOptionFAQ,
    kMenuOptionContactUS,
    kMenuOptionLogout,
}kMenuOption;

#import "LeftVC.h"
#import "Global.h"
#import "VisitorFavBlockVC.h"
#import "User.h"
#import "LoginViewController.h"
#import "UIViewController+JASidePanel.h"
#import "MessagesViewController.h"
#import "SGNewsFeedViewController.h"
#import "SupportingBadgeViewController.h"
#import "PremiumMemberViewController.h"
#import "StealthModeViewController.h"
#import "SGCalculatorViewController.h"
#import "WebViewController.h"
#import "SGXMPP.h"
#import "THContactPickerViewController.h"
#import "ContactUsViewController.h"
#import "SGPostPage.h"
#import "SGNewsFeedPageDetailViewController.h"
#import "GroupListVC.h"
#import "SGGroup.h"
#import "RehabGroupListVC.h"
@interface LeftVC ()<GroupListVCDelegate>
{
    NSInteger openIndex;
    NSArray *arrGroups;
}
@property (nonatomic,strong)    NSMutableArray *arrControllers;

@end

@implementation LeftVC
@synthesize tblView;

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
    _arrControllers = [[NSMutableArray alloc]init];
    openIndex = -1;
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMessagecell) name:NOTIFICATION_GOTNEWUNREADMESSAGE object:nil];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Tableview Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (openIndex != -1 && openIndex == indexPath.row - 1) {
        return (arrGroups.count > groupLimit) ? (groupLimit + 1)*44 : arrGroups.count * 44;
    }
    return (isIPad) ? 60 : 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (openIndex == -1) {
        return 16;
    }else
        return 17;
    
}
#pragma mark - Make any action to work from selcting row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selectedRow = indexPath.row;
    if (indexPath.row != kMenuOptionRehabAluminiGroup && openIndex != -1) {
        if (indexPath.row > openIndex) {
            selectedRow = indexPath.row - 1;
        }
    }
    if (openIndex != -1 && openIndex == indexPath.row - 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        GroupListVC *gpListvc = [[GroupListVC alloc]init];
        [gpListvc setGroups:arrGroups];
        gpListvc.delegate = self;
        [_arrControllers addObject:gpListvc];
        CGRect cellFrame = cell.frame;
        cellFrame.size.height = (arrGroups.count > groupLimit) ? (groupLimit + 1)*44 : arrGroups.count * 44;
        cell.frame = cellFrame;
        gpListvc.view.frame = cellFrame;
        [cell addSubview:gpListvc.view];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
        
    }
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if(selectedRow==kMenuOptionGrid){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"Grid_Icon")];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"The Grid", nil)];
    }
    else if (selectedRow == kMenuOptionNewsFeed){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"Newsfeed_Icon")];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Newsfeed", nil)];
    }
    else if(selectedRow == kMenuOptionProfile){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"profile")];
        cell.textLabel.text =[NSString stringWithFormat:NSLocalizedString(@"Profile", nil)];
    }
    else if(selectedRow == kMenuOptionMessage){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"Message_Icon")];
        int count = [[SGXMPP sharedInstance] getAllUnreadMessages];
        if (count > 0) {
            cell.textLabel.text =[NSString stringWithFormat:@"%@ (%d)",NSLocalizedString(@"Messages", nil),count];
        }else
        {
            cell.textLabel.text = NSLocalizedString(@"Messages", nil);
        }
        
    }
    else if(selectedRow == kMenuOptionVisitors){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"Stealth_Mode_Icon")];
        cell.textLabel.text =[NSString stringWithFormat:NSLocalizedString(@"Visitors", nil)];
    }
    else if(selectedRow==kMenuOptionBadge){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"Supporting_Badge_Icon")];
        cell.textLabel.text =[NSString stringWithFormat:NSLocalizedString(@"Supporting Badge", nil)];
    }
    else if(selectedRow==kMenuOptionPremium){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"Go_Premium_Icon")];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Go Premium", nil)];
    }
    else if (selectedRow == kMenuOptionRehabAluminiGroup){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"RAG_icon")];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Rehab Alumni Group", nil)];
        UIImageView *imgDiscl = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNameRefToDevice(@"Right_Arrow")]];
        UIView *viewDiscl = [[UIView alloc]initWithFrame:imgDiscl.bounds];
        viewDiscl.frame = CGRectMake(tblView.frame.size.width - viewDiscl.frame.size.width -5, 10, viewDiscl.frame.size.width, viewDiscl.frame.size.height);
        viewDiscl.center = CGPointMake(viewDiscl.center.x, (isIPad) ? 60/2 : 40/2);
        viewDiscl.tag = 545;
        [cell.contentView addSubview:viewDiscl];
        // [appDelegate setBorderTo:viewDiscl];
        [viewDiscl addSubview:imgDiscl];
        //  cell.accessoryView = viewDiscl;
        
    }
    else if(selectedRow==kMenuOptionFavourite){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"Favourite_Icon")];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Favorites", nil)];
    }
    else if (selectedRow == kMenuOptionBlock){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"Block_Button_icon")];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Block", nil)];
    }
    else if(selectedRow == kMenuOptionStealthMode){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"Stealth_Mode_Icon")];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Stealth Mode", nil)];
    }
    //    else if (indexPath.row == kMenuOptionBigBook){
    //        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"Big_Book_Icon")];
    //        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Big Book", nil)];
    //    }
    else if (selectedRow == kMenuOptionSoberityCalculator){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"Calculator_Icon")];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Sobriety Calculator", nil)];
    }
    //    else if (indexPath.row == kMenuOption12x12){
    //        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"12x12_Icon")];
    //        cell.textLabel.text = @"12 & 12";
    //    }
    else if (selectedRow == kMenuOptionFAQ){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"faq")];
        cell.textLabel.text = NSLocalizedString(@"FAQ", nil);
    }
    else if (selectedRow == kMenuOptionContactUS){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"contactus")];
        cell.textLabel.text = NSLocalizedString(@"Contact Us", nil);
    }else if(selectedRow == kMenuOptionInviteFriends){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"invite_frnds")];
        cell.textLabel.text = NSLocalizedString(@"Invite Friends", nil);
    }else if(selectedRow == kMenuOptionLogout){
        cell.imageView.image = [UIImage imageNamed:imageNameRefToDevice(@"logout")];
        cell.textLabel.text = NSLocalizedString(@"Logout", nil);
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor=[UIColor whiteColor];
    if (selectedRow == kMenuOptionRehabAluminiGroup) {
        cell.textLabel.font = SGBOLDFONT(15.0);
    }else
        cell.textLabel.font = SGBOLDFONT(17);
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selectedRow = indexPath.row;
    if (indexPath.row != kMenuOptionRehabAluminiGroup && openIndex != -1) {
        if (indexPath.row > openIndex) {
            selectedRow = indexPath.row - 1;
        }
        CGFloat indexToClose = openIndex;
        openIndex = -1;
        [self removeChannelAtIndexPath:indexToClose];
    }
    
    
    self.sidePanelController.recognizesPanGesture = YES;
    if(selectedRow==kMenuOptionGrid)
    {
        // For Grid
        SGNavigationController *temNc=(SGNavigationController*)self.sidePanelController.centerPanel;
        UIViewController *tempVc=[[temNc viewControllers] objectAtIndex:0];
        
        SGNavigationController*  centerNC = [self.storyboard instantiateViewControllerWithIdentifier:@"CenterNavigationController"];
        
        if ([tempVc isKindOfClass:[GridViewController class]]) {
            [self.sidePanelController toggleLeftPanel:nil];
            return;
        }
        
        self.sidePanelController.centerPanel=centerNC;
        
    }else if (selectedRow == kMenuOptionNewsFeed){
        // For news feed
        SGNewsFeedViewController *sgNFController = [[SGNewsFeedViewController alloc]init];
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:sgNFController];
        self.sidePanelController.centerPanel = navCtrl;
        
    }
    else if(selectedRow==kMenuOptionProfile)
    {
        ProfileVC *profileVC=[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileVC"];
        // profileVC.pUser = [User currentUser];
        [profileVC setUsers:[@[[User currentUser]]mutableCopy] withShowIndex:0];
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:profileVC];
        self.sidePanelController.centerPanel=navCtrl;
    }
    
    else if (selectedRow == kMenuOptionMessage){
        
        MessagesViewController *mVC=[self.storyboard instantiateViewControllerWithIdentifier:@"MessagesViewController"];
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:mVC];
        self.sidePanelController.centerPanel=navCtrl;
        
        
    }
    else if (selectedRow == kMenuOptionVisitors){
        // ForVisiters
        VisitorFavBlockVC *VisitorFavBlockVC=[self.storyboard instantiateViewControllerWithIdentifier:@"VisitorFavBlockVC"];
        VisitorFavBlockVC.isVisitor=TRUE;
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:VisitorFavBlockVC];
        self.sidePanelController.centerPanel=navCtrl;
        
    }
    else if (selectedRow == kMenuOptionBadge){
        
        // For self supporting badge
        SupportingBadgeViewController *sbVC=[[SupportingBadgeViewController alloc]init];
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:sbVC];
        self.sidePanelController.centerPanel=navCtrl;
        
    }
    else if (selectedRow == kMenuOptionPremium){
        
        // for Go premium
        PremiumMemberViewController * pmVC=[[PremiumMemberViewController alloc]init];
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:pmVC];
        self.sidePanelController.centerPanel=navCtrl;
    }else if (selectedRow == kMenuOptionRehabAluminiGroup){
        
        if (openIndex == -1) {
            openIndex = indexPath.row;
            [self openChannelAtIndex:indexPath.row];
        }else{
            openIndex = -1;
            [self removeChannelAtIndexPath:indexPath.row];
        }
        
    }
    else if(selectedRow==kMenuOptionFavourite)
    {
        // For Favs
        VisitorFavBlockVC *VisitorFavBlockVC=[self.storyboard instantiateViewControllerWithIdentifier:@"VisitorFavBlockVC"];
        VisitorFavBlockVC.isFavotires=TRUE;
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:VisitorFavBlockVC];
        self.sidePanelController.centerPanel=navCtrl;
    }
    else if(selectedRow==kMenuOptionBlock)
    {
        // For Blocks
        VisitorFavBlockVC *VisitorFavBlockVC=[self.storyboard instantiateViewControllerWithIdentifier:@"VisitorFavBlockVC"];
        VisitorFavBlockVC.isBlock=TRUE;
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:VisitorFavBlockVC];
        self.sidePanelController.centerPanel=navCtrl;
    }else if (selectedRow == kMenuOptionStealthMode){
        // For Stealth mode
        
        StealthModeViewController *stealthVC=[[StealthModeViewController alloc] init];
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:stealthVC];
        self.sidePanelController.centerPanel=navCtrl;
        
    }
    //    else if(indexPath.row==kMenuOptionBigBook)
    //    {
    //
    //        // For Big Book
    //        WebViewController *webVC=[[WebViewController alloc] init];
    //        webVC.webViewType = kWebViewTypeBigBook;
    //        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:webVC];
    //        self.sidePanelController.centerPanel=navCtrl;
    //
    //    }
    else if(selectedRow == kMenuOptionSoberityCalculator)
    {
        // For sobirity calculater
        SGCalculatorViewController *stealthVC=[[SGCalculatorViewController alloc] init];
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:stealthVC];
        self.sidePanelController.centerPanel=navCtrl;
        
    }
    //    else if (indexPath.row == kMenuOption12x12){
    //        // FOR 12*12
    //
    //        WebViewController *webVC=[[WebViewController alloc] init];
    //        webVC.webViewType = kWebViewType12;
    //        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:webVC];
    //        self.sidePanelController.centerPanel=navCtrl;
    //
    //    }
    else if (selectedRow == kMenuOptionFAQ){
        // FOR FAQ
        WebViewController *webVC=[[WebViewController alloc] init];
        webVC.webViewType = kWebViewTypeFAQ;
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:webVC];
        self.sidePanelController.centerPanel=navCtrl;
        
    }else if(selectedRow == kMenuOptionContactUS){
        // FOR Contact US
        ContactUsViewController *conVC=[[ContactUsViewController alloc] init];
        SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:conVC];
        self.sidePanelController.centerPanel=navCtrl;
    }else if(selectedRow == kMenuOptionInviteFriends){
//        THContactPickerViewController *thVC = [[THContactPickerViewController alloc]init];
//        SGNavigationController *navCTRL = [[SGNavigationController alloc]initWithRootViewController:thVC];
//        self.sidePanelController.centerPanel = navCTRL;
        [self actionButtonPressed:nil];
    }
    else if(selectedRow == kMenuOptionLogout){
        [[Filter sharedInstance] clearFilter];
        [[User currentUser]logout];
        
        
        SGNavigationController*    centerNC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
        self.sidePanelController.centerPanel = centerNC;
        
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

- (void)groupListDidSelectedOptionAtIndex:(NSInteger)index{
    SGGroup *gp = [arrGroups objectAtIndex:index];
    SGNewsFeedPageDetailViewController *sgfpViewController=[[SGNewsFeedPageDetailViewController alloc]init];
    [sgfpViewController setDetailMode:kDetailModeGroup WithObject:gp];
    SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:sgfpViewController];
    self.sidePanelController.centerPanel=navCtrl;
    CGFloat indexToClose = openIndex;
    openIndex = -1;
    [self removeChannelAtIndexPath:indexToClose];
    
    
}
- (void)groupListDidSelectedOptionMore{
    SGNavigationController *navCtrl=[[SGNavigationController alloc]initWithRootViewController:[[RehabGroupListVC alloc] init]];
    self.sidePanelController.centerPanel=navCtrl;
    CGFloat indexToClose = openIndex;
    openIndex = -1;
    [self removeChannelAtIndexPath:indexToClose];
}
- (void)reloadMessagecell{
    [tblView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kMenuOptionMessage inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)removeChannelAtIndexPath:(NSInteger)index{
    
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [tblView cellForRowAtIndexPath:cellIndexPath];
    UIView *disclosureView =[cell.contentView viewWithTag:545];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) 0);
                         disclosureView.transform = transform;
                     }
                     completion:nil];
    
    NSIndexPath *deletionIndexPath = [NSIndexPath indexPathForRow:index + 1 inSection:0];
    [tblView deleteRowsAtIndexPaths:@[deletionIndexPath]
                   withRowAnimation:UITableViewRowAnimationFade];
    [_arrControllers removeAllObjects];
}
- (void)openChannelAtIndex:(NSInteger)index {
    [SGGroup deleteUnwantedGroups];
    arrGroups = [SGGroup getAllGroups];
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [tblView cellForRowAtIndexPath:cellIndexPath];
    UIView *disclosureView =[cell.contentView viewWithTag:545];
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) M_PI_2);
                         disclosureView.transform = transform;
                     }
                     completion:nil];
    
    
    NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:(index + 1) inSection:0];
    [tblView insertRowsAtIndexPaths:@[insertionIndexPath]
                   withRowAnimation:UITableViewRowAnimationFade];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
