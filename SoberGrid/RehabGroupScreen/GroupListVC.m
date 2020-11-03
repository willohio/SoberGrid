//
//  GroupListVC.m
//  SoberGrid
//
//  Created by agilepc-159 on 7/4/15.
//  Copyright (c) 2015 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "GroupListVC.h"
#import "SGGroup.h"

@interface GroupListVC () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tblView;
    NSArray *arrGroups;
}
@end

@implementation GroupListVC
- (void)formatUI{
    self.view.backgroundColor = [UIColor clearColor];
    
    tblView = [[UITableView alloc]initWithFrame:self.view.bounds];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    tblView.scrollEnabled = NO;
    tblView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tblView];
    
    self.view.autoresizesSubviews = YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self formatUI];
    // Do any additional setup after loading the view.
}
- (void)setGroups:(NSArray*)groups{
    arrGroups = groups;
    if (tblView) {
        [tblView reloadData];

    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView Deleagate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (arrGroups.count > groupLimit) ? (groupLimit + 1) : arrGroups.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupcell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupcell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    if (indexPath.row == groupLimit) {
        cell.textLabel.text = [NSString stringWithFormat:@"%u more",(arrGroups.count - groupLimit)];
    }else{
        SGGroup *gp = [arrGroups objectAtIndex:indexPath.row];
        cell.textLabel.text = gp.strFullName;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = SGBOLDFONT(17);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == groupLimit) {
        if ([_delegate respondsToSelector:@selector(groupListDidSelectedOptionMore)]) {
            [_delegate groupListDidSelectedOptionMore];
        }
    }
    else {
        if([_delegate respondsToSelector:@selector(groupListDidSelectedOptionAtIndex:)]) {
        [_delegate groupListDidSelectedOptionAtIndex:indexPath.row];
    }
    }
    NSLog(@"Selected row");
}
- (void)dealloc{
    NSLog(@"dealloc called");
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
