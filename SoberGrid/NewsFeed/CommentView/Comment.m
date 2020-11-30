//
//  Comment.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/22/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "Comment.h"

@implementation Comment
+ (id)commentWithDetails:(NSDictionary*)details forType:(NSString*)strType
{
    Comment* obj = [[self alloc] init];
    if (obj) {
        obj = [[super alloc] initUniqueInstancewithDict:details];
        obj.commentType = strType;
        // Initialization code
    }
    return obj;
}
- (instancetype)initUniqueInstancewithDict:(NSDictionary*)dict {
    self = [super init];
    
    if (self) {
        
        [self setValuesFromDictionary:dict];
        
    }
    
    return self;
}
- (void)setValuesFromDictionary:(NSDictionary*)dict{
    self.strComment = (dict[@"comment"])? dict[@"comment"]:@"";
    self.likesCount = (dict[@"totalcommentlikes"]) ? [dict[@"totalcommentlikes"] intValue]:0;
    self.strCommentID = (dict[@"commentid"]) ? dict[@"commentid"] : @"";
    self.isLiked = (dict[@"islike"])?[dict[@"islike"] boolValue] : NO;
    User *objUser=[[User alloc]init];
    objUser.strName = (dict[@"username"]) ? dict[@"username"] : @"Dummy User";
    objUser.struserId = (dict[@"user_id"]) ? dict[@"user_id"] : @"0";
    objUser.strProfilePicThumb = (dict[@"user_picture"]) ? dict[@"user_picture"] : @"";
    _objUser = objUser;
    NSDateFormatter *datFormat = [[NSDateFormatter alloc]init];
    [datFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [datFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    _postDate = [datFormat dateFromString:dict[@"creationdate"]];
}

+ (id)commentWithMyDetails:(NSDictionary*)details forType:(NSString*)strType
{
    Comment* obj = [[self alloc] init];
    if (obj) {
        obj = [[super alloc] initUniqueInstancewithMyDetail:details];
        obj.commentType = strType;
        // Initialization code
    }
    return obj;
}
- (instancetype)initUniqueInstancewithMyDetail:(NSDictionary*)dict {
    self = [super init];
    
    if (self) {
        
        [self setValuesFromDictionaryForMe:dict];
        
    }
    
    return self;
}
- (void)setValuesFromDictionaryForMe:(NSDictionary*)dict{
    self.strComment = (dict[@"comment"])? dict[@"comment"]:@"";
    self.strCommentID = (dict[@"commentid"]) ? dict[@"commentid"] : @"";
    self.likesCount = 0;
    _objUser = [User currentUser];
    _postDate = [NSDate date];
}

@end
