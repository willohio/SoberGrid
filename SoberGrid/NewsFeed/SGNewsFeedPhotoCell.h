//
//  SGNewsFeedPhotoCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/9/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SGPostPhoto.h"
#import "SGPostStatus.h"
#import "SGNewsFeedBubbleCell.h"
#import "UHLabel.h"
@interface SGNewsFeedPhotoCell : SGNewsFeedBubbleCell <CommonApiCallDelegate>{
    UHLabel         *lblLikesAndComments;
    UHLabel         *lblDiscription;
    NSString        *postType;
    id               _feedPost;
    SGPostPhoto     *_post;
    SGPostPage      *_page;
    SGPostStatus    *_postStatus;
  
}
@property (nonatomic,strong)UIImageView     *imgViewPost;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withLine:(BOOL)status;
- (void)customizeWithPost:(id)post withFullVersion:(BOOL)status forType:(NSString*)strType;
+ (CGFloat)getHeightForPost:(SGPostPhoto*)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus;
+ (CGFloat)getHeightForPage:(SGPostPage *)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus;
+ (CGFloat)getHeightAccordingToPost:(id)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus;
+ (CGFloat)getHeightWithoutLikeAndCommentAccordintToPost:(id)post withFullVersion:(BOOL)status withLine:(BOOL)lineStatus;
@end
