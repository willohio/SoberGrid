//
//  LeftVC.h
//  SoberGrid
//
//  Created by William Santiago on 9/2/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "ProfileVC.h"
#import "GridViewController.h"


@class MainVC;
@interface LeftVC : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tblView;
@property (assign, nonatomic) ProfileVC *profileView;
@property(assign,nonatomic)GridViewController *centerView;
@property (nonatomic) UIActivityViewController *activityViewController;

@end
