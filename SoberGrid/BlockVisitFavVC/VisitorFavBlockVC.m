//
//  VisitorFavBlockVC.m
//  SoberGrid
//
//  Created by Binty Shah on 9/10/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "VisitorFavBlockVC.h"
#import "ProfileVC.h"
#import "global.h"
#import "User.h"
#import "UIImageView+WebCache.h"
#import "SGButton.h"
#import "MEAlertView.h"
#import "NSDate+Utilities.h"
#import "SGXMPP.h"

@interface VisitorFavBlockVC () <CommonApiCallDelegate,UIAlertViewDelegate>

@end

@implementation VisitorFavBlockVC
@synthesize tblView,isBlock,isFavotires,isVisitor;

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
    
    if (isBlock) {
        [self getBlocks];
        [Localytics tagEvent:LLUserInBlockScreen];
    }
    if (isFavotires) {
        [self getFavourites];
        [Localytics tagEvent:LLUserInFavouriteScreen];
    }
    if (isVisitor) {
        [self getVistors];
        [Localytics tagEvent:LLUserInVisitorScreen];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if(isVisitor)
        self.title=NSLocalizedString(@"Visitors", nil);
    else if (isFavotires)
        self.title=NSLocalizedString(@"Favorites", nil);
    else
        self.title=NSLocalizedString(@"Block", nil);
    
    if (isFavotires) {
        if (arrFinalUsers.count > 0) {
            [arrFinalUsers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(User* obj, NSUInteger idx, BOOL *stop) {
                
                if (!obj.isFav) {
                    [arrFinalUsers removeObject:obj];
                }
                if (idx == 0) {
                    [tblView reloadData];
                }
                
            }];
            
            
        }
    }
    
}
- (void)getFavourites{
    CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"myFavourite") andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
}
- (void)getBlocks{
    CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"myBlock") andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
}
- (void)getVistors{
    CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"My_Visitor") andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"visitor_id":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
}
#pragma mark - Tableview Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrFinalUsers.count;
}
#pragma mark - Make any action to work from selcting row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"favBlockCell"];
    UIView *cellView;
    UIImageView *image;
    UILabel *lblName;
    UILabel *lblCity;
    SGButton *btnInfo;
    UIImageView *ImgArrow;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"favBlockCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
     
    }
    cellView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,tblView.frame.size.width, 80)];
    image=[[UIImageView alloc]initWithFrame:CGRectMake(3, 5, 72, 72)];
//    image.layer.cornerRadius = image.frame.size.height/2;
//    image.clipsToBounds = YES;
    lblName=[[UILabel alloc]initWithFrame:CGRectMake(90, 10, 150, 25)];
    lblName.font=[UIFont boldSystemFontOfSize:17.0];
    lblCity=[[UILabel alloc]initWithFrame:CGRectMake(90, 40, 150, 25)];
    lblCity.font=[UIFont systemFontOfSize:15.0];
    lblCity.textColor=[UIColor lightGrayColor];
    ImgArrow=[[UIImageView alloc]initWithFrame:CGRectMake(tblView.frame.size.width-15, 35, 6, 10)];
    
    btnInfo=[[SGButton alloc]init];


    User *objUser=[arrFinalUsers objectAtIndex:indexPath.row];
    [image sd_setImageWithURL:[NSURL URLWithString:objUser.strProfilePicThumb] placeholderImage:[UIImage imageNamed:imageNameRefToDevice(@"placeholder")]];
    
    
    lblName.text=objUser.strName;
    if (isVisitor) {
        lblCity.text=[objUser.dateLastSeen formattedStringwithFormat:@"MMM d yyyy"];
    }else
    lblCity.text=objUser.strCity;
    if(isFavotires)
    {
        btnInfo.frame =CGRectMake(tblView.frame.size.width-50, 28, 23, 23);
        [btnInfo setImage:[UIImage imageNamed:@"Star_Icon.png"] forState:UIControlStateNormal];
        ImgArrow.image=[UIImage imageNamed:@"next_arrow-1.png"];

    }
    else if (isBlock)
    {
        btnInfo.frame=CGRectMake(tblView.frame.size.width-100, 25, 78, 30);
        [btnInfo setImage:[UIImage imageNamed:@"Unblock_Button.png"] forState:UIControlStateNormal];
        btnInfo.userInfo = objUser;
        [btnInfo addTarget:self action:@selector(btnBlock_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    }else{
         ImgArrow.image=[UIImage imageNamed:@"next_arrow-1.png"];
    }
    btnInfo.tag = indexPath.row;
    [cellView addSubview:btnInfo];
    [cellView addSubview:ImgArrow];
    [cellView addSubview:lblCity];
    [cellView addSubview:lblName];
    [cellView addSubview:image];
    [cell.contentView addSubview:cellView];
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isBlock) {
        return;
    }
    ProfileVC *profileVC=[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileVC"];
    profileVC.isCurrentUserProfile=false;
    [profileVC setUsers:arrFinalUsers withShowIndex:indexPath.row];
    [self.navigationController pushViewController:profileVC animated:YES];
}
- (IBAction)btnBlock_Clicked:(SGButton*)sender{
    
    
    User *objUser=sender.userInfo;
    [[SGXMPP sharedInstance] unblockUser:objUser];
    CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"block") andDelegate:self];
    [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"type":@"remove",@"userid":[User currentUser].struserId,@"sobergrid_user":objUser.struserId} options:NSJSONWritingPrettyPrinted error:nil]];
    [arrFinalUsers removeObjectAtIndex:sender.tag];
    [tblView reloadData];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    MEAlertView *cuAlert=(MEAlertView *)alertView;
    
    if (buttonIndex == 1) {
        User *objUser=(User*)cuAlert.userInfo;
        CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"block") andDelegate:self];
        [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"type":@"remove",@"userid":[User currentUser].struserId,@"sobergrid_user":objUser.struserId} options:NSJSONWritingPrettyPrinted error:nil]];
        [arrFinalUsers removeObjectAtIndex:cuAlert.tag];
        [tblView reloadData];
    }
}
#pragma mark - CommonApi delegate
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    if ([requestedURL rangeOfString:@"block"].location != NSNotFound) {
        return;
    }
    arrFinalUsers = [[NSMutableArray alloc] init];
    NSDictionary *dictResponse=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    if ([requestedURL rangeOfString:@"myFavourite"].location != NSNotFound) {
        NSArray *arrusers=[[dictResponse objectForKey:RESPONSE] objectForKey:@"users"];
        for (NSDictionary *dictTemp in arrusers) {
            User *objuser=[[User alloc]init];
            [objuser createUserWithDict:dictTemp];
            objuser.isFav = true;
            [arrFinalUsers addObject:objuser];
        }
    }
    if ([requestedURL rangeOfString:@"myBlock"].location != NSNotFound) {
        NSArray *arrusers=[[dictResponse objectForKey:RESPONSE] objectForKey:@"users"];
        for (NSDictionary *dictTemp in arrusers) {
            User *objuser=[[User alloc]init];
            [objuser createUserWithDict:dictTemp];
            objuser.isBlocked = true;
            [arrFinalUsers addObject:objuser];
        }
    }
    if ([requestedURL rangeOfString:@"My_Visitor"].location != NSNotFound) {
        NSArray *arrusers=[[dictResponse objectForKey:RESPONSE] objectForKey:@"visitor"];
        for (NSDictionary *dictTemp in arrusers) {
            User *objuser=[[User alloc]init];
            [objuser createUserWithDict:dictTemp];
            [arrFinalUsers addObject:objuser];
        }
    }
    [tblView reloadData];
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)dealloc{
    tblView = nil;
}

@end
