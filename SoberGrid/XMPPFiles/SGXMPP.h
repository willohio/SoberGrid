//
//  DemoXMPP.h
//  XMPPDemo
//
//  Created by agilepc-38 on 12/31/13.
//  Copyright (c) 2013 agilepc-38. All rights reserved.
//


typedef void (^SGXMMFetchHistoryComletionHaldler)(NSArray *arrHistory);

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPMessage+XEP0045.h"
#import "XMPPCoreDataStorage.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "JSON.h"
#import "NSXMLElement+XEP_0203.h"
#import "XMPPPubSub.h"
#import "XMPPModule.h"
#import "User.h"
#import "CommonApiCall.h"
#import "MEAlertView.h"
#import "MPGNotification.h"

@protocol SGXMPPDelegate <NSObject>

@optional

- (void)didReceiveMessage:(XMPPMessage*)message From:(NSString*)user ofType:(int)type;
- (void)groupCreated;
- (void)groupLeaved;

@end

@interface SGXMPP : NSObject <XMPPRosterDelegate,XMPPStreamDelegate,XMPPRoomDelegate,XMPPMUCDelegate,XMPPRoomDelegate,XMPPPubSubDelegate,CommonApiCallDelegate,ApiclassDelegate,XMPPPrivacyDelegate,UIAlertViewDelegate>
{
    XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    XMPPRoom*   xmppRoom;
    
    // for Archive
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
    XMPPMessageArchiving                *xmppMessageArchivingModule;
    XMPPPrivacy                         *    xmppPrivacy;
    
    NSOutputStream *outputStream;
    
    BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
    
    NSString *password;
    int currentChat_id;
    
    NSString *strGroupName;
    
    XMPPRoomCoreDataStorage * rosterstorage;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingStorage;
    NSMutableArray *arrMessagesOnly;
    
    dispatch_queue_t subscribeQueue;

    
}
@property (nonatomic,copy)SGXMMFetchHistoryComletionHaldler completionblock;

@property (nonatomic,copy)User *otherUser;
@property (assign)BOOL groupOwner;
@property (nonatomic,strong)NSMutableArray *arrMessages;
@property (assign)id<SGXMPPDelegate>delegate;
@property (nonatomic, retain) NSMutableArray *penddingMessages;
@property int currentChat_id;
// Roster
@property (nonatomic,strong)NSMutableArray *arrRostermemebers;

- (void)emptyRoster;
//chat

@property (nonatomic,retain) NSMutableArray *rosterUsers;
@property (nonatomic, retain) NSMutableDictionary *dictallUserPresence;

// XMPP Objects ---
@property (nonatomic,strong , readonly) XMPPPubSub *xmppPubsub;
@property (nonatomic,strong , readonly) XMPPModule *xmppModule;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong)NSMutableArray *arrHistMessages;




+(SGXMPP *)sharedInstance;
- (BOOL)connect;
- (void)disconnect;
- (void)setupStream;

- (void)blockUser:(User*)user;
- (void)unblockUser:(User *)objUser;
- (BOOL)isBlockUser:(User*)objUser;
-(void)createGroup:(NSString *)groupName UserType:(NSString *)userrole;
-(BOOL)sendMessage:(NSString*)toUser Groupname:(NSString*)groupname Message:(NSString*)message isPhoto:(BOOL)status photo:(UIImage*)image;
-(void)deleteHistoryWithUserId:(NSString*)userid withCompletionHandler:(SGXMMFetchHistoryComletionHaldler)completion;

-(void)fetchHistoryWithUserId:(NSString*)userid withLimit:(int)limit ascending:(BOOL)status withCompletionHandler:(SGXMMFetchHistoryComletionHaldler)completion;

- (void)fetchHistoryProgramatically;
- (void)subScribeToJabberIdforUserid:(NSString*)userid;
- (int)getUnreadMessagesCountForUserid:(NSString*)userid;
- (BOOL)isUnReadMessageForUserid:(NSString*)userid;
- (void)allMessagesReadForUserid:(NSString*)userid;
- (int)getAllUnreadMessages;
- (void)subscribePresenceForUsers:(NSArray*)arr;
- (void)fetchRoseter;
@property (assign)BOOL isNewUser;
@end
