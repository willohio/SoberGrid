//
//  NetworkListioner.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/7/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "NetworkListioner.h"
#import "PopUpNotification.h"
#import "Reachability.h"
#import "PopUpNotification.h"

@implementation NetworkListioner
+ (NetworkListioner *)listner{
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [(NetworkListioner *) [super alloc] initUniqueInstance];
    });
    return shared;
}
#pragma mark -
- (instancetype)initUniqueInstance {
    self = [super init];
    
    if (self) {
        
        [self registerNetwork];
        
    }
    
    return self;
}


+ (instancetype)alloc {
    return nil;
}


- (instancetype)init {
    return nil;
}


+ (instancetype)new {
    return nil;
}
- (void)registerNetwork{
     reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
}
- (void) handleNetworkChange:(NSNotification *)notice
{
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if (remoteHostStatus == NotReachable)      {
        [[PopUpNotification sharedInstance] show];
    
    }
    else if(remoteHostStatus == ReachableViaWiFi)  {
        [[PopUpNotification sharedInstance] hide];

    }
    else if (remoteHostStatus == ReachableViaWWAN)  {
        [[PopUpNotification sharedInstance] hide];
    }
}
- (BOOL)isInternetAvailable{
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus remoteHostStatus = [internetReach currentReachabilityStatus];
    if (remoteHostStatus == NotReachable) {
        [[PopUpNotification sharedInstance] show];
        return NO;
    }
    else
        return YES;
}


@end
