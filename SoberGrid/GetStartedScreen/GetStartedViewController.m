//
//  GetStartedViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/12/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "GetStartedViewController.h"
#import "LoginViewController.h"
@interface GetStartedViewController ()

@end

@implementation GetStartedViewController

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
    self.navigationController.navigationBarHidden=YES;
    btnGetStarted.layer.cornerRadius = 6.0;
    btnGetStarted.clipsToBounds = YES;
    
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


- (IBAction)getStarted_Clicked:(id)sender {
    
    [self performSegueWithIdentifier:@"getstartedtologin" sender:nil];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"getstartedtologin"])
    {
        // Get reference to the destination view controller
        // Pass any objects to the view controller here, like...
        
    }
}
@end
