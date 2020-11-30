//
//  ProfileView.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 11/4/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StyledPullableView.h"
#import "BlurView.h"
#import "PROExapandableCell.h"
#import "TextEditerCell.h"
#import "AGMedallionView.h"
#import "ViewImageIncemental.h"
#import "User.h"
#import "ProfileVC.h"
#import "SwipeView.h"
#import "MEAlertView.h"
@protocol ProfileViewDelegate<NSObject>

@optional
- (void)chatClickedForUser:(User*)user;
- (void)btnImageUploadClickedForUser:(User*)user;
@end

@interface ProfileView : UIView <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,CommonApiCallDelegate,ViewImageIncementalDelegate,PullableViewDelegate>
{
    StyledPullableView *pullUpView;
    UIView *viewProfileHolder;
    UIImageView *pullUpimage;
    BOOL imageClicked;
    BlurView *bottomView;
    AGMedallionView *rounbView1;
    UITableView *tblView;
   
    UIImage *imgChosenImage;
    User  *_pUser;
    BOOL isCurrentUserProfile;
    UIView *bottomButtonsView;
    ProfileVC *pfVC;
    SwipeView *_spView;
    UIScrollView *_ScrollView;

}
- (void)setSwipeView:(SwipeView*)swipView;
@property (nonatomic,strong)ViewImageIncemental *viewBottomContents;
@property (nonatomic,assign)id<ProfileViewDelegate>delegate;
- (void)setController:(ProfileVC*)controller;
- (void)setUser:(User*)user;
- (void)unload;
-(void)SetScrollView;
- (void)reloadTable;
- (void)removeFullMode;
@end
