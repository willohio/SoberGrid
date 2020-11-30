//
//  FilterVC.h
//  SoberGrid
//
//  Created by William Santiago on 9/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "ExpandableCell.h"
#import "Filter.h"

@protocol FilterDelegate <NSObject>

- (void)filterVCDoneClicked;
- (void)clearFilterClicked;

@end

@interface FilterVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIToolbarDelegate>
{
    NSArray *distanceData,*genderData;
    NSMutableArray *ageStartData,*ageEndData;
    UILabel *lblAgeRange,*lblDistance,*lblGender,*lblOrientation,*lblRelationStatus,*lblSeeking;
    IBOutlet UILabel *lblExample;
}

@property (assign)id<FilterDelegate>delegate;
@property (strong, nonatomic)Filter          *objFilter;
@property (strong, nonatomic) NSIndexPath    *lastOpenIndexpath;
@property (strong, nonatomic) NSMutableDictionary *dictExpandingRowDetail;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (strong, nonatomic) IBOutlet UITableView *tblView;
- (IBAction)pickerDone_Clicked:(UIBarButtonItem *)sender;
@end
