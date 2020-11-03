//
//  VisitorFavBlockVC.h
//  SoberGrid
//
//  Created by Binty Shah on 9/10/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//


@interface VisitorFavBlockVC : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *arrFinalUsers;
}
@property BOOL isVisitor;
@property BOOL isFavotires;
@property BOOL isBlock;
@property (strong, nonatomic) IBOutlet UITableView *tblView;
@end
