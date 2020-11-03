//
//  ViewBanner.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/22/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ViewBannerDelegate <NSObject>
- (void)viewBannerLike_ClickedWithSelectedState:(BOOL)state;
@end

@interface ViewBanner : UIView
@property (nonatomic,assign)id<ViewBannerDelegate>delegate;
- (instancetype)initWithFrame:(CGRect)frame customizeWithBannerUrl:(NSString*)strBannerUrl withProfileImageUrl:(NSString*)strProfileUrl withTitle:(NSString*)strTitle isLiked:(BOOL)liked LikeEnable:(BOOL)enable withDelegate:(id<ViewBannerDelegate>)delegate;
- (void)updateWithBannerUrl:(NSString*)strBannerUrl withProfileImageUrl:(NSString*)strProfileUrl withTitle:(NSString*)strTitle isLiked:(BOOL)liked withLikeEnable:(BOOL)enable;
- (void)enableLike:(BOOL)enable;
@end
