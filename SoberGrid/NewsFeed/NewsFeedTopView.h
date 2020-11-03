//
//  NewsFeedTopView.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/10/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "NSDate+NVTimeAgo.h"
#import "UHLabel.h"
#import "SGPostPage.h"
@protocol NewsFeedTopViewDelegate <NSObject>
@optional
- (void)profileViewTapped:(UIView*)view;
- (void)blockOptionClicked:(UIView*)view;
@end

@interface NewsFeedTopView : UIView{
    UHLabel *lblUserName;
    UIImageView *imgeUser;
    UHLabel *lblDate;
    UIView *viewDisclosure;
}



- (void)setPage:(SGPostPage*)page;
- (void)setUser:(User*)user withPostDate:(NSDate*)date withMoodMessage:(NSString*)moodMessage;

@property (nonatomic,assign)id<NewsFeedTopViewDelegate>delegate;
@property (nonatomic,copy)SGPostPage *objPage;
@property (nonatomic,copy)User *objUser;
@property (nonatomic,assign)NSDate *postDate;
@property (nonatomic,assign)NSString *moodMessage;

@end
