//
//  SGPostVideo.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "SGPostVideo.h"

@implementation SGPostVideo
- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
        // Copy NSObject subclasses
        [copy setStrDesrciption:[self.strDesrciption copyWithZone:zone]];
        [copy setStrFeedId:[self.strFeedId copyWithZone:zone]];
        [copy setStrThumbUrl:[self.strThumbUrl copyWithZone:zone]];
        [copy setStrVideoUrl:[self.strVideoUrl copyWithZone:zone]];
        [copy setDatePosted:[self.datePosted copyWithZone:zone]];
        [copy setArrLikedUsers:[self.arrLikedUsers copyWithZone:zone]];
        [copy setArrCommentedUsers:[self.arrCommentedUsers copyWithZone:zone]];
        [copy setObjUser:[self.objUser copyWithZone:zone]];
        [copy setStrIsHide:[self.strIsHide copyWithZone:zone]];
        [copy setStrIsLike:[self.strIsLike copyWithZone:zone]];
        [copy setStrLocation:[self.strLocation copyWithZone:zone]];
        [copy setLikesCount:self.likesCount];
        [copy setCommentsCount:self.commentsCount];
    }
    return copy;
}
- (id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    if (self) {
        [self customizeWithDict:dict];
    }
    return self;
}
- (void)customizeWithDict:(NSDictionary*)dict{
    self.strDesrciption = dict[@"status"];
    NSDateFormatter *datFormat = [[NSDateFormatter alloc]init];
    [datFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [datFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    self.datePosted = [datFormat dateFromString:dict[@"creationdate"]];
    self.strLocation = [dict objectForKey:@"location"];
    self.strIsHide  = (dict[@"isHide"])? dict[@"isHide"]:@"0";
    self.strIsLike  = (dict[@"isLike"]) ? dict[@"isLike"]:@"0";
    self.strFeedId  = (dict [@"post_id"]) ? dict [@"post_id"] : nil;
    self.likesCount = (dict [@"totalLikes"]) ? [dict [@"totalLikes"] intValue] : 0;
    self.commentsCount = (dict [@"totalComment"]) ? [dict [@"totalComment"] intValue] : 0;
    self.strVideoUrl= dict[@"media"];
    self.strThumbUrl= dict[@"video_thumb"];

    
}
@end
