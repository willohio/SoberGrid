//
//  User.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/11/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//
#define STEALTHMODE @"stealthmode"

#import "User.h"
#import "SGXMPP.h"
#import "SoberGridIAPHelper.h"
#import "DatabaseManager.h"
#import "SGGroup.h"
@implementation User
static User *_sharedDelegate = nil;

+ (User *)currentUser {
    @synchronized ([User class]) {
        if (!_sharedDelegate) {
            _sharedDelegate = [[super alloc] initUniqueInstance];
        }
        
        return _sharedDelegate;
    }
}
- (instancetype)initUniqueInstance {
    self = [super init];
    
    if (self) {
        
        [self initialise];
        
    }
    
    return self;
}
- (void)initialise{
    if ([self isLogin]) {
        [self createUserWithDict:nil];
    }
}
- (id)init{
    self = [super init];
    
    if (self) {
        
    }
    return self;
}
- (void)createUserWithDict:(NSDictionary*)dictData{
    
    NSDictionary *dictUser;
    if (dictData == nil) {
        NSData *userdata= [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
        dictUser = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:userdata];
        userdata     = nil;
    }else{
        if (![dictData isKindOfClass:[NSDictionary class]]) {
            return;
        }
        dictUser = dictData;
    }
    
    dictUser = [dictUser dictionaryByReplacingNullsWithBlanks];
    
    _strEmailid         = (dictUser[@"email"]) ? [dictUser objectForKey:@"email"] : @"";
    _strName            = (dictUser[@"fullname"]) ? [dictUser objectForKey:@"fullname"] : @"";
    _struserId          = (dictUser[@"userid"]) ?[dictUser objectForKey:@"userid"] : @"";
    _strLookingToMeetUP =  (dictUser[@"available_meeting"]) ? [dictUser[@"available_meeting"] capitalizedString]:  nil;
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *strBirthDate = (dictUser[@"birthdate"]) ? dictUser[@"birthdate"] : nil;
    _birthDate          = (strBirthDate.length > 0) ? [inputFormatter dateFromString:strBirthDate] : nil;
    NSString *strSoberDate = (dictUser[@"sobriety_date"]) ? dictUser[@"sobriety_date"] : nil;
    
    _showSoberDate = (dictUser[@"showSoberDate"]) ?  [dictUser[@"showSoberDate"] boolValue] : NO;
    
    _dateSoberity       = (strSoberDate.length > 0) ? [inputFormatter dateFromString:strSoberDate] : nil;
  //  _arrfellowShipType  = ([dictUser [@"fellowship"] isKindOfClass:[NSArray class]]) ? dictUser [@"fellowship"] :nil;
    _strGender          = (dictUser [@"gender"]) ? [dictUser [@"gender"] capitalizedString]: @"No Answer";
    _strOrientation     = (dictUser [@"orientation"]) ? [dictUser [@"orientation"] capitalizedString]: @"No Answer";
    _strRelStatus       = (dictUser[@"relationship_status"]) ? [dictUser[@"relationship_status"] capitalizedString]:nil;
    _arrSeekingType     = ([dictUser[@"seeking"] isKindOfClass:[NSArray class]]) ? [dictUser[@"seeking"] mutableCopy]:nil;
    _strCity            = (dictUser[@"city"]) ? [dictUser[@"city"] capitalizedString]:@"Location";
    _strDistance        = (dictUser[@"distance"]) ? dictUser[@"distance"] : @"0";
    _strNeedRide        = (dictUser[@"need_a_ride"]) ? dictUser[@"need_a_ride"] : @"0";
    
    _strBurningDesire   = (dictUser[@"burning_desire"]) ? dictUser[@"burning_desire"] : @"0";
    _isBadgePurchased     = (dictUser[@"Gold_badgePurchased"]) ? [dictUser[@"Gold_badgePurchased"] boolValue] :  false;
    _strisAvailbeToGiveRide = (dictUser[@"available_ride"]) ? [dictUser[@"available_ride"] capitalizedString] : @"No Answer";
    _strAboutMe           = (dictUser[@"about_me"]) ? dictUser[@"about_me"] : @"";
    _isFav                = (dictUser [@"isFav"]) ?  [dictUser [@"isFav"] boolValue] : false;
    _isBlocked            = (dictUser [@"is_block"]) ?[dictUser [@"is_block"] boolValue] : false;
    _isStealthModeEnable = [[NSUserDefaults standardUserDefaults] boolForKey:STEALTHMODE];
    
    NSString *strLastSeen = (dictUser[@"date"]) ? dictUser[@"date"] : nil;
    
    _dateLastSeen       = (strLastSeen.length > 0) ? [inputFormatter dateFromString:strLastSeen] : nil;
    
    if (dictUser[@"user_picture"]) {
        if ([dictUser[@"user_picture"] isKindOfClass:[NSArray class]]) {
            _arrPics            = (dictUser[@"user_picture"]) ?[dictUser[@"user_picture"] mutableCopy]:nil;
            if (_arrPics.count > 0) {
                _dictProfilePic = [self dictProfilePicFromArray:_arrPics];
                _strProfilePicThumb = [_dictProfilePic objectForKey:@"pic_thumb"];
                _strProfilePic  = [_dictProfilePic objectForKey:@"pic_url"];
            }
        }
    }
    
}
- (NSDictionary*)dictProfilePicFromArray:(NSArray*)arrTemp{
    for (NSDictionary *dictTemp in arrTemp) {
        if ([[dictTemp objectForKey:@"isProfile"] intValue] == 1) {
            return dictTemp;
        }
    }
    return nil;
}
- (void)saveUser:(NSDictionary *)dict{
    NSData *dataUser=[NSKeyedArchiver archivedDataWithRootObject:dict];
    [[NSUserDefaults standardUserDefaults]setObject:dataUser forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dataUser = nil;
    [[User currentUser] createUserWithDict:nil];
}
- (BOOL)isLogin{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
        return true;
    }
    return false;
}
- (void)setStealthMode:(BOOL)status{
    [[NSUserDefaults standardUserDefaults]setBool:status forKey:STEALTHMODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _isStealthModeEnable = status;
}
- (void)updatePictures:(NSArray*)arrPictures{
    NSData *userdata= [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSDictionary *dictUser = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:userdata];
    NSMutableDictionary *dictFinal=[[NSMutableDictionary alloc]initWithDictionary:dictUser copyItems:YES];
    [dictFinal setObject:arrPictures forKey:@"user_picture"];
    _arrPics = [arrPictures mutableCopy];
    [self saveUser:dictFinal];
    userdata  = nil;
    dictFinal = nil;
}
- (void)updateSoberityDate:(NSDate *)date{
    NSData *userdata= [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSMutableDictionary *dictUser =[[NSMutableDictionary alloc]initWithDictionary: (NSMutableDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:userdata]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dictUser setObject:[dateFormatter stringFromDate:date] forKey:@"sobriety_date"];
    _dateSoberity = date;
    [self saveUser:dictUser];
    
    
}
- (void)changeProfileDictWithDict:(NSDictionary*)dict;
{
    NSData *userdata= [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSMutableDictionary *dictUser = (NSMutableDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:userdata];
    NSMutableDictionary *dictFinal = [[NSMutableDictionary alloc]initWithDictionary:dictUser];
    
    if ([dictFinal[@"user_picture"] isKindOfClass:[NSArray class]]) {
        NSMutableArray * arrPics = [[NSMutableArray alloc]initWithArray:dictFinal[@"user_picture"]];
        for (int i =0 ; i<arrPics.count;i++) {
            NSDictionary *dictTemp=[arrPics objectAtIndex:i];
            if ([[dictTemp objectForKey:@"isProfile"] intValue] == 1) {
                NSMutableDictionary *dictResult = [[NSMutableDictionary alloc]initWithDictionary:dictTemp];
                [dictResult setObject:@"0" forKey:@"isProfile"];
                [arrPics replaceObjectAtIndex:i withObject:dictResult];
                
            }
            if ([[dictTemp objectForKey:@"pic_id"] intValue] == [[dict objectForKey:@"pic_id"] intValue]) {
                NSMutableDictionary *dictResult = [[NSMutableDictionary alloc]initWithDictionary:dictTemp];
                
                [dictResult setObject:@"1" forKey:@"isProfile"];
                [arrPics replaceObjectAtIndex:i withObject:dictResult];
                _dictProfilePic = dictResult;
                _strProfilePicThumb = [_dictProfilePic objectForKey:@"pic_thumb"];
                _strProfilePic  = [_dictProfilePic objectForKey:@"pic_url"];
            }
            
        }
        [dictFinal setObject:arrPics forKey:@"user_picture"];
    }
    
    [self saveUser:dictFinal];
    
}
- (void)upatePremiumwithType:(int)type{
    NSData *userdata= [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSDictionary *dictUser = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:userdata];
    NSMutableDictionary *dictFinal=[[NSMutableDictionary alloc]initWithDictionary:dictUser copyItems:YES];
    [dictFinal setObject:[NSString stringWithFormat:@"%d",type] forKey:@"premium"];
    [[SoberGridIAPHelper sharedInstance] setTypeOfSubscription:type];
    [self saveUser:dictFinal];
}
- (void)updateGoldBadge:(BOOL)status{
    NSData *userdata= [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSDictionary *dictUser = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:userdata];
    NSMutableDictionary *dictFinal=[[NSMutableDictionary alloc]initWithDictionary:dictUser copyItems:YES];
    [dictFinal setObject:[NSString stringWithFormat:@"%d",status] forKey:@"Gold_badgePurchased"];
    [self saveUser:dictFinal];
}
- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
        // Copy NSObject subclasses
        [copy setStruserId:[self.struserId copyWithZone:zone] ];
        [copy setStrthumbUrl:[self.strthumbUrl copyWithZone:zone]];
        [copy setStrName:[self.strName copyWithZone:zone]];
        [copy setStrEmailid:[self.strEmailid copyWithZone:zone]];
        [copy setBirthDate:[self.birthDate copyWithZone:zone]];
       // [copy setArrfellowShipType:[self.arrfellowShipType copyWithZone:zone]];
        [copy setStrisAvailbeToGiveRide:[self.strisAvailbeToGiveRide copyWithZone:zone]];
        [copy setArrSeekingType:[self.arrSeekingType copyWithZone:zone]];
        [copy setStrLookingToMeetUP:[self.strLookingToMeetUP copyWithZone:zone]];
        [copy setStrGender:[self.strGender copyWithZone:zone]];
        [copy setStrOrientation:[self.strOrientation copyWithZone:zone]];
        [copy setStrRelStatus:[self.strRelStatus copyWithZone:zone]];
        [copy setStrCity:[self.strCity copyWithZone:zone]];
        [copy setArrPics:[self.arrPics copyWithZone:zone]];
        [copy setStrDistance:[self.strDistance copyWithZone:zone]];
        [copy setStrBurningDesire:[self.strBurningDesire copyWithZone:zone]];
        [copy setStrNeedRide:[self.strNeedRide copyWithZone:zone]];
        [copy setStrProfilePic:[self.strProfilePic copyWithZone:zone]];
        [copy setIsBadgePurchased:self.isBadgePurchased];
        [copy setDictProfilePic:[self.dictProfilePic copyWithZone:zone]];
        [copy setStrAboutMe:[self.strAboutMe copyWithZone:zone]];
        [copy setIsFav:self.isFav];
        [copy setIsBlocked:self.isBlocked];
        [copy setIsStealthModeEnable:self.isStealthModeEnable];
        [copy setStrProfilePicThumb:[self.strProfilePicThumb copyWithZone:zone]];
        [copy setDateSoberity:[self.dateSoberity copyWithZone:zone]];
        [copy setDateLastSeen:[self.dateLastSeen copyWithZone:zone]];
        [copy setIsUserTypePage:self.isUserTypePage];
        [copy setIsOnline:self.isOnline];
        [copy setShowSoberDate:self.showSoberDate];
        
    }
    return copy;
}
- (void)logout{
    [SGGroup deleteAllGroups];
    [Localytics tagEvent:LLUserLogout];
    appDelegate.notificationBadge = 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self deleteAllCachePhotoes];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _struserId              =   nil;
    _strthumbUrl            =   nil;
    _strProfilePic          =   nil;
    _strProfilePicThumb     =   nil;
    _strName                =   nil;
    _strEmailid             =   nil;
    _birthDate              =   nil;
   // _arrfellowShipType      =   nil;
    _strisAvailbeToGiveRide =   nil;
    _arrSeekingType         =   nil;
    _strLookingToMeetUP     =   nil;
    _strGender              =   nil;
    _strOrientation         =   nil;
    _strRelStatus           =   nil;
    _strCity                =   nil;
    _arrPics                =   nil;
    _strDistance            =   nil;
    _isFav                  = false;
    _isBlocked              = false;
    _isStealthModeEnable    = false;
    _dateSoberity           = nil;
    _dateLastSeen           = nil;
    _isUserTypePage         = false;
    _isOnline               = false;
    _showSoberDate          = false;
      if ([FBSession activeSession].isOpen) {
          [FBSession.activeSession closeAndClearTokenInformation];
          [FBSession.activeSession close];
          [FBSession setActiveSession:nil];
    }
   
    [[DatabaseManager sharedInstance] clearTableData];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"unreadmessages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //  [[SGXMPP sharedInstance] fetchRoseter];
    [[SGXMPP sharedInstance] disconnect];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
}
- (void)deleteAllCachePhotoes{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strTempDirectoryPath = [paths objectAtIndex:0];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:strTempDirectoryPath error:nil];
    
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH[cd] '.png'"];

    NSArray *onlyJPGs = [dirContents filteredArrayUsingPredicate:fltr];
    NSError *error = nil;
    for (NSString *path in onlyJPGs) {
        NSString *fullPath = [strTempDirectoryPath stringByAppendingPathComponent:path];
        BOOL removeSuccess = [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
        if (!removeSuccess) {
            // Error handling
            NSLog(@"Error %@",error.localizedDescription);
        }
    }
}

#pragma mark - UPDATE USER
- (void)updateToServerwithCompletionBlock:(UserUpdateCompletionHandler)completion{
    if (_completionblock) {
        _completionblock = nil;
    }
    _completionblock = completion;
    //userid,user_name,user_gender,user_email,user_password,user_fbid,user_fbtoken,user_age,user_birthdate,user_city,user_orientation,user_relationship_status,user_fellowship,user_seeking,user_body_type,user_available_meeting,user_sobriety_date,user_sponsoring,user_about_me,user_Premium,user_latitude,user_longitude,user_burning_desire,user_need_a_ride,user_device_platform,user_ethnicity
    // http://180.211.99.162/rs/sobergrid/API/edituser
    
    //  ApiClass *aClass=[ApiClass sharedClass];
    //  aClass.delegate = self;
    
    NSMutableDictionary *dictUser=[[NSMutableDictionary alloc]init];
    (_struserId) ? [dictUser setObject:_struserId forKey:@"userid"]: NSLog(@"");
    
    (_strName) ? [dictUser setObject:_strName forKey:@"user_name"]:NSLog(@"");
    (_strGender) ? [dictUser setObject:_strGender forKey:@"user_gender"]:NSLog(@"");
    // (_strEmailid) ? [dictUser setObject:_strEmailid forKey:@"user_email"]:NSLog(@"");
    // Birthdate need to be converted in string format
    if (_birthDate) {
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        [inputFormatter setDateFormat:@"dd-MM-yyyy"];
        [dictUser setObject:[inputFormatter stringFromDate:_birthDate] forKey:@"user_birthdate"];
    }
    if (_dateSoberity) {
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        [inputFormatter setDateFormat:@"dd-MM-yyyy"];
        [dictUser setObject:[inputFormatter stringFromDate:_dateSoberity] forKey:@"sobriety_date"];
    }
    
    (_strOrientation) ? [dictUser setObject:_strOrientation forKey:@"user_orientation"]:NSLog(@"");
    (_strRelStatus) ? [dictUser setObject:_strRelStatus forKey:@"user_relationship_status"]:NSLog(@"");
  //  (_arrfellowShipType) ? [dictUser setObject:_arrfellowShipType forKey:@"user_fellowship"]:NSLog(@"");
    (_arrSeekingType.count > 0) ? [dictUser setObject:_arrSeekingType forKey:@"user_seeking"]:NSLog(@"");
    (_strisAvailbeToGiveRide) ? [dictUser setObject:_strisAvailbeToGiveRide forKey:@"available_ride"]:NSLog(@"");
    (_strLookingToMeetUP) ? [dictUser setObject:_strLookingToMeetUP forKey:@"user_available_meeting"]:NSLog(@"");
    (_strCity) ? [dictUser setObject:_strCity forKey:@"user_city"]:NSLog(@"");
    
    //NSString *strAbout = _strAboutMe;
    //strAbout = [strAbout stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
    //_strAboutMe=strAbout;
    
    (_strAboutMe) ? [dictUser setObject:_strAboutMe forKey:@"user_about_me"] : NSLog(@"");
    
    [dictUser setObject:[NSString stringWithFormat:@"%d",_showSoberDate] forKey:@"showSoberDate"];
    [dictUser setObject:@"0" forKey:@"user_device_platform"];
    
    NSString *strUser=[dictUser JSONRepresentation];
    dictUser = nil;

    CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@edituser",baseUrl()] andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"key": strUser} options:NSJSONWritingPrettyPrinted error:nil]];
    
    // [aClass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@edituser",baseUrl()]] withPostParameters:@{@"key": strUser} withRequestMethod:POST];
    strUser = nil;
}
- (void)setInviteFriendsBool:(BOOL)status{
    [[NSUserDefaults standardUserDefaults] setBool:status forKey:@"invitefrds"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)inviteProcessDone{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"invitefrds"];
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    if ([requestedURL rangeOfString:@"edituser"].location != NSNotFound) {
        NSDictionary *dicTemp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        dicTemp = [dicTemp dictionaryByReplacingNullsWithBlanks];
        if ([dicTemp isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response=(NSDictionary*)dicTemp;
            if ([[response objectForKey:@"Type"]isEqualToString:@"OK"]) {
                [self saveUser:[[response objectForKey:@"Responce"] objectForKey:@"User"]];
                if(_completionblock){
                    _completionblock (true , nil);
                    _completionblock = nil;
                }
            }else{
                if(_completionblock){
                    _completionblock (false , [response objectForKey:@"Error"]);
                    _completionblock = nil;
                }
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[response objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
    
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    if ([requestedURL rangeOfString:@"edituser"].location != NSNotFound) {
        if(_completionblock){
            
            _completionblock (false , error);
            _completionblock = nil;
        }
    }
}
- (void)returnData:(id)data forUrl:(NSURL *)url withTag:(int)tag{
    if ([url.absoluteString rangeOfString:@"edituser"].location != NSNotFound) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response=(NSDictionary*)data;
            if ([[response objectForKey:@"Type"]isEqualToString:@"OK"]) {
                [self saveUser:[[response objectForKey:@"Responce"] objectForKey:@"User"]];
                if(_completionblock){
                    _completionblock (true , nil);
                    _completionblock = nil;
                }
            }else{
                if(_completionblock){
                    _completionblock (false , [response objectForKey:@"Error"]);
                    _completionblock = nil;
                }
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[response objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
    
}
- (void)failedData:(NSError *)error forUrl:(NSURL *)url withTag:(int)tag{
    if ([url.absoluteString rangeOfString:@"edituser"].location != NSNotFound) {
        if(_completionblock){
            
            _completionblock (false , error.localizedDescription);
            _completionblock = nil;
        }
    }
}



@end
