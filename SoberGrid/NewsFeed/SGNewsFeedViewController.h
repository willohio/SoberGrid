//
//  SGNewsFeedViewController.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#define kStatusCellIdentifier @"statusCell"
#define kPhotosCellIdentifier @"photoCell"
#define kVideoCellIdentifier  @"videoCell"
#define kPageCellIdentifier   @"pageCell"

#define API_GET_NEWS_FEED  @"news_feed"


#define kSGNEWSFEED_HEADER_HEIGHT 44


#import <UIKit/UIKit.h>
#import "SGNavigationController.h"
#import "MEAlertView.h"
@interface SGNewsFeedViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    UITableView *tblNewsFeed;
    NSMutableArray  *arrOnlyImages;
    int pagNo;
    BOOL isApiRunning;
    NSInteger pageOffset;
    NSMutableArray *arrBlockedUsers;
    NSMutableArray *arrDeletedPost;
}
@property (nonatomic,strong)    NSMutableArray *arrPosts;

@property (nonatomic) UIActivityViewController *activityViewController;

@end
