//
//  CommentsViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/20/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//
NSString *const commentTypePage = @"page";
NSString *const commentTypePost = @"post";

#import "CommentsViewController.h"
#import "SGNewsFeedPhotoCell.h"
#import "SGNewsFeedStatusCell.h"
#import "SGNewsFeedVideoCell.h"
#import "SGNewsFeedViewController.h"
#import "MHFacebookImageViewer.h"
#import "CommentInputView.h"
#import "Comment.h"
#import "CommentCell.h"
#import <Social/Social.h>
#import "SDWebImageManager.h"
#import "XHDisplayMediaViewController.h"
#import "SGNewsFeedPageDetailViewController.h"
#import "LikesViewController.h"
#import "ProfileVC.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
@interface CommentsViewController () <SGNewsFeedVideoCellDelegate,CommentInputViewDelegate,CommonApiCallDelegate,SGNewsFeedCellDelegate,CommentCellDelegate>
{
    CommentInputView *cmView;
}

@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SG_BACKGROUD_COLOR;
    arrComments = [[NSMutableArray alloc]init];
    [self createNewsFeedTable];
    [self getComments];
    [self addCommentView];
}

- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) addCommentView {
    cmView=[[CommentInputView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-40, CGRectGetWidth(self.view.bounds), 40)];
    cmView.delegate =self;
    
    [self.view addSubview:cmView];
}


- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = cmView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + cmView.frame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    cmView.frame = containerFrame;
    CGRect tblFrame = tblComments.frame;
    tblFrame.size.height = cmView.frame.origin.y;
    tblComments.frame = tblFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = cmView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    cmView.frame = containerFrame;
    CGRect tblFrame = tblComments.frame;
    tblFrame.size.height = cmView.frame.origin.y;
    tblComments.frame = tblFrame;
    
    // commit animations
    [UIView commitAnimations];
}

- (void)createNewsFeedTable{
    tblComments = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-40)];
    tblComments.dataSource = self;
    tblComments.delegate   = self;
    tblComments.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tblComments];
}

- (void)getComments{
    if(_isPage){
        CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"get_all_comment") andDelegate:self];
        [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"page_feed_id":_post.strFeedId,@"userid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
    }else{
        CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"get_post_comment") andDelegate:self];
        [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"post_id":_post.strFeedId,@"userid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
    }
    [appDelegate startLoadingview:@"Loading..."];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else
        return arrComments.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if ([_post isKindOfClass:[SGPostVideo class]]) {
            // Show fullvierson of photo
            SGPostVideo *sVideo=(SGPostVideo*)_post;
            SGNewsFeedVideoCell *videoCell = [tableView dequeueReusableCellWithIdentifier:kVideoCellIdentifier];
            if (videoCell == nil) {
                videoCell = [[SGNewsFeedVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVideoCellIdentifier withLine:false];
                videoCell.delegate = self;
                videoCell.videodelegate = self;
                
            }
            // videoCell.delegate = self;
            [videoCell customizeWithPost:sVideo withFullVersion:true forType:(_isPage)?@"page":@"post"];
            
            return videoCell;
            
        }else{
            // Show fullvierson of photo
            
            SGNewsFeedPhotoCell *photocell =[tableView dequeueReusableCellWithIdentifier:kPhotosCellIdentifier];
            if (photocell == nil) {
                photocell = [[SGNewsFeedPhotoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPhotosCellIdentifier withLine:false];
                photocell.delegate = self;
                
            }
            
            [photocell customizeWithPost:_post withFullVersion:true forType:(_isPage)?@"page":@"post"];
            if ([_post isKindOfClass:[SGPostPhoto class]]) {
                
                SGPostPhoto *sPhoto=(SGPostPhoto*)_post;

                 [photocell.imgViewPost setupImageViewerWithImageURL:[NSURL URLWithString:sPhoto.strImageUrl] onOpen:^{
                        } onClose:^{
                        }];
             }
            return photocell;
        }
    }
    
    Comment *cm=[arrComments objectAtIndex:indexPath.row];
    
    CommentCell *cell=[tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    
    if (cell == nil) {
        cell = [[CommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commentCell" withDelegate:self];
    }
    
    [cell customizeWithComment:cm];
    
    
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if ([_post isKindOfClass:[SGPostVideo class]]) {
            // Show fullvierson of photo
            SGPostVideo *sVideo=(SGPostVideo*)_post;
            return [SGNewsFeedVideoCell getHeightForPost:sVideo withFullVersion:true withLine:false];
        }else{
            return [SGNewsFeedPhotoCell getHeightAccordingToPost:_post withFullVersion:YES withLine:NO];
        }
    }
    return [CommentCell getHeightForCellForComment:[arrComments objectAtIndex:indexPath.row]];
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
}
- (void)likeClickedForComment:(Comment *)cmt{
    LikesViewController * likeVC = [[LikesViewController alloc]init];
    likeVC.likeOn = (_isPage)?kLikeOnCommentPage: kLikeOnCommentPost;
    [likeVC setComment:cmt];
    [self.navigationController pushViewController:likeVC animated:YES];
    
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
//    
//    
//}
//- (void)unloadCells:(NSArray*)cells{
//    for (UITableViewCell *cell in cells) {
//        if ([cell isKindOfClass:[SGNewsFeedBubbleCell class]]) {
//            SGNewsFeedBubbleCell *bubbleCell = (SGNewsFeedBubbleCell*)cell;
//            bubbleCell.delegate = nil;
//            
//        }
//    }
//    
//}



- (void)sendButtonClickedWithText:(NSString *)text{
    if (text.length == 0) {
        return;
    }
    [cmView.textView resignFirstResponder];
    NSString *feedId;
    if ([_post isKindOfClass:[SGPostStatus class]]) {
        SGPostStatus *sPost=(SGPostStatus*)_post;
        feedId = sPost.strFeedId;
    }
    if ([_post isKindOfClass:[SGPostPhoto class]]) {
        SGPostPhoto *sPost=(SGPostPhoto*)_post;
        feedId = sPost.strFeedId;
    }
    if ([_post isKindOfClass:[SGPostVideo class]]) {
        SGPostVideo *sPost=(SGPostVideo*)_post;
        feedId = sPost.strFeedId;
    }
    if ([_post isKindOfClass:[SGPostPage class]]) {
        SGPostPage *sPost=(SGPostPage*)_post;
        feedId = sPost.strPageId;
    }
    [appDelegate startLoadingview:@"Posting..."];
    if(_isPage)
    {
        
        CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"postfeed_comment") andDelegate:self];
        [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"page_feed_id":feedId,@"comment":text,@"type":@"add"} options:NSJSONWritingPrettyPrinted error:nil]];
        
        
        
    }else{
        CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"post_comment") andDelegate:self];
        [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"post_id":feedId,@"comment":text,@"type":@"add"} options:NSJSONWritingPrettyPrinted error:nil]];
    }
    
}
#pragma mark - VideoCell delegate
- (void)sgNewsFeedVideoCellClickeVideoforUrl:(NSString *)videoUrl{
    XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
    messageDisplayTextView.videoUrl = [NSURL URLWithString:videoUrl];
    [self.navigationController pushViewController:messageDisplayTextView animated:YES];
}
- (void)commentInputViewHeightUpdatedwithHeight:(CGFloat)height{
    CGRect tblFrame = tblComments.frame;
    tblFrame.size.height =  height;
    tblComments.frame = tblFrame;
}
- (void)btnShareClickedForPost:(id)post{
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
- (void)btnLikeClickedForPost:(id)post fromCell:(UITableViewCell *)cell{
    LikesViewController * likeVC = [[LikesViewController alloc]init];
    likeVC.likeOn = (_isPage)? kLikeOnPage: kLikeOnPost;
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
        [self pushToUser:spost.objUser];
    }
}

- (void)updatedPost:(id)post ForCell:(UITableViewCell *)cell{
    _post = post;
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
- (void)commentCellDidSelectedProfileWithUser:(User *)user{
    [self pushToUser:user];
}
- (void)pushToUser:(User*)objUser{
    [appDelegate startLoadingview:@"Loading..."];
    CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@get_user_details",baseUrl()] andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": objUser.struserId,@"myuserid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
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
    
    NSDictionary *dictResponse=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    if (([requestedURL rangeOfString:@"get_post_comment"].location != NSNotFound) || ([requestedURL rangeOfString:@"get_all_comment"].location != NSNotFound) ) {
        
        NSArray *arrDictComments = [[dictResponse objectForKey:RESPONSE] objectForKey:@"comments"];
        for (NSDictionary *dictTemp in arrDictComments) {
            [arrComments addObject:[Comment commentWithDetails:dictTemp forType:(_isPage)?commentTypePage : commentTypePost]];
            
        }
        _post.commentsCount =(int) arrComments.count;
        [tblComments reloadData];
        [self scrollToBottom];
    }else{
        
        if ([[dictResponse objectForKey:TYPE] isEqualToString:RESPONSE_OK]) {
            [arrComments addObject:[Comment commentWithMyDetails:[dictResponse objectForKey:RESPONSE] forType:(_isPage)?commentTypePage : commentTypePost]];
            _post.commentsCount = _post.commentsCount + 1;
            [tblComments reloadData];
            [self scrollToBottom];
        }
    }
    [appDelegate stopLoadingview];

}
- (void)setPost:(SGPost *)objPost{
    _post=objPost;
}
- (void)scrollToBottom{
    if(arrComments.count > 0){
        [tblComments scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:arrComments.count-1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];

}
- (void)dealloc{
    //tblComments = nil;
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
