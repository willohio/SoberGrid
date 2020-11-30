//
//  ViewImageIncemental.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/17/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "ViewImageIncemental.h"
#import "MEAlertView.h"
#import "NSObject+ConvertingViewPixels.h"
#import "User.h"
#import "SoberGridIAPHelper.h"

@implementation ViewImageIncemental

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
    }
    return self;
}
- (void)customizewithProfileImages:(NSArray*)arrayImages{
    
    _arrImages = [arrayImages mutableCopy];
    [self setNeedsDisplay];
    
   
}
- (void)refresh{
    [self unload];
    _arrImages = [[User currentUser].arrPics mutableCopy];
    [self setNeedsDisplay];

}
- (void)unload{
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
}
- (void)btnImageUpload_Clicked:(UITapGestureRecognizer*)recognizer{
//    if ([[SoberGridIAPHelper sharedInstance] getTypeOfSubsciption] == kSGSubscriptionTypeNone) {
//        [[SoberGridIAPHelper sharedInstance] showAlertForActivatePack];
//        return;
//    }
   
    AGMedallionView *view=(AGMedallionView*)recognizer.view;
    _lastClicked =(int) view.tag;
    [_delegate imageClickedAtView:view];
}
- (void)btnCancelImage_Clicked:(UITapGestureRecognizer*)recognizer{
    AGMedallionView *view=(AGMedallionView*)recognizer.view;
    MEAlertView *alertView;
    
    if (([User currentUser].arrPics.count > 1) && !([view.userInfo[@"isProfile"] intValue] == 1)) {
        alertView=[[MEAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Would you like to do?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Set as profile pic", nil),NSLocalizedString(@"Delete", nil), nil];
    }else
        alertView=[[MEAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Would you like to do?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Delete", nil), nil];
    alertView.userInfo=@{@"tag": [NSNumber numberWithInt:(int)view.tag],@"userinfo":view.userInfo};
    [alertView show];
}
- (void)setImageToLasttapped:(UIImage*)image{
    AGMedallionView *view = (AGMedallionView*)[self viewWithTag:_lastClicked];
    [view setImage:image];
    _lastClicked = 0;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat pading = 0;
    
    for (int i = 0;i<_arrImages.count;i++) {
        
        NSDictionary *dictPic=[_arrImages objectAtIndex:i];
        
        AGMedallionView*  rounbView1 =  [[AGMedallionView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - [self deviceSpesificValue:60] - pading, [self deviceSpesificValue:22.5], [self deviceSpesificValue:50], [self deviceSpesificValue:50])];
        [rounbView1 setImageWithURL:[NSURL URLWithString:[dictPic objectForKey:@"pic_thumb"]]];
        rounbView1.userInfo = dictPic;
        rounbView1.tag = i;
        if([[dictPic objectForKey:@"isProfile"] intValue] == 1){
            rounbView1.borderColor = [UIColor redColor];

        }else
        rounbView1.borderColor = [UIColor whiteColor];
        rounbView1.borderWidth=1;

        UITapGestureRecognizer *tapround=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnCancelImage_Clicked:)];
        tapround.numberOfTapsRequired = 1.0;
        tapround.numberOfTouchesRequired = 1.0;
        [rounbView1 addGestureRecognizer:tapround];
        
        [self addSubview:rounbView1];
        rounbView1 = nil;
        pading = pading + [self deviceSpesificValue:60];
        
    }
    if (_arrImages.count < 5) {
        AGMedallionView*  rounbView1 =  [[AGMedallionView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - [self deviceSpesificValue:60] - pading, [self deviceSpesificValue:22.5], [self deviceSpesificValue:50], [self deviceSpesificValue:50])];
        [rounbView1 setImage:[UIImage imageNamed:@"Add_Icon.png"]];
        rounbView1.shadowColor=[UIColor clearColor];
        rounbView1.borderColor = [UIColor whiteColor];
        rounbView1.tag = _arrImages.count + 1;
        
        UITapGestureRecognizer *tapround=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnImageUpload_Clicked:)];
        tapround.numberOfTapsRequired = 1.0;
        tapround.numberOfTouchesRequired = 1.0;
        [rounbView1 addGestureRecognizer:tapround];
        [self addSubview:rounbView1];
        rounbView1 = nil;
    }
    
}

#pragma mark - Alerview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return;
    }
    MEAlertView *alert=(MEAlertView*)alertView;
    NSDictionary *dictInfo=alert.userInfo;
    if (buttonIndex == 1 && [User currentUser].arrPics.count > 1 && !([dictInfo[@"userinfo"][@"isProfile"] intValue] == 1)) {
        if ([User currentUser].dictProfilePic) {
            CommonApiCall *apiCall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"updateprofile") andDelegate:self];
            
            [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"update_profilepicid":dictInfo[@"userinfo"][@"pic_id"],@"from_profilepicid":[User currentUser].dictProfilePic[@"pic_id"]} options:NSJSONWritingPrettyPrinted error:nil]];
            [[User currentUser] changeProfileDictWithDict:dictInfo[@"userinfo"]];
            _arrImages = [[User currentUser].arrPics mutableCopy];
            [self refresh];
        }
    }else {
        int tag=[[dictInfo objectForKey:@"tag"] intValue];
        if ([[[dictInfo objectForKey:@"userinfo"] objectForKey:@"isProfile"] intValue] == 1) {
            if (_arrImages.count > 1) {
                NSDictionary *dictTemp;
                if (_arrImages.count == tag+1) {
                    
                    dictTemp = [_arrImages objectAtIndex:tag-1];
                }else{
                    dictTemp = [_arrImages objectAtIndex:tag+1];
                }
                CommonApiCall *apiCall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"updateprofile") andDelegate:self];
                
                [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"update_profilepicid":dictTemp[@"pic_id"],@"from_profilepicid":[User currentUser].dictProfilePic[@"pic_id"]} options:NSJSONWritingPrettyPrinted error:nil]];
                [[User currentUser] changeProfileDictWithDict:dictTemp];
                _arrImages = [[User currentUser].arrPics mutableCopy];
            }else{
                 [User currentUser].dictProfilePic = nil;
                [User currentUser].strProfilePic = nil;
                [User currentUser].strProfilePicThumb = nil;
            }
           
            
        }
        [_arrImages removeObjectAtIndex:tag];
        [[User currentUser] updatePictures:_arrImages];
        [self refresh];
        [self deleteImageFromserverfor:[dictInfo objectForKey:@"userinfo"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROFILE_PIC_DELETED object:nil userInfo:nil];
        return;
    }
    
    if (buttonIndex == 2) {
        int tag=[[dictInfo objectForKey:@"tag"] intValue];
        [_arrImages removeObjectAtIndex:tag];
        [[User currentUser] updatePictures:_arrImages];
        [self refresh];
        [self deleteImageFromserverfor:[dictInfo objectForKey:@"userinfo"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROFILE_PIC_DELETED object:nil userInfo:nil];

    }
}
- (void)deleteImageFromserverfor:(NSDictionary*)dict{
    
  //  ApiClass *aClass=[ApiClass sharedClass];
  //  aClass.delegate = self;
    CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@deleteprofilepic",baseUrl()] andDelegate:self];
    
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"profilepicId":[dict objectForKey:@"pic_id"]} options:NSJSONWritingPrettyPrinted error:nil]];
   // [aClass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@deleteprofilepic",baseUrl()]] withPostParameters:@{@"profilepicId":[dict objectForKey:@"pic_id"]}withRequestMethod:POST];
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    if ([requestedURL rangeOfString:@"deleteprofilepic"].location != NSNotFound) {
        NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
        if ([[dictResponse objectForKey:@"Type"] isEqualToString:@"OK"]) {
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:[dictResponse objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}
-(void)returnData:(id)data forUrl:(NSURL*)url withTag:(int)tag{
    if ([url.absoluteString rangeOfString:@"deleteprofilepic"].location != NSNotFound) {
    NSDictionary *dictResponse = (NSDictionary *)data;
    if ([[dictResponse objectForKey:@"Type"] isEqualToString:@"OK"]) {
       
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:[dictResponse objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    }
    
}
-(void)failedData:(NSError*)error forUrl:(NSURL*)url withTag:(int)tag{
    
}


@end
