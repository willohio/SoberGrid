//
//  Comment.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/22/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//
#define kCommentApi @"Add_likeunlike_comment"
#import <Foundation/Foundation.h>
#import "User.h"
@interface Comment : NSObject
+ (id)commentWithDetails:(NSDictionary*)details forType:(NSString*)strType;
+ (id)commentWithMyDetails:(NSDictionary*)details forType:(NSString*)strType;
@property (nonatomic,copy)User *objUser;
@property (nonatomic,strong)NSString *strCommentID;
@property (nonatomic,strong)NSString *strComment;
@property (nonatomic,strong)NSDate *postDate;
@property (nonatomic,strong)NSString *strImageUrl;
@property (nonatomic,strong)NSString *strVideoUrl;
@property (nonatomic,strong)NSString *commentType;
@property (nonatomic,assign)BOOL isLiked;
@property (nonatomic,assign)int likesCount;
- (void)setValuesFromDictionary:(NSDictionary*)dict;

@end
