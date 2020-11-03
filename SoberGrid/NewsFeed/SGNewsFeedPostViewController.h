//
//  ACEViewController.h
//  ACEExpandableTextCellDemo
//
//  Created by Stefano Acerbetti on 6/5/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostImagesCellTableViewCell.h"
@protocol SGNewsFeedPostDelegate <NSObject>
@optional
- (void)sgnewsFeedPostPostedThePost:(id)post;
@end

@interface SGNewsFeedPostViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PostImagesCellTableViewCellDelegate>
{
    UITableView *tblView;
    NSMutableArray *arrImages;
    int postType;
    NSURL *urlVideo;
}
@property (assign)BOOL isTypeMedia;
@property (nonatomic,assign)id<SGNewsFeedPostDelegate>delegate;
@end
