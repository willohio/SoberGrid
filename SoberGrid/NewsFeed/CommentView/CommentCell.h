//
//  CommentCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/22/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupedCell.h"
#import "Comment.h"
#import "UHLabel.h"
@protocol CommentCellDelegate <NSObject>
- (void)likeClickedForComment:(Comment*)cmt;
- (void)commentCellDidSelectedProfileWithUser:(User*)user;
@end
@interface CommentCell : GroupedCell<TTTAttributedLabelDelegate,CommonApiCallDelegate>{
   
    UIImageView *imgProfile;
    UHLabel     *lblUserName;
    
    UHLabel     *lblComment;
    UHLabel     *lblDate;
    UILabel     *lblLikes;
    Comment     *objCmt;
    UIButton    *btnLike;
    
}
@property (nonatomic,assign)id<CommentCellDelegate>delegate;
@property (nonatomic, strong)UIImageView *imgProfile;
@property (nonatomic, strong)UHLabel     *lblUserName;
@property (nonatomic, strong)UHLabel     *lblComment;
@property (nonatomic, strong)UHLabel     *lblDate;
@property (nonatomic, strong)UILabel     *lblLikes;
@property (nonatomic, strong)Comment     *objCmt;
@property (nonatomic, strong)UIButton    *btnLike;

- (void)customizeWithComment:(Comment*)cmt;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDelegate:(id<CommentCellDelegate>)delegate;

+ (CGFloat)getHeightForCellForComment:(Comment*)cmt;


@end
