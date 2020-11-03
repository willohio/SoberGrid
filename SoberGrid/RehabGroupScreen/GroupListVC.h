//
//  GroupListVC.h
//  SoberGrid
//
//  Created by agilepc-159 on 7/4/15.
//  Copyright (c) 2015 Agile Infoways Pvt. Ltd. All rights reserved.
//
static NSInteger groupLimit = 5;

#import <UIKit/UIKit.h>
@protocol GroupListVCDelegate <NSObject>
- (void)groupListDidSelectedOptionAtIndex:(NSInteger)index;
- (void)groupListDidSelectedOptionMore;
@end

@interface GroupListVC : UIViewController
@property(nonatomic,assign)id<GroupListVCDelegate>delegate;
- (void)setGroups:(NSArray*)groups;
@end
