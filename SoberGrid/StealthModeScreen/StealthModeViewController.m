//
//  StealthModeViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 11/5/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

static NSString *const kSGStealthMessage=@"By turning On: will not allow others to be informed you have visited their profile. Be a supportive  member of Sober Grid, so you can use stealth mode feature.";

#import "StealthModeViewController.h"
#import "User.h"
#import "SoberGridIAPHelper.h"

@interface StealthModeViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tblView;
}
@end

@implementation StealthModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Localytics tagEvent:LLUserInStealthModeScreen];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTable];
    self.title = @"Stealth Mode";
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)createTable{
    tblView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tblView.scrollEnabled = false;
    tblView.dataSource = self;
    tblView.delegate   = self;
    [self.view addSubview:tblView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"stCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Turn On Stealth Mode?", nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.font = SGBOLDFONT(17.0);
        
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"Stealth Mode";
        cell.textLabel.font = SGREGULARFONT(17.0);

        UISwitch *switchView;
        if (indexPath.row == 0  || indexPath.row == 1) {
            switchView = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 5, 50, 30)];
            
            
            [switchView setOn:[User currentUser].isStealthModeEnable];
            [switchView addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            
            switchView.tag=indexPath.row;
            [cell.contentView addSubview:switchView];
        }

    }
    if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(kSGStealthMessage, nil);
        cell.textLabel.numberOfLines = 0.0;
        cell.textLabel.font = SGREGULARFONT(17.0);
        CGRect textRect=[NSLocalizedString(kSGStealthMessage, nil) boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : SGREGULARFONT(17.0)} context:nil];
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, textRect.size.width, textRect.size.height);

    }
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        CGRect textRect=[NSLocalizedString(kSGStealthMessage, nil) boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : SGREGULARFONT(17.0)} context:nil];
        return textRect.size.height + 10;
    }
    else
        return 40;
}

- (IBAction)changeSwitch:(UISwitch*)sender{
       if ([SoberGridIAPHelper sharedInstance].getTypeOfSubsciption != kSGSubscriptionTypeNone) {
           [[User currentUser] setStealthMode:[sender isOn]];
           return;
       }
    [[SoberGridIAPHelper sharedInstance] showAlertForActivatePack];
    [sender setOn:false];
}
- (IBAction)showAlert:(id)sender{
    
}
- (void)dealloc{
    tblView = nil;
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
