//
//  EventCollectionViewHelper.m
//  ScenePop
//
//  Created by Haresh Kalyani on 7/3/14.
//  Copyright (c) 2014 agilepc-38. All rights reserved.
//

#import "PICollectionViewHelper.h"

@implementation PICollectionViewHelper
- (id)initWithDelegate:(UIViewController *)delegate
{
    self = [super init];
    if (self) {
        _delegateVC = delegate;
        _mode=GRID_MODE;
        _arrPhotos = nil;
    }
    return self;
}
#pragma mark -
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   
    return _arrPhotos.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    if ([_mode isEqualToString:GRID_MODE]) {
        PICollcetionViewCell * eventCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
        NSString *strFilepath =[ NSTemporaryDirectory() stringByAppendingPathComponent:[_arrPhotos objectAtIndex:indexPath.row]];
        NSURL *fileUrl =[NSURL fileURLWithPath:strFilepath];
        [eventCell customizewithMediaURL:fileUrl];
        eventCell.tag = collectionView.tag;
        return eventCell;

    }
    
    
       return nil;
}

#pragma mark -
#pragma mark UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_arrPhotos.count > 0) {
        NSString *strFilepath =[ NSTemporaryDirectory() stringByAppendingPathComponent:[_arrPhotos objectAtIndex:indexPath.row]];
        NSURL *fileUrl =[NSURL fileURLWithPath:strFilepath];

        NSData *data = [NSData dataWithContentsOfURL:fileUrl];
        UIImage *img = [UIImage imageWithData:data];
       
         [_delegate didSelectitem:img];
        data = nil;
        img = nil;
        fileUrl = nil;
    }
   
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

    
}
//
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
//{
//
//}
//
//// These methods provide support for copy/paste actions on cells.
//// All three should be implemented if any are.
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//
//}
//
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//
//}
//
//// support for custom transition layout
//- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
//{
//
//}


#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_arrPhotos.count == 0) {
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
    }else{
        if ([_mode isEqualToString:GRID_MODE]) {
            if (_gridSize.width !=0 && _gridSize.height != 0) {
                return _gridSize;
            }
             return CGSizeMake(140, 140);
        }
        if ([_mode isEqualToString:LIST_MODE]) {
            if (_listSize.width !=0 && _listSize.height != 0) {
                return _listSize;
            }
            return CGSizeMake(320, 100);
        }
       
    }
    
    return CGSizeMake(0, 0);
  

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 1 , 0, 1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3;
}
//
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 3;
}
- (void)setUpCollectionView:(UICollectionView*)collectionView{
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(startRefresh:)
//             forControlEvents:UIControlEventValueChanged];
//    refreshControl.tintColor = [UIColor redColor];
//    [collectionView addSubview:refreshControl];
}
- (void)startRefresh:(UIRefreshControl*)refreshController{
   
    if (![refreshController isRefreshing]) {
    }
      [refreshController endRefreshing];
    
   
}

//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(320, 64);
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//
//}


@end
