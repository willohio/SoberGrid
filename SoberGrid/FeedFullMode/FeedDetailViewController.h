//
//  FeedDetailViewController.h
//  SoberGrid
//
//  Created by agilepc-159 on 7/15/15.
//  Copyright (c) 2015 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGPost.h"
@interface FeedDetailViewController : UIViewController{
    SGPost            * _post;

}
-(void)setPost:(SGPost*)objPost;
@end
