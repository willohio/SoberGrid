//
//  ViewImageIncemental.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/17/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGMedallionView.h"
#import "ApiClass.h"
#import "CommonApiCall.h"
@protocol ViewImageIncementalDelegate <NSObject>
- (void)imageClickedAtView:(UIView*)view;
@end

@interface ViewImageIncemental : UIView <UIAlertViewDelegate,ApiclassDelegate,CommonApiCallDelegate>
@property (nonatomic,assign)id<ViewImageIncementalDelegate>delegate;
@property (assign)int lastClicked;
@property (strong,nonatomic)NSMutableArray *arrImages;
- (void)customizewithProfileImages:(NSArray*)arrayImages;

- (void)setImageToLasttapped:(UIImage*)image;
- (void)refresh;

@end
