//
//  FilterVC.m
//  SoberGrid
//
//  Created by William Santiago on 9/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//
typedef enum {
    kFilterTypeOnline,
    kFilterTypePhotos,
    kFilterTypeRehab,
    kFilterTypeAge,
    kFilterTypeDistance,
    kFilterTypeGender,
    kFilterTypeOrientation,
    kFilterTypeRelationship,
    kFilterTypeSeeking,
    kFilterTypeClear,
}kFilterType;

#import "FilterVC.h"
#import "NSObject+ConvertingViewPixels.h"
#import "SoberGridIAPHelper.h"
#import "SGGroup.h"
@interface FilterVC ()

@end

@implementation FilterVC
@synthesize tblView,pickerView,picker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setHidden:FALSE];
    pickerView.backgroundColor=[UIColor lightGrayColor];
    pickerView.tintColor=[UIColor whiteColor];
    pickerView.hidden=TRUE;
    
    
    ageStartData=[[NSMutableArray alloc]init];
    ageEndData=[[NSMutableArray alloc]init];
    
    for(int i=18;i<=100;i++)
    {
        [ageStartData addObject:[NSString stringWithFormat:@"%d",i]];
    }
    for(int i=100;i>17;i--)
    {
        [ageEndData addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    tblView.separatorStyle=UITableViewCellSeparatorStyleNone;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.title=@"Filter";
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(btnDone_Clicked:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    UIBarButtonItem * leftBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(btnCancel_Clicked:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    
    
    [self.view bringSubviewToFront:lblExample];
}

-(void)viewDidDisappear:(BOOL)animated
{
    
}

-(void)btnCancel_Clicked:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)btnDone_Clicked:(UIButton*)sender{
    if (_lastOpenIndexpath) {
        [self closeOtherRowforIndexPath:_lastOpenIndexpath];
    }
    
    [_objFilter copyToObject:[Filter sharedInstance]];
    _objFilter = nil;
    [_delegate filterVCDoneClicked];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Tableview In Pullview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >=kFilterTypeOnline && indexPath.row <=kFilterTypeAge ) {
        // For Switches
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SwithCell"];
        if (cell == nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SwithCell"];
            cell.backgroundColor=[UIColor clearColor];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        UISwitch *switchView;
        if (indexPath.row == kFilterTypeOnline  || indexPath.row == kFilterTypePhotos || indexPath.row == kFilterTypeRehab) {
            switchView = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 5, 50, 30)];
            
            [switchView addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            switchView.tag=indexPath.row;
            [cell.contentView addSubview:switchView];
        }
        if(indexPath.row==kFilterTypeOnline){
            cell.textLabel.text=[NSString stringWithFormat:NSLocalizedString(@"Online Users Only", nil)];
            [switchView setOn:_objFilter.onlyOnline];
        }
        else if (indexPath.row==kFilterTypePhotos){
            cell.textLabel.text=[NSString stringWithFormat:NSLocalizedString(@"Photos", nil)];
            [switchView setOn:_objFilter.onlyPhotoes];
            
        }else if (indexPath.row == kFilterTypeRehab){
            cell.textLabel.text=[NSString stringWithFormat:NSLocalizedString(@"My Rehab Alumni Group", nil)];
            [switchView setOn:_objFilter.onlyRehabGroup];
            
        }
        else{
            cell.textLabel.text=[NSString stringWithFormat:NSLocalizedString(@"All Ages", nil)];
            if (_objFilter.minimumAge != 0 && _objFilter.maximumAge != 0) {
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%d - %d",_objFilter.minimumAge,_objFilter.maximumAge];
            }else{
                cell.detailTextLabel.text = @" ";
            }
            
        }
        cell.textLabel.font = SGREGULARFONT(17.0);
        return cell;
    }
    else if(indexPath.row == kFilterTypeClear){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clearcell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clearcell"];
        }
        UIButton * btnClear=[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2 - [self deviceSpesificValue:50], [self deviceSpesificValue:40] - [self deviceSpesificValue:15], [self deviceSpesificValue:100], [self deviceSpesificValue:30])];
        [btnClear setTitle:NSLocalizedString(@"Clear", nil) forState:UIControlStateNormal];
        btnClear.titleLabel.font = SGREGULARFONT(17.0);
        btnClear.layer.cornerRadius = btnClear.frame.size.height/2;
        btnClear.backgroundColor = [UIColor redColor];
        [btnClear addTarget:self action:@selector(clearFilter_clicked) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnClear];
        btnClear = nil;
        return cell;
        
    }else
    {
        ExpandableCell *exCell=[tableView dequeueReusableCellWithIdentifier:@"ExpandableCell"];
        if (exCell == nil) {
            exCell = [[ExpandableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ExpandableCell"];
        }
        BOOL expand=false;
        if ([_dictExpandingRowDetail objectForKey:@"index"]) {
            NSIndexPath *index=[_dictExpandingRowDetail objectForKey:@"index"];
            if (index.row == indexPath.row) {
                expand = true;
            }
        }
        else if (indexPath.row == kFilterTypeDistance) {
            [exCell customizeWithOptions:_objFilter.arrOptionsForDistance withselectedOptions:_objFilter.arrSelectedDistance forTitle:NSLocalizedString(@"Distance", nil) Expand:expand withMultipleSupport:false withOtherOption:NO];
        }
        else if (indexPath.row == kFilterTypeGender) {
            [exCell customizeWithOptions:_objFilter.arrOptionsForGender withselectedOptions:_objFilter.arrSelectedGender forTitle:NSLocalizedString(@"Gender", nil) Expand:expand withMultipleSupport:true withOtherOption:NO];
        }
        else if (indexPath.row == kFilterTypeOrientation) {
            [exCell customizeWithOptions:_objFilter.arrOptionsForOrientation withselectedOptions:_objFilter.arrSelectedOrientation forTitle:NSLocalizedString(@"Orientation", nil) Expand:expand withMultipleSupport:true withOtherOption:NO];
        }
        else if (indexPath.row == kFilterTypeRelationship) {
            [exCell customizeWithOptions:_objFilter.arrOptionsForRStatus withselectedOptions:_objFilter.arrSelectedRStatus forTitle:NSLocalizedString(@"Relationship status", nil) Expand:expand withMultipleSupport:true withOtherOption:NO];
        }
        else if (indexPath.row == kFilterTypeSeeking) {
            [exCell customizeWithOptions:_objFilter.arrOptionsForSeeking withselectedOptions:_objFilter.arrSelectedSeeking forTitle:NSLocalizedString(@"Seeking", nil) Expand:expand withMultipleSupport:true withOtherOption:NO];
        }
        
        return exCell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kFilterTypeClear) {
        return [self deviceSpesificValue:80];
    }
    if ([_dictExpandingRowDetail objectForKey:@"index"]) {
        NSIndexPath *index=[_dictExpandingRowDetail objectForKey:@"index"];
        if (index.row == indexPath.row) {
            return [[_dictExpandingRowDetail objectForKey:@"height"] floatValue];
        }
    }
    return [self deviceSpesificValue:40];
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[ExpandableCell class]]) {
        ExpandableCell *exCell=(ExpandableCell*)cell;
        [exCell unload];
    }else{
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self PickerViewHidden:true];
    
    // For expanding cell
    if (indexPath.row >=kFilterTypeDistance && indexPath.row <=kFilterTypeSeeking) {
        ExpandableCell *selectedcell =(ExpandableCell*) [tableView cellForRowAtIndexPath:indexPath];
        CGFloat totalHeight = [selectedcell totalHeight];
        if ([_dictExpandingRowDetail objectForKey:@"index"]) {
            NSIndexPath *index=[_dictExpandingRowDetail objectForKey:@"index"];
            if (index.row == indexPath.row) {
                if (indexPath.row == kFilterTypeDistance) {
                    _objFilter.arrSelectedDistance = [selectedcell.selectedOptions mutableCopy];
                }
                else if (indexPath.row == kFilterTypeGender) {
                    _objFilter.arrSelectedGender = [selectedcell.selectedOptions mutableCopy];
                }
                else if (indexPath.row == kFilterTypeOrientation) {
                    _objFilter.arrSelectedOrientation = [selectedcell.selectedOptions mutableCopy];
                }
                else if (indexPath.row == kFilterTypeRelationship) {
                    _objFilter.arrSelectedRStatus = [selectedcell.selectedOptions mutableCopy];
                }
                else if (indexPath.row == kFilterTypeSeeking) {
                    _objFilter.arrSelectedSeeking = [selectedcell.selectedOptions mutableCopy];
                }
                //                else if (indexPath.row == 8){
                //                    _objFilter.arrSelectedFellowship = [selectedcell.selectedOptions mutableCopy];
                //                }
                _dictExpandingRowDetail = [[NSMutableDictionary alloc] init];
                [selectedcell collapse];
                [tblView beginUpdates];
                [tblView endUpdates];
                return;
            }
        }
        
        _dictExpandingRowDetail = [[NSMutableDictionary alloc] init];
        [_dictExpandingRowDetail setObject:indexPath forKey:@"index"];
        [_dictExpandingRowDetail setObject:[NSString stringWithFormat:@"%f",totalHeight] forKey:@"height"];
        NSMutableArray *arrIndexpath=[[NSMutableArray alloc]init];
        [arrIndexpath addObject:indexPath];
        if (_lastOpenIndexpath && _lastOpenIndexpath.row != indexPath.row) {
            [arrIndexpath addObject:_lastOpenIndexpath];
            [self closeOtherRowforIndexPath:_lastOpenIndexpath];
        }
        [selectedcell expand];
        [tblView beginUpdates];
        [tblView endUpdates];
        _lastOpenIndexpath = indexPath;
        
    }
    
    // For pickers
    if (indexPath.row == kFilterTypeAge) {
        [self PickerViewHidden:FALSE];
    }
}

- (IBAction)pickerDone_Clicked:(UIBarButtonItem *)sender {
    [self PickerViewHidden:TRUE];
}
- (void)closeOtherRowforIndexPath:(NSIndexPath*)indexPath{
    ExpandableCell *selectedcell =(ExpandableCell*) [tblView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == kFilterTypeDistance) {
        _objFilter.arrSelectedDistance = [selectedcell.selectedOptions mutableCopy];
    }
    if (indexPath.row == kFilterTypeGender) {
        _objFilter.arrSelectedGender = [selectedcell.selectedOptions mutableCopy];
    }
    if (indexPath.row == kFilterTypeOrientation) {
        _objFilter.arrSelectedOrientation = [selectedcell.selectedOptions mutableCopy];
    }
    if (indexPath.row == kFilterTypeRelationship) {
        _objFilter.arrSelectedRStatus = [selectedcell.selectedOptions mutableCopy];
    }
    if (indexPath.row == kFilterTypeSeeking) {
        _objFilter.arrSelectedSeeking = [selectedcell.selectedOptions mutableCopy];
    }
    [selectedcell collapse];
    
}
#pragma mark - PickerView Delegate methods

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView1
{
    return 2;
    
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView1 numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0){
        return ageStartData.count+1;
    }
    else{
        return ageEndData.count;
    }
    
    
}

- (NSString*)pickerView:(UIPickerView *)pickerView1 titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if(component == 0)
        return [ageStartData objectAtIndex:row];
    else
        return [ageEndData objectAtIndex:row];
    
    
    
}

- (void)pickerView:(UIPickerView *)pickerView1 didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UITableViewCell *cell=[tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kFilterTypeAge inSection:0]];
    
    NSString *string=[NSString stringWithFormat:@"%@ - %@",[ageStartData objectAtIndex:[pickerView1 selectedRowInComponent:0]],[ageEndData objectAtIndex:[pickerView1 selectedRowInComponent:1]]];
    _objFilter.minimumAge =[[ageStartData objectAtIndex:[pickerView1 selectedRowInComponent:0]] intValue];
    _objFilter.maximumAge =[[ageEndData objectAtIndex:[pickerView1 selectedRowInComponent:1]] intValue];
    cell.detailTextLabel.text=string;
    
}

-(void)PickerViewHidden:(BOOL)sender
{
    if(!sender)
    {
        pickerView.hidden=FALSE;
        [picker reloadAllComponents];
    }
    else
    {
        pickerView.hidden=TRUE;
        
    }
}

#pragma mark - UISwitch Action

- (IBAction)changeSwitch:(UISwitch *)sender
{
    if (sender.tag == kFilterTypeOnline) {
        _objFilter.onlyOnline = sender.on;
        
    }
    if (sender.tag == kFilterTypePhotos) {
        if ([[SoberGridIAPHelper sharedInstance] getTypeOfSubsciption] == kSGSubscriptionTypeNone) {
            [[SoberGridIAPHelper sharedInstance] showAlertForActivatePack];
            [sender setOn:false];
            return;
        }
        _objFilter.onlyPhotoes = sender.on;
    }
    if (sender.tag == kFilterTypeRehab) {
        NSArray *arrGroups = [SGGroup getAllJoinedGroups];
        if (arrGroups.count > 0) {
            _objFilter.onlyRehabGroup = sender.on;
        }else{
            [sender setOn:false];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"You must join a Rehab Alumni Group before you can use this feature" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }
    }
}
- (IBAction)clearFilter_clicked{
    
    [_objFilter clearFilter];
    [[Filter sharedInstance] clearFilter];
    [tblView reloadData];
    [_delegate clearFilterClicked];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    tblView = nil;
}
@end

