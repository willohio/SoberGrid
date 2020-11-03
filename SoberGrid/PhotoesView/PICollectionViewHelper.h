//
//  EventCollectionViewHelper.h
//  ScenePop
//
//  Created by Haresh Kalyani on 7/3/14.
//  Copyright (c) 2014 agilepc-38. All rights reserved.
//

#define GRID_MODE @"1"
#define LIST_MODE @"2"

#import <Foundation/Foundation.h>

#import "PICollcetionViewCell.h"
@protocol PICollectionViewHelperDelegate<NSObject>

@optional
- (void)didSelectitem:(id)item;
@end


@interface PICollectionViewHelper : NSObject <UICollectionViewDataSource,UICollectionViewDelegate>
{
    UIViewController * _delegateVC;
}
@property (nonatomic,strong)NSMutableArray *arrPhotos;
@property (nonatomic,strong)NSString *mode;
@property (nonatomic,assign)id<PICollectionViewHelperDelegate>delegate;
@property (nonatomic,assign)CGSize gridSize;
@property (nonatomic,assign)CGSize listSize;
- (id)initWithDelegate:(UIViewController *)delegateVC;
- (void)setUpCollectionView:(UICollectionView*)collectionView;


@end
