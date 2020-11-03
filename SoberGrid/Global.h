//
//  Global.h
//  SoberGrid
//
//  Created by Binty Shah on 9/8/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#ifndef SoberGrid_Global_h
#define SoberGrid_Global_h
// Null checking
@interface NSDictionary (NullReplacement)

- (NSDictionary *)dictionaryByReplacingNullsWithBlanks;

@end

@interface NSArray (NullReplacement)

- (NSArray *)arrayByReplacingNullsWithBlanks;

@end

@implementation NSDictionary (NullReplacement)

- (NSDictionary *)dictionaryByReplacingNullsWithBlanks {
    const NSMutableDictionary *replaced = [self mutableCopy];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    
    for (NSString *key in self) {
        id object = [self objectForKey:key];
        if (object == nul) [replaced setObject:blank forKey:key];
        else if ([object isKindOfClass:[NSDictionary class]]) [replaced setObject:[object dictionaryByReplacingNullsWithBlanks] forKey:key];
        else if ([object isKindOfClass:[NSArray class]]) [replaced setObject:[object arrayByReplacingNullsWithBlanks] forKey:key];
    }
    return [NSMutableDictionary dictionaryWithDictionary:[replaced copy]];
}

@end

@implementation NSArray (NullReplacement)

- (NSArray *)arrayByReplacingNullsWithBlanks  {
    NSMutableArray *replaced = [self mutableCopy];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    for (int idx = 0; idx < [replaced count]; idx++) {
        id object = [replaced objectAtIndex:idx];
        if (object == nul) [replaced replaceObjectAtIndex:idx withObject:blank];
        else if ([object isKindOfClass:[NSDictionary class]]) [replaced replaceObjectAtIndex:idx withObject:[object dictionaryByReplacingNullsWithBlanks]];
        else if ([object isKindOfClass:[NSArray class]]) [replaced replaceObjectAtIndex:idx withObject:[object arrayByReplacingNullsWithBlanks]];
    }
    return [replaced copy];
}

@end

//////////// Import Header Files ////////////
#import "AppDelegate.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "UIViewController+JASidePanel.h"
//#import "JASidePanelController.h"
#import "UIImage+Additions.h"
#import "SGNavigationController.h"
#import "Localytics.h"

//////////// Import Framework ////////////
#import <QuartzCore/QuartzCore.h>

//////////// Add Class Files ////////////
@class SGNavigationController;
@class AppDelegate;
@class ASIFormDataRequest;
@class ASIHTTPRequest;

//////////// Define the Global Variable ////////////

#define appDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
//#define sharedDelegate ((SharedDelegate *)[[UIApplication sharedApplication] delegate])

#define POST    @"POST"
#define GET     @"GET"


#define DEVICE_TOKEN @"devicetoken"
static inline NSString *serverBase(){
   // return @"180.211.99.162";
    return @"chat.sobergrid.co.uk";
}

static inline NSString *XMPPDomain(){
    //return @"180.211.99.162";
    return @"166.62.41.207";
    // return @"app.sobergrid.co.uk";
}

static inline NSString* baseUrl()
{
    // for Live
    NSString * url = @"http://app.sobergrid.co.uk/API/";
   // NSString * url = @"http://180.211.99.162/rs/sobergrid/API/";
    NSString *currentVersion;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"version"]) {
        currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
    }else{
            currentVersion = @"v3";
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"version"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSString *strBaseUrl = [NSString stringWithFormat:@"%@%@/",url,currentVersion];
    // for Test
    return strBaseUrl;
}
#define IS_IPHONE (!IS_IPAD)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
#define IS_IPHONE5          ([[UIScreen mainScreen] bounds].size.height == 568)?YES:NO
//#define IS_IPHONE           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)?YES:NO
//#define IS_IPAD             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?YES:NO

#define DeviceType          ((IS_IPAD)?@"IPAD":(IS_IPHONE5)?@"IPHONE 5":@"IPHONE")
#define LanguateTuype

static inline UIStoryboard* SGstoryBoard()
{
    UIStoryboard *storyBoard;
    if(IS_IPAD)
    {
        // Load IPAD StoryBoard
        return storyBoard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
    }
    
    return storyBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
}

// Get images
static inline NSString *imageNameRefToDevice(NSString *str){
    return (IS_IPAD) ? [str stringByAppendingString:@"_iPad"]:str;
}

static inline NSString *createurlFor(NSString *str){
    return [NSString stringWithFormat:@"%@%@",baseUrl(),str];
}


#define RGB(x,y,z,a) [UIColor colorWithRed:x/255.f green:y/255.f blue:z/255.f alpha:a]





#define RESPONSE    @"Responce"
#define ERROR       @"Error"
#define RESPONSE_OK @"OK"
#define TYPE        @"Type"


#define NOTIFICATION_PROFILE_PIC_DELETED @"profilepicdeleted"
#define NOTIFICATION_NEW_MESSAGE_RECEIVED @"newmessagereceived"
#define NOTIFICATIN_RECEIVED_PRESENCE_REPORT @"presencereportreceieved"
#define NOTIFICATION_MOVETOMEMBEROPTION      @"movetomemberoptions"
#define NOTIFICATION_MOVETONEWSFEEDSCREEN @"movetonewsfeedscreen"
#define NOTIFICATION_GOLDBADGE_PURCHASED     @"goldbadgepurchased"
#define NOTIFICATIN_NEWUSERLOGGEDIN          @"newuserloggedin"
#define NOTIFICATION_PREMIUMMEMBER_PURCHASED @"premiummemberpurchased"
#define NOTIFICATION_STARTCHAT              @"startChatwithUser"
#define NOTIFICATION_LINKTAPPED             @"linktapped"
#define NOTIFICATION_HASHTAGTAPPED             @"hashTagtapped"
#define NOTIFICATION_HANDLETAPPED             @"handletapped"
#define NOTIFICATION_GOTNEWUNREADMESSAGE        @"gotnewunreadmessage"
#define NOTIFICATION_BADGECHANGED       @"badgechanged"
#define NOTIFICATION_NEWPUSH    @"NOTIFICATION_NEWPUSH"

#define I_PAD_PERCENTAGE 125

#define SGREGULARFONT(_size_) ((UIFont *)[UIFont fontWithName:@"MavenProRegular" size:(CGFloat)(_size_)])
#define SGBOLDFONT(_size_) ((UIFont *)[UIFont fontWithName:@"MavenProBold" size:(CGFloat)(_size_)])

#define SG_LINE_COLOR [UIColor colorWithRed:211.0/255.0 green:206.0/255.0 blue:203.0/255.0 alpha:1.0]

#define SG_BACKGROUD_COLOR [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]

#define SG_BACKGROUD_COLOR_REC [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0]
#define SG_BACKGROUD_COLOR_SEND [UIColor colorWithRed:219.0/255.0 green:224.0/255.0 blue:255.0/255.0 alpha:1.0]

#define kSoberGridBadgeIdentifier   @"com.sobergrid.sobergrid_Badge"
#define kSoberGrid1MonthIdentifier  @"com.sobergrid.sobergrid.1month"
#define kSoberGrid3MonthIdentifier  @"com.sobergrid.sobergrid.3month"
#define kSoberGrid12MonthIdentifier @"com.sobergrid.sobergrid.12month"

#define kKeyVersion @"version_iOS"
#define kKeyApiUrl @"api_url"


// Events for Localytics
#define LLAppLunch @"app launched"
#define LLAppInBackground @"app in background"
#define LLUserDidLogin @"user loggedin"
#define LLUserLogout @"user logout"
#define LLUserInSGCalculator @"user in sobriety calculator screen"
#define LLUserInGridScreen @"user in grid screen"
#define LLUserInNewsFeedScreen @"user in newsfeed screen"
#define LLUserInProfileScreen @"user in profile screen"
#define LLUserInMessageScreen @"user in message screen"
#define LLUserInInviteFriendScreen @"user in invite friends screen"
#define LLUserInVisitorScreen @"user in visitors screen"
#define LLUserInSupportingBadgeScreen @"user in supporting badge screen"
#define LLUserInPremiumScreen @"user in premium screen"
#define LLUserInFavouriteScreen @"user in favourite screen"
#define LLUserInBlockScreen @"user in block screen"
#define LLUserInStealthModeScreen @"user in stealth mode screen"
#define LLUserInFAQScreen @"user in FAQ screen"
#define LLUserInContactUsScreen @"user in contact us screen"
#define LLUserInChatScreen @"user in chat screen"

typedef enum {
    kSGNewsFeedTypeStatus = 0,
    kSGNewsFeedTypePhoto,
    kSGNewsFeedTypeVideo,
    kSGNewsFeedTypePage,
}kSGNewsFeedType;

typedef enum {
    kSGSubscriptionTypeNone = 0,
    kSGSubscriptionType1Month = 1,
    kSGSubscriptionType3Month = 3,
    kSGSubscriptionType12Month = 12,
}kSGSubscriptionType;

#define SGSubscriptionPack  @"SGSubscriptionPack"

#define LIMIT_CHARACTER 5000

// Predefined profile limits
#define No_Of_SeekingTypes 3

#endif
