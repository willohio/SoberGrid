//
//  Wazobia_CoreData_ManagedContext.m
//  WazobiaChat
//
//  Created by agilepc-159 on 12/9/14.
//  Copyright (c) 2014 AgileInfoways. All rights reserved.
//

#import "SoberGrid_CoreData_ManagedContext.h"

@implementation SoberGrid_CoreData_ManagedContext
+ (instancetype)sharedContext {
    static SoberGrid_CoreData_ManagedContext *_sharedContext = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedContext = [[self alloc] init];
        [_sharedContext createmanagedObjectContext];
    });
    
    return _sharedContext;
}


- (void)createmanagedObjectContext
{
    self.managedObjectContext =
    [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator =
    [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedModel]];
    
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSURL *storeUrl = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"sobergrid.sqlite"]];
    NSError* error;
    [self.managedObjectContext.persistentStoreCoordinator
     addPersistentStoreWithType:NSSQLiteStoreType
     configuration:nil
     URL:storeUrl
     options:nil
     error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
    self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
}
- (NSManagedObjectModel*)managedModel{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SoberGrid" withExtension:@"momd"];
    NSManagedObjectModel* managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}
- (void)saveContext{
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"error %@",error.localizedDescription);
    }
}
@end
