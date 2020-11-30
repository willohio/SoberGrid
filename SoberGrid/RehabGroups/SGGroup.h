//
//  SGGroup.h
//  SoberGrid
//
//  Created by agilepc-159 on 7/3/15.
//  Copyright (c) 2015 William Santiago All rights reserved.
//

typedef enum {
    kSGGroupStatusNone,
    kSGGroupStatusRequested,
    kSGGroupStatusAccepted,
    kSGGroupStatusCancel,
    kSGGroupStatusDelete,
}kSGGroupStatus;
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SGGroup : NSManagedObject

@property (nonatomic, retain) NSString * strCity;
@property (nonatomic, retain) NSString * strEmail;
@property (nonatomic, retain) NSString * strFullName;
@property (nonatomic, retain) NSString * strGroupId;
@property (nonatomic, retain) NSString * strImageUrl;
@property (nonatomic, retain) NSNumber * members;
@property (nonatomic, retain) NSNumber * joinStatus;
@property (nonatomic, retain) NSString * strThumbUrl;
@property (nonatomic, retain) NSNumber * totalLikes;
@property (nonatomic, retain) NSString * strBannerUrl;
@property (nonatomic, retain) NSString * strBannerThumbUrl;
@property (nonatomic, retain) NSNumber * isLiked;
@property (nonatomic, retain) NSString * strWebsiteUrl;
@property (nonatomic, retain) NSString * strPhoneNumber;
+ (instancetype)groupWithDetails:(NSDictionary*)detail;
+ (instancetype)instanse;
+ (void)deleteUnwantedGroups;
+ (NSArray*)getAllGroups;
+ (void)deleteAllGroups;
+ (NSArray*)getAllJoinedGroups;
+ (SGGroup*)getGroupWithGroupId:(NSString*)groupID;
+ (void)save;
+ (void)deleteObject:(SGGroup*)objGroup;
@end
