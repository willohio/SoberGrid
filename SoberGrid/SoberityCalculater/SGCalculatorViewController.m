//
//  SGCalculatorViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 11/5/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "SGCalculatorViewController.h"
#import "User.h"
#import "NSDate+Utilities.h"

@interface SGCalculatorViewController () <UITableViewDataSource,UITableViewDelegate,CommonApiCallDelegate,UITextFieldDelegate>
{
    UITableView *tblView;
    UIButton *btnDone;
    BOOL inEditMode;
    UIDatePicker* picker;
}
@end

@implementation SGCalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Localytics tagEvent:LLUserInSGCalculator];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Sobriety Calculator";
    [self createTable];
    
    picker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    picker.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - picker.frame.size.height,picker.frame.size.width , picker.frame.size.height);
    picker.center = CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2,picker.center.y);
    picker.datePickerMode = UIDatePickerModeDate;
    [picker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:picker];
    picker.hidden = true;
    picker.maximumDate = [NSDate date];
    
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnDone setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [btnDone setImage:[UIImage imageNamed:@"done_logo"] forState:UIControlStateSelected];
    
    [btnDone addTarget:self action:@selector(addSoberityDate:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc]initWithCustomView:btnDone];
    self.navigationItem.rightBarButtonItem  = barButton;
    
    
    // Do any additional setup after loading the view.
}

- (void)createTable{
    tblView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tblView.scrollEnabled = false;
    tblView.dataSource = self;
    tblView.delegate   = self;
    [self.view addSubview:tblView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"stCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    if(indexPath.row == 0){
        cell.contentView.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:45.0/255.0 blue:46.0/255.0 alpha:1];
        
        NSString *strDate=[[User currentUser].dateSoberity formattedStringwithFormat:@"MMM d yyyy"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@\n%@",NSLocalizedString(@"Your sobriety date is:", nil),(strDate.length > 0)?strDate : @"",NSLocalizedString(@"I have been Sober for", nil)];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = SGBOLDFONT(17.0);
        cell.textLabel.numberOfLines = 0.0;
    }
    
    else {
        NSMutableDictionary *dictDates=[[User currentUser].dateSoberity monthsandDays];
        int years = (dictDates[@"year"]) ? [dictDates[@"year"] intValue] :0;
        UILabel *lblYears;
        if (years > 0) {
            lblYears = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds)/3, 100)];
            lblYears.text = [NSString stringWithFormat:@"%@\nYears",(dictDates[@"year"]) ? dictDates[@"year"]  : @"0"];
            lblYears.backgroundColor =[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:10.0/255.0 alpha:1];
            //lblYears.backgroundColor = [UIColor lightGrayColor];
            lblYears.font = SGBOLDFONT(17.0);
            lblYears.textColor = [UIColor whiteColor];
            lblYears.numberOfLines = 0.0;
            lblYears.textAlignment = NSTextAlignmentCenter;
//            lblYears.layer.borderColor = [UIColor blackColor].CGColor;
//            lblYears.layer.borderWidth = 0.5;
            [cell.contentView addSubview:lblYears];
        }
        
        int months= (dictDates[@"month"]) ? [dictDates[@"month"] intValue] : 0;
        UILabel *lblMonths;
        if (months > 0 || lblYears) {
            lblMonths = [[UILabel alloc]initWithFrame:CGRectMake(lblYears.frame.origin.x + lblYears.frame.size.width, 0, (lblYears)?lblYears.frame.size.width :CGRectGetWidth([UIScreen mainScreen].bounds)/2, 100 )];
            lblMonths.text = [NSString stringWithFormat:@"%@\nMonths",(dictDates[@"month"]) ? dictDates[@"month"]  : @"0"];
            lblMonths.backgroundColor =[UIColor colorWithRed:255.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1];
           // lblMonths.backgroundColor = [UIColor lightGrayColor];
            lblMonths.font = SGBOLDFONT(17.0);
            lblMonths.textColor = [UIColor whiteColor];
            lblMonths.numberOfLines = 0.0;
            lblMonths.textAlignment = NSTextAlignmentCenter;
//            lblMonths.layer.borderColor = [UIColor blackColor].CGColor;
//            lblMonths.layer.borderWidth = 0.5;
            [cell.contentView addSubview:lblMonths];
        }
        
        UILabel *lblDays = [[UILabel alloc]initWithFrame:CGRectMake(lblMonths.frame.origin.x + lblMonths.frame.size.width, 0, (lblMonths)?lblMonths.frame.size.width :CGRectGetWidth([UIScreen mainScreen].bounds) , 100)];
        lblDays.text = [NSString stringWithFormat:@"%@\nDays",(dictDates[@"day"]) ? dictDates[@"day"]  : @"0"];
        lblDays.backgroundColor =[UIColor colorWithRed:255.0/255.0 green:69.0/255.0 blue:77.0/255.0 alpha:1];
       // lblDays.backgroundColor = [UIColor lightGrayColor];
        lblDays.font = SGBOLDFONT(17.0);
        lblDays.textColor = [UIColor whiteColor];
        lblDays.numberOfLines = 0.0;
        lblDays.textAlignment = NSTextAlignmentCenter;
//        lblDays.layer.borderColor = [UIColor blackColor].CGColor;
//        lblDays.layer.borderWidth = 0.5;
        [cell.contentView addSubview:lblDays];
        cell.contentView.backgroundColor = [UIColor redColor];
    }
        return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 102;
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
}
- (void)addSoberityDate:(UIButton*)sender{
    sender.selected = !sender.selected;
    picker.hidden = !sender.selected;

    if (!sender.selected) {
        [self updateSoberityDate];
    }else{
        if ([User currentUser].dateSoberity) {
            [picker setDate:[User currentUser].dateSoberity];
        }
    }
    
    [tblView reloadData];

   
}
- (void)updateSoberityDate{
    NSMutableDictionary *dictUser = [[NSMutableDictionary alloc]init];
    [dictUser setObject:[User currentUser].struserId forKey:@"userid"];
    if ([User currentUser].dateSoberity) {
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        [inputFormatter setDateFormat:@"dd-MM-yyyy"];
        [dictUser setObject:[inputFormatter stringFromDate:[User currentUser].dateSoberity] forKey:@"sobriety_date"];
    }
    
    NSString *strUser=[dictUser JSONRepresentation];
    dictUser = nil;
    
    CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@edituser",baseUrl()] andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"key": strUser} options:NSJSONWritingPrettyPrinted error:nil]];
    [tblView reloadData];
}
- (void) datePickerValueChanged:(UIDatePicker*)datePicker
{
    [[User currentUser] updateSoberityDate:datePicker.date];
    
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
