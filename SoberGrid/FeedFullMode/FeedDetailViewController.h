//
//  FeedDetailViewController.h
//  SoberGrid
//
//  Created by agilepc-159 on 7/15/15.
//  Copyright (c) 2015 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGPost.h"
@interface FeedDetailViewController : UIViewController{
    SGPost            * _post;

}
-(void)setPost:(SGPost*)objPost;
@end
