//
//  VisitorFavBlockVC.h
//  SoberGrid
//
//  Created by William Santiago on 9/10/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//


@interface VisitorFavBlockVC : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *arrFinalUsers;
}
@property BOOL isVisitor;
@property BOOL isFavotires;
@property BOOL isBlock;
@property (strong, nonatomic) IBOutlet UITableView *tblView;
@end
