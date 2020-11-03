//
//  LikesViewController.h
//  SoberGrid
//
//  Created by agilepc-159 on 3/25/15.
//  Copyright (c) 2015 Agile Infoways Pvt. Ltd. All rights reserved.
//
typedef enum {
    kLikeOnPost,
    kLikeOnPage,
    kLikeOnCommentPost,
    kLikeOnCommentPage,
}kLikeOn;

#import <UIKit/UIKit.h>
#import "SGPost.h"
#import "Comment.h"


@interface LikesViewController : UIViewController{
    SGPost *_post;
    Comment *_comment;
}
@property (assign)kLikeOn likeOn;
- (void)setPost:(SGPost*)post;
- (void)setComment:(Comment*)comment;
@end
