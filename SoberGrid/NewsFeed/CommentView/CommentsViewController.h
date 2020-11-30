//
//  CommentsViewController.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/20/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SGPost.h"
#import "TPKeyboardAvoidingTableView.h"
@interface CommentsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    UITableView *tblComments;
    NSMutableArray *arrComments;
    SGPost            * _post;
    
}
@property (nonatomic,assign)BOOL            isPage;
-(void)setPost:(SGPost*)objPost;
@end
