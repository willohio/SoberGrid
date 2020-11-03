//
//  ProfileVC.m
//  SoberGrid
//
//  Created by Binty Shah on 9/6/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "ProfileVC.h"
#import "Global.h"
#import "Filter.h"
#import "NSDate+Utilities.h"
#import "UIImageView+WebCache.h"
#import "SGRoundButton.h"
#import "NSObject+ConvertingViewPixels.h"
#import "ChatViewController.h"
#import "XHDemoWeChatMessageTableViewController.h"
#import "UIImage+Resize.h"
#import "MEAlertView.h"
#import "ProfileView.h"
#import "SwipeView.h"
#import "SoberGridIAPHelper.h"

@interface ProfileVC () <CommonApiCallDelegate,ProfileViewDelegate,SwipeViewDataSource,SwipeViewDelegate>
{
    UICollectionView *profileCollectionView;
    SwipeView *spView;
}
@end

@implementation ProfileVC

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
    [Localytics tagEvent:LLUserInProfileScreen];
    [self.navigationController.navigationBar setHidden:NO];
    imageClicked=FALSE;
    self.automaticallyAdjustsScrollViewInsets=NO;
      // [self preparePullableView];
   

    

}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = true;
    self.title=NSLocalizedString(@"Profile", nil);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadBackImages:) name:NOTIFICATION_PROFILE_PIC_DELETED object:nil];
    
    if (spView) {
        UIView *viewTemp=[spView itemViewAtIndex:spView.currentPage];
        ProfileView *pfView=(ProfileView *)[viewTemp viewWithTag:1];
        [pfView reloadTable];
    }

   // [self SetScrollView];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PROFILE_PIC_DELETED object:nil];
    User *user=[arrAllUsers objectAtIndex:spView.currentItemIndex];
    self.title = user.strName;
   
    UIView *viewTemp=[spView itemViewAtIndex:spView.currentPage];
    ProfileView *pfView=(ProfileView *)[viewTemp viewWithTag:1];
    [pfView removeFullMode];
    
    if(self.isMovingFromParentViewController){
        [self unloadSwipeView];
    }
}
- (void)unloadSwipeView
{
    NSArray *arrTemp = [spView visibleItemViews];
    for (UIView *viewTemp in arrTemp) {
        ProfileView *pfView=(ProfileView *)[viewTemp viewWithTag:1];
        [pfView unload];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}




#pragma mark - Button Action
- (IBAction)pushToEdit{
    [self performSegueWithIdentifier:@"protoeditscreen" sender:nil];
}

- (void)chatClickedForUser:(User *)user{
    [self enterMessagewithUser:user];
}

- (void)btnImageUploadClickedForUser:(User *)user{
    if (user.arrPics.count == 1) {
        if ([[SoberGridIAPHelper sharedInstance] getTypeOfSubsciption] == kSGSubscriptionTypeNone) {
            [[SoberGridIAPHelper sharedInstance] showAlertForActivatePack];
            return;
        }
    }
    tempUser = user;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Select Option", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Take New Picture", nil), NSLocalizedString(@"Choose From Library", nil), nil];
    [alert show];
   
}
-(void)btnImageUpload_Clicked:(UIButton *)sender
{
   
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"profileToChatpush"])
    {
       
        // Get reference to the destination view controller
       // ChatViewController *chatVC = [segue destinationViewController];
       // chatVC.otherUser=_pUser;
        
        
        // Pass any objects to the view controller here, like...
        
    }
}
- (void)enterMessagewithUser:(User*)user {
    
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[XHDemoWeChatMessageTableViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    
    XHDemoWeChatMessageTableViewController *demoWeChatMessageTableViewController = [[XHDemoWeChatMessageTableViewController alloc] init];
    demoWeChatMessageTableViewController.otherSideUser = user;
    [self.navigationController pushViewController:demoWeChatMessageTableViewController animated:YES];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return;
    }
    if (buttonIndex != 3) {
        // Delete the file using NSFileManager
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:imagePath]) {
            [fileManager removeItemAtPath:imagePath error:nil];
        }
    }
    
    if(buttonIndex == 2)
    {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate=self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing=TRUE;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else if (buttonIndex == 1)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.allowsEditing=TRUE;
            [self presentViewController:picker animated:YES completion:NULL];
        }
        else {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Can not find Camera Device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }

}


#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{}

- (void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   
    
    [picker1 dismissViewControllerAnimated:YES completion:^{

        UIImage *chosenImage=[info objectForKey:@"UIImagePickerControllerEditedImage"];
        imgChosenImage =chosenImage;

        ApiClass *classApi=[ApiClass sharedClass];
        classApi.delegate = self;
        [classApi uploadImageToUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@image_upload",baseUrl()]] withPostParameters:@{@"user_profilepic":(tempUser.arrPics.count > 0)?@"0":@"1",@"userid":tempUser.struserId} ofImage:chosenImage inKey:@"file" withName:@"image.jpg" withTag:0];
    }];
    [appDelegate startLoadingview:@"Uploading"];


//    chosenImage = [UIImage scaleAndRotateImage:chosenImage];
//    
   
//    [self performSelector:@selector(uploadImage:) withObject:chosenImage afterDelay:2];
    
    // Show Loader
    
}

#pragma mark - API DELEGATE
- (void)returnData:(id)data forUrl:(NSURL *)url withTag:(int)tag{
    if ([url.absoluteString rangeOfString:@"image_upload"].location != NSNotFound) {
    [appDelegate stopLoadingview];
    NSDictionary *dictResponser=(NSDictionary*)data;
    if ([[dictResponser objectForKey:@"Type"] isEqualToString:@"OK"]) {
        // Successfully uploaded image
//        NSMutableArray *arrTemp = [[[dictResponser objectForKey:RESPONSE] objectForKey:@"user_picture"] mutableCopy];
//        NSMutableDictionary *dictTemp = [[arrTemp lastObject] mutableCopy];
//        [dictTemp setObject:imgChosenImage forKey:@"pic_image"];
//        [arrTemp addObject:dictTemp];
//        dictTemp = nil;
//        [_pUser updatePictures:arrTemp];
//        arrTemp = nil;
//        imgChosenImage = nil;
         NSDictionary *dictTemp = [[[dictResponser objectForKey:RESPONSE] objectForKey:@"user_picture"] lastObject];
        NSURL *pic_url = [NSURL URLWithString:[dictTemp objectForKey:@"pic_url"]];
        SDWebImageManager *manager=[SDWebImageManager sharedManager];
        [manager saveImageToCache:imgChosenImage forURL:pic_url];
        imgChosenImage = nil;
        [tempUser updatePictures:[[dictResponser objectForKey:@"Responce"] objectForKey:@"user_picture"]];
        UIView *viewTemp=[spView itemViewAtIndex:spView.currentPage];
        ProfileView *pfView=(ProfileView *)[viewTemp viewWithTag:1];
       pfView.viewBottomContents.arrImages = [tempUser.arrPics mutableCopy];
        [pfView.viewBottomContents refresh];
        [pfView SetScrollView];
        
    }else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[dictResponser objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    }
    // Hide loader
}
-(void)reloadBackImages:(NSNotification*)notif{
    UIView *viewTemp=[spView itemViewAtIndex:spView.currentPage];
    ProfileView *pfView=(ProfileView *)[viewTemp viewWithTag:1];
    pfView.viewBottomContents.arrImages = [tempUser.arrPics mutableCopy];
    [pfView.viewBottomContents refresh];
    [pfView SetScrollView];
}

- (void)failedData:(NSError *)error forUrl:(NSURL *)url withTag:(int)tag{
    if ([url.absoluteString rangeOfString:@"image_upload"].location != NSNotFound) {
    [appDelegate stopLoadingview];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    }
    // Hide Loader
}

#pragma mark - Comman Api delegate
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{

}

- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
- (void)setUsers:(NSMutableArray *)arrUsers withShowIndex:(NSInteger)index{
    arrAllUsers = arrUsers;
    [self setupPagination];
    [spView scrollToItemAtIndex:index duration:0];
    
}
- (void)setupPagination{
    spView = [[SwipeView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    spView.delegate = self;
    spView.dataSource = self;
    [self.view addSubview:spView];
    if([[SoberGridIAPHelper sharedInstance] getTypeOfSubsciption] == kSGSubscriptionTypeNone){
        spView.scrollEnabled=false;
    }
}


#pragma mark -
#pragma mark iCarousel methods
- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView{
    
}
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    return [arrAllUsers count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    ProfileView*   profileView;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIView alloc] initWithFrame:swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        profileView=[[ProfileView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        profileView.tag = 1;
        [profileView setSwipeView:swipeView];
        [view addSubview:profileView];
    }
    else
    {
        //get a reference to the label in the recycled view
        profileView = (ProfileView *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    profileView.delegate = self;
    User *user=[arrAllUsers objectAtIndex:index];
    [profileView setController:self];
    [profileView setUser:user];
	return profileView;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return swipeView.bounds.size;
}

- (void)dealloc{
    spView = nil;
}




@end
