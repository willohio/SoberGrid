//
//  EditProfileViewController.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/15/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpandableCell.h"
#import "TextEditerCell.h"
#import "User.h"
#import "TPKeyboardAvoidingTableView.h"

@interface EditProfileViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,TextEditerCellDelegate>
@property (strong,nonatomic)User *objUser;
@property (strong, nonatomic) IBOutlet UIView *viewDatePickerHolder;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingTableView *tblView;
@property (strong,nonatomic)NSIndexPath *lastOpenIndexpath;

@property (strong,nonatomic)NSMutableDictionary *dictExpandingRowDetail;
@property (strong, nonatomic) IBOutlet UIDatePicker *birthdatePicker;
- (IBAction)datePickerChangedValue:(UIDatePicker *)sender;

@end
