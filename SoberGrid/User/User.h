//
//  User.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/11/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//


typedef void (^UserUpdateCompletionHandler)(BOOL status,NSString *strError);

#import <Foundation/Foundation.h>
#import "ApiClass.h"
#import "JSON.h"
#import "CommonApiCall.h"

@interface User : NSObject <ApiclassDelegate,NSCopying,CommonApiCallDelegate>
+ (User *)currentUser;

@property (strong,nonatomic)NSString *struserId;
@property (strong,nonatomic)NSString *strthumbUrl;
@property (strong,nonatomic)NSString *strName;
@property (strong,nonatomic)NSString *strEmailid;
@property (strong,nonatomic)NSDate   *birthDate;
@property (strong,nonatomic)NSDate   *dateSoberity;
//@property (strong,nonatomic)NSMutableArray *arrfellowShipType;
@property (strong,nonatomic)NSString *strisAvailbeToGiveRide;
@property (strong,nonatomic)NSMutableArray *arrSeekingType;
@property (strong,nonatomic)NSString *strLookingToMeetUP;
@property (strong,nonatomic)NSString *strGender;
@property (strong,nonatomic)NSString *strOrientation;
@property (strong,nonatomic)NSString *strRelStatus;
@property (strong,nonatomic)NSString *strCity;
@property (strong,nonatomic)NSString *strDistance;
@property (strong,nonatomic)NSString *strAboutMe;
@property (strong,nonatomic)NSString *strBurningDesire;
@property (strong,nonatomic)NSString *strNeedRide;
@property (strong,nonatomic)NSMutableArray *arrPics;
@property (strong,nonatomic)NSString *strProfilePic;
@property (strong,nonatomic)NSString *strProfilePicThumb;
@property (strong,nonatomic)NSDictionary *dictProfilePic;
@property (assign,nonatomic)BOOL isFav;
@property (assign,nonatomic)BOOL isBlocked;
@property (assign,nonatomic)BOOL isBadgePurchased;
@property (assign,nonatomic)BOOL isStealthModeEnable;
@property (strong,nonatomic)NSDate *dateLastSeen;
@property (assign,nonatomic)BOOL isUserTypePage;
@property (assign,nonatomic)BOOL isOnline;
@property (assign,nonatomic)BOOL showSoberDate;
@property (nonatomic,copy)UserUpdateCompletionHandler completionblock;

- (void)updatePictures:(NSArray*)arrPictures;
- (void)saveUser:(NSDictionary*)dict;
- (BOOL)isLogin;
- (void)logout;
- (void)updateToServerwithCompletionBlock:(UserUpdateCompletionHandler)completion;
- (void)createUserWithDict:(NSDictionary*)dictData;
- (void)upatePremiumwithType:(int)type;
- (void)updateGoldBadge:(BOOL)status;
- (void)changeProfileDictWithDict:(NSDictionary*)dict;
- (void)setStealthMode:(BOOL)status;
- (void)updateSoberityDate:(NSDate*)date;
- (NSDictionary*)dictProfilePicFromArray:(NSArray*)arrTemp;

- (void)setInviteFriendsBool:(BOOL)status;
- (BOOL)inviteProcessDone;
@end
