//
//  SGGroup.m
//  SoberGrid
//
//  Created by agilepc-159 on 7/3/15.
//  Copyright (c) 2015 William Santiago All rights reserved.
//

#import "SGGroup.h"
#import "SoberGrid_CoreData_ManagedContext.h"

@implementation SGGroup

@dynamic strCity;
@dynamic strEmail;
@dynamic strFullName;
@dynamic strGroupId;
@dynamic strImageUrl;
@dynamic members;
@dynamic joinStatus;
@dynamic strThumbUrl;
@dynamic totalLikes;

- (void)remove{
    [[SoberGrid_CoreData_ManagedContext sharedContext].managedObjectContext deleteObject:self];
}
+ (void)save{
    [[SoberGrid_CoreData_ManagedContext sharedContext] saveContext];
}
+ (instancetype)instanse{
    
    SGGroup *group = [NSEntityDescription insertNewObjectForEntityForName:@"SGGroup"
                                                 inManagedObjectContext:[SoberGrid_CoreData_ManagedContext sharedContext].managedObjectContext];
    return group;
}
+ (instancetype)groupWithDetails:(NSDictionary*)detail{
    
    SGGroup *group = [self getGroupWithGroupId:(detail[@"groupid"] ? detail[@"groupid" ] : @"")];
    if (!group) {
        group = [NSEntityDescription insertNewObjectForEntityForName:@"SGGroup"
                                              inManagedObjectContext:[SoberGrid_CoreData_ManagedContext sharedContext].managedObjectContext];
    }
    /*  city = ahmedabad;
    "created_at" = "2015-06-18 07:03:45";
    email = "zoya@m.com";
    fullname = Zoya;
    groupid = 5;
    imageurl = "";
    member = 1;
    status = "";
    thumbimageurl = "";
    totallikes = 0;*/
    group.strCity = detail[@"city"] ? detail[@"city" ] : @"";
    group.strEmail = detail[@"email"] ? detail[@"email" ] : @"";
    group.strFullName = detail[@"fullname"] ? detail[@"fullname" ] : @"";
    group.strGroupId = detail[@"groupid"] ? detail[@"groupid" ] : @"";
    group.strImageUrl = detail[@"image"] ? detail[@"image" ] : @"";
    group.members = detail[@"member"] ? [NSNumber numberWithInteger:[detail[@"member"] integerValue]] : 0;
    group.joinStatus = detail[@"status"] ? [NSNumber numberWithInteger:[detail[@"status"] integerValue]] : 0;
    group.strThumbUrl = detail[@"image_thumb"] ? detail[@"image_thumb"] : @"";
    group.strBannerUrl =  detail[@"banner"] ? detail[@"banner"] : @"";
    group.strBannerThumbUrl = detail[@"banner_thumb"] ? detail[@"banner_thumb"] : @"";
    group.totalLikes = detail[@"totallikes"] ? [NSNumber numberWithInteger:[detail[@"totallikes"] integerValue]] : 0;
    group.isLiked = detail[@"islike"] ? [NSNumber numberWithInteger:[detail[@"islike"] integerValue]] : [NSNumber numberWithInteger:0];
    group.strPhoneNumber = detail[@"phone_number"] ? detail[@"phone_number"] : group.strPhoneNumber;
    group.strWebsiteUrl = detail[@"website"] ? detail[@"website"] : group.strWebsiteUrl;
    return group;
}
+ (void)deleteAllGroups{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self entityDiscriptionForEntity:@"SGGroup"]];
    [request setReturnsObjectsAsFaults:NO];
    
    NSError *error;
    NSArray *array = [[self context] executeFetchRequest:request error:&error];
    for (SGGroup *gpObject in array) {
        [[self context] deleteObject:gpObject];
    }
    [[self context] save:nil];
}
+ (void)deleteObject:(SGGroup*)objGroup{
    [[self context] deleteObject:objGroup];
    [[self context] save:nil];
}


+ (void)deleteUnwantedGroups{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(joinStatus == %@) OR (joinStatus == %@) OR (joinStatus == %@)", [NSNumber numberWithInteger:kSGGroupStatusCancel], [NSNumber numberWithInteger:kSGGroupStatusNone],[NSNumber numberWithInteger:kSGGroupStatusDelete]];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self entityDiscriptionForEntity:@"SGGroup"]];
    [request setPredicate:predicate];
    [request setReturnsObjectsAsFaults:NO];
    
    NSError *error;
    NSArray *array = [[self context] executeFetchRequest:request error:&error];
    for (SGGroup *gpObject in array) {
        [[self context] deleteObject:gpObject];
    }
    [[self context] save:nil];
}
+ (NSArray*)getAllJoinedGroups{
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"joinStatus == %@", [NSNumber numberWithInteger:kSGGroupStatusAccepted]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self entityDiscriptionForEntity:@"SGGroup"]];
    [request setPredicate:predicate];
    [request setReturnsObjectsAsFaults:NO];
    
    NSError *error;
    NSArray *array = [[self context] executeFetchRequest:request error:&error];
    return (array.count > 0)?array:nil;

}
+ (NSArray*)getAllGroups{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self entityDiscriptionForEntity:@"SGGroup"]];
    [request setReturnsObjectsAsFaults:NO];
    
    NSError *error;
    NSArray *array = [[self context] executeFetchRequest:request error:&error];
    return (array.count > 0)?array:nil;

}
+ (SGGroup*)getGroupWithGroupId:(NSString*)groupID{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"strGroupId == %@",groupID];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self entityDiscriptionForEntity:@"SGGroup"]];
    [request setPredicate:predicate];
    [request setReturnsObjectsAsFaults:NO];
    
    NSError *error;
    NSArray *array = [[self context] executeFetchRequest:request error:&error];
    return (array.count > 0) ? [array objectAtIndex:0] : nil;
}
+ (NSEntityDescription*)entityDiscriptionForEntity:(NSString*)entityName{
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityName inManagedObjectContext:[self context]];
    return entityDescription;
}
+ (NSManagedObjectContext*)context{
    SoberGrid_CoreData_ManagedContext *moc=[SoberGrid_CoreData_ManagedContext sharedContext];
    return moc.managedObjectContext;
}

@end
