//
//  ProfileVC.h
//  SoberGrid
//
//  Created by Binty Shah on 9/6/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "StyledPullableView.h"
#import "BlurView.h"
#import "PROExapandableCell.h"
#import "TextEditerCell.h"
#import "ApiClass.h"
#import "AGMedallionView.h"
#import "ViewImageIncemental.h"
#import "User.h"

@interface ProfileVC : UIViewController<FBLoginViewDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationBarDelegate,UINavigationControllerDelegate,ApiclassDelegate>
{
    BOOL imageClicked;
    NSString *imagePath;
    UIImage *imgChosenImage;
    NSMutableArray *arrAllUsers;
    User *tempUser;
    
}
//@property (nonatomic,copy)User *pUser;
- (void)setUsers:(NSMutableArray *)arrUsers withShowIndex:(NSInteger)index;
@property (assign, nonatomic)BOOL isCurrentUserProfile;
@end
