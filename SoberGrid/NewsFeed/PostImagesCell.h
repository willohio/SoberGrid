//
//  PostImagesCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/14/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PostImagesCellDelegate <NSObject>
@optional
- (void)postImageCellCancelButtonClicked:(UITableViewCell*)cell;
- (void)postImageCellPlayButtonClicked:(UITableViewCell*)cell;

@end
@interface PostImagesCell : UICollectionViewCell
{
    UIImageView *imgView;
    UIButton    *btnCancel;
    UIView      *viewTouch;
    UIButton    *btnPlay;
}
@property (nonatomic,assign)id<PostImagesCellDelegate>delegate;
- (void)customizeWithImage:(UIImage*)image forSize:(CGSize)size ofTypeVideo:(BOOL)status;
- (void)unload;
@end
