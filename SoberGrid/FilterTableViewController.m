//
//  FilterTableViewController.m
//  SoberGrid
//
//  Created by Sajid Israr on 8/10/15.
//  Copyright (c) 2015 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "FilterTableViewController.h"
#import "NFFilterCustomCell.h"

@interface FilterTableViewController ()

@end

@implementation FilterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setHidden:FALSE];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title=@"Filter";
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(btnDone_Clicked:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    UIBarButtonItem * leftBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(btnCancel_Clicked:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
}

-(void)viewWillAppear:(BOOL)animated
{

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NFFilterCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCustomCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    switch (indexPath.row) {
        case 0:
            cell.titleLbl.text = @"My Posts";
            cell.statusSwithch.tag = indexPath.row;
            [cell.statusSwithch setOn:[Filter sharedInstance].myPosts];
            [cell.statusSwithch addTarget:self action:@selector(statusSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        case 1:
            cell.titleLbl.text = @"Posts I've commented on";
            cell.statusSwithch.tag = indexPath.row;
            [cell.statusSwithch setOn:[Filter sharedInstance].mySubscribed];
            [cell.statusSwithch addTarget:self action:@selector(statusSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            break;
            
        default:
            break;
    }
    return cell;
}


-(void)btnCancel_Clicked:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)btnDone_Clicked:(UIButton*)sender{
    [self.delegate filterDone_Pressed];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)statusSwitchValueChanged:(id)sender {
    UISwitch *myswitch = sender;
    switch ([sender tag]) {
        case 0:
            [[Filter sharedInstance] setMyPosts:[myswitch isOn]];
            break;
            
        case 1:
            [[Filter sharedInstance] setMySubscribed:[myswitch isOn]];
            break;
            
        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
