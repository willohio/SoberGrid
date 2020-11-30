//
//  AppDelegate.h
//  SoberGrid
//
//  Created by William Santiago on 8/28/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTSpinKitView.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CommonApiCall.h"
#import "MEAlertView.h"
#import "MPGNotification.h"
#import "UIViewController+JASidePanel.h"

#import <AssetsLibrary/AssetsLibrary.h>
@class RTSpinKitView;

@class MMDrawerController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,CommonApiCallDelegate>
{
    RTSpinKitView *objSpinKit;
    UIView *viewShowLoad;    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MMDrawerController *drawerController;
@property (strong, nonatomic) ALAssetsLibrary *assetLibrary;
@property (assign, nonatomic) NSInteger notificationBadge;
@property (strong, nonatomic) NSDictionary *NotificationObj;
@property (nonatomic) BOOL AppComesFromNotification;
@property (nonatomic,strong)    MPGNotification *notification;
- (void)Logoutuserafterdelete:(NSDictionary*)pushDetail;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
-(void)showAlertMessage:(NSString *)strMessage;
-(void)startLoadingview :(NSString *)strMessage;
-(void)stopLoadingview;
- (void)registerForPush;
-(void)setBorderTo:(UIView*)controller;
@end
