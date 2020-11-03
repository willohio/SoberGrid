//
//  DatabaseManager.h
//  Project172
//
//  Created by Apple on 09/05/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Global.h"
#import "JSON.h"
@class FMDatabaseQueue;
@class Friend;

@interface DatabaseManager : NSObject {
}

// clue for improper use (produces compile time error)
+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));


/*Singleton getter*/
+ (DatabaseManager *)sharedInstance;

/*Database updater*/
- (void)checkUpdates;
- (void)clearTableData;
- (BOOL)addPresenceReportForUserId:(NSString *)userid withPresenceStatus:(NSString*)availableStatus;
- (BOOL)getPresenceRepostForUserId:(NSString*)userId;


@end
