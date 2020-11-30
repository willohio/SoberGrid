//
//  EditProfileViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/15/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

typedef enum {
    kEditProfileCellTypeName,
    kEditProfileCellTypeAbout,
    kEditProfileCellTypeDOB,
    kEditProfileCellTypeSDate,
    kEditProfileCellTypeSobeity,
    kEditProfileCellTypeCityName,
    kEditProfileCellTypeRehabGroup,
    kEditProfileCellTypeGender,
    kEditProfileCellTypeOrientation,
    kEditProfileCellTypeRelStatus,
    kEditProfileCellTypeSeeking,
    kEditProfileCellTypeAGiveRide,
    kEditProfileCellTypeLMeetUp,
}kEditProfileCellType;

#import "EditProfileViewController.h"
#import "Filter.h"
#import "NSDate+Utilities.h"
#import "ACEExpandableTextCell.h"
#import "NSObject+ConvertingViewPixels.h"
#import "RehabGroupViewController.h"

@interface EditProfileViewController ()<ACEExpandableTableViewDelegate>
{
    CGFloat _cellHeight[1];
}
@property (nonatomic, strong) NSMutableArray *cellData;

@end

@implementation EditProfileViewController

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
    _objUser = [[User alloc]init];
    [_objUser createUserWithDict:nil];
    UIBarButtonItem *button=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(btnDone_Clicked)];
    self.navigationItem.rightBarButtonItem=button;
    
    self.title =NSLocalizedString(@"Edit Profile", nil);
    
    // Age limit of 18
    
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    
    
}
- (void)viewWillDisappear:(BOOL)animated{
    // IT WAS CRASHING SO I PUT IT
    [self.view endEditing:YES];
    if ([self isMovingFromParentViewController]) {
        ACEExpandableTextCell *exCell =(ACEExpandableTextCell*) [_tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [exCell unload];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - Tableview Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 13;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kEditProfileCellTypeName) {
        TextEditerCell *tcell=[tableView dequeueReusableCellWithIdentifier:@"tEditor"];
        if (tcell == nil) {
            tcell = [[TextEditerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tEditor"];
        }
        
        [tcell customizeWithText:(_objUser.strName)?_objUser.strName : @"" andPlaceHolder:@"Username" andAge:@"24" isEditable:true withTextLimit:15];
        tcell.delegate=self;
        return tcell;
    }
    else  if (indexPath.row == kEditProfileCellTypeAbout) {
        
        
        ACEExpandableTextCell *cell = [tableView expandableTextCellWithId:@"cellId"];
        cell.text = _objUser.strAboutMe;
        
        cell.textView.placeholder = NSLocalizedString(@"Write Something about you!", nil);
        [cell customizeForAbout];
        return cell;
        
    }
    
    else  if (indexPath.row == kEditProfileCellTypeDOB) {
        // For Switches
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SwithCell"];
        if (cell == nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SwithCell"];
            cell.backgroundColor=[UIColor clearColor];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text=@"DOB";
        cell.textLabel.font = SGREGULARFONT(17.0);
        cell.textLabel.textColor = [UIColor blackColor];
        
        if (_objUser.birthDate) {
            cell.detailTextLabel.text=[_objUser.birthDate formattedStringwithFormat:@"MMM d yyyy"];
            
        }else
            cell.detailTextLabel.text=@"  ";
        
        
        // Accessorview
        UIView* viewDisclosure=[[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)-35, 0, 40, 40)];
        viewDisclosure.backgroundColor=[UIColor clearColor];
        viewDisclosure.tag = 5001;
        
        UIImageView *imgDisclosure=[[UIImageView alloc]initWithFrame:CGRectMake(13, 13, 15, 15)];
        imgDisclosure.image=[UIImage imageNamed:@"disclosure_closed.png"];
        
        imgDisclosure.contentMode=UIViewContentModeScaleAspectFill;
        [viewDisclosure addSubview:imgDisclosure];
        [cell.contentView addSubview:viewDisclosure];
        return cell;
    }
    else  if (indexPath.row == kEditProfileCellTypeSDate) {
        // For Switches
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SwithCell"];
        if (cell == nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SwithCell"];
            cell.backgroundColor=[UIColor clearColor];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text=NSLocalizedString(@"Sobriety Date", nil);
        cell.textLabel.font = SGREGULARFONT(17.0);
        cell.textLabel.textColor = [UIColor blackColor];
        
        if (_objUser.dateSoberity) {
            cell.detailTextLabel.text=[_objUser.dateSoberity formattedStringwithFormat:@"MMM d yyyy"];
            
        }else
            cell.detailTextLabel.text=@"  ";
        
        
        // Accessorview
        UIView* viewDisclosure=[[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)-35, 0, 40, 40)];
        viewDisclosure.backgroundColor=[UIColor clearColor];
        viewDisclosure.tag = 5001;
        
        UIImageView *imgDisclosure=[[UIImageView alloc]initWithFrame:CGRectMake(13, 13, 15, 15)];
        imgDisclosure.image=[UIImage imageNamed:@"disclosure_closed.png"];
        
        imgDisclosure.contentMode=UIViewContentModeScaleAspectFill;
        [viewDisclosure addSubview:imgDisclosure];
        [cell.contentView addSubview:viewDisclosure];
        return cell;
    }
    else   if (indexPath.row == kEditProfileCellTypeSobeity)
    {
        // For Switches
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SwithCell"];
        if (cell == nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SwithCell"];
            cell.backgroundColor=[UIColor clearColor];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        UISwitch *switchView= [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 5, 50, 30)];
        
        [switchView addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        switchView.tag=indexPath.row;
        [cell.contentView addSubview:switchView];
        cell.textLabel.text=[NSString stringWithFormat:NSLocalizedString(@"Sobriety", nil)];
        [switchView setOn:_objUser.showSoberDate];
        cell.textLabel.font = SGREGULARFONT(17.0);
        return cell;
    }
    
    else  if (indexPath.row == kEditProfileCellTypeCityName) {
        TextEditerCell *tcell=[tableView dequeueReusableCellWithIdentifier:@"tEditor"];
        if (tcell == nil) {
            tcell = [[TextEditerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tEditor"];
        }
        
        [tcell customizeWithText:(_objUser.strCity)?_objUser.strCity : @"" andPlaceHolder:NSLocalizedString(@"City Name", @"City Name") andAge:nil isEditable:true withTextLimit:30];
        tcell.delegate=self;
        return tcell;
        
    }else if (indexPath.row == kEditProfileCellTypeRehabGroup){
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"rehabcell"];
        if (cell == nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"rehabcell"];
            cell.backgroundColor=[UIColor clearColor];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text=NSLocalizedString(@"Rehab Alumni Group", nil);
        cell.textLabel.font = SGREGULARFONT(17.0);
        cell.textLabel.textColor = [UIColor blackColor];
        
        
        // Accessorview
        UIView* viewDisclosure=[[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)-35, 0, 40, 40)];
        viewDisclosure.backgroundColor=[UIColor clearColor];
        viewDisclosure.tag = 5001;
        
        UIImageView *imgDisclosure=[[UIImageView alloc]initWithFrame:CGRectMake(13, 13, 15, 15)];
        imgDisclosure.image=[UIImage imageNamed:@"disclosure_closed.png"];
        
        imgDisclosure.contentMode=UIViewContentModeScaleAspectFill;
        [viewDisclosure addSubview:imgDisclosure];
        [cell.contentView addSubview:viewDisclosure];
        return cell;
        
    }else {
        
        
        ExpandableCell *exCell=[tableView dequeueReusableCellWithIdentifier:@"ExpandableCell"];
        if (exCell == nil) {
            exCell = [[ExpandableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ExpandableCell"];
            [exCell setController:self];
        }
        BOOL expand=false;
        if ([_dictExpandingRowDetail objectForKey:@"index"]) {
            NSIndexPath *index=[_dictExpandingRowDetail objectForKey:@"index"];
            if (index.row == indexPath.row) {
                expand = true;
            }
        }
        
        if (indexPath.row == kEditProfileCellTypeGender) {
            [exCell customizeWithOptions:[Filter sharedInstance].arrOptionsForGender withselectedOptions:(_objUser.strGender != nil)?[@[_objUser.strGender] mutableCopy] : nil forTitle:NSLocalizedString(@"Gender", nil) Expand:expand withMultipleSupport:false withOtherOption:NO];
        }
        if (indexPath.row == kEditProfileCellTypeOrientation) {
            [exCell customizeWithOptions:[Filter sharedInstance].arrOptionsForOrientation withselectedOptions:(_objUser.strOrientation != nil)?[@[_objUser.strOrientation] mutableCopy]:nil forTitle:NSLocalizedString(@"Orientation", nil) Expand:expand withMultipleSupport:false withOtherOption:NO];
        }
        if (indexPath.row == kEditProfileCellTypeRelStatus) {
            [exCell customizeWithOptions:[Filter sharedInstance].arrOptionsForRStatus withselectedOptions:(_objUser.strRelStatus != nil)?[@[_objUser.strRelStatus] mutableCopy]:nil forTitle:NSLocalizedString(@"Relationship status", nil) Expand:expand withMultipleSupport:false withOtherOption:NO];
        }
        if (indexPath.row == kEditProfileCellTypeSeeking) {
            [exCell customizeWithOptions:[Filter sharedInstance].arrOptionsForSeeking withselectedOptions:(_objUser.arrSeekingType != nil)?_objUser.arrSeekingType:nil forTitle:NSLocalizedString(@"Seeking", nil) Expand:expand withMultipleSupport:true withOtherOption:YES];
        }
        if (indexPath.row == kEditProfileCellTypeAGiveRide) {
            
            [exCell customizeWithOptions:[Filter sharedInstance].arrOptionsForAvailableToGiveRid withselectedOptions:(_objUser.strisAvailbeToGiveRide != nil)?[@[_objUser.strisAvailbeToGiveRide] mutableCopy]:nil forTitle:NSLocalizedString(@"Available to give a ride", nil) Expand:expand withMultipleSupport:false withOtherOption:NO];
        }
        // Client dont need it any more
        //    if (indexPath.row == 10) {
        //
        //        [exCell customizeWithOptions:[Filter sharedInstance].arrOptionsForFellowship withselectedOptions:(_objUser.arrfellowShipType != nil)?_objUser.arrfellowShipType:nil forTitle:NSLocalizedString(@"Fellowship type", nil) Expand:expand withMultipleSupport:YES withOtherOption:NO];
        //    }
        if (indexPath.row == kEditProfileCellTypeLMeetUp) {
            
            [exCell customizeWithOptions:[Filter sharedInstance].arrOptionsForLMeetUp withselectedOptions:(_objUser.strLookingToMeetUP != nil)?[@[_objUser.strLookingToMeetUP] mutableCopy]:nil forTitle:NSLocalizedString(@"Looking to meet up", nil) Expand:expand withMultipleSupport:false withOtherOption:NO];
        }
        
        return exCell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kEditProfileCellTypeAbout) {
        return MAX(75, _cellHeight[0]);
        
    }
    if ([_dictExpandingRowDetail objectForKey:@"index"]) {
        NSIndexPath *index=[_dictExpandingRowDetail objectForKey:@"index"];
        if (index.row == indexPath.row) {
            return [[_dictExpandingRowDetail objectForKey:@"height"] floatValue];
        }
    }
    return [self deviceSpesificValue:40];
}
- (void)tableView:(UITableView *)tableView updatedHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath
{
    _cellHeight[0] = height;
}

- (void)tableView:(UITableView *)tableView updatedText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath
{
    _objUser.strAboutMe = text;
}
- (BOOL)tableView:(UITableView *)tableView textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length == 0 && [text isEqualToString:@"\n"]) {
        return false;
    }
    if (textView.text.length == 0 && [text isEqualToString:@" "]) {
        return false;
    }
    const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");
    
    if (isBackSpace == -8) {
        // is backspace
        return true;
    }
    if (textView.text.length > LIMIT_CHARACTER) {
        return false;
    }
    return true;
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[ExpandableCell class]]) {
        ExpandableCell *exCell=(ExpandableCell*)cell;
        [exCell unload];
    }else if([cell isKindOfClass:[ACEExpandableTextCell class]]){
        ACEExpandableTextCell *exCell=(ACEExpandableTextCell*)cell;
        [exCell unload];
    }else
    {
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kEditProfileCellTypeName) {
    }
    if (indexPath.row == kEditProfileCellTypeSDate || indexPath.row == kEditProfileCellTypeDOB) {
        if (_lastOpenIndexpath) {
            _dictExpandingRowDetail = [[NSMutableDictionary alloc] init];
            [self closeOtherRowforIndexPath:_lastOpenIndexpath];
        }
        [self showHidePickerwithTag:(int)indexPath.row];
    }else
        [self hidePicker];
    
    
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ExpandableCell class]]) {
        // For expanding cell
        ExpandableCell *selectedcell =(ExpandableCell*) [tableView cellForRowAtIndexPath:indexPath];
        CGFloat totalHeight = [selectedcell totalHeight];
        if ([_dictExpandingRowDetail objectForKey:@"index"]) {
            NSIndexPath *index=[_dictExpandingRowDetail objectForKey:@"index"];
            if (index.row == indexPath.row) {
                if (selectedcell.selectedOptions.count > 0) {
                    
                    
                    if (indexPath.row == kEditProfileCellTypeGender) {
                        
                        _objUser.strGender = [selectedcell.selectedOptions objectAtIndex:0];
                    }
                    if (indexPath.row == kEditProfileCellTypeOrientation) {
                        _objUser.strOrientation = [selectedcell.selectedOptions objectAtIndex:0];
                    }
                    if (indexPath.row == kEditProfileCellTypeRelStatus) {
                        _objUser.strRelStatus = [selectedcell.selectedOptions objectAtIndex:0];
                    }
                    if (indexPath.row == kEditProfileCellTypeSeeking) {
                        
                        _objUser.arrSeekingType = selectedcell.selectedOptions ;
                    }
                    if (indexPath.row == kEditProfileCellTypeAGiveRide) {
                        _objUser.strisAvailbeToGiveRide= [selectedcell.selectedOptions objectAtIndex:0];
                    }
                    // client dont need it any more
                    //                    if (indexPath.row == 10) {
                    //                        _objUser.arrfellowShipType =selectedcell.selectedOptions;
                    //
                    //                    }
                    if (indexPath.row == kEditProfileCellTypeLMeetUp) {
                        _objUser.strLookingToMeetUP =[selectedcell.selectedOptions objectAtIndex:0];
                        
                    }
                }
                _dictExpandingRowDetail = [[NSMutableDictionary alloc] init];
                [selectedcell collapse];
                [_tblView beginUpdates];
                [_tblView endUpdates];
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
        [_tblView beginUpdates];
        [_tblView endUpdates];
        _lastOpenIndexpath = indexPath;
        
        
    }
    if (indexPath.row == kEditProfileCellTypeRehabGroup) {
        RehabGroupViewController *rgVC = [[RehabGroupViewController alloc]init];
        [self.navigationController pushViewController:rgVC animated:YES];
        
    }
    
    // For pickers
    
}


- (void)closeOtherRowforIndexPath:(NSIndexPath*)indexPath{
    ExpandableCell *selectedcell =(ExpandableCell*) [_tblView cellForRowAtIndexPath:indexPath];
    
    if (selectedcell.selectedOptions.count>0 && selectedcell.isExpanded) {
        
        
        if (indexPath.row == kEditProfileCellTypeGender) {
            
            _objUser.strGender = [selectedcell.selectedOptions objectAtIndex:0];
        }
        if (indexPath.row == kEditProfileCellTypeOrientation) {
            _objUser.strOrientation = [selectedcell.selectedOptions objectAtIndex:0];
        }
        if (indexPath.row == kEditProfileCellTypeRelStatus) {
            _objUser.strRelStatus = [selectedcell.selectedOptions objectAtIndex:0];
        }
        if (indexPath.row == kEditProfileCellTypeSeeking) {
            
            _objUser.arrSeekingType = selectedcell.selectedOptions;
        }
        if (indexPath.row == kEditProfileCellTypeAGiveRide) {
            _objUser.strisAvailbeToGiveRide= [selectedcell.selectedOptions objectAtIndex:0];
        }
        // Client dont need it any more
        //        if (indexPath.row == 10) {
        //            _objUser.arrfellowShipType =selectedcell.selectedOptions;
        //
        //        }
        if (indexPath.row == kEditProfileCellTypeLMeetUp) {
            _objUser.strLookingToMeetUP =[selectedcell.selectedOptions objectAtIndex:0];
        }
    }
    [selectedcell collapse];
    [_tblView beginUpdates];
    [_tblView endUpdates];
}
-(IBAction)changeSwitch:(UISwitch*)sender{
    NSLog(@"showsoberdate %d",sender.on);
    _objUser.showSoberDate = sender.on;
}
#pragma mark - TextEditor delegate
- (void)editingStartedForCell:(UITableViewCell *)cell{
}
- (void)editingEndedForCell:(UITableViewCell *)cell{
    TextEditerCell *tcell=(TextEditerCell*)cell;
    NSIndexPath *indexPath=[_tblView indexPathForCell:tcell];
    if (indexPath.row == kEditProfileCellTypeName) {
        _objUser.strName = tcell.txtField.text;
    }
    if (indexPath.row == kEditProfileCellTypeCityName) {
        _objUser.strCity = tcell.txtField.text;
    }
    
}
- (void)showHidePickerwithTag:(int)tag{
    
    UITableViewCell *cell=[_tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
    UIView *viewDisclosure=[cell.contentView viewWithTag:5001];
    _viewDatePickerHolder.tag = tag;
    if (tag == 2) {
        _birthdatePicker.maximumDate = [[NSDate date] offsetYear:-18];
        if (_objUser.birthDate) {
            [_birthdatePicker setDate:_objUser.birthDate];
        }else
            [_birthdatePicker setDate:[NSDate date]];
        
    }else{
        _birthdatePicker.maximumDate = [NSDate date];
        if (_objUser.dateSoberity) {
            [_birthdatePicker setDate:_objUser.dateSoberity];
        }
        
    }
    if (_viewDatePickerHolder.hidden) {
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) M_PI_2);
                             viewDisclosure.transform = transform;
                         }
                         completion:nil];
        _viewDatePickerHolder.hidden = false;
    }else{
        
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                             viewDisclosure.transform = transform;
                         }
                         completion:nil];
        _viewDatePickerHolder.hidden = true;
    }
    
    
}
- (void)hidePicker{
    UITableViewCell *cell=[_tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kEditProfileCellTypeDOB inSection:0]];
    UIView *viewDisclosure=[cell.contentView viewWithTag:5001];
    _viewDatePickerHolder.hidden = true;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                         viewDisclosure.transform = transform;
                     }
                     completion:nil];
    
    
}


- (IBAction)datePickerChangedValue:(UIDatePicker *)sender {
    UIView *viewHolder=sender.superview;
    if (viewHolder.tag == 2) {
        UITableViewCell *cell=[_tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kEditProfileCellTypeDOB inSection:0]];
        
        cell.detailTextLabel.text=[sender.date formattedStringwithFormat:@"MMM d yyyy"];
        _objUser.birthDate = sender.date;
    }if (viewHolder.tag == 3) {
        UITableViewCell *cell=[_tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kEditProfileCellTypeSDate inSection:0]];
        
        cell.detailTextLabel.text=[sender.date formattedStringwithFormat:@"MMM d yyyy"];
        _objUser.dateSoberity = sender.date;
    }
    
}
- (IBAction)btnDone_Clicked{
    
    TextEditerCell *cell = (TextEditerCell*)[_tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell.txtField isFirstResponder]) {
        [cell.txtField resignFirstResponder];
        [cell.delegate editingEndedForCell:cell];
    }
    cell = (TextEditerCell*)[_tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    if ([cell.txtField isFirstResponder]) {
        [cell.txtField resignFirstResponder];
        [cell.delegate editingEndedForCell:cell];
    }
    if (_lastOpenIndexpath) {
        [self closeOtherRowforIndexPath:_lastOpenIndexpath];
    }
    
    
    [appDelegate startLoadingview:@"Updating"];
    
    [_objUser updateToServerwithCompletionBlock:^(BOOL status, NSString *strError) {
        [appDelegate stopLoadingview];
        if (status) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}
- (void)dealloc{
    _birthdatePicker = nil;
}
@end
