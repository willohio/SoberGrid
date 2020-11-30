//
//  NewsFeedButtonsView.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGRoundButton.h"
@protocol NewsFeedButtonsViewDelegate <NSObject>
@optional
- (void)btnLike_Clicked:(UIButton*)sender;
- (void)btnComment_Clicked:(UIButton*)sender;
- (void)btnShare_Clicked:(UIButton*)sender;
@end

@interface NewsFeedButtonsView : UIView{
    SGRoundButton *btnLike,*btnComment,*btnShare;
}
@property (nonatomic,assign)id <NewsFeedButtonsViewDelegate>delegate;
- (void)setLikeStatus:(BOOL)status forPage:(BOOL)isPage;
- (void)hideLike;
- (void)hideComment;

@end
