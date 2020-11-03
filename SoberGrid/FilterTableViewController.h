//
//  FilterTableViewController.h
//  SoberGrid
//
//  Created by Sajid Israr on 8/10/15.
//  Copyright (c) 2015 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Filter.h"

@protocol NewsFeedFilterDelegate <NSObject>

- (void)filterDone_Pressed;

@end

@interface FilterTableViewController : UITableViewController

@property (nonatomic, assign) id<NewsFeedFilterDelegate> delegate;

@property (nonatomic, strong) Filter *objFilter;

@end
