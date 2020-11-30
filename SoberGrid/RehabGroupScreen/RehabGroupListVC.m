//
//  RehabGroupListVC.m
//  SoberGrid
//
//  Created by agilepc-159 on 7/15/15.
//  Copyright (c) 2015 William Santiago All rights reserved.
//
static NSString *const kGroupCellIdentifier = @"groupcell";

#import "RehabGroupListVC.h"
#import "SGGroup.h"
#import "SGNewsFeedPageDetailViewController.h"
@interface RehabGroupListVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *arrGroups;
}
@end

@implementation RehabGroupListVC
- (void)formatUI{
    self.title = @"Rehab Alumni Group";
    arrGroups = [SGGroup getAllGroups];
    UITableView *tblView = [[UITableView alloc]initWithFrame:self.view.bounds];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:tblView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self formatUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrGroups.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGroupCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGroupCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    SGGroup *gp = [arrGroups objectAtIndex:indexPath.row];
    cell.textLabel.text = gp.strFullName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SGGroup *gp = [arrGroups objectAtIndex:indexPath.row];
    SGNewsFeedPageDetailViewController *sgfpViewController=[[SGNewsFeedPageDetailViewController alloc]init];
    [sgfpViewController setDetailMode:kDetailModeGroup WithObject:gp];
    [self.navigationController pushViewController:sgfpViewController animated:YES];
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
