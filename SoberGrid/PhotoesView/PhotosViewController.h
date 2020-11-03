//
//  FacebookPhotosViewController.h
//  PleaseIdentify
//
//  Created by Haresh Kalyani on 7/21/14.
//  Copyright (c) 2014 agilepc-38. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFDepthView.h"
@protocol PhotosViewControllerDelegate <NSObject>

- (void)photosViewControllerdidFinishPickingPhoto:(UIImage*)photo;

@end
@interface PhotosViewController : UIViewController {
    UICollectionView *eventCollectionView;
}
- (IBAction)btnCancel_Clicked:(UIButton *)sender;
@property (assign)BOOL isMyPhotoes;
@property (nonatomic,strong)NSMutableArray *arrFBPhotos;
@property (weak, nonatomic) JFDepthView* depthViewReference;
@property (weak, nonatomic) UIView* presentedInView;
@property (nonatomic,assign)id<PhotosViewControllerDelegate>delegate;
- (IBAction)closeView:(id)sender;
@end
