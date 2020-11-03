//
//  DemoXMPP.m
//  XMPPDemo
//
//  Created by Haresh Kalyani on 12/31/13.
//  Copyright (c) 2013 agilepc-38. All rights reserved.
//



#define PORT_NO   5222
#define PASSWORD  @"T865pG9w"


#import "SGXMPP.h"
#import "DDLog.h"
#import "DDAbstractDatabaseLogger.h"
#import "DDTTYLogger.h"
#import "JSON.h"
//#import "NSObject+XMPPMessage.h"
#import "NSXMLElement+XEP_0059.h"
#import "XMPPResultSet.h"
#import "XMPPPubSub.h"
#import "User.h"
#import "NSString+Utilities.h"
#import "DatabaseManager.h"
#import "XMPPMessage+XMPPMessageHelper.h"
#import "XHDemoWeChatMessageTableViewController.h"
#import "XMPPMessage+XEP_0333.h"
#import "NetworkListioner.h"
#import "NSDate+Utilities.h"

@interface SGXMPP()
- (void)setupStream;
- (void)goOnline;
- (void)goOffline;
@end
@implementation SGXMPP
@synthesize xmppCapabilities,xmppCapabilitiesStorage,xmppModule,xmppPubsub,xmppReconnect,xmppRoster,xmppRosterStorage,xmppStream,xmppvCardAvatarModule,xmppvCardTempModule,currentChat_id;

// Write this in AppDelegate.m
static SGXMPP *shared = nil;

+ (SGXMPP *)sharedInstance {
    @synchronized ([SGXMPP class]) {
        if (!shared) {
            shared = [[self alloc] init];
            //   [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(disconnect) name:UIApplicationWillResignActiveNotification object:Nil];
            //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connect) name:UIApplicationDidBecomeActiveNotification object:Nil];
        }
        
        return shared;
    }
}
- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[xmppStream sendElement:presence];

}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[xmppStream sendElement:presence];
    NSLog(@"OFFLINE");
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
    
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    subscribeQueue = dispatch_queue_create("subscirbeQueue", 0);

	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		// xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	xmppRosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
    	//xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];

	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
    [xmppStream setHostName:serverBase()];
    [xmppStream setHostPort:PORT_NO];
	
    
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
    
    // xmppmodule
    xmppModule = [[XMPPModule alloc] init];
    [xmppModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppModule activate:xmppStream];
    
    XMPPJID *serviceJID =
    [XMPPJID jidWithString:[NSString stringWithFormat:@"pubsub.%@", XMPPDomain()]];
    xmppPubsub = [[XMPPPubSub alloc]initWithServiceJID:serviceJID dispatchQueue:dispatch_get_main_queue()];
    [xmppPubsub activate:xmppStream];
    [xmppPubsub addDelegate:self delegateQueue:dispatch_get_main_queue()];
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    [xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMessageArchivingModule activate:xmppStream];
    
    xmppPrivacy = [[XMPPPrivacy alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    //Activate xmpp modules
    [xmppPrivacy activate:xmppStream];
    //Delegate XMPPPrivacy
    [xmppPrivacy addDelegate:self delegateQueue:dispatch_get_main_queue()];
    xmppPrivacy.autoRetrievePrivacyListItems = true;
    
    
}

- (BOOL)connect
{
    [self setupStream];

    NSString *jid = [NSString stringWithFormat:@"%@_sobergrid@%@", [User currentUser].struserId, XMPPDomain()];
    NSLog(@"Jid = %@",jid);
    
    [xmppStream setMyJID:[XMPPJID jidWithString:jid]];
	password = PASSWORD;
	NSError *error = nil;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
		return NO;
	}
	return YES;
}

- (void)disconnect
{
	[self goOffline];
	[xmppStream disconnect];
   // [self emptyRoster];
    [self teardownStream];
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	//DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    /*DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
     
     // The delegate method should likely have code similar to this,
     // but will presumably perform some extra security code stuff.
     // For example, allowing a specific self-signed certificate that is known to the app.
     allowSelfSignedCertificates = YES;
     allowSSLHostNameMismatch = NO;
     dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_async(bgQueue, ^{
     
     SecTrustResultType result = kSecTrustResultDeny;
     OSStatus status = SecTrustEvaluate(trust, &result);
     
     if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
     completionHandler(YES);
     }
     else {
     completionHandler(NO);
     }
     
     });
     */
    completionHandler(YES);
    
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	//DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	//DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    
	//DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
    
	if (![[self xmppStream] authenticateWithPassword:PASSWORD error:&error])
	{
		//DDLogError(@"Error authenticating: %@", error);
	}
    else{
        // [self callAlert:@"Connected with XMPP"];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	//DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
  //  [xmppPubsub createNode:@"TestNode"];
 //
	[self goOnline];
    
    [xmppPrivacy retrieveListWithName:@"block"];
    
    
    //    if([delegate respondsToSelector:@selector(newUserRegister)]){
    //        [delegate newUserRegister];
    //    }
}
- (void)subScribeNewUser{
    
    //[xmppPubsub subscribeToNode:@"helloGroup"];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	//DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
     NSError * err = nil;
    
    if(![xmppStream registerWithPassword:PASSWORD error:&err])
    {
       // NSLog(@"Error registering: %@", err);
    }
}
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    _isNewUser = true;
    NSError *error;
    if (![self.xmppStream authenticateWithPassword:password error:&error])
    {
      //  NSLog(@"error authenticate : %@",error.description);
    }
    else
    {
        // Setup Server Side Message Archive
        XMPPIQ *iq = [[XMPPIQ alloc] initWithType:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"auto1"];
        NSXMLElement *query = [NSXMLElement elementWithName:@"auto" xmlns:@"urn:xmpp:archive"];
        [query addAttributeWithName:@"save" stringValue:@"true"];
        [iq addChild:query];
        [[self xmppStream] sendElement:iq];
    }
    //    if([delegate respondsToSelector:@selector(userDidRegister)])
    //        [delegate userDidRegister];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement*)error{
    [self teardownStream];
    [self performSelector:@selector(connect) withObject:nil afterDelay:2];
   
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    
    NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
    
    if (queryElement) {
        NSArray *itemElements = [queryElement elementsForName: @"item"];
        if (_arrRostermemebers) {
            [_arrRostermemebers addObjectsFromArray:itemElements];
        }else{
            _arrRostermemebers = [[NSMutableArray alloc] initWithArray:itemElements];
        }
    }
  //	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
   NSXMLElement *queryElementChatBody = [iq elementForName:@"list" xmlns:@"urn:xmpp:archive"];
    NSXMLElement *queryElementMessage = [iq elementForName:@"chat" xmlns:@"urn:xmpp:archive"];
    
    
    if (queryElementChatBody) {
        NSArray *itemElements = [queryElementChatBody elementsForName: @"chat"];
        for (int i=0; i<[itemElements count]; i++) {
            
            NSString *startTime=[[[itemElements objectAtIndex:i] attributeForName:@"start"] stringValue];
           // [self fetchHistoryStartingFromDate:startTime];
        }
 
    }
    if (queryElementMessage) {
        NSArray *itemElements = [queryElementMessage elementsForName: @"to"];
        NSString *with=[[queryElementMessage attributeForName:@"with"] stringValue];
        for (int i=0; i<[itemElements count]; i++) {
            NSXMLElement *recmessage=[itemElements objectAtIndex:i];
            NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
            [body setStringValue:[[recmessage attributeForName:@"body"]stringValue]];
            
            NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
            [message addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@",[[User currentUser].struserId userIdAddedSoberGrid], XMPPDomain()]];
            [message addAttributeWithName:@"type" stringValue:@"chat"];
            [message addAttributeWithName:@"to" stringValue:with];
            [message addChild:body];

            
//            XMPPMessage *finalmessage=[XMPPMessage messageFromElement:message];
//            
//            NSString *startTime=[[[itemElements objectAtIndex:i] attributeForName:@"start"] stringValue];
        }
    }
    
	return YES;
}
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if ([message isErrorMessage]) {
        return;
    }
//    [message generateReceiptResponse];
//    [message generateReceivedChatMarker];
//    [message addReceivedChatMarkerWithID:[[message sender] userIdByRemovingSoberGrid]];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        // Call local
        [self callLocalNotificationFormessage:message];
        return;
    }
    if (_delegate) {
        if([_delegate isKindOfClass:[XHDemoWeChatMessageTableViewController class]]){
            XHDemoWeChatMessageTableViewController *wechatVC=(XHDemoWeChatMessageTableViewController*)_delegate;
            if ([wechatVC.otherSideUser.struserId isEqualToString:[[message sender] userIdByRemovingSoberGrid]]) {
                if ([_delegate respondsToSelector:@selector(didReceiveMessage:From:ofType:) ]) {
                    [_delegate didReceiveMessage:message From:[message sender] ofType:[message sendertype]];
                }
            }else{
                [self callLocalNotificationFormessage:message];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEW_MESSAGE_RECEIVED object:[[message sender] userIdByRemovingSoberGrid]];
            }
        }
        
    }else{
        [self callLocalNotificationFormessage:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEW_MESSAGE_RECEIVED object:[[message sender] userIdByRemovingSoberGrid]];
    }
    
    

}
- (void)callLocalNotificationFormessage:(XMPPMessage*)message{
    NSDictionary *dictTemp=[[message getmessage] JSONValue];
    NSString *sender;
    if ([dictTemp objectForKey:@"sender"]) {
        sender = dictTemp[@"sender"];
    }else
        sender = [message sender];

    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    notification.alertBody = [NSString stringWithFormat:@"%@ sent you message",sender];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    [self showNotificationwithTitle:sender withIconUrl:nil withSubtitle:[message getMessageFormattedString] withObject:[[message sender] userIdByRemovingSoberGrid]];
    
//    MEAlertView *alertView=[[MEAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ sent you message",sender] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"View", nil];
//    alertView.Object = [[message sender] userIdByRemovingSoberGrid];
//    [alertView show];

    [self saveUnreadMessage:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GOTNEWUNREADMESSAGE object:nil];
}
- (void)showNotificationwithTitle:(NSString*)title withIconUrl:(NSString*)iconUrl withSubtitle:(NSString*)subtitle withObject:(id)object;
{
    NSArray *buttonArray = [NSArray arrayWithObjects:@"Reply",@"Later", nil];
    if([_delegate isKindOfClass:[XHDemoWeChatMessageTableViewController class]]){
        buttonArray = nil;
    }
    
    appDelegate.notification = [MPGNotification notificationWithTitle:title subtitle:subtitle backgroundColor:[UIColor clearColor] iconImage:[UIImage imageNamed:@"contacts_add_newmessage"] withObject:object];
   // [appDelegate.notification setButtonConfiguration:buttonArray.count withButtonTitles:buttonArray];
    appDelegate.notification.duration = 3.0;
    [appDelegate.notification setTitleColor:[UIColor whiteColor]];
    [appDelegate.notification setSubtitleColor:[UIColor whiteColor]];
    appDelegate.notification.swipeToDismissEnabled = NO;
    [appDelegate.notification setAnimationType:MPGNotificationAnimationTypeLinear];
    [appDelegate.notification show];
    
    __block SGXMPP *blockSafeSelf = self;
    
    [appDelegate.notification setButtonHandler:^(MPGNotification *notification, NSInteger buttonIndex){
        CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@get_user_details",baseUrl()] andDelegate:blockSafeSelf];
        [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": object,@"myuserid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return;
    }
    if (buttonIndex == 1) {
        
        MEAlertView *alert=(MEAlertView*)alertView;
        
        if (_delegate) {
            if([_delegate isKindOfClass:[XHDemoWeChatMessageTableViewController class]]){
                XHDemoWeChatMessageTableViewController *wechatVC=(XHDemoWeChatMessageTableViewController*)_delegate;
                if ([wechatVC.otherSideUser.struserId isEqualToString:alert.Object]) {
                    return;
                }
            }
            
        }
        CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@get_user_details",baseUrl()] andDelegate:self];
        [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": alert.Object,@"myuserid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
    }
}
- (void)saveUnreadMessage:(XMPPMessage*)message{
    NSDictionary *dictUnreadMessages = [[NSUserDefaults standardUserDefaults]objectForKey:@"unreadmessages"];
    if (dictUnreadMessages) {
        NSMutableDictionary *dictModifiedDict=[dictUnreadMessages mutableCopy];
        if ([dictModifiedDict objectForKey:[message sender]]) {
            int count = [[dictModifiedDict objectForKey:[message sender]] intValue] + 1;
            [dictModifiedDict setObject:[NSString stringWithFormat:@"%d",count] forKey:[message sender]];
        }else{
            [dictModifiedDict setObject:@"1" forKey:[message sender]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:dictModifiedDict forKey:@"unreadmessages"];
        dictModifiedDict = nil;
        
    }else{
        NSMutableDictionary *dictUmessages=[[NSMutableDictionary alloc] init];
        [dictUmessages setObject:@"1" forKey:[message sender]];
        [[NSUserDefaults standardUserDefaults] setObject:dictUmessages forKey:@"unreadmessages"];
        dictUmessages = nil;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (int)getUnreadMessagesCountForUserid:(NSString*)userid{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"unreadmessages"]) {
        NSDictionary *dictTemp = [[NSUserDefaults standardUserDefaults]objectForKey:@"unreadmessages"];
        if ([dictTemp objectForKey:[userid userIdAddedSoberGrid]]) {
            return [[dictTemp objectForKey:[userid userIdAddedSoberGrid]] intValue];
        }else
            return 0;
    }else
        return 0;
}


- (int)reduceUnreadMessages:(NSString *)senderid{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"unreadmessages"]) {
        NSDictionary *dictTemp = [[NSUserDefaults standardUserDefaults]objectForKey:@"unreadmessages"];
        int messageCounts = 0;
        NSArray *allUsers=[dictTemp allKeys];
        for (NSString *strUserid in allUsers) {
            messageCounts =  [[dictTemp objectForKey:strUserid] intValue]-1;
            if (messageCounts<0) {
                messageCounts=0;
            }
        }
        NSMutableDictionary *dictUmessages=[[NSMutableDictionary alloc] init];

        [dictUmessages setObject:[NSString stringWithFormat:@"%d",messageCounts] forKey:[senderid userIdAddedSoberGrid]];
        [[NSUserDefaults standardUserDefaults] setObject:dictUmessages forKey:@"unreadmessages"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GOTNEWUNREADMESSAGE object:nil];

        return messageCounts;
    }else
        return 0;
}

- (int)getAllUnreadMessages{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"unreadmessages"]) {
        NSDictionary *dictTemp = [[NSUserDefaults standardUserDefaults]objectForKey:@"unreadmessages"];
        int messageCounts = 0;
        NSArray *allUsers=[dictTemp allKeys];
        for (NSString *strUserid in allUsers) {
            messageCounts = messageCounts + [[dictTemp objectForKey:strUserid] intValue];
        }
        return messageCounts;
    }else
        return 0;
}
- (BOOL)isUnReadMessageForUserid:(NSString*)userid{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"unreadmessages"]) {
        NSDictionary *dictTemp = [[NSUserDefaults standardUserDefaults]objectForKey:@"unreadmessages"];
        if ([dictTemp objectForKey:userid]) {
            return YES;
        }
    }
    return NO;
}
- (void)allMessagesReadForUserid:(NSString*)userid{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"unreadmessages"]) {
        NSDictionary *dictTemp = [[NSUserDefaults standardUserDefaults]objectForKey:@"unreadmessages"];
        if ([dictTemp objectForKey:[userid userIdAddedSoberGrid]]) {
            NSMutableDictionary *dictTempMutable = [dictTemp mutableCopy];
            [dictTempMutable removeObjectForKey:[userid userIdAddedSoberGrid]];
            [[NSUserDefaults standardUserDefaults] setObject:dictTempMutable forKey:@"unreadmessages"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dictTempMutable = nil;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GOTNEWUNREADMESSAGE object:nil];
}
- (void)saveMessagesIfChateroomisNotOpenwithMessage:(NSString*)msg From:
(NSString*)user withSendingDate:(NSDate*)date{
    
    if ([arrMessagesOnly containsObject:msg]) {
        return;
    }else
        [arrMessagesOnly addObject:msg];
   
    NSString *strDate;
    NSDate *now1;
     NSMutableDictionary *dict=[[msg JSONValue] mutableCopy];
    if (date) {
       now1 = date;
    }else{
        int timeStamp = [[dict objectForKey:@"time"]intValue];
        now1 = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    }
    
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    if ([now1 isTodayDate]) {
        dateFormatter1.dateFormat = @"hh:mm a";
    }else
        dateFormatter1.dateFormat = @"yyyy-MM-dd hh:mm a";
    
    [dateFormatter1 setTimeZone:[NSTimeZone systemTimeZone]];
    strDate = [NSString stringWithFormat:@"%@",[dateFormatter1 stringFromDate:now1]];
    [dict setObject:strDate forKey:@"receivedtime"];
    
    
    if ([[user lowercaseString] isEqualToString:[[NSString stringWithFormat:@"%@_UH",[User currentUser].struserId] lowercaseString]]) {
        
       // [_arrMessages addObject:[Message messageWithString:[dict JSONRepresentation] image:[UIImage imageNamed:@""]type:1]];
        
    }else{

      //  [_arrMessages addObject:[Message messageWithString:[dict JSONRepresentation] image:[UIImage imageNamed:@""]type:2]];
        
    }
    
}
- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}
- (void)emptyRoster{
    dispatch_async(subscribeQueue, ^{

    for (int i = 0; i<_arrRostermemebers.count; i++) {
        NSString *jid=[[[_arrRostermemebers objectAtIndex:i] attributeForName:@"jid"] stringValue];
        [xmppRoster removeUser:[XMPPJID jidWithString:jid]];
    }
        [_arrRostermemebers removeAllObjects];
        _arrRostermemebers = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self teardownStream];
        });
        
    });
}
- (void)getRosterList{
    NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
    
    NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
    [iqStanza addAttributeWithName: @"type" stringValue: @"get"];
    [iqStanza addChild: queryElement];
    
    [xmppStream sendElement: iqStanza];
}
- (void)unblockUser:(User *)objUser
{
    NSString *jid = [NSString stringWithFormat:@"%@@%@",[objUser.struserId userIdAddedSoberGrid],XMPPDomain()];
    if (xmppPrivacy == nil) return;
    
    NSString *listName = @"block";
    
    NSArray *existingItems = [xmppPrivacy listWithName:listName];
    NSMutableArray *items = [NSMutableArray array];
    int itemCount = existingItems == nil ? 0 : (int)[existingItems count];
    
    if (itemCount > 0) {
        for (NSXMLElement *item in existingItems) {
            NSString *pid = [item attributeForName:@"value"].stringValue;
            if ([jid isEqualToString:pid]) continue;
            
            [items addObject:[item copy]];
        }
    }
    if ([items count] > 0) {
        [xmppPrivacy setListWithName:listName items:items];
    } else {
        [xmppPrivacy setListWithName:listName items:nil]; // THIS LINE
    }
    [xmppPrivacy retrieveListWithName:listName];
}
- (void)blockUser:(User*)user{
    
    // No need of it
    [self privacyBlock:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",[user.struserId userIdAddedSoberGrid],XMPPDomain()]]];
}
- (BOOL)isBlockUser:(User*)objUser{
  //
    BOOL status = false;;
    for (NSXMLElement *xmlElement in [xmppPrivacy listWithName:@"block"]) {
        NSString *userId = [xmlElement attributeStringValueForName:@"value"];
        userId =[userId stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_sobergrid@%@", XMPPDomain()] withString:@""];
        if ([userId isEqualToString:objUser.struserId]) {
            return true;
        }
        
    }
  
    return status;
}
- (void)privacyBlock:(XMPPJID *)jid
{
    NSXMLElement *privacyElement = [XMPPPrivacy privacyItemWithType:@"jid" value:jid.bare action:@"deny" order:1];
    [XMPPPrivacy blockIQs:privacyElement];
    [XMPPPrivacy blockMessages:privacyElement];
    [XMPPPrivacy blockPresenceIn:privacyElement];
    [XMPPPrivacy blockPresenceOut:privacyElement];
    NSArray *arrExistingPrivacyList = [xmppPrivacy listWithName:@"block"];
    NSMutableArray *arrBlockUsers = [[NSMutableArray alloc]init];
    for (id obj in arrExistingPrivacyList) {
        [arrBlockUsers addObject:[obj copy]];
    }
    
    if (arrBlockUsers.count == 0) {
        [arrBlockUsers addObject:privacyElement];
        [xmppPrivacy setListWithName:@"block" items:arrBlockUsers];
        [xmppPrivacy setActiveListName:@"block"];
        [xmppPrivacy setDefaultListName:@"block"];
    }else{
        [arrBlockUsers addObject:privacyElement];
        [xmppPrivacy setListWithName:@"block" items:arrBlockUsers];
    }
    
}
-(NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end MyFullString:(NSString*)fullstring{
    NSScanner* scanner = [NSScanner scannerWithString:fullstring];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}
- (void)xmppPrivacy:(XMPPPrivacy *)sender didNotReceiveListNamesDueToError:(id)error{
    
}
- (void)xmppPrivacy:(XMPPPrivacy *)sender didNotReceiveListWithName:(NSString *)name error:(id)error{
    
}
- (void)xmppPrivacy:(XMPPPrivacy *)sender didNotSetActiveListName:(NSString *)name error:(id)error{
    
}
- (void)xmppPrivacy:(XMPPPrivacy *)sender didReceiveListNames:(NSArray *)listNames{
   NSArray *items =  [xmppPrivacy listWithName:@"block"];
   // NSLog(@"items %@",items);
}
- (void)xmppPrivacy:(XMPPPrivacy *)sender didSetListWithName:(NSString *)name{
    
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	//DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    
    dispatch_async(subscribeQueue, ^{
        NSString *presenceType = [presence type];            // online/offline
        NSString *strType;
        if ([presenceType isEqualToString:@"available"]) {
            strType = @"1";
        }
        else if ([presenceType isEqualToString:@"unavailable"]) {
            strType = @"0";
        }else
            return ;
        
        //        NSString *myUsername = [[sender myJID] user];
        NSString *presenceFromUser = [[presence from] user];
        
        if (presenceFromUser || presenceFromUser.length > 0) {
            [[DatabaseManager sharedInstance]addPresenceReportForUserId:[presenceFromUser userIdByRemovingSoberGrid] withPresenceStatus:strType];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATIN_RECEIVED_PRESENCE_REPORT object:[presenceFromUser userIdByRemovingSoberGrid]];
        }
       
    });
    
}



- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	//DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	//DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		//DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPMUCDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitation:(XMPPMessage *)message{
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitationDecline:(XMPPMessage *)message{
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	//DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
    
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRoomDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    //    if([delegate respondsToSelector:@selector(roomJoined)]){
    //        [delegate roomJoined];
    //    }
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sende{
    
}
- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
    
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult{
    //    if([delegate respondsToSelector:@selector(roomNotConfigured)])
    //        [delegate roomNotConfigured];
    
    // [self callAlert:@"Room did not configure properly..."];
    
}
- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    
    [sender fetchConfigurationForm];
    
   // <field var='FORM_TYPE'>
    //         <value>http://jabber.org/protocol/muc#roomconfig</value>
    //       </field>
    //       <field var='muc#roomconfig_roomname'>
    //         <value>A Dark Cave</value>
    //       </field>
    //       <field var='muc#roomconfig_enablelogging'>
    //         <value>0</value>
    //       </field>
    //        <field var="muc#roomconfig_persistentroom" type="boolean" label="Room is Persistent"><value>0</value></field>
   // if (_groupOwner) {
        _groupOwner=false;
        NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
        [x addAttributeWithName:@"type" stringValue:@"submit"];
        NSXMLElement *formTypeField = [NSXMLElement elementWithName:@"field"];
        [formTypeField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
        [formTypeField addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        
        [x addChild:formTypeField];
        
        [sender configureRoomUsingOptions:x];

}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    
}

- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm{
    
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    // [self printTitle:@"occupantJID" Message:[NSString stringWithFormat:@"%@",occupantJID]];
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    
}


- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    
    
}

#pragma mark Members List

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError{
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items{
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError{
}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult{
}
- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError{
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Send and Recive message
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    
}

-(BOOL)sendMessage:(NSString*)toUser Groupname:(NSString*)groupname Message:(NSString*)message isPhoto:(BOOL)status photo:(UIImage *)image{
    if (![[NetworkListioner listner] isInternetAvailable]) {
        return false;
    }
    
    if( ![[DatabaseManager sharedInstance] getPresenceRepostForUserId:_otherUser.struserId] && !_otherUser.isOnline)
    {
        [self sendPush];
        
        //  [self sendPushtoUserid:_otherSideUser.struserId andName:[User currentUser].strName];
    }
    if (status) {
        CommonApiCall *apiClass =  [[CommonApiCall alloc] initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@chat_img",baseUrl()] andDelegate:self];
        [apiClass uploadImageToUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@chat_img",baseUrl()]] withPostParameters:nil ofImage:image inKey:@"chat_img" withName:@"chat_img.jpg" withobject:@{@"id":_otherUser.struserId,@"name":_otherUser.strName}];
    }else{

    NSString *messageStr = message;
    
    if([messageStr length] > 0)
    {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@",[[User currentUser].struserId userIdAddedSoberGrid], XMPPDomain()]];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",[toUser userIdAddedSoberGrid], XMPPDomain()]];
        [message addChild:body];
        
        [self.xmppStream sendElement:message];
    }
    }
    return YES;
}

-(BOOL)receiveMessage:(NSString*)message{
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Save chat history
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)saveChatHistory:(NSString *)sender RecieverName:(NSString*)receiver Message:(NSString*)message Time:(NSString*)time
{
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Create Group and add Buddy
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)RegistredNewUserInXmpp:(NSString*)service Username:(NSString*)regusername Password:(NSString*)regpassword{
    NSString *strJid;
   // NSString *strJid = [NSString stringWithFormat:@"%@@%@",[NSString stringWithFormat:@"%@_UH",[[[SharedDelegate sharedInstance] getUser] objectForKey:@"user_id"]],HOST_NAME];
    
    XMPPJID *jid = [XMPPJID jidWithString:strJid];
    if([self xmppRoster])
        [[self xmppRoster] subscribePresenceToUser:jid];
}


- (void)subscribePresenceForUsers:(NSArray*)arr{
    dispatch_async(subscribeQueue, ^{
        for (NSDictionary *dictTemp in arr) {
            NSDictionary *nullRemoved = [dictTemp dictionaryByReplacingNullsWithBlanks];
            NSString *userId=[nullRemoved objectForKey:@"userid"];
            NSString *jid = [NSString stringWithFormat:@"%@_sobergrid@%@",userId, XMPPDomain()];
           // [self.xmppRoster unsubscribePresenceFromUser:[XMPPJID jidWithString:jid]];
            [self.xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:jid]];
        }
    });
}
- (void)fetchRoseter{
    [xmppRoster fetchRoster];
}


-(void)createGroup:(NSString *)groupName UserType:(NSString *)userrole{
    

    arrMessagesOnly=[[NSMutableArray alloc]init];

    NSString *strJid;
    
    XMPPJID *jid = [XMPPJID jidWithString:strJid];
    
    strGroupName = groupName;
    _arrMessages = [[NSMutableArray alloc]init];
    
    NSString *roomID1;
  //  NSString *roomID1 = [NSString stringWithFormat:@"%@@conference.%@/%@",strGroupName,HOST_NAME,[NSString stringWithFormat:@"%@_UH",[[[SharedDelegate sharedInstance] getUser] objectForKey:@"user_id"]]];
    
    
//    //// My  code with xmpproom
//    XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
//    xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage jid:[XMPPJID jidWithString:roomID1] dispatchQueue:dispatch_get_main_queue()];
//    
//    [xmppRoom activate:xmppStream];
//    
//    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [xmppRoom joinRoomUsingNickname:[[[SharedDelegate sharedInstance] getUser] objectForKey:@"screen_name"] history:nil];
//    [xmppRoom fetchConfigurationForm];
//
//    [xmppRoom configureRoomUsingOptions:nil];
//    
//    [_delegate groupCreated];
//    
//    xmppMessageArchivingStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
//    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:xmppMessageArchivingStorage];
//    
//    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
//    
//    [xmppMessageArchivingModule activate:xmppStream];
//    [xmppMessageArchivingModule  addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    
//    return;
    
    
    

    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    [history addAttributeWithName:@"maxstanzas" stringValue:@"50"];
    
    NSString* roomID = [roomID1 lowercaseString];
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    NSString *xmlns=[NSString stringWithFormat:@"http://jabber.org/protocol/muc#%@",userrole];
    [presence addAttributeWithName:@"from" stringValue:[jid full]];
    [presence addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@", roomID]];
    NSXMLElement *xelement = [NSXMLElement elementWithName:@"x" xmlns:xmlns];
    [presence addChild:xelement];
    
    
    [xmppStream sendElement:presence];
    
//    xmppMessageArchivingStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
//    
//    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:xmppMessageArchivingStorage];
//    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
//    
//    [xmppMessageArchivingModule activate:xmppStream];
//    [xmppMessageArchivingModule  addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [self performSelector:@selector(fetchHistoryProgramatically) withObject:nil afterDelay:3.0];
    //[self fetchHistoryProgramatically];
//    NSString *barJidString=[NSString stringWithFormat:@"%@@conference.%@",strGroupName,HOST_NAME];
//    NSMutableArray *arrMessagesForGroup=[self filterMessagesForGroupId:barJidString FromAllMessages:[[SharedDelegate sharedInstance] getMessages]];
//     for (XMPPMessageArchiving_Message_CoreDataObject *message in arrMessagesForGroup) {
//         [self saveMessage:message.message];
//    }
    [_delegate groupCreated];
}




-(void)addPersonforChat:(NSString*)userName withMessage:(NSString*)message{
    @try {
        XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
        NSString *strJid;
       // NSString *strJid = [NSString stringWithFormat:@"%@@%@",[NSString stringWithFormat:@"%@_UH",[[[SharedDelegate sharedInstance] getUser] objectForKey:@"user_id"]],HOST_NAME];
        xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage jid:[XMPPJID jidWithString:strJid] dispatchQueue:dispatch_get_main_queue()];
        [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [xmppRoom activate:self.xmppStream];
        [xmppRoom joinRoomUsingNickname:[NSString stringWithFormat:@"%@_UH",[User currentUser].struserId] history:nil];
        
        //inviting
        NSString *strInvitedUserName = [NSString stringWithFormat:@"%@@%@",userName, XMPPDomain()];
        [xmppRoom inviteUser:[XMPPJID jidWithString:strInvitedUserName] withMessage:message];
    }
    @catch (NSException *exception) {
        
    }
}

//
-(void)addPersonInGroup:(NSString*)personName GroupName:(NSString*)groupname withMessage:(NSString*)message{
    @try {
        
        XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
        NSString *strJid;
        //NSString *strJid = [NSString stringWithFormat:@"%@@conference.%@/%@",groupname,HOST_NAME,[NSString stringWithFormat:@"%@_UH",[[[SharedDelegate sharedInstance] getUser] objectForKey:@"user_id"]]];
        xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage jid:[XMPPJID jidWithString:strJid] dispatchQueue:dispatch_get_main_queue()];
        [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [xmppRoom activate:self.xmppStream];
        [xmppRoom joinRoomUsingNickname:[NSString stringWithFormat:@"%@_UH",[User currentUser].struserId] history:nil];
        
        //inviting
        NSString *strInvitedUserName = [NSString stringWithFormat:@"%@@%@",personName, XMPPDomain()];
        [xmppRoom inviteUser:[XMPPJID jidWithString:strInvitedUserName] withMessage:message];
        
    }
    @catch (NSException *exception) {
        
    }
}

-(void)ConfigureRoom:(XMPPRoom *)xmppRoom1
{
    
    [xmppRoom fetchConfigurationForm];
    NSXMLElement *xelement = [NSXMLElement elementWithName:@"x" xmlns:@"muc#roomconfig_persistentroom"];
    
    [xmppRoom configureRoomUsingOptions:xelement];
    
}

-(NSString *)StartsWithstring:(NSString*)string forstring:(NSString *)str {
    NSRange range = [str rangeOfString:string];
    if(range.length) {
        NSRange rangeend = [str rangeOfString:@" " options:NSLiteralSearch range:NSMakeRange(range.location,[str length] - range.location - 1)];
        if(rangeend.length) {
            return [str substringWithRange:NSMakeRange(range.location,rangeend.location - range.location)];
        }
        else
        {
            return [str substringFromIndex:range.location] ;
        }
    }
    else {
        return @"";
    }
}
// For Background Task
- (void)xmppStream:(XMPPStream *)sender socketWillConnect:(GCDAsyncSocket *)socket
{
    // Tell the socket to stay around if the app goes to the background (only works on apps with the VoIP background flag set)
//    [socket performBlock:^{
//        [socket enableBackgroundingOnSocket];
//    }];
}
- (void)teardownStream
{
    
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
    [xmppMessageArchivingModule deactivate];

	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}
-(void)deleteHistoryWithUserId:(NSString*)userid withCompletionHandler:(SGXMMFetchHistoryComletionHaldler)completion{
    if (_completionblock) {
        _completionblock = nil;
        _completionblock = completion;
    }else{
        _completionblock = completion;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                             inManagedObjectContext:moc];
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        [request setEntity:entityDescription];
        NSString *barJidString=[NSString stringWithFormat:@"%@@%@",[userid userIdAddedSoberGrid], XMPPDomain()];
        if (userid) {
            NSString *predicateFrmt = @"bareJidStr == %@ AND streamBareJidStr == %@";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFrmt, barJidString,[NSString stringWithFormat:@"%@@%@",[[User currentUser].struserId userIdAddedSoberGrid], XMPPDomain()]];
            request.predicate = predicate;
            
        }else{
            NSString *predicateFrmt = @"streamBareJidStr == %@";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFrmt, [NSString stringWithFormat:@"%@@%@",[[User currentUser].struserId userIdAddedSoberGrid], XMPPDomain()]];
            request.predicate = predicate;
        }
        
        
        NSError *error;
        NSArray *messages = [moc executeFetchRequest:request error:&error];
        
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages)
        {
            [moc deleteObject:message];
            
            NSError *error = nil;
            if (![moc save:&error])
            {
                NSLog(@"Error deleting object, %@", [error userInfo]);
            }
            else
                
            {
                [self reduceUnreadMessages:userid];
            
            }
        }
        
        
        _completionblock = nil;
        
        
        
    });
    
    
}
-(void)fetchHistoryWithUserId:(NSString*)userid withLimit:(int)limit ascending:(BOOL)status withCompletionHandler:(SGXMMFetchHistoryComletionHaldler)completion{
    if (_completionblock) {
        _completionblock = nil;
        _completionblock = completion;
    }else{
        _completionblock = completion;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                             inManagedObjectContext:moc];
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        [request setEntity:entityDescription];
        NSString *barJidString=[NSString stringWithFormat:@"%@@%@",[userid userIdAddedSoberGrid], XMPPDomain()];
        if (userid) {
            NSString *predicateFrmt = @"bareJidStr == %@ AND streamBareJidStr == %@";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFrmt, barJidString,[NSString stringWithFormat:@"%@@%@",[[User currentUser].struserId userIdAddedSoberGrid], XMPPDomain()]];
            request.predicate = predicate;

        }else{
            NSString *predicateFrmt = @"streamBareJidStr == %@";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFrmt, [NSString stringWithFormat:@"%@@%@",[[User currentUser].struserId userIdAddedSoberGrid], XMPPDomain()]];
            request.predicate = predicate;
        }
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:status];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        if (limit > 0) {
            [request setFetchLimit:limit];
        }
        NSError *error;
        NSArray *messages = [moc executeFetchRequest:request error:&error];
        _completionblock (messages);
        _completionblock = nil;
        
        

    });

    
}
-(void)print:(NSMutableArray*)messages{
    @autoreleasepool {
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
            if ([message.message isMessageWithBody]) {
           // NSLog(@"messageStr param is %@",message.messageStr);
//            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
//            NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
//            NSLog(@"NSCore object id param is %@",message.objectID);
//            NSLog(@"bareJid param is %@",message.bareJid);
//            NSLog(@"bareJidStr param is %@",message.bareJidStr);
            NSLog(@"body param is %@",message.body);
//            NSLog(@"timestamp param is %@",message.timestamp);
//            NSLog(@"outgoing param is %d",[message.outgoing intValue]);
            }
        }
    }
}
- (NSString*) stringBetweenString:(NSString*)start andString:(NSString*)end forString:(NSString *)str {
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}
- (void)fetchHistoryStartingFromDate:(NSString*)strDate{
    NSXMLElement *iq1 = [NSXMLElement elementWithName:@"iq"];
    [iq1 addAttributeWithName:@"type" stringValue:@"get"];
    [iq1 addAttributeWithName:@"id" stringValue:[xmppStream myJID].full];
    
    NSXMLElement *retrieve = [NSXMLElement elementWithName:@"retrieve" xmlns:@"urn:xmpp:archive"];
    [retrieve addAttributeWithName:@"with" stringValue:@"33_sobergrid@180.211.99.162"];
    [retrieve addAttributeWithName:@"start" stringValue:strDate];
    NSXMLElement *set = [NSXMLElement elementWithName:@"set" xmlns:@"http://jabber.org/protocol/rsm"];
    NSXMLElement *max = [NSXMLElement elementWithName:@"max" stringValue:@"100"];
    [iq1 addChild:retrieve];
    [retrieve addChild:set];
    [set addChild:max];
    [xmppStream sendElement:iq1];
}
- (void)fetchHistoryProgramatically{
    NSXMLElement *iQ = [NSXMLElement elementWithName:@"iq"];
    [iQ addAttributeWithName:@"type" stringValue:@"get"];
    [iQ addAttributeWithName:@"id" stringValue:[xmppStream myJID].full];
    
    NSXMLElement *list = [NSXMLElement elementWithName:@"list"];
    [list addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:archive"];
    [list addAttributeWithName:@"with" stringValue:@"33_sobergrid@180.211.99.162"];
    
    
    
    NSXMLElement *set = [NSXMLElement elementWithName:@"set"];
    [set addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/rsm"];
    
    NSXMLElement *max = [NSXMLElement elementWithName:@"max"];
    [max addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/rsm"];
    max.stringValue = @"30";
    
    [set addChild:max];
    
    [list addChild:set];
    [iQ addChild:list];
    [xmppStream sendElement:iQ];
    [self fetchHistoryStartingFromDate:@"2014-09-26T09:58:13.588Z"];


}

#pragma mark - pubshub delegate
- (void)xmppPubSub:(XMPPPubSub *)sender didCreateNode:(NSString *)node withResult:(XMPPIQ *)iq{
    
}
- (void)xmppPubSub:(XMPPPubSub *)sender didNotCreateNode:(NSString *)node withError:(XMPPIQ *)iq{
}
- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveMessage:(XMPPMessage *)message{
}
- (void)xmppPubSub:(XMPPPubSub *)sender didSubscribeToNode:(NSString *)node withResult:(XMPPIQ *)iq{

}
- (void)xmppPubSub:(XMPPPubSub *)sender didUnsubscribeFromNode:(NSString *)node withResult:(XMPPIQ *)iq{

}


- (void)subScribeToJabberIdforUserid:(NSString*)userid{
    NSString *jid = [NSString stringWithFormat:@"%@_sobergrid@%@",userid, XMPPDomain()];
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"to" stringValue:[[XMPPJID jidWithString:jid] bare]];
    [presence addAttributeWithName:@"type" stringValue:@"subscribe"];
    [xmppStream sendElement:presence];
    
}
- (void)sendPush{
    
    [self performSelector:@selector(sendPushtouser:) withObject:[@{@"name": [User currentUser].strName,@"userid":_otherUser.struserId}mutableCopy] afterDelay:0.5];
}
#pragma mark - Send push
- (void)sendPushtouser:(NSDictionary*)dictInfo{
    NSString *name = [dictInfo objectForKey:@"name"];
    NSString *userid = [dictInfo objectForKey:@"userid"];
    //ApiClass *apiClass=[ApiClass sharedClass];
    //apiClass.delegate = self;
    CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@send_push_notification",baseUrl()] andDelegate:self];
    [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"to_userid":userid,@"username":name,@"my_userid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
    //  [apiClass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@send_push_notification",baseUrl()]] withPostParameters:@{@"to_userid":userid,@"username":name} withRequestMethod:POST];
    
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    if ([requestedURL rangeOfString:@"get_user_details"].location != NSNotFound) {
        NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
        if ([requestedURL rangeOfString:@"get_user_details"].location != NSNotFound){
            if ([[dictResponse objectForKey:@"Type"] isEqualToString:@"OK"]) {
                User *userTemp = [[User alloc]init];
                [userTemp createUserWithDict:[[dictResponse objectForKey:@"Responce"] objectForKey:@"user"]];
                if (userTemp.struserId.length > 0) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STARTCHAT object:userTemp];
                }
               
            }else{
                
                
            }
        }

    }
    if ([requestedURL rangeOfString:@"send_push_notification"].location != NSNotFound) {
        
    }
    if ([requestedURL rangeOfString:@"chat_img"].location != NSNotFound){
        NSDictionary *dictUser=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        dictUser = [dictUser dictionaryByReplacingNullsWithBlanks];
        if ([[dictUser objectForKey:@"Type"] isEqualToString:@"OK"]) {
            
            NSString *jsonResponse = [[dictUser objectForKey:RESPONSE] JSONRepresentation];
            NSDictionary *dictPhoto=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)XHBubbleMessageMediaTypePhoto],@"type",jsonResponse,@"message",[User currentUser].strName,@"sender",userInfo[@"name"],@"to", nil];
            NSString *jsonString = [dictPhoto JSONRepresentation];
            [self sendMessage:userInfo[@"id"] Groupname:nil Message:jsonString isPhoto:false photo:nil];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[dictUser objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }

    }

    
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
   
}
- (void)returnData:(id)data forUrl:(NSURL *)url withTag:(int)tag{
    if ([url.absoluteString rangeOfString:@"chat_img"].location != NSNotFound){
        NSDictionary *dictUser=(NSDictionary*)data;
        if ([[dictUser objectForKey:@"Type"] isEqualToString:@"OK"]) {
            
            NSString *jsonResponse = [[dictUser objectForKey:RESPONSE] JSONRepresentation];
            NSDictionary *dictPhoto=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)XHBubbleMessageMediaTypePhoto],@"type",jsonResponse,@"message",[User currentUser].strName,@"sender",_otherUser.strName,@"to", nil];
            NSString *jsonString = [dictPhoto JSONRepresentation];
            [self sendMessage:[NSString stringWithFormat:@"%d",tag] Groupname:nil Message:jsonString isPhoto:false photo:nil];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[dictUser objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }

}
- (void)failedData:(NSError *)error forUrl:(NSURL *)url withTag:(int)tag{
    if ([url.absoluteString rangeOfString:@"chat_img"].location != NSNotFound){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

@end
