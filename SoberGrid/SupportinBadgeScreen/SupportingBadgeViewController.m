//
//  SupportingBadgeViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/29/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "SupportingBadgeViewController.h"
#import "UHLabel.h"
#import "SGRoundButton.h"
#import "User.h"
#import "SoberGridIAPHelper.h"

NSString *const kSOBERGRIDMessage = @"Support the sober community! Get a self supporting badge on your profile for only $.99.\nBy buying a self supporting badge you are helping to ensure Sober Grid as a self supporting community whose mission is to help clean and sober people around the world connect.";

@interface SupportingBadgeViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tblBadge;

}
@end

@implementation SupportingBadgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Localytics tagEvent:LLUserInSupportingBadgeScreen];
    self.title = @"Supporting Badge";
    self.navigationController.navigationBar.titleTextAttributes=@{NSFontAttributeName:SGBOLDFONT(17.0)};
    self.view.backgroundColor = SG_BACKGROUD_COLOR;
    [self createTableView];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(badgePruchased)
                                                 name:NOTIFICATION_GOLDBADGE_PURCHASED
                                               object:nil];
    //  [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)badgePruchased{
    UITableViewCell *cell=[tblBadge cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    for (UIView *view in [cell.contentView subviews]) {
        if ([view isKindOfClass:[SGRoundButton class]]) {
            SGRoundButton *btn=(SGRoundButton*)view;
            [btn setTitle:@"Purchased" forState:UIControlStateNormal];
        }
    }
}
- (void)createTableView{
    tblBadge = [[UITableView alloc]initWithFrame:self.view.bounds];
   // tblBadge.scrollEnabled = false;
    tblBadge.separatorStyle=UITableViewCellSeparatorStyleNone;
    tblBadge.dataSource = self;
    tblBadge.delegate   = self;
    [self.view addSubview:tblBadge];
}
#pragma mark - tableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"badgeCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"badgeCell"];
        cell.backgroundColor = SG_BACKGROUD_COLOR;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0) {
        UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(50, 50, CGRectGetWidth(tableView.bounds) - 100, [self heightForIndexpath:indexPath]-100)];
      //  imgView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        imgView.backgroundColor = [UIColor clearColor];
        imgView.contentMode=UIViewContentModeScaleAspectFit;
        imgView.image = [UIImage imageNamed:imageNameRefToDevice(@"Badge")];
        [cell.contentView addSubview:imgView];
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(kSOBERGRIDMessage, nil);
        cell.textLabel.font = SGREGULARFONT(13.5);
        cell.textLabel.numberOfLines = 0;
        
        CGRect textRect=[NSLocalizedString(kSOBERGRIDMessage, nil) boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : SGREGULARFONT(13.5)} context:nil];
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, textRect.size.width, textRect.size.height);
    }
    if (indexPath.row == 2) {
        SGRoundButton *btnRound = [[SGRoundButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds) - 100, 45)];
        [btnRound setBorderColor:[UIColor clearColor]];
        [btnRound setTitle:([User currentUser].isBadgePurchased)?@"Purchased":@"$.99" forState:UIControlStateNormal];
        [btnRound setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnRound.titleLabel.font = SGBOLDFONT(17.0);
        btnRound.backgroundColor = [UIColor colorWithRed:0/255.0 green:202.0/255.0 blue:152.0/255.0 alpha:1];
        [cell.contentView addSubview:btnRound];
        btnRound.center = CGPointMake(CGRectGetWidth(tableView.frame)/2, [self heightForIndexpath:indexPath]/2 );
        [btnRound addTarget:self action:@selector(buyBadge) forControlEvents:UIControlEventTouchUpInside];

    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        return [self heightForIndexpath:indexPath];
}
- (CGFloat)heightForIndexpath:(NSIndexPath*)indexPath{
    if (indexPath.row == 0) {
        return (((CGRectGetHeight(self.view.bounds)-64)*63.5)/100);
    }
    if (indexPath.row == 1) {
        CGRect textRect=[NSLocalizedString(kSOBERGRIDMessage, nil) boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : SGREGULARFONT(13.5)} context:nil];
        return textRect.size.height + 10;
    }
    if (indexPath.row == 2) {
//         CGRect textRect=[NSLocalizedString(kSOBERGRIDMessage, nil) boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : SGREGULARFONT(13.5)} context:nil];
//        CGFloat upperRowHeight=textRect.size.height + 10;
        
         return 55;
    }
    return 0;
}
- (void)buyBadge{
    if ([User currentUser].isBadgePurchased) {
        return;
    }
    [[SoberGridIAPHelper sharedInstance] buyBadge];
}
- (void)dealloc{
    tblBadge = nil;
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
