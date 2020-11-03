//
//  SGNewsFeedPageDetailViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/21/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "SGNewsFeedPageDetailViewController.h"
#import "SGNewsFeedPageCell.h"
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
#import "CommonApiCall.h"
#import "ViewBanner.h"
#import "GroupedCell.h"
#import "NSString+Utilities.h"
#import "NSString+Utilities.h"
#import "SGNewsFeedPageAboutViewController.h"
#import "LikesViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "GroupedCell.h"
#import "FeedDetailViewController.h"
#import "PSTAlertController.h"
#import "WebViewController.h"
static NSInteger feedLimit = 30;

@interface SGNewsFeedPageDetailViewController () <CommonApiCallDelegate,MHFacebookImageViewerDatasource,SGNewsFeedCellDelegate,SGNewsFeedVideoCellDelegate,ViewBannerDelegate>{
    ViewBanner *bannerView;
    NSInteger offset;
}

@end

@implementation SGNewsFeedPageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    offset = 0;
    

    self.view.backgroundColor = SG_BACKGROUD_COLOR;
    _arrPosts =[[NSMutableArray alloc]init];
    arrOnlyImages = [[NSMutableArray alloc]init];

    self.title = _objPage.strPageTitle;
    [self createPageTable];
    [self getPageDetails];
    
    if (_detailMode == kDetailModeGroup) {
        self.title = @"Rehab Alumni Group";
        if ([_objGroup.joinStatus integerValue] == kSGGroupStatusAccepted) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Leave" style:UIBarButtonItemStyleDone target:self action:@selector(leaveGroup_Clicked:)];
        }
        
        [self addInfinitesScrollInTable:tblPageDetail];
    }

    // Do any additional setup after loading the view.
}
- (IBAction)leaveGroup_Clicked:(id)sender{
    PSTAlertController *alertCtrl = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"Rehab Alumni Group", nil) message:NSLocalizedString(@"Are you sure you want to leave this group?", nil) preferredStyle:PSTAlertControllerStyleAlert];
    [alertCtrl addAction:[PSTAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) handler:^(PSTAlertAction *action) {
        [appDelegate startLoadingview:@"Please Wait..."];
        CommonApiCall *apiCall = [[CommonApiCall alloc] initWithRequestMethod:POST andRequestURL:createurlFor(@"leave_rehab_group") andDelegate:self];
        [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"groupid":_objGroup.strGroupId} options:NSJSONWritingPrettyPrinted error:nil]];
    }]];
    [alertCtrl addAction:[PSTAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) handler:nil]];
    [alertCtrl showWithSender:self controller:self animated:YES completion:nil];
}
- (void) addInfinitesScrollInTable:(UITableView *)tableView {
    __weak SGNewsFeedPageDetailViewController *weakSelf = self;
    __block UITableView *blockSafeTable  = tableView;
    
    [tableView addInfiniteScrollingWithActionHandler:^{
        //  [weakSelf fetchUserContactswithFirstTime:NO];
        
        blockSafeTable.showsInfiniteScrolling = YES;
        if(_arrPosts.count > 0){
             [weakSelf getPageDetails];
        }
       
    }];
    tblPageDetail.showsInfiniteScrolling = YES;
}
- (void)viewWillAppear:(BOOL)animated{
    [tblPageDetail reloadData];
}
- (void)viewWillDisappear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)createPageTable{
    tblPageDetail = [[UITableView alloc]initWithFrame:self.view.bounds];
    tblPageDetail.dataSource = self;
    tblPageDetail.delegate   = self;
    tblPageDetail.backgroundColor = SG_BACKGROUD_COLOR;
    tblPageDetail.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    if (_detailMode == kDetailModePage) {
        //  _objPage.strPageTitle change with nil to hide title By Sajid
        bannerView = [[ViewBanner alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 230) customizeWithBannerUrl:_objPage.strPageBanner_Url withProfileImageUrl:_objPage.strPageProfile_Url withTitle:nil isLiked:[_objPage.strIsLike boolValue] LikeEnable:NO withDelegate:self];
    }else{
        bannerView = [[ViewBanner alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 230) customizeWithBannerUrl:_objGroup.strBannerThumbUrl withProfileImageUrl:_objGroup.strThumbUrl withTitle:_objGroup.strFullName isLiked:[_objGroup.isLiked boolValue] LikeEnable:([_objGroup.joinStatus integerValue] == kSGGroupStatusAccepted)?YES:NO withDelegate:self];
    }
    tblPageDetail.tableHeaderView = bannerView;

    [self.view addSubview:tblPageDetail];
  
}
- (void)viewBannerLike_ClickedWithSelectedState:(BOOL)state{
    if (_detailMode == kDetailModePage) {
        _objPage.strIsLike =  [NSString stringWithFormat:@"%d",state];
        CommonApiCall *apiclass=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(kAPI_LIKE) andDelegate:self];
        [apiclass startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"id":_objPage.strPageId,@"likestatus":[NSNumber numberWithBool:state],@"type":@"page"} options:NSJSONWritingPrettyPrinted error:nil]];
    }else{
        _objGroup.isLiked = [NSNumber numberWithBool:state];
        CommonApiCall *apiclass=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"Add_likeunlike_rehab_group") andDelegate:self];
        [apiclass startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"groupid":_objGroup.strGroupId,@"likestatus":[NSString stringWithFormat:@"%d",state]} options:NSJSONWritingPrettyPrinted error:nil]];
        
    }
}
- (void)getPageDetails{

    if (_detailMode == kDetailModePage) {
        CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"getpage_feed") andDelegate:self];
        [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"page_id": _objPage.strPageId,@"userid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
    }else{
        
        CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"group_page_feed") andDelegate:self];
        [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"groupid": _objGroup.strGroupId,@"userid":[User currentUser].struserId,@"limit":[NSString stringWithFormat:@"%d",feedLimit],@"offset":[NSString stringWithFormat:@"%d",offset]} options:NSJSONWritingPrettyPrinted error:nil]];
    }

}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        if (_detailMode == kDetailModeGroup) {
            if (_objGroup.strWebsiteUrl.length > 0) {
                return 1;
            } else
                return 0;
        } else { // page
            return 1;
        }
    }else if(section == 1){
        if (_detailMode == kDetailModeGroup) {
            if (_objGroup.strPhoneNumber.length > 0) {
                return 1;
            }else
                return 0;
        } else {
            return 1;
        }
        
    }else
        return _arrPosts.count;
    
    
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        GroupedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"likeCell"];
        UILabel *lbl;
        if (cell == nil) {
            cell = [[GroupedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"likeCell"];
            cell.clipsToBounds = YES;
            cell.backgroundColor = [UIColor clearColor];
            lbl =[[UILabel alloc]initWithFrame:cell.viewContentHolder.bounds];
            lbl.textColor   = [UIColor blackColor];
            lbl.font        = SGBOLDFONT(14.0);
            lbl.backgroundColor = [UIColor whiteColor];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.numberOfLines = 0;
            lbl.tag = 545;
            [cell.viewContentHolder addSubview:lbl];
            [cell setHight:40];

            
        }
        lbl = (UILabel*)[cell.viewContentHolder viewWithTag:545];
        if (_detailMode == kDetailModePage) {
//            NSMutableAttributedString *attTotalString = [[NSMutableAttributedString alloc]init];
//            NSAttributedString *attString1=[[NSAttributedString alloc]initWithString:[NSString formattedNumber:(_detailMode == kDetailModePage)?_objPage.likesCount : [_objGroup.totalLikes integerValue]] attributes:@{NSFontAttributeName : SGBOLDFONT(16.0),NSForegroundColorAttributeName : [UIColor blackColor]}];
//            NSAttributedString *attString2=[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"\n%@",NSLocalizedString([@"Like" stringWithExtensionforCount:(_detailMode == kDetailModePage)?_objPage.likesCount : [_objGroup.totalLikes integerValue]], nil)] attributes:@{NSFontAttributeName : SGREGULARFONT(14.0),NSForegroundColorAttributeName : [UIColor grayColor]}];
//            [attTotalString appendAttributedString:attString1];
//            [attTotalString appendAttributedString:attString2];
//            lbl.attributedText = attTotalString;
            lbl.text = _objPage.strPage_Phone;
        }else{
            lbl.text = NSLocalizedString(@"Visit Website", nil);
        }
                return cell;
        
    }
    else if (indexPath.section == 1){
        GroupedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aboutCell"];
        UILabel *lbl;
        if (cell == nil) {
            cell = [[GroupedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aboutCell"];
            cell.clipsToBounds = YES;
            cell.backgroundColor = [UIColor clearColor];
            lbl =[[UILabel alloc]initWithFrame:cell.viewContentHolder.bounds];
            lbl.textColor   = [UIColor blackColor];
            lbl.font        = SGBOLDFONT(14.0);
            lbl.backgroundColor = [UIColor whiteColor];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.numberOfLines = 0;
            if (_detailMode == kDetailModePage) {
                lbl.text = @"About Us";
            }else{
                lbl.text = _objGroup.strPhoneNumber;
            }
            [cell.viewContentHolder addSubview:lbl];
            [cell setHight:40];

            
        }
    
        return cell;
        
    }
    
    
    
         if ([[_arrPosts objectAtIndex:indexPath.row] isKindOfClass:[SGPostVideo class]]){
            SGNewsFeedVideoCell *videoCell = [tableView dequeueReusableCellWithIdentifier:kVideoCellIdentifier];
            
            if (videoCell == nil) {
                videoCell = [[SGNewsFeedVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVideoCellIdentifier lineType:kSGNewsFeedTypeVideo withLine:true];
                videoCell.delegate = self;
                videoCell.videodelegate = self;
            }
             if (_detailMode == kDetailModeGroup) {
                 [videoCell hideLikeOption];
                 [videoCell hideCommentOption];
             }
             
            [videoCell customizeWithPost:[_arrPosts objectAtIndex:indexPath.row] withFullVersion:false forType:@"page"];
            return videoCell;
         }else{
             SGPostPhoto *postPhoto = (SGPostPhoto*)[_arrPosts objectAtIndex:indexPath.row];
             
             
             SGNewsFeedPhotoCell *photocell =[tableView dequeueReusableCellWithIdentifier:kPhotosCellIdentifier];
             if (photocell == nil) {
                 photocell = [[SGNewsFeedPhotoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPhotosCellIdentifier withLine:true];
                 photocell.delegate = self;
                 
             }
             if (_detailMode == kDetailModeGroup) {
                 [photocell hideLikeOption];
                 [photocell hideCommentOption];
             }
             [photocell customizeWithPost:[_arrPosts objectAtIndex:indexPath.row] withFullVersion:false forType:@"page"];
             if ([[_arrPosts objectAtIndex:indexPath.row] isKindOfClass:[SGPostPhoto class]]) {
                 [photocell.imgViewPost setupImageViewerWithDatasource:self initialIndex:[arrOnlyImages indexOfObject:postPhoto.strImageUrl] onOpen:^{
                     NSLog(@"OPEN!");
                 } onClose:^{
                     NSLog(@"CLOSE!");
                 }];

             }
             
             return photocell;
             
         }
    
    return nil;
}
#pragma mark - Tableview Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        return 40;
    }
    
    // FOR PAGE CELL
    if (_detailMode == kDetailModeGroup) {
        if ([[_arrPosts objectAtIndex:indexPath.row] isKindOfClass:[SGPostVideo class]])
        {
            return [SGNewsFeedVideoCell getheightWithLikeAndCommentForPost:[_arrPosts objectAtIndex:indexPath.row] withFullVersion:false withLine:true];
        }else{
            return [SGNewsFeedPhotoCell getHeightWithoutLikeAndCommentAccordintToPost:[_arrPosts objectAtIndex:indexPath.row] withFullVersion:NO withLine:YES];
            
        }
    }else{
     if ([[_arrPosts objectAtIndex:indexPath.row] isKindOfClass:[SGPostVideo class]])
    {
        return [SGNewsFeedVideoCell getHeightForPost:[_arrPosts objectAtIndex:indexPath.row] withFullVersion:false withLine:true];
        
    }else{
        return [SGNewsFeedPhotoCell getHeightAccordingToPost:[_arrPosts objectAtIndex:indexPath.row] withFullVersion:NO withLine:YES];
    }
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_detailMode == kDetailModePage) {
         return 15;
    }else{
        if (section == 0 ) {
            if (_objGroup.strWebsiteUrl.length > 0) {
                return 15;
            }else
                return 0;
        }else if (section == 1){
            if (_objGroup.strPhoneNumber.length > 0) {
                return 15;
            }else
                return 0;

        }else if (_objGroup.strWebsiteUrl.length == 0 && _objGroup.strPhoneNumber.length == 0 ) {
            return 0;
        }else
        return 15;
    }
   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && _detailMode == kDetailModeGroup) {
        WebViewController *webVC = [[WebViewController alloc]init];
        webVC.webViewType = kWebViewTypeGeneral;
        
        [self.navigationController pushViewController:webVC animated:YES];
        [webVC setUrl:[NSURL URLWithString:[_objGroup.strWebsiteUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
    }else if (indexPath.section == 1 && _detailMode == kDetailModeGroup){
        
        NSString *phoneNumber =_objGroup.strPhoneNumber;
    
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]]];
        } else {
            UIAlertView *notPermitted=[[UIAlertView alloc] initWithTitle:nil message:@"Your device doesn't support this feature" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [notPermitted show];
        }
    }
    if(indexPath.section == 1 && _detailMode == kDetailModePage){
        SGNewsFeedPageAboutViewController *paVC=[[SGNewsFeedPageAboutViewController alloc]init];
        paVC.page = _objPage;
        [self.navigationController pushViewController:paVC animated:YES];
    }
}

- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer*) imageViewer{
    return arrOnlyImages.count;

}
- (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer{
    return [NSURL URLWithString:[arrOnlyImages objectAtIndex:index]];

}
- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer{
    return [UIImage imageNamed:@"placeholderImage"];

}
#pragma mark - Delegates of cells
- (void)btnCommentClickedForPost:(id)post fromCell:(UITableViewCell*)cell{
    if (_detailMode == kDetailModeGroup) {
        FeedDetailViewController *fdVC = [[FeedDetailViewController alloc]init];
        [fdVC setPost:post];
        [self.navigationController pushViewController:fdVC animated:YES];
    }else{
        CommentsViewController *cmVC=[[CommentsViewController alloc]init];
        [cmVC setPost:post];
        cmVC.isPage = true;
        [self.navigationController pushViewController:cmVC animated:YES];
    }
}
- (void)btnLikeClickedForPost:(id)post fromCell:(UITableViewCell *)cell{
    LikesViewController * likeVC = [[LikesViewController alloc]init];
    likeVC.likeOn = kLikeOnPage;
    [likeVC setPost:post];
    [self.navigationController pushViewController:likeVC animated:YES];
}
#pragma mark - API RESPONSE
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    
    if ([[dictResponse objectForKey:TYPE] isEqualToString:RESPONSE_OK]) {
        if ([requestedURL rangeOfString:@"leave_rehab_group"].location != NSNotFound) {
            [appDelegate stopLoadingview];
            [SGGroup deleteObject:_objGroup];
            PSTAlertController *alertCtrl = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"Rehab Alumni Group", nil) message:NSLocalizedString(@"Group Leaved Successfully", nil) preferredStyle:PSTAlertControllerStyleAlert];
            [alertCtrl addAction:[PSTAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) handler:^(PSTAlertAction *action) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MOVETONEWSFEEDSCREEN object:nil];
            }]];
            [alertCtrl showWithSender:self controller:self animated:YES completion:nil];
        }
        else if ([requestedURL rangeOfString:kAPI_LIKE].location != NSNotFound) {
            if (_detailMode == kDetailModePage) {
                NSInteger totalLikes = [dictResponse[@"Responce"][@"totatllikes"] integerValue];
                _objPage.likesCount = (int)totalLikes;
            }else{
                NSInteger totalLikes = [dictResponse[@"Responce"][@"totatllikes"] integerValue];
                _objGroup.totalLikes = [NSNumber numberWithInteger:totalLikes];
            }
            [tblPageDetail reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [tblPageDetail.infiniteScrollingView stopAnimating];
            NSArray *arrFeeds = [[dictResponse objectForKey:RESPONSE] objectForKey:@"page_feed"];
            if (_detailMode == kDetailModeGroup) {
                [SGGroup groupWithDetails:[[dictResponse objectForKey:RESPONSE] objectForKey:@"group"]];
                _objGroup.joinStatus = [NSNumber numberWithInteger:[dictResponse[RESPONSE][@"status"] integerValue]];
                [bannerView updateWithBannerUrl:_objGroup.strBannerThumbUrl withProfileImageUrl:_objGroup.strThumbUrl withTitle:_objGroup.strFullName isLiked:[_objGroup.isLiked boolValue] withLikeEnable:([_objGroup.joinStatus integerValue] == kSGGroupStatusAccepted)?YES:NO];
                if (arrFeeds.count < feedLimit) {
                    tblPageDetail.infiniteScrollingView.enabled = NO;
                }else
                    tblPageDetail.infiniteScrollingView.enabled = YES;
                
                offset = offset + (NSInteger)arrFeeds.count;
                
            }
            
            if (arrFeeds.count > 0) {
                
                for (NSDictionary *dict in arrFeeds) {
                    User *objUser=[[User alloc]init];
                    if (_detailMode == kDetailModeGroup) {
                        objUser.strName = _objGroup.strFullName;
                        objUser.struserId = _objGroup.strGroupId;
                        objUser.strProfilePicThumb = _objGroup.strThumbUrl;
                    }else{
                        objUser.strName = _objPage.strPageTitle;
                        objUser.struserId = _objPage.strPageId;
                        objUser.strProfilePicThumb = _objPage.strPageProfile_Url;
                    }
                    objUser.isUserTypePage = true;
                    if ([dict[@"feedtype"] intValue] == kSGNewsFeedTypeStatus) {
                        SGPostStatus *sgStatus = [[SGPostStatus alloc]initWithDictionary:dict];
                        sgStatus.objUser = objUser;
                        
                        [_arrPosts addObject:sgStatus];
                    }else if ([dict[@"feedtype"] intValue] == kSGNewsFeedTypePhoto){
                        SGPostPhoto *sgStatus = [[SGPostPhoto alloc]initWithDictionary:dict];
                        sgStatus.objUser = objUser;
                        [arrOnlyImages addObject:sgStatus.strImageUrl];
                        
                        [_arrPosts addObject:sgStatus];
                    }else{
                        SGPostVideo *sgVideo=[[SGPostVideo alloc]initWithDictionary:dict];
                        sgVideo.objUser = objUser;
                        
                        [_arrPosts addObject:sgVideo];
                    }
                }
                [tblPageDetail reloadData];
            }
        }
        
    }else{
        if (_detailMode == kDetailModeGroup) {
            if ([requestedURL rangeOfString:@"leave_rehab_group"].location != NSNotFound) {
                            [appDelegate stopLoadingview];
                
            }else{
            tblPageDetail.infiniteScrollingView.enabled = NO;
            if ([[[dictResponse objectForKey:RESPONSE] objectForKey:@"group"] isKindOfClass:[NSDictionary class]]) {
                [SGGroup groupWithDetails:[[dictResponse objectForKey:RESPONSE] objectForKey:@"group"]];
            }
            
            if (dictResponse[RESPONSE][@"status"]) {
                 _objGroup.joinStatus = [NSNumber numberWithInteger:[dictResponse[RESPONSE][@"status"] integerValue]];
                if ([_objGroup.joinStatus integerValue] == kSGGroupStatusAccepted) {
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Leave" style:UIBarButtonItemStyleDone target:self action:@selector(leaveGroup_Clicked:)];
                }else{
                    self.navigationItem.rightBarButtonItem = nil;
                }
            }
           
            [SGGroup save];
            [bannerView updateWithBannerUrl:_objGroup.strBannerThumbUrl withProfileImageUrl:_objGroup.strThumbUrl withTitle:_objGroup.strFullName isLiked:[_objGroup.isLiked boolValue] withLikeEnable:([_objGroup.joinStatus integerValue] == kSGGroupStatusAccepted)?YES:NO];
            }
            
        }
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[dictResponse objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    }
    
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];
    [appDelegate showAlertMessage:error];
}
- (void)updatedPost:(id)post ForCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [tblPageDetail indexPathForCell:cell];
    [_arrPosts replaceObjectAtIndex:indexPath.row withObject:post];
}
- (void)setDetailMode:(kDetailMode)detailMode WithObject:(id)object{
    _detailMode = detailMode;
    if (detailMode == kDetailModePage) {
        _objPage = object;
    }else{
        _objGroup = object;
    }
}
- (void)dealloc{
    tblPageDetail = nil;
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
