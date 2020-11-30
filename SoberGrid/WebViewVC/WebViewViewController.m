//
//  WebViewViewController.m
//  SoberGrid
//
//  Created by Harsh Shah on 6/18/15.
//  Copyright (c) 2015 William Santiago All rights reserved.
//

#import "WebViewViewController.h"

@interface WebViewViewController ()

@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationController.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DoneButton_Clicked:)];
    
    
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:fullURL];
    [webViewForTerms loadRequest:requestObj];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=false;
}

- (void)DoneButton_Clicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
    
}

-(void)loadURLToWebView:(NSURL*)strURL
{
    fullURL = strURL;
    
}

- (void)dealloc{
    [webViewForTerms stopLoading];
    webViewForTerms = nil;
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
