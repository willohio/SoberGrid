//
//  PremiumMemberViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/29/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "PremiumMemberViewController.h"
#import "UHLabel.h"
#import "SGRoundButton.h"
#import "SoberGridIAPHelper.h"
@interface PremiumMemberViewController () <UITableViewDataSource,UITableViewDelegate>{
    UITableView  *tblPremiums;
}

@end

@implementation PremiumMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Localytics tagEvent:LLUserInPremiumScreen];
    self.title = @"Supporting Member";
    self.navigationController.navigationBar.titleTextAttributes=@{NSFontAttributeName:SGBOLDFONT(17.0)};
    self.view.backgroundColor = SG_BACKGROUD_COLOR;
    [self createTableView];

    // Do any additional setup after loading the view.
}
- (void)createTableView{
    tblPremiums = [[UITableView alloc]initWithFrame:self.view.bounds];
    // tblBadge.scrollEnabled = false;
    tblPremiums.separatorStyle=UITableViewCellSeparatorStyleNone;
    tblPremiums.dataSource = self;
    tblPremiums.delegate   = self;
    [self.view addSubview:tblPremiums];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4
    ;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"badgeCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"badgeCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
    }

    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:165.0/255.0 blue:98.0/255.0 alpha:1];
    }
    if (indexPath.row == 1) {
        cell.backgroundColor = [UIColor colorWithRed:106.0/255.0 green:187.0/255.0 blue:59.0/255.0 alpha:1];
    }
    if (indexPath.row == 2) {
        cell.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:169.0/255.0 blue:41.0/255.0 alpha:1];
    }
    if (indexPath.row == 3) {
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, 280, cell.textLabel.frame.size.height);
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.attributedText = [self discription];
    }else
        cell.textLabel.attributedText = [self stringForIndexPath:indexPath];
    

    // \u2022 will be used for bullets
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightForIndexpath:indexPath];
}
- (CGFloat)heightForIndexpath:(NSIndexPath*)indexPath{
    if (indexPath.row < 3) {
        return 60;
    }
    if (indexPath.row == 3) {
        CGRect attRect=[[self discription] boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return attRect.size.height+5;
    }
    if (indexPath.row == 2) {
        return (((CGRectGetHeight(self.view.bounds)-64) - (3*60)));
    }
    return 0;
}
- (NSMutableAttributedString*)stringForIndexPath:(NSIndexPath*)indexPath{
    if (indexPath.row >=3) {
        return nil;
    }
    NSString *strMonths;
    NSString *strPrice;
    switch (indexPath.row) {
        case 0:
            strMonths = @"1 month for ";
            strPrice  = @"$3.99";
            break;
        case 1:
            strMonths = @"3 months for ";
            strPrice  = @"$9.99";
            break;
        case 2:
            strMonths = @"12 months for ";
            strPrice  = @"$39.99";
            break;
            
        default:
            break;
    }
    
    NSMutableAttributedString *strTotalString=[[NSMutableAttributedString alloc]init];
    
    NSAttributedString *attString1 = [[NSAttributedString alloc] initWithString:strMonths attributes:@{NSFontAttributeName : SGREGULARFONT(20.0),NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    NSAttributedString *attString2 = [[NSAttributedString alloc] initWithString:strPrice attributes:@{NSFontAttributeName : SGBOLDFONT(25.0),NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [strTotalString appendAttributedString:attString1];
    [strTotalString appendAttributedString:attString2];
    
    return strTotalString;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 3){
        return;
    }
    
    if (![[SoberGridIAPHelper sharedInstance]getTypeOfSubsciption] == kSGSubscriptionTypeNone) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"You are already subscribed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }

    switch (indexPath.row) {
        case 0:
            [[SoberGridIAPHelper sharedInstance] buy1MonthPack];
            break;
        case 1:
            [[SoberGridIAPHelper sharedInstance] buy3MonthPack];
            break;
        case 2:
            [[SoberGridIAPHelper sharedInstance] buy12MonthPack];
            break;
        default:
            break;
    }
    
}

- (NSMutableAttributedString*)discription{
    NSMutableAttributedString *attTotalString=[[NSMutableAttributedString alloc]init];
    
    NSAttributedString *attStr1=[[NSAttributedString alloc]initWithString:NSLocalizedString(@"Exclusive Features for Supporting Member\n", nil) attributes:@{NSFontAttributeName :SGBOLDFONT(17.0) }];
    
    NSArray *arr = @[NSLocalizedString(@"Enhanced Profile - Add up to four additional profile pictures to your profile.", nil),NSLocalizedString(@"Photo Albums - Save and create albums of you and your friends. Have the people around you right at your fingertips.", nil),NSLocalizedString(@"Saved Phrases - Have something you find yourself typing a lot? Save it and have it ready to go!", nil),NSLocalizedString(@"Cascade Swipe - Swipe through various profiles instantaneously, loading more people on your screen, and hopefully into your life.", nil),NSLocalizedString(@"Photo Filtering - Filter profiles exclusively by photo.", nil),NSLocalizedString(@"Visit in Stealth Mode - Hide your presence while looking at other profiles.",nil)];
    NSMutableAttributedString *attFeatures=[[NSMutableAttributedString alloc]init];
    for (NSString *str in arr) {
        
        NSAttributedString *attStr=[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"\n\u2022  %@",str] attributes:@{NSFontAttributeName : SGREGULARFONT(17.0)}];
        [attFeatures appendAttributedString:attStr];
    }
    
    NSAttributedString *attLastStr=[[NSAttributedString alloc]initWithString:NSLocalizedString(@"\n\nEnhance your experience on Sober Grid with our pro features. These exclusive features give you increased functionality as you contribute to a network of sober users around the globe.", nil) attributes:@{NSFontAttributeName : SGREGULARFONT(17.0)}];
    
    [attTotalString appendAttributedString:attStr1];
    [attTotalString appendAttributedString:attFeatures];
    [attTotalString appendAttributedString:attLastStr];
    
    
    return attTotalString;
}
- (void)dealloc{
    tblPremiums = nil;
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
