//
//  LeftVC.h
//  SoberGrid
//
//  Created by Binty Shah on 9/2/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
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
