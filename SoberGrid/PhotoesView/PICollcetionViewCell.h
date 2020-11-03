//
//  EventCollcetionViewCell.h
//  ScenePop
//
//  Created by Haresh Kalyani on 7/3/14.
//  Copyright (c) 2014 agilepc-38. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface PICollcetionViewCell : UICollectionViewCell
    

@property (nonatomic,strong)UIImageView *playView;

- (void)customizewithMediaURL:(NSURL *)url;

-(void)unload;
@end
