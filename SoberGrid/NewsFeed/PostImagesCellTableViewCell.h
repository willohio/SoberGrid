//
//  PostImagesCellTableViewCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/14/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//
#define kSG_Cell_height (isIPad)?150:100

#import <UIKit/UIKit.h>
#import "PostImagesCell.h"


@protocol PostImagesCellTableViewCellDelegate <NSObject>
@optional
- (void)postImagesCellTableViewCellCancelImageClickedForindex:(int)index;
- (void)postImagesCellTableViewCellPlayVideoClickedForindex:(int)index;
@end
@interface PostImagesCellTableViewCell : UITableViewCell <UICollectionViewDataSource,UICollectionViewDelegate,PostImagesCellDelegate>{
    UICollectionView *mainCollectionView;
    NSArray *arrTotalImages;
    BOOL isForVideo;
}
@property(nonatomic,assign)id<PostImagesCellTableViewCellDelegate>delegate;
- (void)customizeWithImagesArray:(NSArray*)arrImages ofVideo:(BOOL)status;
- (void)reloadDataWithImages:(NSArray*)arrImages ofVideo:(BOOL)status;
- (void)unload;
@end
