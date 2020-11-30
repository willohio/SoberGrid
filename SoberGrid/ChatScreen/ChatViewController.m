//
//  ChatViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/23/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "ChatViewController.h"
#import "SGXMPP.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

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
    // Do any additional setup after loading the view.
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

- (IBAction)sendMessage_Clicked:(UIButton *)sender {
    [[SGXMPP sharedInstance] sendMessage:_otherUser.struserId Groupname:nil Message:@"test" isPhoto:false photo:nil];
}
@end
