//
//  LikesViewController.m
//  SoberGrid
//
//  Created by agilepc-159 on 3/25/15.
//  Copyright (c) 2015 Agile Infoways Pvt. Ltd. All rights reserved.
//
#define kCellImageViewTag 444
#define kCellLableNameTag 445

#define kApiPostLikes @"getlikeusers_post"
#define kApiPageFeedLikes @"getlikeusers_page"
#define kApiCommentPostLikes @"getlikeusers_post_comment"
#define kApiCommentPageLikes @"getlikeusers_page_comment"

#import "LikesViewController.h"
#import "SGButton.h"
#import "CommonApiCall.h"
#import "User.h"
#import "UIImageView+WebCache.h"
#import "ProfileVC.h"
#import "AppDelegate.h"
@interface LikesViewController ()<UITableViewDataSource,UITableViewDelegate,CommonApiCallDelegate>
{
    NSMutableArray *arrFinalUsers;
    UITableView    *tblView;
}
@end

@implementation LikesViewController
- (void)formatUI{
    self.title = @"Likes";
    self.view.backgroundColor = [UIColor whiteColor];
    arrFinalUsers = [[NSMutableArray alloc]init];
    tblView = [[UITableView alloc]initWithFrame:self.view.bounds];
    tblView.delegate = self;
    tblView.dataSource = self;
    [self.view addSubview:tblView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self formatUI];
    [self getLikes];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)getLikes{
    [appDelegate startLoadingview:@"Please wait"];
    switch (_likeOn) {
        case kLikeOnPost:
        {
            CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kApiPostLikes) andDelegate:self];
            [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"post_id":_post.strFeedId} options:NSJSONWritingPrettyPrinted error:nil]];
        }
            break;
        case kLikeOnPage:{
            CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kApiPageFeedLikes) andDelegate:self];
            [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"page_feed_id":_post.strFeedId} options:NSJSONWritingPrettyPrinted error:nil]];
        }
            break;
        case kLikeOnCommentPost:{
            CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kApiCommentPostLikes) andDelegate:self];
            [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"commentid":_comment.strCommentID} options:NSJSONWritingPrettyPrinted error:nil]];
        }
            break;
        case kLikeOnCommentPage:{
            CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kApiCommentPageLikes) andDelegate:self];
            [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"commentid":_comment.strCommentID} options:NSJSONWritingPrettyPrinted error:nil]];
        }
            break;
        default:
            break;
    }

    
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];
    NSDictionary *dictTemp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictTemp = [dictTemp dictionaryByReplacingNullsWithBlanks];
    
    if (![[dictTemp objectForKey:TYPE] isEqualToString:RESPONSE_OK]) {
        [appDelegate showAlertMessage:[dictTemp objectForKey:ERROR]];
        return;
    }
    if ([requestedURL rangeOfString:@"get_user_details"].location != NSNotFound) {
        User *user=[[User alloc]init];
        [user createUserWithDict:dictTemp[@"Responce"][@"user"]];
        
        ProfileVC *profileVC=[SGstoryBoard() instantiateViewControllerWithIdentifier:@"ProfileVC"];
        profileVC.isCurrentUserProfile=false;
        [profileVC setUsers:[@[user] mutableCopy] withShowIndex:0];
        [self.navigationController pushViewController:profileVC animated:YES];
    
        return;
    }
    switch (_likeOn) {
        case kLikeOnPost:
        {
            NSMutableArray *arrUsers = [[dictTemp objectForKey:RESPONSE] objectForKey:@"postlikeuser"];
            for (NSDictionary *dictuser in arrUsers) {
                User *objUser=[[User alloc]init];
                objUser.strName = (dictuser[@"username"]) ? dictuser[@"username"] : @"Dummy User";
                objUser.struserId = (dictuser[@"user_id"]) ? dictuser[@"user_id"] : @"0";
                objUser.strProfilePicThumb = (dictuser[@"user_picture"]) ? dictuser[@"user_picture"] : @"";
                [arrFinalUsers addObject:objUser];
                
            }
            
        }
            break;
        case kLikeOnPage:{
            NSMutableArray *arrUsers = [[dictTemp objectForKey:RESPONSE] objectForKey:@"postlikeuser"];
            for (NSDictionary *dictuser in arrUsers) {
                User *objUser=[[User alloc]init];
                objUser.strName = (dictuser[@"username"]) ? dictuser[@"username"] : @"Dummy User";
                objUser.struserId = (dictuser[@"user_id"]) ? dictuser[@"user_id"] : @"0";
                objUser.strProfilePicThumb = (dictuser[@"user_picture"]) ? dictuser[@"user_picture"] : @"";
                [arrFinalUsers addObject:objUser];
                
            }

        }
            break;
        case kLikeOnCommentPost:{
            NSMutableArray *arrUsers = [[dictTemp objectForKey:RESPONSE] objectForKey:@"postlikeuser"];
            for (NSDictionary *dictuser in arrUsers) {
                User *objUser=[[User alloc]init];
                objUser.strName = (dictuser[@"username"]) ? dictuser[@"username"] : @"Dummy User";
                objUser.struserId = (dictuser[@"user_id"]) ? dictuser[@"user_id"] : @"0";
                objUser.strProfilePicThumb = (dictuser[@"user_picture"]) ? dictuser[@"user_picture"] : @"";
                [arrFinalUsers addObject:objUser];
                
            }

        }
            break;
        case kLikeOnCommentPage:{
            NSMutableArray *arrUsers = [[dictTemp objectForKey:RESPONSE] objectForKey:@"postlikeuser"];
            for (NSDictionary *dictuser in arrUsers) {
                User *objUser=[[User alloc]init];
                objUser.strName = (dictuser[@"username"]) ? dictuser[@"username"] : @"Dummy User";
                objUser.struserId = (dictuser[@"user_id"]) ? dictuser[@"user_id"] : @"0";
                objUser.strProfilePicThumb = (dictuser[@"user_picture"]) ? dictuser[@"user_picture"] : @"";
                [arrFinalUsers addObject:objUser];
                
            }

        }
            break;
        default:
            break;
    }
    [tblView reloadData];
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];
    [appDelegate showAlertMessage:error];
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
   
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"favBlockCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *imgView =[[UIImageView alloc]initWithFrame:CGRectMake(3, 5, 72, 72)];
        imgView.tag = kCellImageViewTag;
        [cell.contentView addSubview:imgView];
        
        UILabel  *lblName = [[UILabel alloc]initWithFrame:CGRectMake(90, 10, 150, 25)];
        lblName.tag = kCellLableNameTag;
        [cell.contentView addSubview:lblName];
    }

   UIImageView* image=(UIImageView*) [cell.contentView viewWithTag:kCellImageViewTag];
    //    image.layer.cornerRadius = image.frame.size.height/2;
    //    image.clipsToBounds = YES;
   UILabel* lblName=(UILabel*)[cell.contentView viewWithTag:kCellLableNameTag];
    lblName.font=[UIFont boldSystemFontOfSize:17.0];
    
    User *objUser=[arrFinalUsers objectAtIndex:indexPath.row];
    if (objUser.strProfilePicThumb.length > 0) {
        [image sd_setImageWithURL:[NSURL URLWithString:objUser.strProfilePicThumb] placeholderImage:[UIImage imageNamed:imageNameRefToDevice(@"placeholder")]];
    }else{
        [image setImage:[UIImage imageNamed:imageNameRefToDevice(@"placeholder")]];
    }
    
    
    lblName.text=objUser.strName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *objUser = [arrFinalUsers objectAtIndex:indexPath.row];
    if ([objUser.struserId isEqualToString:[User currentUser].struserId]) {
        ProfileVC *profileVC=[SGstoryBoard() instantiateViewControllerWithIdentifier:@"ProfileVC"];
        profileVC.isCurrentUserProfile=YES;
        [profileVC setUsers:[@[[User currentUser]] mutableCopy] withShowIndex:0];
        [self.navigationController pushViewController:profileVC animated:YES];
        return;
    }
    CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@get_user_details",baseUrl()] andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": objUser.struserId,@"myuserid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
    [appDelegate startLoadingview:@"Loading..."];
    
}

- (void)setPost:(SGPost *)post{
    _post = post;
}
- (void)setComment:(Comment *)comment{
    _comment = comment;
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
