//
//  DatabaseManager.m
//  Project172
//
//  Created by Apple on 09/05/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import "DatabaseManager.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

#define dbFileName @"sobergrid.sqlite"

@interface DatabaseManager () {
}
@property(strong, nonatomic) FMDatabaseQueue *databaseQueue;

- (void)checkUpdates;
@end

@implementation DatabaseManager

#pragma mark Singleton methods
+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [(DatabaseManager *) [super alloc] initUniqueInstance];
    });
    return shared;
}


- (instancetype)initUniqueInstance {
    self = [super init];

    if (self) {
        NSString *databasePath = [self applicationHiddenDocumentsDirectory];
        self.databaseQueue = [[FMDatabaseQueue alloc] initWithPath:databasePath];
        NSURL *fileURLPathTemp = [NSURL fileURLWithPath:databasePath];
        
        NSError *error=nil;
        BOOL success = [fileURLPathTemp setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error: &error ];
        if(!success)
        {
          //  NSLog(@"Error excluding %@ from backup %@", [fileURLPathTemp lastPathComponent], error);
        }


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

#pragma mark Data access methods
- (NSString *)dataFilePath {
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *libraryPath = [self applicationHiddenDocumentsDirectory];
    NSString *path = [libraryPath stringByAppendingPathComponent:@"Private Documents"];
    return [path stringByAppendingPathComponent:dbFileName];
    
}
- (NSString *)applicationHiddenDocumentsDirectory {
    // NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@".data"];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [libraryPath stringByAppendingPathComponent:dbFileName];
    return path;
    
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (isDirectory)
            return path;
        else {
            // Handle error. ".data" is a file which should not be there...
            [NSException raise:@".data exists, and is a file" format:@"Path: %@", path];
            // NSError *error = nil;
            // if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
            //     [NSException raise:@"could not remove file" format:@"Path: %@", path];
            // }
        }
    }
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        // Handle error.
        [NSException raise:@"Failed creating directory" format:@"[%@], %@", path, error];
    }
   
    
    NSURL *fileURLPathTemp = [NSURL fileURLWithPath:path];
    
    
    BOOL success = [fileURLPathTemp setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error: &error ];
    if(!success)
    {
       // NSLog(@"Error excluding %@ from backup %@", [fileURLPathTemp lastPathComponent], error);
    }
    return path;
}


- (void)checkUpdates {
    [self.databaseQueue inDatabase:^(FMDatabase *database) {
        database.logsErrors = YES;
        

        // Save friends only for that view (for tblView use)
        NSArray *presenceReport= @[@"CREATE TABLE IF NOT EXISTS presencereports (userid Text,presence Text);\n"];
        
       
        NSArray *revisionsScripts = @[presenceReport];

        for (NSArray *revision in revisionsScripts) {
            for (NSString *script in revision) {
                BOOL result = [database executeUpdate:script];
                if (!result) {
                }else{
                }
            }
        }
    }];
}
- (void)clearTableData {
    // only for channel, subscription, series and episodes.
    [self.databaseQueue inDatabase:^(FMDatabase *database) {
        NSString *query = @"delete from presencereports";
        [database executeUpdate:query];
      

    }];
}



- (BOOL)addPresenceReportForUserId:(NSString *)userid withPresenceStatus:(NSString*)availableStatus{
    
    if ([self isUserDetailThereinDBForUserid:userid].length > 0) {
        return [self updateStatusForUserid:userid withstatus:availableStatus];
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *database) {
        NSString *query = @"insert or replace into presencereports values (?, ?)";
        result = [database executeUpdate:query,
                  userid,
                  availableStatus
                  ];
        
    }];
    return result;
}
- (BOOL)updateStatusForUserid:(NSString*)userid withstatus:(NSString*)status{
    __block BOOL result = NO;
    
    [self.databaseQueue inDatabase:^(FMDatabase *database) {
        NSString *query = @"Update presencereports set presence = ? where userid = ?";
        result = [database executeUpdate:query,
                  status,
                  userid
                  ];
    }];
    
    return result;
}
- (BOOL)getPresenceRepostForUserId:(NSString*)userId{
    
    
    __block BOOL itemresult= false;
    [self.databaseQueue inDatabase:^(FMDatabase *database) {
        NSString *query = @"select * from presencereports where userid = ? ";
        
        FMResultSet *resultSet = [database executeQuery:query,userId];
        
        while ([resultSet next]) {
            itemresult = [self presensestatusFromResultSet:resultSet];
        }
        [resultSet close];
    }];
    
    
    return itemresult;
}
- (NSString*)isUserDetailThereinDBForUserid:(NSString*)userid{
    __block NSString* itemresult;
    [self.databaseQueue inDatabase:^(FMDatabase *database) {
        NSString *query = @"select * from presencereports where userid = ? ";
        
        FMResultSet *resultSet = [database executeQuery:query,userid];
        
        while ([resultSet next]) {
            itemresult = [self statusFromResultSet:resultSet];
        }
        [resultSet close];
    }];
    
    
    return itemresult;
}

- (BOOL)presensestatusFromResultSet:(FMResultSet*)resultset{
    return [[resultset stringForColumn:@"presence"] boolValue];
}
- (NSString*)statusFromResultSet:(FMResultSet*)resultset{
    return [resultset stringForColumn:@"presence"];

}


@end