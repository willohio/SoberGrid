//
//  Wazobia_CoreData_ManagedContext.h
//  WazobiaChat
//
//  Created by agilepc-159 on 12/9/14.
//  Copyright (c) 2014 AgileInfoways. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SoberGrid_CoreData_ManagedContext : NSObject{
}
@property(nonatomic,strong)NSManagedObjectContext *managedObjectContext;
+ (instancetype)sharedContext;
- (void)saveContext;
@end
