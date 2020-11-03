//
//  ACEViewController.m
//  ACEExpandableTextCellDemo
//
//  Created by Stefano Acerbetti on 6/5/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//
#define API_ADD_POST_FEED @"Add_post_feed"

#import "SGNewsFeedPostViewController.h"
#import "ACEExpandableTextCell.h"
#import "SGNewsFeedViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Utility.h"
#import "XHDisplayMediaViewController.h"
#import "SDWebImageManager.h"
#import "UIImage+Utility.h"
#import <AVFoundation/AVFoundation.h>
#import "NetworkListioner.h"
#import "SGPostStatus.h"
#import "SGPostVideo.h"
#import "SGPostPage.h"
#import "SGPostPhoto.h"

@interface SGNewsFeedPostViewController ()<ACEExpandableTableViewDelegate,UIAlertViewDelegate,CommonApiCallDelegate,ApiclassDelegate> {
    CGFloat _cellHeight[2];
    ApiClass *apiClass;
}

@property (nonatomic, strong) NSMutableArray *cellData;

@end

@implementation SGNewsFeedPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cellData = [NSMutableArray arrayWithArray:@[@""]];
    arrImages = [[NSMutableArray alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self customizeNavigation];
    self.title = NSLocalizedString(@"Post Status", nil);
    
    if (_isTypeMedia) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Select source type", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"None", nil) otherButtonTitles:NSLocalizedString(@"Gallery", nil),NSLocalizedString(@"Camera", nil), nil];
        alert.delegate = self;
        [alert show];
    }
    
}
- (void)customizeNavigation{

    
    UIBarButtonItem * barButtonDone=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(btnDoneAccessoryBtn_Clickded:)];
    self.navigationItem.rightBarButtonItem=barButtonDone;
    
    UIBarButtonItem *barButtonCancel = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(btnCancel_Clicked:)];
    self.navigationItem.leftBarButtonItem = barButtonCancel;
}

- (void)btnCancel_Clicked:(UIBarButtonItem*)sender{
    [self.view endEditing:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table View Data Source

- (void)viewWillDisappear:(BOOL)animated{
    ACEExpandableTextCell *cell=(ACEExpandableTextCell*)[tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell unload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ACEExpandableTextCell *cell = [tableView expandableTextCellWithId:@"cellId"];
        cell.text = [self.cellData objectAtIndex:indexPath.row];
        
        cell.textView.placeholder = (_isTypeMedia) ? NSLocalizedString(@"Write something about media", nil) : NSLocalizedString(@"What`s on your mind?", nil);
        [cell customizewithUser:[User currentUser]];
        return cell;
    }
    if (indexPath.row == 1) {
        PostImagesCellTableViewCell *pCell=[tableView dequeueReusableCellWithIdentifier:@"pCell"];
        if (pCell == nil) {
            pCell = [[PostImagesCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pCell"];
        }
        pCell.delegate=self;
        [pCell customizeWithImagesArray:arrImages ofVideo:(urlVideo.absoluteString.length>0)?true:false];
        return pCell;
    }
    return nil;
   
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return MAX(60, _cellHeight[indexPath.section]);

    }else{
    
        if (arrImages.count % ((isIPad)?5:3) == 0) {
            return kSG_Cell_height *(int)(arrImages.count / ((isIPad)?5:3));
        }else{

            return kSG_Cell_height * (int)((arrImages.count / ((isIPad)?5:3))+ 1 );
        }
       
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[PostImagesCellTableViewCell class]]) {
        PostImagesCellTableViewCell *pcell = (PostImagesCellTableViewCell*)cell;
        [pcell unload];
    }
    
}

- (void)tableView:(UITableView *)tableView updatedHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath
{
    _cellHeight[indexPath.row] = height;
}

- (void)tableView:(UITableView *)tableView updatedText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath
{
    [_cellData replaceObjectAtIndex:indexPath.section withObject:text];
}
- (BOOL)tableView:(UITableView *)tableView textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView.text.length == 0 && [text isEqualToString:@"\n"]) {
        return false;
    }
    if (textView.text.length == 0 && [text isEqualToString:@" "]) {
        return false;
    }
    const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");
    
    if (isBackSpace == -8) {
        // is backspace
        return true;
    }
    if (textView.text.length > LIMIT_CHARACTER) {
        return false;
    }

    return true;

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return;
    }
    [self.view endEditing:true];
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc]init];
    imgPicker.delegate = self;
    if (buttonIndex == 1) {
            imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    if (buttonIndex == 2) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
        }else{
            imgPicker = nil;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Selected source is not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    imgPicker.mediaTypes =@[(NSString *) kUTTypeImage,(NSString *) kUTTypeMovie];
    imgPicker.allowsEditing = YES;
    imgPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    imgPicker.videoMaximumDuration = 10.0f;
    [self.navigationController presentViewController:imgPicker animated:YES completion:nil];
}
- (void)btnCameraAccessoryBtn_Clicked:(UIButton *)sender{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Select source type", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"None", nil) otherButtonTitles:NSLocalizedString(@"Gallery", nil),NSLocalizedString(@"Camera", nil), nil];
    alert.delegate = self;
    [alert show];
}
- (void)btnDoneAccessoryBtn_Clickded:(UIButton *)sender{
    NSLog(@"button clicked");
    if (![[NetworkListioner listner] isInternetAvailable]) {
        return;
    }
    ACEExpandableTextCell *cell = (ACEExpandableTextCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (arrImages.count == 0 && cell.textView.text.length == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if (cell.textView.text.length > 5000) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Status should be max of 5000 charecters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [self.view endEditing:YES];

    [appDelegate startLoadingview:@"Uploading..."];
    if (arrImages.count > 0) {
        if (postType == kSGNewsFeedTypePhoto) {
            SGPostPhoto *postPhoto = [[SGPostPhoto alloc] init];
            postPhoto.postImage = [[arrImages objectAtIndex:0] rotate];
            postPhoto.strDesrciption = cell.textView.text;
            [self uploadPhotoPost:postPhoto];
        }
        if (postType == kSGNewsFeedTypeVideo) {
            SGPostVideo *postVideo = [[SGPostVideo alloc] init];
            postVideo.strDesrciption = cell.textView.text;
            postVideo.strVideoUrl = [urlVideo path];
            postVideo.thumbImage  = [[arrImages objectAtIndex:0] rotate];
            [self uploadVideoPost:postVideo];
        }
       
        // It is post
    }else{
            SGPostStatus *postStatus = [[SGPostStatus alloc]init];
            postStatus.strStatus =cell.textView.text;
            [self uploadStatusPost:postStatus];
        
       
    }
}
- (void)postImagesCellTableViewCellCancelImageClickedForindex:(int)index{
    [arrImages removeObjectAtIndex:(NSUInteger)index];
    PostImagesCellTableViewCell *cell = (PostImagesCellTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell reloadDataWithImages:arrImages ofVideo:(urlVideo.absoluteString.length>0)?true:false];
}
- (void)postImagesCellTableViewCellPlayVideoClickedForindex:(int)index{
    XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
    messageDisplayTextView.videoUrl = urlVideo;
    [self.navigationController pushViewController:messageDisplayTextView animated:YES];

}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

   
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        // Media is an image
        
        UIImage * originalImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        
        NSData *imgData = UIImageJPEGRepresentation(originalImage, 1); //1 it represents the quality of the image.
        arrImages = [[NSMutableArray alloc]initWithObjects:[info objectForKey:@"UIImagePickerControllerEditedImage"], nil];
        postType = kSGNewsFeedTypePhoto;
        urlVideo = nil;
       

    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Media is a video
        
        NSURL *url = info[UIImagePickerControllerMediaURL];
        [self convertMP4:info];
        
       // urlVideo = url;
        arrImages = [[NSMutableArray alloc]initWithObjects:[UIImage thumbnailImageFromVideoUrl:url], nil];
        postType = kSGNewsFeedTypeVideo;
        
    }
    
//     [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    PostImagesCellTableViewCell *cell = (PostImagesCellTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell reloadDataWithImages:arrImages ofVideo:(urlVideo.absoluteString.length>0)?true:false];
    [tblView beginUpdates];
    [tblView endUpdates];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        ACEExpandableTextCell *cell = (ACEExpandableTextCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell.textView becomeFirstResponder];
    }];


}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        ACEExpandableTextCell *cell = (ACEExpandableTextCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell.textView becomeFirstResponder];
    }];
}
-(void)convertMP4:(NSDictionary*)info

{
    NSString *videoPath1 = @"";
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
        
    {
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        videoPath1 =[NSString stringWithFormat:@"%@/tempv.mov",docDir];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath1]) {
            [[NSFileManager defaultManager] removeItemAtPath:videoPath1 error:nil];
        }
        
        NSData *videoData = [NSData dataWithContentsOfURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        
        [videoData writeToFile:videoPath1 atomically:NO];
        
    }
    
    CFRelease((__bridge CFStringRef)(mediaType));//CRA
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath1] options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
        
    {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        
        NSString* videoPath = [NSString stringWithFormat:@"%@/sgVideo.mp4", [paths objectAtIndex:0]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
        }
        
        urlVideo = [NSURL URLWithString:videoPath];
        
        exportSession.outputURL = [NSURL fileURLWithPath:videoPath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            [[NSFileManager defaultManager]removeItemAtPath:videoPath1 error:nil];
            
            switch ([exportSession status]) {
                    
                case AVAssetExportSessionStatusFailed:
                    
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                    
                case AVAssetExportSessionStatusCompleted:
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath1]) {
                        [[NSFileManager defaultManager] removeItemAtPath:videoPath1 error:nil];
                    }
                    break;
                    
                default:
                    
                    break;
                    
            }
            
        }];
        
    }
    
}
#pragma mark - Newsfeed Api delegate
- (void)postUploadedWithReponse:(id)response{
    [appDelegate stopLoadingview];
    if ([[response objectForKey:@"feedtype"] intValue] == kSGNewsFeedTypeStatus) {
        SGPostStatus * sgPost=[[SGPostStatus alloc]initWithDictionary:response];
        sgPost.objUser = [User currentUser];
        [_delegate sgnewsFeedPostPostedThePost:sgPost];
    }else if ([[response objectForKey:@"feedtype"] intValue] == kSGNewsFeedTypePhoto) {
        SGPostPhoto * sgPost=[[SGPostPhoto alloc]initWithDictionary:response];
        sgPost.objUser = [User currentUser];
        [[SDWebImageManager sharedManager] saveImageToCache:[[arrImages objectAtIndex:0] rotate] forURL:[NSURL URLWithString:sgPost.strImageUrl]];
        [[SDWebImageManager sharedManager] saveImageToCache:[[arrImages objectAtIndex:0] rotate] forURL:[NSURL URLWithString:sgPost.strThumImageUrl]];
        [_delegate sgnewsFeedPostPostedThePost:sgPost];
    }else{
        
        SGPostVideo *sgPost = [[SGPostVideo alloc]initWithDictionary:response];
        sgPost.objUser = [User currentUser];
        [[SDWebImageManager sharedManager] saveImageToCache:[[arrImages objectAtIndex:0] rotate] forURL:[NSURL URLWithString:sgPost.strThumbUrl]];
        [_delegate sgnewsFeedPostPostedThePost:sgPost];
        

    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:[urlVideo path]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[urlVideo path] error:nil];
    }
    
}
- (void)failToUploadPost{
    [appDelegate stopLoadingview];
    ACEExpandableTextCell *cell = (ACEExpandableTextCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textView becomeFirstResponder];
}
#pragma mark - Upload feeds
// TO POST STATUS
- (void)uploadStatusPost:(SGPostStatus*)post{
    CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@%@",baseUrl(),API_ADD_POST_FEED] andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"location":@"",@"feedtype":[NSNumber numberWithInt:kSGNewsFeedTypeStatus],@"status":post.strStatus} options:NSJSONWritingPrettyPrinted error:nil]];
}
// TO POST PHOTO
- (void)uploadPhotoPost:(SGPostPhoto*)post{
    CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@%@",baseUrl(),API_ADD_POST_FEED] andDelegate:self];
    
    [apicall uploadImageToUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl(),API_ADD_POST_FEED]] withPostParameters:@{@"userid":[User currentUser].struserId,@"location":@"",@"feedtype":[NSNumber numberWithInt:kSGNewsFeedTypePhoto],@"status":post.strDesrciption} ofImage:post.postImage inKey:@"media" withName:@"image.png" withobject:nil];
    
}
// TO POST VIDEO
- (void)uploadVideoPost:(SGPostVideo*)post{
    apiClass = [ApiClass sharedClass];
    apiClass.delegate = self;
    [apiClass uploadVideoToUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl(),API_ADD_POST_FEED]] withthumbImage:post.thumbImage withPostParameters:@{@"userid":[User currentUser].struserId,@"location":@"",@"feedtype":[NSNumber numberWithInt:kSGNewsFeedTypeVideo],@"status":post.strDesrciption} videoAtPath:post.strVideoUrl inKey:@"media"];
}
#pragma mark - ApiClass delegate
- (void)returnData:(id)data forUrl:(NSURL *)url withTag:(int)tag{
    NSDictionary *dictResponse=(NSDictionary*)data;
    
    if ([url.absoluteString rangeOfString:API_ADD_POST_FEED].location != NSNotFound){
        if ([[dictResponse objectForKey:@"Type"] isEqualToString:@"OK"]) {
            [self postUploadedWithReponse:[[dictResponse objectForKey:@"Responce"] objectForKey:@"post"]];
        }else{
            [self failToUploadPost];
        }
    }
    
}
- (void)failedData:(NSError *)error forUrl:(NSURL *)url withTag:(int)tag{
    [self failToUploadPost];
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    NSDictionary *dictResponse=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    if ([requestedURL rangeOfString:API_ADD_POST_FEED].location != NSNotFound){
        if ([[dictResponse objectForKey:@"Type"] isEqualToString:@"OK"]) {
            [self postUploadedWithReponse:[[dictResponse objectForKey:@"Responce"] objectForKey:@"post"]];
        }else{
            [self failToUploadPost];
        }
    }
    
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [self failToUploadPost];
}
- (void)dealloc{
    tblView = nil;
    arrImages = nil;
    urlVideo = nil;
    _delegate = nil;
}

@end
