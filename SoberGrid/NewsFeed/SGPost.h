//
//  SGPost.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/28/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
@interface SGPost : NSObject
@property (nonatomic,copy)User *objUser;
@property (nonatomic,strong)NSString        *strFeedId;
@property (nonatomic,strong)NSDate          *datePosted;
@property (nonatomic,strong)NSString        *strLocation;
@property (nonatomic,strong)NSString        *strIsHide;
@property (nonatomic,strong)NSString        *strIsLike;
@property (nonatomic,assign)int              likesCount;
@property (nonatomic,assign)int              commentsCount;
@property (nonatomic,strong)NSMutableArray  *arrLikedUsers;
@property (nonatomic,strong)NSMutableArray  *arrCommentedUsers;

@end
