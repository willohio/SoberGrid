//
//  PostImagesCellTableViewCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/14/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "PostImagesCellTableViewCell.h"

@implementation PostImagesCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)customizeWithImagesArray:(NSArray*)arrImages ofVideo:(BOOL)status{
    isForVideo = status;
    arrTotalImages = arrImages;
    [self createCollectionviewwithCount:(int)arrImages.count];
}

- (void)createCollectionviewwithCount:(int)count{
    // UICollection View
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    mainCollectionView.scrollEnabled=TRUE;
    CGFloat height;
    if (count % 5 == 0) {
        height = kSG_Cell_height *(int)(count / ((isIPad)?5:3));
    }else{
        
        height = kSG_Cell_height * (int)((count / ((isIPad)?5:3))+ 1 );
    }
    mainCollectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), height) collectionViewLayout:layout];
    layout.minimumLineSpacing = (isIPad) ? 2 : 5;
    
    [mainCollectionView setDataSource:self];
    [mainCollectionView setDelegate:self];
    [mainCollectionView registerClass:[PostImagesCell class] forCellWithReuseIdentifier:@"PostCell"];
    [mainCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:mainCollectionView];
    
    
}
#pragma mark - Collection View delegate methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
        return arrTotalImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
        PostImagesCell * postCell = [collectionView1 dequeueReusableCellWithReuseIdentifier:@"PostCell" forIndexPath:indexPath];
        postCell.delegate=self;
        [postCell customizeWithImage:arrTotalImages[indexPath.row] forSize:CGSizeMake(kSG_Cell_height, kSG_Cell_height) ofTypeVideo:isForVideo];
        return postCell;
   
    
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
        return CGSizeMake(kSG_Cell_height, kSG_Cell_height);
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0;
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[PostImagesCell class]]) {
        PostImagesCell *pCell=(PostImagesCell*)cell;
        [pCell unload];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}
- (void)postImageCellCancelButtonClicked:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [mainCollectionView indexPathForCell:(PostImagesCell*)cell];
    [_delegate postImagesCellTableViewCellCancelImageClickedForindex:(int)indexPath.row];
    
}
- (void)postImageCellPlayButtonClicked:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [mainCollectionView indexPathForCell:(PostImagesCell*)cell];
    [_delegate postImagesCellTableViewCellPlayVideoClickedForindex:(int)indexPath.row];

}
- (void)reloadDataWithImages:(NSArray*)arrImages ofVideo:(BOOL)status{
    isForVideo = status;
    arrTotalImages = arrImages;
    CGFloat height;
    if (arrImages.count % 5 == 0) {
        height = kSG_Cell_height *(int)(arrImages.count / ((isIPad)?5:3));
    }else{
        
        height = kSG_Cell_height * (int)((arrImages.count / ((isIPad)?5:3))+ 1 );
    }
    mainCollectionView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), height);
    [mainCollectionView reloadData];
}
- (void)unload{
    [mainCollectionView removeFromSuperview];
    arrTotalImages = nil;
    mainCollectionView = nil;
}
- (void)dealloc{
    arrTotalImages = nil;
    mainCollectionView = nil;
}
@end
